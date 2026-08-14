import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../ansi/c0.dart';
import '../../ansi/c1.dart';
import '../../ansi/sgr.dart';
import '../../extensions/remove.dart';
import '../../extensions/show_control_codes.dart';
import '../../extensions/show_escape_codes.dart';
import '../../internal/sgr_rules.dart';
import '../../internal/strings.dart';
import '../../ready_to_use/csi.dart';
import '../../ready_to_use/esc.dart';
import '../../ready_to_use/osc.dart';
import '../../ready_to_use/sgr/sgr.dart';
import '../colors/color.dart';
import '../control_functions/control_functions_c0.dart';
import '../control_functions/control_functions_c1.dart';
import '../control_functions/control_functions_esc_fs.dart';
import '../control_functions/control_sequences.dart';
import '../control_functions/sgr.dart';
import '../patterns/patterns.dart';
import '../state/state.dart';
import 'unfinished_sequence_exception.dart';

part 'printer.dart';
part 'entities/control_string.dart';
part 'entities/csi.dart';
part 'entities/entity.dart';
part 'entities/esc.dart';
part 'entities/matching_state.dart';
part 'entities/osc.dart';
part 'entities/sgr.dart';
part 'pieces/parser_iterator.dart';
part 'pieces/piece.dart';
part 'pieces/pieces.dart';
part 'pieces/pieces_result.dart';

/// A parser that processes strings containing ANSI escape codes and tracks the
/// current [Style].
///
/// [Parser] allows you to perform various operations on strings with ANSI
/// sequences, such as:
/// * Stripping out the escape codes using [removeAll].
/// * Optimizing the string to remove redundant codes using [optimize].
/// * Extracting a substring while preserving the active style using
///   [substring].
/// * Inserting text that takes the style of the place it lands in and leaves
///   the rest of the string as it was using [insertBefore] and [insertAfter].
/// * Retrieving the computed [Style] at a specific text position using
///   [stateAt] and [finalState].
/// * Retrieving the hyperlink in force at a text position using [linkAt] and
///   [finalLink].
/// * Analyzing a string using [pieces].
///
/// [Parser] allows you to work with a string containing ANSI escape codes as
/// with a regular string without ANSI escape codes:
/// * [length] - string length without ANSI escape codes.
/// * [indexOf] - index of the first occurrence of a pattern in the string
///   without ANSI escape codes.
/// * [lastIndexOf] - index of the last occurrence of a pattern in the string
///   without ANSI escape codes.
/// * [contains] - whether the string contains a pattern in the string without
///   ANSI escape codes.
/// * [startsWith] - whether the string starts with a pattern in the string
///   without ANSI escape codes.
/// * [endsWith] - whether the string ends with a pattern in the string without
///   ANSI escape codes.
///
/// On a large input, prefer walking `pieces` with a `for` and taking what
/// the loop needs as it goes: the walk parses lazily, and what it has read
/// it keeps. `prepare`, `length` and the string methods read the whole
/// string and keep every piece, which on megabytes of input is megabytes
/// of parse tree.
///
/// Keeping a [Text] from that walk after the loop is not free either, and
/// reading its [Text.string] does not make it so: see [Text.string] for
/// what a kept piece holds onto for as long as it is kept.
final class Parser extends _ParserBase<Style> {
  /// Creates a [Parser] for the given [input] string.
  Parser(String input) : super(input, Style.terminalColors);

  /// A [Parser] over a string that begins inside [initialLink].
  ///
  /// The seeding is internal — a string read on its own begins outside every
  /// link, and only a reader taking a document apart line by line has a link
  /// to hand on — but it has to be reachable to be pinned, and from outside
  /// the package nothing else reaches it.
  @visibleForTesting
  Parser.debugInsideLink(String input, Link initialLink)
      : super(input, Style.terminalColors, initialLink: initialLink);
}

/// A parser that processes strings containing ANSI escape codes and tracks
/// the [Stack] of styles.
///
/// Similar to [Parser], but instead of maintaining only the currently active
/// [Style], [StackedParser] tracks the full history of applied styles using a
/// [Stack]. This is useful for complex formatting where styles might be
/// applied and reverted hierarchically.
final class StackedParser extends _ParserBase<Stack> {
  /// Creates a [StackedParser] for the given [input] string.
  StackedParser(String input) : super(input, Stack.terminalColors);
}

final class _ParserBase<S extends State<S>> {
  /// The string being read, escape codes and all.
  final String input;

  /// The state the string is read as starting in.
  ///
  /// The terminal's own colours for a [Parser] and a [StackedParser]; a
  /// [Printer] reads each line from where the last one ended.
  final S initialState;

  /// The link the string is read as starting inside, where there is one.
  ///
  /// The mirror of [initialState] on the link channel: a [Printer] reads each
  /// line from the link the line before it left open, so that a link cut by a
  /// newline goes on being one link. A [Parser] over a whole string starts
  /// outside every link.
  final Link? initialLink;

  Pieces<S>? _pieces;
  String? _plainString;

  /// Where the last positional question stopped, so that the next can carry
  /// on from there rather than walk the string from the beginning.
  ///
  /// Asking about position after position — laying text out, measuring it,
  /// cutting it into lines — would otherwise walk the string from the
  /// beginning every time, and cost the questions times the length of it.
  _Walk<S>? _walk;

  _ParserBase(this.input, this.initialState, {this.initialLink});

  String get _requirePlainString => _plainString ??= () {
        final buf = StringBuffer();
        for (final m in pieces) {
          final entity = m.entity;
          if (entity is Text) {
            buf.write(entity.string);
          }
        }

        return buf.toString();
      }();

  /// Whether the whole string has been read, rather than as much of it as the
  /// questions asked so far needed. See [prepare].
  @visibleForTesting
  bool get isParsed => _pieces?.isParsed ?? false;

  /// The [Pieces] of the string.
  Pieces<S> get pieces =>
      _pieces ??= Pieces._(input, initialState, initialLink: initialLink);

  /// The final [S] after processing the entire string.
  ///
  /// See also [stateAt].
  S get finalState => pieces._requireParsingResult.finalState;

  /// The hyperlink the string leaves open, or `null` where it leaves none.
  ///
  /// The mirror of [finalState] on the link channel. A string that closed the
  /// link it opened — or the link it was seeded with — leaves none open; a
  /// string that touched no link at all leaves the seed as it was.
  ///
  /// Reads the whole string, as [finalState] does.
  ///
  /// See also [linkAt].
  Link? get finalLink => pieces._requireParsingResult.finalLink;

  /// String length without ANSI escape codes, in UTF-16 code units.
  ///
  /// The count is [String.length] minus the codes — `𝄞` is two, and a
  /// grapheme a terminal draws as one glyph may be several. Graphemes are
  /// not counted.
  int get length => _requirePlainString.length;

