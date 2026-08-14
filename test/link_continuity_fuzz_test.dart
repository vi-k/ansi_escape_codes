import 'dart:math';

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The seed the documents are drawn from.
///
/// Fixed, so that what this file finds today it finds again tomorrow, and a
/// failure is gone back to rather than waited for.
const int _seed = 20260807;

/// The link in force at every position of the plain text, as a list.
///
/// This is what "as clickable as it was" is measured with: two strings are
/// equally clickable where these lists are equal, whatever bytes it took to
/// say so. The form of the opening is deliberately outside the comparison —
/// `ST` or `BEL`, with an `id=` or without — because a slice and a printed
/// line are free to reopen a link however they like as long as the
/// characters end up inside it. Nothing here pins the bytes.
List<String?> _clickability(String text) {
  final parser = Parser(text);

  return [for (var i = 0; i < parser.length; i++) parser.linkAt(i)?.url];
}

/// The string with its escape codes named, so that a failure can be read.
String _show(String text) => text
    .replaceAll(ST, '<ST>')
    .replaceAll(ESC, '<ESC>')
    .replaceAll(BEL, '<BEL>')
    .replaceAll('\n', '<NL>');

/// One piece of the alphabet the documents are built from.
///
/// The pieces are drawn one at a time and written one after another, so a
/// document is any sequence of them: an opening lands inside a link as
/// readily as outside one, a close closes nothing as readily as something, a
/// link is as likely to run to the end of the string as to be closed, and
/// the codes that are none of a link's business — a colour, a reset that
/// resets nothing, a cursor move — stand between them everywhere.
///
/// [readWhole] says the document is read as one string, the way a slice
/// reads it, and lets in the one shape that only means the same thing there:
/// an opening with no terminator of its own, which runs to the next `ESC`.
/// A line break or a write boundary put in front of that `ESC` changes how
/// far it reaches, and then the two sides are no longer reading the same
/// document at all. With [readWhole] off the shape is still drawn, but the
/// code whose `ESC` ends the opening travels with it in one piece.
///
/// [saves] draws `ESC 7` and `ESC 8`: bare where the document is read whole,
/// and as a save with its own restore beside it where it is not. What a save
/// puts away does not cross a line break in this package — on the link
/// channel or on the style one, as the last test in this file shows — so a
/// printed document is only ever asked about a save and a restore standing
/// in the same piece of it.
///
/// [lineBreaks] draws `'\n'`, which is a character of the plain text like
/// any other and the one place a printed line is allowed to differ.
String _piece(
  Random random, {
  required bool readWhole,
  bool saves = true,
  bool lineBreaks = true,
}) {
  final url = 'http://${random.nextInt(3)}/';

  switch (random.nextInt(24)) {
    case 0:
      return '$linkOpen$url$linkTextOpen';
    case 1:
      return '$linkOpen$url$BEL';
    case 2:
      return '${OSC}8;id=${random.nextInt(3)};$url$ST';
    case 3:
      // An opening whose terminator never came: what ends it is the `ESC` of
      // whatever stands behind it.
      return readWhole
          ? '$linkOpen$url'
          : '$linkOpen$url${random.nextBool() ? reset : cursorUp}';
    case 4:
      return linkClose;
    case 5:
      // A close carrying an `id=` is a close all the same.
      return '${OSC}8;id=1;$ST';
    case 6:
    case 7:
      if (!saves) {
        break;
      }

      return readWhole
          ? (random.nextBool() ? saveCursor : restoreCursor)
          : _saveAndRestore(random);
    case 8:
      return fgRed;
    case 9:
      // A reset that resets nothing, the style being the default already.
      return reset;
    case 10:
      return cursorUp;
    case 11:
      return '𝄞';
    case 12:
      if (!lineBreaks) {
        break;
      }

      return '\n';
    case 13:
      // A window title with no terminator of its own: the same shape as the
      // opening in case 3, and it ends the same way — at the `ESC` of
      // whatever stands behind it. `readWhole` is honoured for the same
      // reason: a line break put in front of that `ESC` changes how far the
      // sequence reaches, and then the two sides are no longer reading the
      // same document.
      return readWhole
          ? '${OSC}0;title'
          : '${OSC}0;title${random.nextBool() ? reset : cursorUp}';
    case 14:
      // The same title, terminated: the shape that must not change.
      return '${OSC}0;title$ST';
    case 15:
      // The bytes of a close with nothing to end them. A close is an `OSC`
      // like any other and runs to the next `ESC` too, so what these bytes
      // are depends on what is drawn behind them: a close where an `ESC` or
      // the end of the document follows, and an opening on the url they read
      // out of the text where anything else does. Drawing them puts both
      // readings in the alphabet, and with them the shortest link opening
      // there is — the one whose url the text alone supplies. `readWhole` is
      // honoured as in case 3, and pins the first reading where it is off.
      return readWhole
          ? '${OSC}8;;'
          : '${OSC}8;;${random.nextBool() ? reset : cursorUp}';
    default:
      break;
  }

  return const ['word ', 'a', 'x', 'yz'][random.nextInt(4)];
}

