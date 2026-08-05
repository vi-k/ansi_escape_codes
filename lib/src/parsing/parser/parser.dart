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

part 'printer.dart';
part 'entities/csi.dart';
part 'entities/entity.dart';
part 'entities/esc.dart';
part 'entities/matching_state.dart';
part 'entities/osc.dart';
part 'entities/sgr.dart';
part 'matches/parser_iterator.dart';
part 'matches/match.dart';
part 'matches/matches.dart';
part 'matches/matches_result.dart';

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
/// * Analyzing a string using [matches].
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
/// On a large input, prefer walking `matches` with a `for` and taking what
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

  Matches<S>? _matches;
  String? _plainString;

  /// Where the last positional question stopped, so that the next can carry
  /// on from there rather than walk the string from the beginning.
  ///
  /// Asking about position after position — laying text out, measuring it,
  /// cutting it into lines — would otherwise walk the string from the
  /// beginning every time, and cost the questions times the length of it.
  _Walk<S>? _walk;

  _ParserBase(this.input, this.initialState);

  String get _requirePlainString => _plainString ??= () {
        final buf = StringBuffer();
        for (final m in matches) {
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
  bool get isParsed => _matches?.isParsed ?? false;

  /// The [Matches] of the string.
  Matches<S> get matches => _matches ??= Matches._(input, initialState);

  /// The final [S] after processing the entire string.
  ///
  /// See also [stateAt].
  S get finalState => matches._requireParsingResult.finalState;

  /// String length without ANSI escape codes, in UTF-16 code units.
  ///
  /// The count is [String.length] minus the codes — `𝄞` is two, and a
  /// grapheme a terminal draws as one glyph may be several. Graphemes are
  /// not counted.
  int get length => _requirePlainString.length;

  /// Whether the string ends in the state it began in.
  bool get isClosed => finalState == initialState;

  /// Reads the whole string, ahead of the questions asked of it.
  ///
  /// [stateAt] and [substring] read only as far as they must, and what they
  /// read is kept, so nothing is parsed twice. This reads it all in one go
  /// instead of letting it grow question by question, and builds the plain
  /// text [length], [indexOf] and the other string methods work on.
  ///
  /// It is for [length], [indexOf] and the other string methods, which need
  /// the whole of the text before they can answer anything. [stateAt] and
  /// [substring] do not gain by it — they keep their place as it is — and lose
  /// by it where the questions are not going to reach the end of the string.
  /// `benchmark/parser_benchmark.dart` measures both.
  void prepare() {
    matches._requireParsingResult;
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
  S stateAt(int pos) {
    RangeError.checkNotNegative(pos, 'pos');

    // The piece the last question was answered from may hold this one too.
    var walk = _walk;
    if (walk?.current case final match?
        when pos >= walk!.pieceStart && pos < walk.passed) {
      return match.state;
    }

    // Anything else already passed means going back, and the walk starts
    // over.
    if (walk == null || pos < walk.passed) {
      walk = _walk = _Walk(matches.iterator);
    }

    while (walk.nextPiece()) {
      if (pos < walk.passed) {
        return walk.current!.state;
      }
    }

    RangeError.checkValidIndex(pos, null, 'pos', walk.passed + 1);

    return finalState;
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

    for (final m in matches) {
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
  /// [close] is whether to close the substring with the default style. A
  /// hyperlink the slice opened and did not close is closed along with it,
  /// the way an insertion closes one: what is printed after the slice must
  /// not stay clickable. With `close: false` the link stays open, as the
  /// style does. A slice that began inside a link does not repeat the
  /// opening, and is not the one to close it.
  ///
  /// The close written is [linkClose], `OSC 8;; ST`, whatever form the
  /// opening took: a link opened `BEL`-terminated, the way [linkBel] opens
  /// one, is closed with `ST` all the same, and the slice comes out carrying
  /// both terminators. Terminals take either.
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
    Match<S>? lastMatch;
    var linkIsOpen = false;

    var walk = _walk;
    int pos;
    Match<S>? piece;
    if (walk != null && !walk.isSpent && walk.resumesAt(start)) {
      // The walk already stands in a piece the slice begins in or after:
      // pick that piece up and read on, one pass for a run of slices.
      pos = walk.pieceStart;
      piece = walk.current;
      lastMatch = walk.lastCode;
    } else {
      walk = _walk = _Walk(matches.iterator);
      pos = 0;
    }

    while (true) {
      final Match<S> m;
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
        walk
          ..pieceStart = pos
          // Same as entity.string.length, without reading the text: a Text
          // piece is cut from exactly [m.start, m.end), so the length is
          // there in the match already.
          ..passed = pos + (m.end - m.start)
          ..current = m;
      } else {
        walk.lastCode = m;
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
              buf
                ..write(currentState.transitTo(m.state))
                ..write(substring);
              currentState = m.state.toStyle();
              lastMatch = m;
            }
          }

        case EscapeCode():
          if (entity is! Sgr && pos >= start && (end == null || pos <= end)) {
            buf
              ..write(currentState.transitTo(m.state))
              ..write(entity.string);
            currentState = m.state.toStyle();
            if (entity is Link) {
              linkIsOpen = entity.url.isNotEmpty;
            }
          }
          lastMatch = m;
      }

      if (end != null && pos > end) {
        break;
      }
    }

    if (start > pos) {
      throw RangeError.range(start, 0, pos, 'start');
    }

    if (lastMatch != null) {
      if (close && linkIsOpen) {
        // A slice that opened a link closes it, the way an insertion does:
        // what is printed after the slice must not stay clickable on the
        // slice's URL. A slice that began inside a link never wrote the
        // opening, and has nothing to close.
        buf.write(linkClose);
      }
      buf.write(
        currentState.transitTo(
          close ? initialState : lastMatch.state,
          skipSet: true,
        ),
      );
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
  /// back: the style it opens of its own is closed after it, and so is a
  /// hyperlink, so the string that follows keeps the look it had and stays
  /// outside whatever the insertion pointed at.
  ///
  /// ```dart
  /// const text = '${fgRed}Hello$reset world';
  /// print(Parser(text).insertBefore(5, '!')); // '${fgRed}Hello!$reset world'
  /// ```
  ///
  /// The exclamation mark is red: at position 5 stands the `reset`, and this
  /// goes in front of it. See [insertAfter] for the other side of it.
  ///
  /// Hyperlinks are the one thing that cannot be given back. They do not nest
  /// — the sequence that closes one closes them all — so text that opens a
  /// link of its own, inserted inside a link that was already open, ends that
  /// one too, and the rest of it is no longer clickable.
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
  String insertAfter(int pos, String text) => _insert(pos, text, after: true);

  String _insert(int pos, String text, {required bool after}) {
    final (cut, ambient) = _seamAt(pos, after: after);
    final read = Matches<S>._(text, ambient)._requireParsingResult;

    return '${input.substring(0, cut)}'
        '$text'
        '${_closeLink(read.matches)}'
        '${read.finalState.toStyle().transitTo(ambient)}'
        '${input.substring(cut)}';
  }

  /// The sequence that closes a hyperlink the inserted text left open, or
  /// nothing where it left none.
  ///
  /// A [Link] carries no style, so the state says nothing about it, and text
  /// that follows an unclosed one is inside it — clickable, and pointing
  /// somewhere it has nothing to do with.
  String _closeLink(List<Match<S>> matches) {
    var isOpen = false;

    for (final m in matches) {
      if (m.entity case Link(:final url)) {
        isOpen = url.isNotEmpty;
      }
    }

    return isOpen ? linkClose : '';
  }

  /// The place in [input] an insertion at the plain text [pos] goes to, and
  /// the state it lands in.
  ///
  /// A seam is what lies between two neighbouring characters of the plain
  /// text: nothing at all, or the escape codes written between them. [after]
  /// chooses which end of it the insertion takes.
  (int, S) _seamAt(int pos, {required bool after}) {
    RangeError.checkNotNegative(pos, 'pos');

    if (!after && pos == 0) {
      return (0, initialState);
    }

    // A seam is looked for in the pieces of text and nowhere else, so a walk
    // that has run out of matches is picked up as readily as one standing in
    // the middle of the string.
    final _Walk<S> walk;
    var standing = false;
    if (_walk case final resumable? when resumable.resumesAt(pos)) {
      walk = resumable;
      standing = true;
    } else {
      walk = _walk = _Walk(matches.iterator);
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

        return (cut, m.state);
      }
    }

    if (pos > walk.passed) {
      throw RangeError.range(pos, 0, walk.passed, 'pos');
    }

    return (input.length, finalState);
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
  /// [close] is whether to close the string with the default style. The style
  /// is all it closes: a string that opens a hyperlink and never closes it
  /// comes back with the link open, and what is printed after it stays
  /// clickable. [substring] writes that close for a slice; this does not
  /// write it for a string.
  String optimize({bool close = true}) {
    final buf = StringBuffer();
    var currentState = initialState.toStyle();

    for (final m in matches) {
      final entity = m.entity;
      if (entity is Text) {
        final string = entity.string;
        if (string.isNotEmpty) {
          buf
            ..write(currentState.transitTo(m.state))
            ..write(string);
        }
        currentState = m.state.toStyle();
      } else if (entity is! Sgr) {
        // Carries no style of its own, so it is kept as it was written. The
        // styles collected so far are flushed first: erasing and scrolling
        // read the current background color.
        buf
          ..write(currentState.transitTo(m.state))
          ..write(entity.string);
        currentState = m.state.toStyle();
      }
    }

    final lastMatch = matches.lastOrNull;

    if (close) {
      buf.write(currentState.transitTo(initialState));
    } else if (lastMatch != null) {
      buf.write(currentState.transitTo(lastMatch.state));
    }

    return buf.toString();
  }
}

/// A resumable walk over the matches: the iterator, how much plain text it
/// has passed, and the piece of text it stopped in.
///
/// [_ParserBase.stateAt], `substring` and the insert seams all walk the same
/// matches forward; sharing the walk makes a run of forward questions cost one
/// pass in all. A question about an earlier position starts a fresh walk.
final class _Walk<S extends State<S>> {
  final Iterator<Match<S>> iterator;

  /// Plain-text position where the piece [current] stands for begins.
  int pieceStart = 0;

  /// Plain text passed so far, the current piece included.
  int passed = 0;

  /// The last [Text] match handed out, or null before the first.
  Match<S>? current;

  /// The last escape code standing in front of [current], where one does.
  ///
  /// A walk picked up at [current] never sees what came before it, and
  /// `substring` closes the slice on the last match it went past. That match
  /// is this one, kept so that resuming answers as walking from the start
  /// would.
  Match<S>? lastCode;

  /// Whether the iterator has run out.
  ///
  /// Everything past [current] has then been taken from it, escape codes and
  /// all, and a walk that must write those out — `substring` does — starts
  /// over rather than resume and lose them.
  bool isSpent = false;

  _Walk(this.iterator);

  /// Whether a question about the plain text position [pos] can be answered
  /// by reading on from [current] instead of from the start of the string.
  ///
  /// Strictly past [pieceStart]: a question about the very place a piece
  /// begins belongs to the escape codes standing in front of it, and the walk
  /// is already past those.
  bool resumesAt(int pos) => current != null && pos > pieceStart;

  /// Moves to the next [Text] piece; false at the end of the string.
  bool nextPiece() {
    while (iterator.moveNext()) {
      final m = iterator.current;
      final entity = m.entity;
      if (entity is Text) {
        pieceStart = passed;
        // Same as entity.string.length, without reading the text — see the
        // matching comment in substring.
        passed += m.end - m.start;
        current = m;

        return true;
      }

      lastCode = m;
    }

    isSpent = true;

    return false;
  }
}

/// Whether [codeUnit] is the leading half of a surrogate pair.
bool _isHighSurrogate(int codeUnit) => (codeUnit & 0xFC00) == 0xD800;

/// Whether [codeUnit] is the trailing half of a surrogate pair.
bool _isLowSurrogate(int codeUnit) => (codeUnit & 0xFC00) == 0xDC00;