  /// Whether the string ends in the state it began in.
  ///
  /// A question about the style alone: a string that leaves a hyperlink open
  /// answers `true` all the same, and [finalLink] is the one to ask beside it.
  bool get isClosed => finalState == initialState;

  /// Reads the whole string, ahead of the questions asked of it.
  ///
  /// [stateAt], [linkAt] and [substring] read only as far as they must, and
  /// what they read is kept, so nothing is parsed twice. This reads it all in
  /// one go instead of letting it grow question by question, and builds the
  /// plain text [length], [indexOf] and the other string methods work on.
  ///
  /// It is for [length], [indexOf] and the other string methods, which need
  /// the whole of the text before they can answer anything. [stateAt],
  /// [linkAt] and [substring] do not gain by it — they keep their place as it
  /// is — and lose by it where the questions are not going to reach the end of
  /// the string.
  /// `benchmark/parser_benchmark.dart` measures both.
  void prepare() {
    pieces._requireParsingResult;
    _requirePlainString;
  }

  /// Index of the first occurrence of a pattern in the string without ANSI
  /// escape codes.
  int indexOf(Pattern pattern) => _requirePlainString.indexOf(pattern);

  /// Index of the last occurrence of a pattern in the string without ANSI
  /// escape codes.
  int lastIndexOf(Pattern pattern) => _requirePlainString.lastIndexOf(pattern);

  /// Whether the string contains a pattern in the string without ANSI escape
  /// codes.
  bool contains(Pattern other, [int startIndex = 0]) =>
      _requirePlainString.contains(other, startIndex);

  /// Whether the string starts with a pattern in the string without ANSI
  /// escape codes.
  bool startsWith(Pattern pattern, [int index = 0]) =>
      _requirePlainString.startsWith(pattern, index);

  /// Whether the string ends with a pattern in the string without ANSI
  /// escape codes.
  bool endsWith(String other) => _requirePlainString.endsWith(other);

  /// Returns the [S] of the string at the given plain text [pos].
  ///
  /// [pos] is the position in the string without ANSI escape codes.
  ///
  /// Reads the string up to [pos] and stops, and keeps its place: a question
  /// about a position at or after the last one carries on from there rather
  /// than walking the string again. Asking about position after position — as
  /// laying text out does — costs one walk in all, not one each.
  ///
  /// Going back is allowed and starts the walk over.
  ///
  /// See also [finalState].
  S stateAt(int pos) => _pieceAt(pos)?.state ?? finalState;

  /// The hyperlink open at the plain text [pos], or `null` where none is.
  ///
  /// [pos] is the position in the string without ANSI escape codes.
  ///
  /// The answer is the link the character at [pos] sits inside, not the one
  /// the string moves on to: a link opened just in front of that character is
  /// in force at it, and a close written just behind it is not. The position
  /// stays with its character until the character is passed.
  ///
  /// Reads the string up to [pos] and stops, and keeps its place the way
  /// [stateAt] does — the same walk serves both, so asking each of them about
  /// a run of positions costs one pass in all, not one a question.
  ///
  /// Going back is allowed and starts the walk over.
  ///
  /// See also [finalLink].
  Link? linkAt(int pos) {
    final piece = _pieceAt(pos);

    // Told apart by the piece, not by the link, the way the iterator's
    // `currentLink` is: past the end of the text the answer is what the
    // string left open, and a piece that stands in no link answers `null` of
    // its own.
    return piece == null ? finalLink : piece.link;
  }

  /// The piece of text the plain text [pos] falls in, or `null` where [pos] is
  /// the position just behind the text and belongs to no piece.
  ///
  /// The one walk [stateAt] and [linkAt] both read their answers off, so that
  /// a run of questions — of either kind, or the two interleaved — costs one
  /// pass over the string in all.
  ///
  /// A position belongs to its piece until the piece is passed: strictly
  /// `pos < passed`, so that an escape code written between two characters is
  /// in force at the second and not at the first.
  ///
  /// Throws a [RangeError] for a negative [pos] and for one past the end of
  /// the text.
  Piece<S>? _pieceAt(int pos) {
    RangeError.checkNotNegative(pos, 'pos');

    // The piece the last question was answered from may hold this one too.
    var walk = _walk;
    if (walk?.current case final piece?
        when pos >= walk!.pieceStart && pos < walk.passed) {
      return piece;
    }

    // Anything else already passed means going back, and the walk starts
    // over.
    if (walk == null || pos < walk.passed) {
      walk = _walk = _Walk(pieces.iterator);
    }

    while (walk.nextPiece()) {
      if (pos < walk.passed) {
        return walk.current;
      }
    }

    RangeError.checkValidIndex(pos, null, 'pos', walk.passed + 1);

    return null;
  }

  /// Replaces all [EscapeCode]s in the string with the result of the [replace]
  /// function.
  ///
  /// [replacePlainText] is an optional function that replaces [Text] entities.
  /// If not provided, [Text] entities are not changed.
  String replaceAll(
    String Function(EscapeCode code) replace, {
    String Function(Text entity)? replacePlainText,
  }) {
    final buf = StringBuffer();

    for (final m in pieces) {
      final entity = m.entity;

      final result = switch (entity) {
        EscapeCode() => replace(entity),
        Text() => replacePlainText?.call(entity) ?? entity.string,
      };

      buf.write(result);
    }

    return buf.toString();
  }

  /// Returns the string without ANSI escape codes.
  String removeAll() => _requirePlainString;

  /// Returns a string in which all [EscapeCode] are replaced with their
  /// identifiers.
  ///
  /// ```dart
  /// const text = 'Hello ${fgRed}world$reset';
  /// final parser = Parser(text);
  /// print(parser.showControlFunctions());
  /// // Hello [fgRed]world[reset]
  /// ```
  ///
  /// [open] is the string to prepend to each [EscapeCode].
  /// [close] is the string to append to each [EscapeCode].
  String showControlFunctions({
    String open = '[',
    String close = ']',
  }) =>
      replaceAll((e) => '$open${e.id}$close');