/// A save and the restore that answers it, with a piece or two between them
/// and no line break and no second save anywhere inside.
String _saveAndRestore(Random random) {
  String inner() =>
      _piece(random, readWhole: false, saves: false, lineBreaks: false);

  return '$saveCursor${inner()}${inner()}$restoreCursor';
}

/// A document of [pieces] pieces.
String _document(
  Random random,
  int pieces, {
  required bool readWhole,
  bool saves = true,
}) =>
    [
      for (var i = 0; i < pieces; i++)
        _piece(random, readWhole: readWhole, saves: saves),
    ].join();

/// The positions where [output] is not as clickable as [source] was, named.
///
/// Every position of the plain text is compared but the line breaks. The
/// break is the one position left out, and by design: a printed line closes
/// the link it leaves open, so that what is printed after it does not stay
/// clickable on a URL it has nothing to do with, and the line after opens the
/// link again in front of the first text it shows. The character a line ends
/// on therefore stands outside the link on purpose. Every character that is
/// drawn is compared, and the URL it is drawn on has to be the one the source
/// put it on.
///
/// [restoresExcused] lets through what an `ESC 8` may cost, from the line it
/// stands on onwards — and only what `_acceptedLoss` calls a cost. A link
/// that appears where the source had none, or turns into another link, is a
/// failure with an `ESC 8` beside it as much as without one. The two tests
/// that switch this off are the strong claim: with no restore in the alphabet
/// at all, nothing is excused and nothing may differ.
List<String> _differences(
  String source,
  String output, {
  required bool restoresExcused,
}) {
  final src = Parser(source);
  final out = Parser(output);
  final plain = src.removeAll();

  if (out.removeAll() != plain) {
    final finding = 'the text itself came out different:\n'
        '  in:  ${_show(source)}\n'
        '  out: ${_show(output)}';

    return [finding];
  }

  final findings = <String>[];
  final lines = output.split('\n');
  var line = 0;
  var restored = lines.first.contains(restoreCursor);
  for (var pos = 0; pos < plain.length; pos++) {
    if (plain[pos] == '\n') {
      line++;
      restored = restored ||
          (line < lines.length && lines[line].contains(restoreCursor));
      continue;
    }

    final was = src.linkAt(pos)?.url;
    final now = out.linkAt(pos)?.url;
    if (was == now ||
        _acceptedLoss(
          was: was,
          now: now,
          restored: restoresExcused && restored,
        )) {
      continue;
    }

    findings.add(
      'character $pos was on ${was ?? 'nothing'} and is now on '
      '${now ?? 'nothing'}:\n'
      '  in:  ${_show(source)}\n'
      '  out: ${_show(output)}',
    );
  }

  return findings;
}

/// Whether the difference between what the input had in force at a character
/// and what came back is the one difference this wave leaves standing.
///
/// A piece that took in an `ESC 8` — [restored] — restores what its own bytes
/// saved, and its own bytes are not the input's: the `ESC 7` was left outside
/// the piece, or it stands inside it in front of the opening the piece
/// writes, so that nothing was open at the save. Either way there is nothing
/// in the piece to give back, and returning the link would mean writing an
/// opening with nothing inside it, which the slice deliberately does not do.
/// `parser_substring_links_test.dart` pins one such slice byte for byte.
///
/// Only a **loss** is let through, and only there. A link where the input had
/// none is not a cost but a fabrication — a clickable region the string never
/// asked for — and a link turned into another link sends the reader
/// somewhere else; an `ESC 8` standing nearby excuses neither. Nor is any
/// loss excused where no `ESC 8` was taken in. And nothing at all is excused
/// on the identity slice, which carries the input's own `ESC 7` and `ESC 8`
/// and wants for nothing — that one is checked apart, against no exception.
bool _acceptedLoss({
  required String? was,
  required String? now,
  required bool restored,
}) =>
    was != null && now == null && restored;

void main() {
  group('every character stays as clickable as it was:', () {
    test('a slice gives back what it cut', () {
      final random = Random(_seed);
      final findings = <String>[];
      var slicesWithRestore = 0;
      var roundsWithLink = 0;

      for (var round = 0; round < 3000; round++) {
        final text = _document(random, 14, readWhole: true);
        final whole = _clickability(text);
        if (whole.isEmpty) {
          continue;
        }
        if (whole.any((url) => url != null)) {
          roundsWithLink++;
        }

        // The whole input in one piece. Nothing was cut away, so nothing may
        // go missing: an `ESC 8` buys no excuse here, because whatever the
        // input's `ESC 7` put away is in the slice too.
        for (final close in [true, false]) {
          expect(
            _clickability(Parser(text).substring(0, close: close)),
            whole,
            reason: 'the identity slice, close: $close, of ${_show(text)}',
          );
        }

        // Then cut it the way a wrapper would and read the pieces back one
        // after another: what the slices say must be what the whole said.
        final width = 1 + random.nextInt(5);
        final close = random.nextBool();
        final parser = Parser(text);
        for (var start = 0; start < whole.length; start += width) {
          final slice = parser.substring(start, maxLength: width, close: close);
          final cut = _clickability(slice);
          final want = whole.sublist(start, min(start + width, whole.length));

          expect(
            cut,
            hasLength(want.length),
            reason: 'the slice at $start of ${_show(text)} shows a different '
                'number of characters: ${_show(slice)}',
          );
          if (slice.contains(restoreCursor)) {
            slicesWithRestore++;
          }

          for (var i = 0; i < cut.length; i++) {
            if (cut[i] == want[i] ||
                _acceptedLoss(
                  was: want[i],
                  now: cut[i],
                  restored: slice.contains(restoreCursor),
                )) {
              continue;
            }

            findings.add(
              'character ${start + i} was on ${want[i] ?? 'nothing'} and the '
              'slice at $start — width $width, close: $close — puts it on '
              '${cut[i] ?? 'nothing'}:\n'
              '  in:    ${_show(text)}\n'
              '  slice: ${_show(slice)}',
            );
          }
        }

        // And then the same slices written one after another and read as the
        // one string they make. Reading each piece alone says nothing about
        // what the pieces do to each other, and that is the whole of what
        // `close: true` is for: the close a slice writes at its end is what
        // keeps the piece stitched behind it out of the link. Without this,
        // a slice that stopped closing anything at all goes unnoticed.
        final stitched = StringBuffer();
        final restoredBy = <bool>[];
        var sawRestore = false;
        final closing = Parser(text);
        for (var start = 0; start < whole.length; start += width) {
          final slice = closing.substring(start, maxLength: width);
          sawRestore = sawRestore || slice.contains(restoreCursor);
          stitched.write(slice);
          final taken = min(start + width, whole.length) - start;
          restoredBy.addAll(List.filled(taken, sawRestore));
        }

        final sewn = _clickability(stitched.toString());
        expect(
          sewn,
          hasLength(whole.length),
          reason: 'the stitched slices of ${_show(text)} show a different '
              'number of characters: ${_show(stitched.toString())}',
        );
        for (var i = 0; i < sewn.length; i++) {
          if (sewn[i] == whole[i] ||
              _acceptedLoss(
                was: whole[i],
                now: sewn[i],
                restored: restoredBy[i],
              )) {
            continue;
          }

          findings.add(
            'character $i was on ${whole[i] ?? 'nothing'} and the slices of '
            'width $width stitched back together put it on '
            '${sewn[i] ?? 'nothing'}:\n'
            '  in:       ${_show(text)}\n'
            '  stitched: ${_show(stitched.toString())}',
          );
        }
      }

      expect(findings, isEmpty, reason: findings.join('\n'));
      // The seed is fixed, so these are what the run really draws — 2114 and
      // 2030 — held well below by a guard that only has to catch a generator
      // that has stopped generating.
      expect(
        roundsWithLink,
        greaterThan(1500),
        reason: 'the documents have to be worth slicing',
      );
      expect(
        slicesWithRestore,
        greaterThan(1000),
        reason: 'and the shape the one excuse is written for has to be drawn',
      );
    });

    test('a printed document keeps it, line for line', () {
      final random = Random(_seed);
      final findings = <String>[];

      for (var round = 0; round < 3000; round++) {
        final text = _document(random, 12, readWhole: false, saves: false);
        final lines = <String>[];
        Printer(output: lines.add).print(text);

        // The lines reach the terminal one after another with the break
        // between them, and that is what the terminal is read as having seen.
        findings.addAll(
          _differences(text, lines.join('\n'), restoresExcused: false),
        );
      }

      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    test('a sink keeps it across the writes a line is made of', () {
      final random = Random(_seed);
      final findings = <String>[];

      for (var round = 0; round < 3000; round++) {
        final pieces = [
          for (var i = 0; i < 12; i++)
            _piece(random, readWhole: false, saves: false),
        ];
        final sink = StringBuffer();
        final printer = SinkPrinter(sink);

        // A line here is made of several writes, and a write may end anywhere
        // between two pieces — inside a link, between an opening and the text
        // it opens, in front of the close that answers it.
        var at = 0;
        while (at < pieces.length) {
          final take = 1 + random.nextInt(3);
          printer.write(pieces.skip(at).take(take).join());
          at += take;
        }
        printer.writeln();

        findings.addAll(
          _differences(
            '${pieces.join()}\n',
            sink.toString(),
            restoresExcused: false,
          ),
        );
      }

      expect(findings, isEmpty, reason: findings.join('\n'));
    });

    test('and with save and restore, only an ESC 8 may cost it', () {
      final random = Random(_seed);
      final findings = <String>[];

      for (var round = 0; round < 3000; round++) {
        final pieces = [
          for (var i = 0; i < 12; i++) _piece(random, readWhole: false),
        ];
        final text = pieces.join();

        final lines = <String>[];
        Printer(output: lines.add).print(text);
        findings.addAll(
          _differences(text, lines.join('\n'), restoresExcused: true),
        );

        final sink = StringBuffer();
        final printer = SinkPrinter(sink);
        var at = 0;
        while (at < pieces.length) {
          final take = 1 + random.nextInt(3);
          printer.write(pieces.skip(at).take(take).join());
          at += take;
        }
        printer.writeln();
        findings.addAll(
          _differences('$text\n', sink.toString(), restoresExcused: true),
        );
      }

      expect(findings, isEmpty, reason: findings.join('\n'));
    });
  });

  group('a restore reaching across a line break keeps the printer in sync:',
      () {
    test('the style goes the same way, so this is not the link channel', () {
      const source = '${fgRed}A\n${restoreCursor}B\nC';
      final lines = <String>[];
      Printer(output: lines.add).print(source);

      expect(
        Parser(source).stateAt(4),
        Parser('C').stateAt(0),
        reason: 'the string restores what nothing saved, which is the '
            'colours the terminal began in, and C is not one of them',
      );
      expect(
        Parser(lines.join('\n')).stateAt(4),
        Parser('C').stateAt(0),
        reason:
            'with no save the restore fallback is the terminal default, not '
            'the state seeded from the line before it',
      );
    });

    test('and the link goes with it', () {
      const source = '$linkOpen'
          'http://u/'
          '${linkTextOpen}A\n'
          '${restoreCursor}B';
      final lines = <String>[];
      Printer(output: lines.add).print(source);

      expect(
        Parser(source).linkAt(2),
        isNull,
        reason: 'the string restores what nothing saved, which is no link',
      );
      expect(
        Parser(lines.join('\n')).linkAt(2),
        isNull,
        reason: 'with no save the restore fallback has no link, even when the '
            'line was seeded inside the link carried from the line before it',
      );
    });
  });

  group('the visible text survives every surface:', () {
    test('nothing a surface hands back has lost a character', () {
      // The codes may be rewritten, reordered or dropped — that is what
      // these surfaces are for — but the characters a terminal draws may
      // not change. An `OSC` that swallows what follows it is the one way
      // they do, and this is the oracle that says so.
      final random = Random(_seed);

      for (var round = 0; round < 500; round++) {
        final whole = _document(random, 12, readWhole: true);
        final plain = Parser(whole).removeAll();

        expect(
          Parser(Parser(whole).optimize()).removeAll(),
          plain,
          reason: 'optimize lost text:\n  in: ${_show(whole)}',
        );
        expect(
          Parser(Parser(whole).optimize(close: false)).removeAll(),
          plain,
          reason: 'optimize(close: false) lost text:\n  in: ${_show(whole)}',
        );
        expect(
          Parser(Parser(whole).substring(0)).removeAll(),
          plain,
          reason: 'substring lost text:\n  in: ${_show(whole)}',
        );
        expect(
          Parser(Parser(whole).substring(0, close: false)).removeAll(),
          plain,
          reason: 'substring(close: false) lost text:\n  in: ${_show(whole)}',
        );
      }

      // The printer reads a document that keeps an unterminated sequence
      // and the code ending it in one piece, the way the rest of this file
      // does: a line break in between would change how far the sequence
      // reaches, and the two sides would stop reading the same document.
      for (var round = 0; round < 500; round++) {
        // The pieces are drawn one at a time, which is all `_document` does,
        // so the printer and the sink below are asked about one and the same
        // document.
        final pieces = [
          for (var i = 0; i < 12; i++)
            _piece(random, readWhole: false, saves: false),
        ];
        final printed = pieces.join();
        final plain = Parser(printed).removeAll();

        final lines = <String>[];
        Printer(output: lines.add).print(printed);

        expect(
          lines.map((line) => Parser(line).removeAll()).join('\n'),
          plain,
          reason: 'the printer lost text:\n  in: ${_show(printed)}',
        );

        // The sink takes the same document a piece at a time — a write ends
        // where the printer had no boundary at all — and the `writeln` is the
        // end of the line the last writes were making.
        final sink = StringBuffer();
        final printer = SinkPrinter(sink);
        pieces.forEach(printer.write);
        printer.writeln();

        expect(
          Parser(sink.toString()).removeAll(),
          '$plain\n',
          reason: 'the sink lost text:\n  in: ${_show(printed)}',
        );
      }
    });
  });
}