  /// Returns a substring of the given [start] position while preserving the
  /// text style.
  ///
  /// [maxLength] is the maximum length of the substring.
  ///
  /// [close] is whether to close the substring with the default style, and
  /// with it the hyperlink the slice has open and the terminator a control
  /// string it ends inside still owes.
  ///
  /// A slice is self-contained: one that began inside a link opens that link
  /// again in front of its first piece of text, so that the text stays
  /// clickable wherever the cut fell, and closes it at the end the way an
  /// insertion does — what is printed after the slice must not stay
  /// clickable on the slice's URL. With `close: false` the link is left
  /// open, as the style is left open. Cutting a string into lines this way
  /// gives lines that are each clickable on their own.
  ///
  /// The opening is written again in the bytes it came in, parameters and
  /// all: a link opened `BEL`-terminated, the way [linkBel] opens one, is
  /// opened `BEL`-terminated again, and an `id=` — which is what `OSC 8`
  /// gives for a link a line break cuts in two — travels with it.
  ///
  /// The close written is [linkClose], `OSC 8;; ST`, whatever form the
  /// opening took, so a slice of a `BEL`-opened link comes out carrying both
  /// terminators. Terminals take either.
  ///
  /// A link code that would change nothing in what the slice has open is not
  /// written at all: a close where the slice has nothing open, an opening of
  /// the link it has open already, and either of them where no text follows
  /// for them to be shown around. With `close: true` that holds to the end,
  /// and an empty slice comes out empty. With `close: false` the codes held
  /// back are written after all, so that the slice ends inside the link the
  /// string stands in there: an empty slice cut at the very place a link code
  /// stands comes out carrying that code, and one cut anywhere else is empty
  /// as before.
  ///
  /// A control string the string never terminated — an `OSC`, a `DCS`, an
  /// `SOS`, a `PM` or an `APC`, a window title as readily as a link opening —
  /// is held back until what follows it in the slice is known. The sequence
  /// runs to the next `ESC` or to the end of the text, and in the string one of
  /// those two always followed it; written in front of text that did not follow
  /// it there, it would read that text as its own. Where text follows in the
  /// slice, then, the terminator it lacks is supplied, and where an escape code
  /// follows the bytes go out exactly as they came — that code's `ESC` ends the
  /// sequence as the string's did. With `close: true` the terminator is written
  /// at the end of the slice as well, though nothing follows it there, for the
  /// reason the link is closed there: what is printed after the slice must not
  /// be read as more of the sequence. With `close: false` the bytes are left as
  /// they came, as the link is left open.
  ///
  /// A slice holding an `ESC 8` is where a link can still come out other than
  /// it was, and this is accepted rather than mended: the restore gives back
  /// what was saved inside the slice, and a save the cut left outside is not
  /// there to be given. The state has the same hole and always had — the
  /// codes are copied as they stand, and neither a save nor a restore is
  /// rewritten. The link is the more easily lost of the two: an opening is
  /// held back until there is text to show inside it, so an `ESC 7` standing
  /// in front of that text saves no link where the string saved one.
  ///
  /// Reads the string up to the end of the piece and stops, and keeps its
  /// place the way [stateAt] does: a slice beginning past the start of the
  /// piece the last question stopped in carries on from there rather than
  /// walking the string again. Cutting a document into lines costs one walk
  /// in all, not one a line.
  ///
  /// A slice beginning exactly where a piece begins walks afresh: the escape
  /// codes standing in front of that piece belong to the slice, and the walk
  /// is already past them. Going back walks afresh as well.
  ///
  /// See [prepare] for reading the whole string at once instead.
  ///
  /// [start] and [maxLength] count UTF-16 code units, as [length] does. A
  /// cut can land inside a surrogate pair and split it, as [String.substring]
  /// can.
  String substring(
    int start, {
    int? maxLength,
    bool close = true,
  }) {
    if (start < 0) {
      throw RangeError.range(start, 0, null, 'start');
    }

    final end = maxLength == null ? null : start + maxLength;
    if (end != null && start > end) {
      throw RangeError.range(end, start, null, 'end');
    }

    final buf = StringBuffer();
    var currentState = initialState.toStyle();
    Piece<S>? lastPiece;

    // The link the slice has open in what it has written; the link it would
    // have open once the codes read since the last piece are written; and
    // those codes themselves.
    //
    // A link code is held back until there is a piece to write it in front
    // of, because until then it changes nothing in what the slice shows: an
    // opening with nothing inside it, and a close for an opening the slice
    // never wrote, are never written at all.
    // Taking them — reading the codes out, clearing them, and bringing
    // `writtenLink` up to `heldLink` — is written out where it happens rather
    // than put in a local function. A function over these three would close
    // over them, and closing over a variable that is written to boxes it: one
    // heap cell per slice, links in the string or none.
    Link? writtenLink;
    Link? heldLink;
    var heldLinkCodes = '';

    // A control string of the slice's own that never terminated — a `DCS` no
    // less than an `OSC` — held back until what comes after it is known, the
    // same waiting the link codes above do, and sometimes beside them.
    //
    // Where the two wait together, this one came first: only the branch that
    // drains both of them fills this one, and the branch that fills the link
    // codes fills nothing else. So every place that writes them out writes
    // this one ahead of the link codes, and what follows an opening is the
    // held link codes wherever there are any.
    var heldOpening = '';

    var walk = _walk;
    int pos;
    Piece<S>? piece;
    if (walk != null && !walk.isSpent && walk.resumesAt(start)) {
      // The walk already stands in a piece the slice begins in or after:
      // pick that piece up and read on, one pass for a run of slices.
      pos = walk.pieceStart;
      piece = walk.current;
      lastPiece = walk.lastCode;
    } else {
      walk = _walk = _Walk(pieces.iterator);
      pos = 0;
    }

    while (true) {
      final Piece<S> m;
      if (piece != null) {
        m = piece;
        piece = null;
      } else if (walk.iterator.moveNext()) {
        m = walk.iterator.current;
      } else {
        walk.isSpent = true;
        break;
      }

      final entity = m.entity;

      if (entity is Text) {
        walk.takePiece(m, pos);
      } else {
        walk.takeCode(m);
      }

      switch (entity) {
        case Text():
          final string = entity.string;
          pos += string.length;
          if (pos >= start) {
            final substring = string.substring(
              math.max(string.length - (pos - start), 0),
              end == null
                  ? string.length
                  : math.min(string.length - (pos - end), string.length),
            );
            if (substring.isNotEmpty) {
              final held = heldLinkCodes;
              heldLinkCodes = '';
              writtenLink = heldLink;

              final opening = heldOpening;
              heldOpening = '';

              // A slice that began inside a link opens it again itself, in
              // the bytes it was opened with: the text is shown inside that
              // link, and nothing the slice has read opened it. An opening
              // the input never terminated is terminated here, or it would
              // swallow the text of the slice — see [Link._reopening].
              final link = m.link;
              var reopening = '';
              if (writtenLink == null && link != null) {
                reopening = link._reopening;
                writtenLink = heldLink = link;
              }

              final transit = currentState.transitTo(m.state);

              // The link codes read after the opening are written straight
              // behind it, so they are the first of what follows it — and
              // where there are none, what follows the piece does.
              if (opening.isNotEmpty) {
                buf.write(
                  _terminatedOpening(
                    opening,
                    _firstNotEmpty(held, reopening, transit, substring),
                    closing: false,
                  ),
                );
              }

              // The codes held back are the input's own, ending as they ended
              // there — and what ended an unterminated opening there was the
              // `ESC` behind it, which the slice need not be writing here.
              // See [_terminatedIfTextFollows].
              if (held.isNotEmpty) {
                buf.write(
                  _terminatedIfTextFollows(
                    held,
                    _firstNotEmpty(reopening, transit, substring),
                  ),
                );
              }

              // Written only where there is something to write: a slice
              // reopens at most once, and every other piece of text would be
              // paying a call to put nothing in the buffer.
              if (reopening.isNotEmpty) {
                buf.write(reopening);
              }

              buf
                ..write(transit)
                ..write(substring);
              currentState = m.state.toStyle();
              lastPiece = m;
            }
          }

        case EscapeCode():
          if (entity is! Sgr && pos >= start && (end == null || pos <= end)) {
            if (entity is Link) {
              // Held, and only where it changes what the slice has open: the
              // link the code leaves behind is what the slice is to be left
              // with, and a code saying what is said already — a close with
              // nothing open, an opening of what that same sequence opened —
              // is nothing to write.
              if (m.link != heldLink) {
                heldLinkCodes += entity.string;
                heldLink = m.link;
              }
            } else {
              final held = heldLinkCodes;
              heldLinkCodes = '';
              writtenLink = heldLink;

              final transit = currentState.transitTo(m.state);

              // Ahead of the held link codes, which is where they were read
              // and so what follows the opening where there are any. Nothing
              // is ever supplied here — every candidate begins with an `ESC`,
              // as the code being written does — but the opening goes out
              // through the same door as everywhere else, so that the
              // guarantee is checked and not assumed.
              final opening = heldOpening;
              heldOpening = '';
              if (opening.isNotEmpty) {
                buf.write(
                  _terminatedOpening(
                    opening,
                    _firstNotEmpty(held, transit, entity.string),
                    closing: false,
                  ),
                );
              }

              // Nothing is ever added here — an escape code begins with an
              // `ESC`, and that is what an unterminated opening needs — but
              // the held codes go out through the same door as everywhere
              // else, so that the guarantee is checked and not assumed.
              if (held.isNotEmpty) {
                buf.write(
                  _terminatedIfTextFollows(
                    held,
                    _firstNotEmpty(transit, entity.string),
                  ),
                );
              }

              buf.write(transit);

              // A code the parser could not finish waits to see what it is
              // written in front of; everything else goes out where it
              // stands.
              if (_unfinished(entity)) {
                heldOpening = entity.string;
              } else {
                buf.write(entity.string);
              }
              currentState = m.state.toStyle();

              // `ESC 8` carries the link the way it carries the rendition, so
              // a restore written out changes what the slice has open, and
              // the account of it is brought up to date beside the state's.
              // Left stale, it would call the opening behind the restore a
              // repetition of what the slice already said and drop it, and
              // the text after it would come out unclickable.
              if (entity is RestoreCursor) {
                writtenLink = heldLink = m.link;
              }
            }
          }
          lastPiece = m;
      }

      if (end != null && pos > end) {
        break;
      }
    }

    if (start > pos) {
      throw RangeError.range(start, 0, pos, 'start');
    }

    if (lastPiece != null) {
      final tail = currentState.transitTo(
        close ? initialState : lastPiece.state,
        skipSet: true,
      );

      if (close) {
        // A slice closes the link it has open, the one it began inside as
        // readily as the one it opened itself: what is printed after the
        // slice must not stay clickable on the slice's URL. An opening held
        // back is written first and terminated, for the same reason and by
        // the same right — what is printed after must not be read as more of
        // it. Held link codes are dropped instead: nothing follows them to
        // be shown inside.
        final closingLink = writtenLink != null ? linkClose : '';

        buf
          ..write(
            _terminatedOpening(
              heldOpening,
              _firstNotEmpty(closingLink, tail),
              closing: true,
            ),
          )
          ..write(closingLink);
      } else {
        // Left open, the way the style is left: what was held back is
        // written out, opening ahead of link codes as everywhere else, and
        // the slice ends inside whatever the string is inside at that point.
        // Neither call supplies anything — nothing follows but the unwinding
        // of the style, which is an `ESC` or nothing at all — but both go
        // through the same door as everywhere else, so that the guarantee is
        // checked and not assumed. See [_terminatedOpening] for the opening
        // and [_terminatedIfTextFollows] for the link codes.
        buf
          ..write(
            _terminatedOpening(
              heldOpening,
              _firstNotEmpty(heldLinkCodes, tail),
              closing: false,
            ),
          )
          ..write(_terminatedIfTextFollows(heldLinkCodes, tail));
      }
      buf.write(tail);
    }

    return buf.toString();
  }

  /// Inserts [text] at the plain text [pos], in front of the escape codes
  /// standing there.
  ///
  /// [pos] is the position in the string without ANSI escape codes.
  ///
  /// [pos] counts UTF-16 code units, the units [String.length] counts. A
  /// position between the halves of a surrogate pair — inside a `𝄞` —
  /// shifts to the front of the pair, so the pair is never split;
  /// [insertAfter] shifts past it instead.
  ///
  /// Input that is not valid UTF-16 to begin with — a lone half of a pair, or
  /// halves an escape code stands between — is neither mended nor refused:
  /// the halves are left as they lie, and an insertion aimed between two of
  /// them lands there.
  ///
  /// The inserted text takes the style of the place it lands in, and gives it
  /// back: the style it opens of its own is closed after it, so the string
  /// that follows keeps the look it had.
  ///
  /// If the inserted text itself ends inside an escape sequence the parser
  /// could not finish, the sequence is terminated before text follows it and
  /// at the end of the result. This is the other side of the unfinished-input
  /// rule below: that rule keeps the insertion out of the input's sequence;
  /// this one keeps the input's tail out of the insertion's sequence.
  ///
  /// A hyperlink is given back the same way. Links do not nest — the sequence
  /// that closes one closes them all — so text with a link of its own,
  /// inserted inside a link that was already open, is followed by that outer
  /// link opened again, in the bytes it was opened with: what comes after the
  /// insertion goes on pointing where it pointed before. An insertion that
  /// lands outside every link is followed by a close instead, so the string
  /// after it stays outside whatever the insertion pointed at.
  ///
  /// ```dart
  /// const text = '${fgRed}Hello$reset world';
  /// print(Parser(text).insertBefore(5, '!')); // '${fgRed}Hello!$reset world'
  /// ```
  ///
  /// The exclamation mark is red: at position 5 stands the `reset`, and this
  /// goes in front of it. See [insertAfter] for the other side of it.
  ///
  /// Neither insertion lands inside a sequence the parser could not finish — a
  /// control string that never got its terminator, be it an `OSC`, a `DCS`, an
  /// `SOS`, a `PM` or an `APC`; a bare `ESC`; a `CSI` with no final byte; an
  /// `ESC` left on an intermediate byte. Whatever is written among the bytes of
  /// one is read as part of it: `ESC` and an `X` are an `SOS`, `CSI` and an `X`
  /// an `ECH`, and neither shows the letter. Aimed at the seam in front of such
  /// a sequence, the text is put there, in front of it, and the tail is copied
  /// on as it came. Where several of them stand in a row, that seam is in front
  /// of the whole run rather than in a gap between two — a gap between two
  /// unfinished codes is inside the first of them.
  ///
  /// Aimed past that seam, the insertion is refused with an
  /// [UnfinishedSequenceException], because no answer is right: in front of the
  /// sequence is before characters counted in front of it, and where it was
  /// asked for is inside the sequence. Past the seam is any position among the
  /// bytes the sequence is still reading, whatever the piece of text they come
  /// back as looks like: the parameters of a truncated `CSI` are the case worth
  /// naming, but a byte no sequence can be built from — a `LF`, a `DEL`, a
  /// letter outside ASCII — breaks off the pattern just as well and leaves the
  /// code in front of it waiting for its ending all the same.
  ///
  /// The seam can be one of those positions itself, and then there is nothing
  /// to serve and both insertions refuse alike. A run that begins behind such a
  /// piece of text begins among bytes the sequence in front of that text is
  /// still reading, so the place before the run is where the byte that ends
  /// that sequence would be written. A code that stands finished between the
  /// text and the run gives the run a seam of its own, and that one is served
  /// as ever.
  ///
  /// A [pos] outside the plain text is a [RangeError], as it always was.
  String insertBefore(int pos, String text) => _insert(pos, text, after: false);

  /// Inserts [text] at the plain text [pos], behind the escape codes standing
  /// there.
  ///
  /// [pos] is the position in the string without ANSI escape codes.
  ///
  /// A position between the halves of a surrogate pair shifts past the
  /// pair; see [insertBefore] for the other direction, and for what becomes
  /// of input that is not valid UTF-16 to begin with — nothing, here as
  /// there.
  ///
  /// The same as [insertBefore] in every other way, and the same as it when no
  /// escape code stands at [pos].
  ///
  /// ```dart
  /// const text = '${fgRed}Hello$reset world';
  /// print(Parser(text).insertAfter(5, '!')); // '${fgRed}Hello$reset! world'
  /// ```
  ///
  /// The exclamation mark is not red: it goes behind the `reset` standing at
  /// position 5.
  ///
  /// The codes it goes behind are the finished ones. A sequence the parser
  /// could not finish is stood in front of rather than passed, and a run of
  /// them is stood in front of whole.
  ///
  /// ```dart
  /// print(Parser('aa\x1B]0;title').insertAfter(2, 'X')); // 'aaX\x1B]0;title'
  /// ```
  ///
  /// A finished code ends the run, though, and what stands before it is
  /// passed along with it — the run the seam is put in front of is the one
  /// reaching the text, not everything unfinished in the string:
  ///
  /// ```dart
  /// print(Parser('aa\x1B]0;title\x1B(B').insertAfter(2, 'X'));
  /// // 'aa\x1B]0;title\x1B(BX'
  /// ```
  ///
  /// The refusal is about the seam this one would take, which is the place
  /// past the codes standing at [pos]. Where that place falls among bytes a
  /// sequence is still reading — because the codes it went behind are
  /// unfinished themselves, or because the run they belong to begins among
  /// such bytes — there is nothing to serve, and an
  /// [UnfinishedSequenceException] is thrown; [insertBefore] says the rule in
  /// full, and this one reads it from its own side.
  ///
  /// Its own side is not the same side, so the two do not refuse in step. A
  /// code that stands finished between such bytes and what follows them puts a
  /// place past the waiting sequence within this one's reach, and it is served
  /// there while [insertBefore], stepping the other way, is refused:
  ///
  /// ```dart
  /// const text = 'aa\x1B[31\x1B(B\x1B[31';
  /// print(Parser(text).insertAfter(4, 'X')); // 'aa\x1B[31\x1B(BX\x1B[31'
  /// Parser(text).insertBefore(4, 'X');       // throws: 4 is inside the CSI
  /// ```
  String insertAfter(int pos, String text) => _insert(pos, text, after: true);

  String _insert(int pos, String text, {required bool after}) {
    final (cut, ambient, ambientLink) = _seamAt(pos, after: after);

    // Read from the seam on both channels: the inserted text lands inside the
    // state and inside the link that stand there, and what it leaves behind
    // is what has to be put right for the tail.
    final read = Pieces<S>._(text, ambient, initialLink: ambientLink)
        ._requireParsingResult;

    final linkBack = _linkBack(seam: ambientLink, left: read.finalLink);
    final transit = read.finalState.toStyle().transitTo(ambient);
    final tail = input.substring(cut);
    final following = _firstNotEmpty(linkBack, transit, tail);
    final insertion = _terminatedInsertion(text, read, following);

    return '${input.substring(0, cut)}'
        '$insertion$linkBack$transit$tail';
  }

  /// [text] copied byte for byte, save for the `ST` an unfinished sequence
  /// needs before text or at the closed edge of the insertion result.
  ///
  /// The argument has already been parsed for its final state and link. Its
  /// pieces are reused here: a second parse would answer the same question
  /// and make every insertion pay for it twice. The fast path returns [text]
  /// itself where no sequence needs holding, so ordinary insertions allocate
  /// no extra copy.
  String _terminatedInsertion(
    String text,
    _PiecesResult<S> read,
    String following,
  ) {
    if (!read.pieces.any((piece) => _unfinished(piece.entity))) {
      return text;
    }

    final buf = StringBuffer();
    var heldOpening = '';

    for (final piece in read.pieces) {
      final entity = piece.entity;
      final string = entity.string;

      if (heldOpening.isNotEmpty) {
        buf.write(
          _terminatedOpening(heldOpening, string, closing: false),
        );
        heldOpening = '';
      }

      if (_unfinished(entity)) {
        heldOpening = string;
      } else {
        buf.write(string);
      }
    }

    buf.write(
      _terminatedOpening(heldOpening, following, closing: true),
    );

    return buf.toString();
  }

  /// The link code that gives the seam its hyperlink back after the inserted
  /// text, or nothing where the insertion left the seam's link as it found it.
  ///
  /// A [Link] carries no style, so the state says nothing about it and it has
  /// to be put right on its own. Links do not nest — an opening supersedes
  /// whatever was open — so the seam's own opening is enough to take the tail
  /// back inside it, whether the insertion closed the link or left one of its
  /// own open; only a seam that stood outside every link is given a close.
  ///
  /// The opening is written in the bytes it was written in the first place —
  /// [Link._reopening], so that the `id=` of it and the form of its
  /// terminator are kept. Those same bytes are what tells the two links
  /// apart, the way `substring` tells them apart: an insertion ending inside
  /// the very link it landed in has nothing to give back.
  ///
  /// [seam] is the link the insertion landed in, [left] the one it left open;
  /// named, because two [Link]s in a row are told apart by nothing but their
  /// order.
  String _linkBack({required Link? seam, required Link? left}) =>
      left == seam ? '' : seam?._reopening ?? linkClose;

  /// The place in [input] an insertion at the plain text [pos] goes to, the
  /// state it lands in, and the hyperlink it lands inside.
  ///
  /// A seam is what lies between two neighbouring characters of the plain
  /// text: nothing at all, or the escape codes written between them. [after]
  /// chooses which end of it the insertion takes.
  (int, S, Link?) _seamAt(int pos, {required bool after}) {
    RangeError.checkNotNegative(pos, 'pos');

    if (!after && pos == 0) {
      return (0, initialState, initialLink);
    }

    // A seam is looked for in the pieces of text and nowhere else, so a walk
    // that has run out of pieces is picked up as readily as one standing in
    // the middle of the string — so long as what it knows of the codes still
    // speaks of the place in front of its piece. Where it does not, the seam
    // would be read off it silently: see [_Walk.codesStopAtPiece]. Such a
    // walk is dropped and the string walked again, which is what a parser
    // asked nothing before this does anyway.
    final _Walk<S> walk;
    var standing = false;
    if (_walk case final resumable?
        when resumable.codesStopAtPiece && resumable.resumesAt(pos)) {
      walk = resumable;
      standing = true;
    } else {
      walk = _walk = _Walk(pieces.iterator);
    }

    while (standing || walk.nextPiece()) {
      standing = false;
      final m = walk.current!;
      final plainPos = walk.pieceStart;
      final end = walk.passed;

      // Both ends of the seam sit inside a piece of text when the position
      // falls within one, and there the two insertions are the same.
      if (after ? pos < end : pos > plainPos && pos <= end) {
        final cut = m.start + (pos - plainPos);

        // A cut between the halves of a surrogate pair would land the
        // insertion inside a character. It shifts along the direction of
        // the insertion — insertBefore to the front of the pair,
        // insertAfter past it — and one step is always enough: the unit
        // next to a pair is never the missing half of another one. Halves
        // an escape code keeps apart are lone surrogates of the input
        // itself, sit in different pieces, and are left as they lie.
        if (cut > m.start &&
            cut < m.end &&
            _isHighSurrogate(input.codeUnitAt(cut - 1)) &&
            _isLowSurrogate(input.codeUnitAt(cut))) {
          return _seamAt(after ? pos + 1 : pos - 1, after: after);
        }

        // The piece may be the parameters of a `CSI` that never got its final
        // byte: the parser hands them back as text, a terminal reads them as
        // part of the sequence, and a cut among them makes the inserted text
        // its final byte. The seam in front of the sequence is served — that
        // is where the insertion was aimed — and nothing past it is: moving
        // the text there would put it before characters the caller counted in
        // front of it, and leaving it where it was asked for would make it
        // part of the sequence.
        if (walk.lastCode case final code?
            when code.end == m.start && _unfinished(code.entity)) {
          if (pos > plainPos) {
            throw UnfinishedSequenceException(pos: pos, offset: code.start);
          }

          // The run itself may begin inside a sequence that never finished:
          // where a piece of text broke the run, that text is bytes the
          // sequence in front of it is still reading, and the place before
          // the run is where the byte that ends it would be written. Text put
          // there is read as that ending and takes the text before it along,
          // and every other byte of the seam belongs to a code that could not
          // be finished either — so the seam has no end to serve, and the
          // insertion is refused the way one aimed past a seam is. A code
          // that stands finished in front of the run gives it a place of its
          // own, and that seam is served as it always was.
          if (walk.runSeamInside case final inside?) {
            throw UnfinishedSequenceException(pos: pos, offset: inside);
          }

          // The seam is in front of the whole run, so what is in force there
          // is what stood before the run — read off [_Walk.beforeRun] and not
          // off the piece, which reads what the run leaves behind it. On the
          // state channel the two agree, unfinished codes carrying none; on
          // the link channel they do not, because an `OSC 8` the parser never
          // saw terminated opens one all the same, and a seam that steps back
          // over that opening steps out of the link it opens.
          final before = walk.beforeRun;

          return (
            walk.unfinishedRunStart ?? code.start,
            before?.state ?? initialState,
            before == null ? initialLink : before.link,
          );
        }

        return (cut, m.state, m.link);
      }
    }

    if (pos > walk.passed) {
      throw RangeError.range(pos, 0, walk.passed, 'pos');
    }

    // The walk is spent, and the string may end inside a sequence that never
    // finished: a cut at the end of the input would fall among bytes a
    // terminal reads as that sequence, and the text would be read as its
    // parameters instead of shown. The insertion goes in front of the
    // sequence instead — no byte of the input is invented — and it lands in
    // the state and the link that stood before it, which for a hyperlink
    // opening means outside the link that opening opens.
    if (walk.lastCode case final code? when _unfinished(code.entity)) {
      // Everything past the last code is plain text, so the sequence runs to
      // the end of the input and its seam is that much before the end.
      final seam = walk.passed - (input.length - code.end);
      if (pos > seam) {
        throw UnfinishedSequenceException(pos: pos, offset: code.start);
      }

      // And the run at the end of the input begins inside an earlier sequence
      // as readily as one before a piece of text does — the same refusal, for
      // the same reason, naming the same sequence.
      if (walk.runSeamInside case final inside?) {
        throw UnfinishedSequenceException(pos: pos, offset: inside);
      }

      // What is in force at the seam is what stood in front of the run, the
      // way the branch above reads it: the piece of text reads what the run
      // leaves behind, and a finished code between the two makes the
      // difference visible. `??` on the link is not the same question — a
      // seam standing in no link answers null, and null is an answer.
      final before = walk.beforeRun;

      return (
        walk.unfinishedRunStart ?? code.start,
        before?.state ?? initialState,
        before == null ? initialLink : before.link,
      );
    }

    return (input.length, finalState, finalLink);
  }

  /// The string with [padding] written after it until the text is [width]
  /// wide.
  ///
  /// [width] is counted in the string without ANSI escape codes, which is the
  /// whole point of it being here: to [String.padRight] the codes are
  /// characters like any other, and a coloured word comes out narrower than
  /// it was asked to be.
  ///
  /// A [padding] longer than one character overshoots the width, the way
  /// [String.padRight] overshoots it: it is written once for every character
  /// still wanted, not once for every place it fills.
  ///
  /// The width is counted in UTF-16 code units, as [length] counts them —
  /// not in glyphs a terminal draws.
  String padRight(int width, [String padding = ' ']) {
    final needToAdd = width - length;
    if (needToAdd <= 0) {
      return input;
    }

    return input.padRight(input.length + needToAdd, padding);
  }

  /// The string with [padding] written before it until the text is [width]
  /// wide.
  ///
  /// See [padRight]: [width] is counted without the escape codes, and a
  /// [padding] longer than one character overshoots it.
  ///
  /// The width is counted in UTF-16 code units, as [length] counts them —
  /// not in glyphs a terminal draws.
  String padLeft(int width, [String padding = ' ']) {
    final needToAdd = width - length;
    if (needToAdd <= 0) {
      return input;
    }

    return input.padLeft(input.length + needToAdd, padding);
  }

  /// Optimizes the string by removing consecutive escape codes.
  ///
  /// [close] is whether to close the string with the default style and outside
  /// every hyperlink: a string that opens a link and never closes it comes
  /// back closed, so that what is printed after it is not clickable. With
  /// `close: false` both are left as the string leaves them, the link no less
  /// than the style. [substring] closes a slice the same way.
  ///
  /// A control string the string never terminated — a window title as readily
  /// as a link opening, a `DCS` as readily as an `OSC` — is held back until
  /// what follows it is known. Where that is text the terminator it lacks is
  /// supplied, or the sequence would read that text as its own; where it is an
  /// escape code the bytes go out as they came, that code's `ESC` ending the
  /// sequence as the string's did. With `close: true` the terminator is written
  /// at the end as well, though nothing follows it there, for the reason the
  /// link is closed there. See [substring], which says the whole of it.
  String optimize({bool close = true}) {
    final buf = StringBuffer();
    var currentState = initialState.toStyle();

    // A control string the string never terminated — a window title no less
    // than a link opening, a `DCS` no less than an `OSC` — held back until what
    // comes after it is known. In the string it was ended by the `ESC` of
    // whatever stood behind it, and that may have been an `SGR` — which this
    // loop does not copy but writes again as a transition, and a transition
    // that changes nothing writes nothing. See [_terminatedOpening], asked
    // inside the string and again at its end.
    var heldOpening = '';

    for (final m in pieces) {
      final entity = m.entity;
      if (entity is Sgr) {
        continue;
      }

      final string = entity.string;

      // A piece of text with nothing in it shows nothing: no transition is
      // written in front of it, and an opening held back goes on waiting for
      // something to be shown inside it.
      if (entity is! Text || string.isNotEmpty) {
        // The styles collected so far are flushed first: erasing and
        // scrolling read the current background color.
        final transit = currentState.transitTo(m.state);

        if (heldOpening.isNotEmpty) {
          buf.write(
            _terminatedOpening(
              heldOpening,
              _firstNotEmpty(transit, string),
              closing: false,
            ),
          );
          heldOpening = '';
        }

        buf.write(transit);

        // A code that carries no style of its own is kept as it was written —
        // save for one the parser could not finish, which waits to see what it
        // is written in front of.
        if (_unfinished(entity)) {
          heldOpening = string;
        } else {
          buf.write(string);
        }
      }

      currentState = m.state.toStyle();
    }

    // The string is over. What follows the opening held back is the close
    // below, or the unwinding of the style, or nothing at all — and where it
    // is nothing, `close` says whether a terminator is owed: what is printed
    // after a closed string must not be read as more of the control string.
    // With `close: false` nothing is supplied by construction — an `ESC` or
    // nothing at all follows it — and the call is made all the same, so that
    // the guarantee is checked and not assumed.
    final lastPiece = pieces.lastOrNull;
    final closingLink = close && finalLink != null ? linkClose : '';
    final tail = close
        ? currentState.transitTo(initialState)
        : lastPiece == null
            ? ''
            : currentState.transitTo(lastPiece.state);
    final following = _firstNotEmpty(closingLink, tail);

    buf
      ..write(_terminatedOpening(heldOpening, following, closing: close))
      // The link is closed the way the style is, and after the opening held
      // back: whatever the string left open — an opening of its own, or the
      // link it was seeded inside — must not go on catching what is printed
      // after.
      ..write(closingLink)
      ..write(tail);

    return buf.toString();
  }
}

/// A resumable walk over the pieces: the iterator, how much plain text it
/// has passed, and the piece of text it stopped in.
///
/// [_ParserBase.stateAt] and [_ParserBase.linkAt] — which read their answers
/// off one piece, through [_ParserBase._pieceAt] — `substring` and the insert
/// seams all walk the same pieces forward; sharing the walk makes a run of
/// forward questions cost one pass in all, whichever of them is asked and in
/// whatever order. A question about an earlier position starts a fresh walk.
final class _Walk<S extends State<S>> {
  final Iterator<Piece<S>> iterator;

  /// Plain-text position where the piece [current] stands for begins.
  int pieceStart = 0;

  /// Plain text passed so far, the current piece included.
  int passed = 0;

  /// The last [Text] piece handed out, or null before the first.
  Piece<S>? current;

  /// The last escape code the walk went past.
  ///
  /// Two things are read off it, and only one of them is true of every walk.
  /// `substring` closes a slice on the last piece it went past and picks the
  /// slice up again on it — that is this one, wherever it stands. `_seamAt`
  /// asks it what stands in front of [current], which holds only while the
  /// walk has gone past nothing else: see [codesStopAtPiece], which says why
  /// the difference cannot be seen without asking for it.
  Piece<S>? lastCode;

  /// Where the run of unfinished codes that [lastCode] ends begins, or null
  /// where that code is finished and where there is none.
  ///
  /// [lastCode] is not enough to step back from: it is the code nearest the
  /// piece, and an insertion that stops in front of it can still land inside
  /// the one before. Two in a row is the case that shows it — a control
  /// string that never closed and a truncated `CSI` behind it — and the seam
  /// belongs in front of both, since the string's body swallows whatever
  /// stands between them.
  int? unfinishedRunStart;

  /// Where the sequence that would swallow a seam in front of the run
  /// [unfinishedRunStart] begins, or null where that seam is a place of its
  /// own.
  ///
  /// A run is broken by a piece of text, and the code in front of that text
  /// decides what the run's beginning is worth. Where that code stands
  /// finished — or where there is none — the text is text, and the seam
  /// behind it is a place like any other. Where it does not, the text is
  /// bytes of a sequence still waiting for the one that ends it, and the
  /// seam behind them is where that ending would be written: the insertion
  /// is refused there, and this is the sequence to name.
  ///
  /// The text is not always parameters. A `CSI` gives up its parameters as
  /// text because the pattern wants a final byte and does not find one, and
  /// that is the case worth naming; but the same happens to a bare `ESC`, to
  /// an `ESC` on an intermediate byte and to a `CSI` before its parameters,
  /// each time the next byte is one no sequence can be built from — a `LF`, a
  /// `DEL`, a letter outside ASCII. Probed on the live parser: `ESC LF bb`
  /// hands back `ESC` and the text `LF bb`. What all of them share is the
  /// only thing this needs: the code is still waiting, and the first byte a
  /// terminal can take as its ending is the one written at the seam.
  ///
  /// Only the code nearest the text is named. A run of three unfinished codes
  /// with text behind it is still one sequence waiting at the byte after that
  /// text — the last of them — and pointing at the first would name bytes a
  /// terminal has long since read as something else.
  int? runSeamInside;

  /// The piece standing in front of the run [unfinishedRunStart] begins, or
  /// null where the run begins the string.
  ///
  /// A seam served in front of a run is served the state and the link that
  /// stand at its own place, and that is what this piece leaves behind it.
  /// Neither can be read off the piece the walk stopped in: the whole run
  /// lies between the two, and an unfinished `OSC 8` — three parameters, the
  /// terminator optional — opens a link there like any other. Probed on the
  /// live parser: `aa OSC 8;;http://u/ CSI 31` reads as a link over the last
  /// two pieces, so the piece says the seam sits inside a link the seam is in
  /// fact in front of, and the insertion writes that link back where nothing
  /// asked for it.
  ///
  /// The state channel is quieter, all eleven unfinished forms leaving it
  /// alone, but it is read from here too rather than from two places at once.
  ///
  /// Both branches of `_seamAt` read this: the one that stopped inside a
  /// piece of text, and the one for a walk that has run out — the string
  /// ending inside the run. They used to disagree, the second reading its
  /// state and its link off the last piece, which is the same thing only
  /// while the run follows the piece directly; a finished code standing
  /// between the two made an insertion drop the style and the link the tail
  /// stood in.
  Piece<S>? beforeRun;

  /// Whether the iterator has run out.
  ///
  /// Everything past [current] has then been taken from it, escape codes and
  /// all, and a walk that must write those out — `substring` does — starts
  /// over rather than resume and lose them.
  bool isSpent = false;

  _Walk(this.iterator);

  /// Whether what the walk knows of escape codes speaks of the place in front
  /// of [current], rather than of somewhere it has since gone on to.
  ///
  /// [lastCode] and the fields of the run it ends are kept for two readers,
  /// and only one of them is served by every walk. Two callers take a walk
  /// past its piece: `substring` steps over the pieces itself and reads on
  /// past the piece it stops in — a slice of the whole string reads to the
  /// end of them — and `stateAt` asked about the position behind the last
  /// piece of text walks the rest of the string looking for one more.
  ///
  /// A seam read off such a walk is read off nothing. The guard in `_seamAt`
  /// asks whether [lastCode] ends where the piece begins, and a code taken
  /// past the piece begins at or after the end of it; pieces tile the input,
  /// so that equality cannot come out true. The guard does not fire, and the
  /// insertion lands among bytes a terminal is still reading instead of being
  /// refused.
  ///
  /// Asked here rather than kept in a field of its own on purpose. A field
  /// would have to be cleared wherever a piece becomes current, and a
  /// clearing forgotten there costs nothing but speed — the walk stops being
  /// picked up at all — which no test of this package notices: measured by
  /// mutation, the whole suite stays green with the clearing taken out.
  bool get codesStopAtPiece {
    final piece = current;
    final code = lastCode;

    return piece == null || code == null || code.end <= piece.start;
  }

  /// Whether a question about the plain text position [pos] can be answered
  /// by reading on from [current] instead of from the start of the string.
  ///
  /// Strictly past [pieceStart]: a question about the very place a piece
  /// begins belongs to the escape codes standing in front of it, and the walk
  /// is already past those.
  bool resumesAt(int pos) => current != null && pos > pieceStart;

  /// Takes in the escape code [m] the walk has just gone past, keeping
  /// [lastCode], [unfinishedRunStart], [runSeamInside] and [beforeRun] on it.
  ///
  /// Two things end a run: a code that stands finished, and a piece of text.
  /// Pieces tile the input, so the text needs no looking at — a code that
  /// does not begin where the last one ended has text in front of it, and
  /// starts a run of its own. What that text was worth is read off the run it
  /// broke: [unfinishedRunStart] is set exactly where [lastCode] could not be
  /// finished, so a run beginning while it stands is a run beginning behind
  /// bytes a terminal is still reading, and [lastCode] is the sequence
  /// reading them.
  ///
  /// Every walk goes through here, `substring` — which steps over the pieces
  /// itself, to write out what it passes — no less than [nextPiece].
  void takeCode(Piece<S> m) {
    if (!_unfinished(m.entity)) {
      unfinishedRunStart = null;
      runSeamInside = null;
      beforeRun = null;
    } else if (lastCode?.end != m.start || unfinishedRunStart == null) {
      // A run begins here rather than goes on, and it is worth what the code
      // in front of it is: nothing, where that code stands finished.
      runSeamInside = unfinishedRunStart == null ? null : lastCode?.start;
      // Pieces tile the input, so what the run stands behind is named by one
      // comparison: the code where the run begins right where that code
      // ended, and the piece of text that fills the gap where it does not.
      beforeRun = lastCode?.end == m.start ? lastCode : current;
      unfinishedRunStart = m.start;
    }
    lastCode = m;
  }

  /// Takes in the piece of text [m], which begins at the plain text position
  /// [plainStart].
  ///
  /// The one door a piece becomes [current] through. Two walks are driven
  /// over the same pieces — [nextPiece] steps to the next piece and stops
  /// there, `substring` steps over every piece itself, to write out what it
  /// passes — and what a piece brings up to date is written here once for
  /// both of them rather than twice.
  void takePiece(Piece<S> m, int plainStart) {
    pieceStart = plainStart;
    // Same as entity.string.length, without reading the text: a Text piece is
    // cut from exactly [m.start, m.end), so the length is there in the piece
    // already.
    passed = plainStart + (m.end - m.start);
    current = m;
  }

  /// Moves to the next [Text] piece; false at the end of the string.
  bool nextPiece() {
    while (iterator.moveNext()) {
      final m = iterator.current;
      final entity = m.entity;
      if (entity is Text) {
        takePiece(m, passed);

        return true;
      }

      takeCode(m);
    }

    isSpent = true;

    return false;
  }
}

/// Whether the parser could not finish this escape code, so that whatever is
/// written after it is read as part of it.
///
/// A control string without its terminator — an `OSC`, a `DCS`, an `SOS`, a
/// `PM` or an `APC` — runs to the next `ESC` or to the end of the text; a
/// bare `ESC`, a `CSI` with no final byte and an `ESC` left on an
/// intermediate byte are all waiting for the byte that ends them, and
/// whatever is written next supplies it — `ESC` and `X` make `SOS`, `CSI` and
/// `X` make `ECH`. Everything else stands finished: `ESC 7` is a save,
/// `CSI 31 m` is a colour, and text written behind either is text.
bool _unfinished(Entity entity) => switch (entity) {
      ControlString() => !entity.terminated,
      Esc() => entity.string == ESC ||
          entity.string == CSI ||
          _isIntermediate(entity.string.codeUnitAt(entity.string.length - 1)),
      _ => false,
    };

/// Whether [codeUnit] is an intermediate byte, which cannot end an escape
/// sequence: ECMA-48 gives them the range `02/00` to `02/15`.
bool _isIntermediate(int codeUnit) => codeUnit >= 0x20 && codeUnit <= 0x2F;

/// Whether [codeUnit] is the leading half of a surrogate pair.
bool _isHighSurrogate(int codeUnit) => (codeUnit & 0xFC00) == 0xD800;

/// Whether [codeUnit] is the trailing half of a surrogate pair.
bool _isLowSurrogate(int codeUnit) => (codeUnit & 0xFC00) == 0xDC00;
