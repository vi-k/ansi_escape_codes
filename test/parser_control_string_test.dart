import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
// The opener set the pattern is built from. Not exported by any entry point —
// it is an implementation detail — but the test that ties its two copies
// together has to read the real one, or it would only be a third copy.
import 'package:ansi_escape_codes/src/parsing/patterns/patterns.dart';
import 'package:test/test.dart';

void main() {
  group('control strings:', () {
    test('a terminated string is one entity, and its body is not text', () {
      final parser = Parser('aa${DCS}pay${ST}bb');

      expect(parser.matches.map((m) => m.entity.runtimeType).toList(), [
        Text,
        Dcs,
        Text,
      ]);
      expect(parser.removeAll(), 'aabb');
      expect(parser.length, 4);
    });

    test('all four openers are read the same way', () {
      for (final (opener, type) in [
        (DCS, Dcs),
        (SOS, Sos),
        (PM, Pm),
        (APC, Apc),
      ]) {
        final parser = Parser('aa${opener}pay${ST}bb');

        expect(
          parser.matches.elementAt(1).entity.runtimeType,
          type,
          reason: 'opener ${opener.ansiShowEscapeSequences()}',
        );
        expect(parser.removeAll(), 'aabb');
      }
    });

    test('a string that never got its terminator runs to the end', () {
      final parser = Parser('aa${DCS}pay');

      expect(parser.removeAll(), 'aa');
      expect(parser.matches.last.entity, isA<Dcs>());
    });

    test('an unterminated string ends where the next sequence starts', () {
      expect(Parser('${DCS}pay${fgRed}x$reset').removeAll(), 'x');
    });

    test('a BEL does not end anything but an OSC', () {
      expect(
        Parser('aa${DCS}pay${BEL}more').removeAll(),
        'aa',
        reason: 'BEL is xterm’s terminator for OSC alone',
      );
      expect(Parser('aa${OSC}pay${BEL}more').removeAll(), 'aamore');
    });

    test('an empty body is a string all the same', () {
      final parser = Parser('aa$DCS${ST}bb');

      expect(parser.removeAll(), 'aabb');
      expect(parser.matches.elementAt(1).entity, isA<Dcs>());
    });

    test('a lone ST opens nothing', () {
      expect(Parser('aa${ST}bb').matches.elementAt(1).entity, isA<Esc>());
    });

    test('the string comes back byte for byte', () {
      for (final opener in [DCS, SOS, PM, APC]) {
        const body = 'pay';
        final input = 'aa$opener$body${ST}bb';

        expect(
          Parser(input).matches.map((m) => m.entity.string).join(),
          input,
        );
      }
    });
  });

  // What opens a string is written down twice: the class of openers in
  // `patterns.dart` says how many bytes the match takes, and the switch in
  // `EscapeCode._parse` says which entity it becomes. Nothing ties the two
  // together, and widening either one alone is silent — a match that takes
  // the body but is built as an `EscUnknown`, or an entity built as an `Apc`
  // out of two bytes. These tests hold both: the plain text holds the class,
  // the entity holds the switch.
  group('control strings, what does not open one:', () {
    // PU1, PU2, STS, CCH, MW, SPA, EPA and SCI, and the unassigned `\x59`
    // among them: the whole of `\x50`–`\x5F` but the four openers, `CSI`,
    // `ST` and `OSC`.
    const neighbours = ['Q', 'R', 'S', 'T', 'U', 'V', 'W', 'Y', 'Z'];

    test('the C1 neighbours of the openers stay escape codes', () {
      for (final letter in neighbours) {
        final parser = Parser('aa$ESC${letter}pay${ST}bb');

        expect(
          parser.matches.elementAt(1).entity,
          isA<Esc>(),
          reason: 'ESC $letter',
        );
        expect(parser.removeAll(), 'aapaybb', reason: 'ESC $letter');
      }
    });

    test('the C1 neighbours owe no terminator', () {
      for (final letter in neighbours) {
        expect(
          Parser('aa$ESC${letter}pay').optimize(),
          'aa$ESC${letter}pay',
          reason: 'ESC $letter',
        );
      }
    });
  });

  // The expectations here were taken off `OSC` on the same shapes of input,
  // which already pays this debt, and then written for the other four. Where
  // one of them differs from `OSC` — the `BEL` test — the difference is the
  // point and is spelt out in the test.
  group('control strings, held openings:', () {
    test('an unterminated string is closed where text follows it', () {
      expect(
        Parser('aa${DCS}pay').optimize(),
        'aa${DCS}pay$ST',
      );
    });

    test('a slice does not leave a string open behind it', () {
      expect(
        Parser('aa${DCS}pay').substring(0, maxLength: 2),
        'aa${DCS}pay$ST',
      );
    });

    test('a body ending in BEL still owes a terminator', () {
      expect(
        Parser('aa${DCS}pay$BEL').optimize(),
        'aa${DCS}pay$BEL$ST',
        reason: 'BEL ends an OSC and no other control string',
      );
    });

    test('an OSC ending in BEL owes nothing', () {
      expect(
        Parser('aa${OSC}pay$BEL').optimize(),
        'aa${OSC}pay$BEL',
      );
    });

    test('a slice left open does not close the string either', () {
      expect(
        Parser('aa${DCS}pay').substring(0, maxLength: 2, close: false),
        'aa${DCS}pay',
      );
    });

    test('a printed line closes what it left open', () {
      final lines = <String>[];

      Printer(output: lines.add).writeln('aa${DCS}pay');

      // The output takes the line without its newline, and every prepared
      // piece opens with a reset — both the printer's own doing.
      expect(lines.single, '${reset}aa${DCS}pay$ST');
    });

    test('a sink printer pays the same debt', () {
      final buf = StringBuffer();

      SinkPrinter(buf).writeln('aa${DCS}pay');

      expect(buf.toString(), '${reset}aa${DCS}pay$ST\n');
    });

    test('all four owe the terminator alike', () {
      for (final opener in [DCS, SOS, PM, APC]) {
        expect(
          Parser('aa${opener}pay').optimize(),
          'aa${opener}pay$ST',
          reason: 'opener ${opener.ansiShowEscapeSequences()}',
        );
      }
    });
  });

  // The group above settles what is owed where the output ends. This one is
  // the other half: the opening is held inside the loop and something of the
  // output itself follows it. The `reset` in these inputs is what ended the
  // string in the input, and it is not copied over — it is written again as a
  // transition to the default style, which changes nothing and so writes
  // nothing, leaving the text against the opening. Expectations taken off
  // `OSC` on the same shapes; the `BEL` ones differ from it, and that is the
  // point.
  group('control strings, held openings inside the output:', () {
    test('a terminator is supplied where text follows in the string', () {
      expect(
        Parser('${DCS}pay${reset}word').optimize(),
        '${DCS}pay${ST}word',
      );
    });

    test('a code copied over as it stands ends the string already', () {
      // The `CSI` is written where it stands and its `ESC` ends the string,
      // so nothing is supplied — the branch that reads what follows.
      expect(
        Parser('${DCS}pay\x1B[2Cword').optimize(),
        '${DCS}pay\x1B[2Cword',
      );
    });

    test('a body ending in BEL owes the terminator here too', () {
      // The in-loop half of the trap: ask whether these bytes ended and the
      // `BEL` says yes, so the text would be swallowed into the string.
      expect(
        Parser('${DCS}pay$BEL${reset}word').optimize(),
        '${DCS}pay$BEL${ST}word',
        reason: 'BEL ends an OSC and no other control string',
      );
      expect(
        Parser('${OSC}pay$BEL${reset}word').optimize(),
        '${OSC}pay${BEL}word',
        reason: 'the OSC it is taken from owes nothing',
      );
    });

    test('a slice supplies it inside even with close: false', () {
      // `close` decides what is owed at the end of the slice, not what is
      // owed in front of text inside it.
      expect(
        Parser('${DCS}pay${reset}word').substring(0, close: false),
        '${DCS}pay${ST}word',
      );
    });

    test('a printed line supplies it inside the line', () {
      final lines = <String>[];

      Printer(output: lines.add).print('${DCS}pay${reset}word');

      expect(lines, ['$reset${DCS}pay${ST}word']);
    });

    test('a sink supplies it inside a write that ends no line', () {
      final buf = StringBuffer();

      SinkPrinter(buf).write('${DCS}pay${reset}word');

      expect(buf.toString(), '$reset${DCS}pay${ST}word');
    });

    test('all four are mended inside the string alike', () {
      for (final opener in [DCS, SOS, PM, APC]) {
        expect(
          Parser('${opener}pay${reset}word').optimize(),
          '${opener}pay${ST}word',
          reason: 'opener ${opener.ansiShowEscapeSequences()}',
        );
      }
    });
  });

  // Insertions were left to the two halves above: the body of a string is no
  // longer text, so no plain-text position falls inside one, and `_unfinished`
  // asks the family rather than `OSC` alone, so an insertion stands in front
  // of a string that never ended instead of among its bytes. These tests hold
  // that, and their expectations were taken off `OSC` on the same shapes.
  group('control strings, insertions:', () {
    test('an insertion does not land inside a terminated string', () {
      final parser = Parser('aa${DCS}pay${ST}bb');

      expect(parser.insertBefore(2, 'X'), 'aaX${DCS}pay${ST}bb');
      expect(parser.insertAfter(2, 'X'), 'aa${DCS}pay${ST}Xbb');
    });

    test('an insertion stands before a string that never ended', () {
      expect(Parser('aa$DCS').insertAfter(2, 'X'), 'aaX$DCS');
      expect(Parser('aa${DCS}pay').insertAfter(2, 'X'), 'aaX${DCS}pay');
    });

    test('a string a finished code ended is passed over, not entered', () {
      // The other shape of an unterminated string: it runs to the `ESC` of
      // the code behind it rather than to the end of the input, and the
      // insertion goes behind that code, where the string is over.
      //
      // Only where that code is finished. An unfinished one — a bare `ESC`,
      // a `CSI` still waiting for its final byte — takes the insertion in
      // front of itself, which is the end of the body of a string that never
      // got its terminator: `aa DCS pay` + `X` + `ESC`, with the `X` inside
      // the string as a terminal reads it. That is the seam the caller asked
      // for, and moving it further would put the text behind bytes counted
      // in front of it.
      final parser = Parser('aa${DCS}pay${fgRed}x$reset');

      expect(parser.insertBefore(2, 'X'), 'aaX${DCS}pay${fgRed}x$reset');
      expect(parser.insertAfter(2, 'X'), 'aa${DCS}pay${fgRed}Xx$reset');
    });

    test('a string standing first is passed over by an insertion after 0', () {
      final parser = Parser('${DCS}pay${ST}bb');

      expect(parser.insertBefore(0, 'X'), 'X${DCS}pay${ST}bb');
      expect(parser.insertAfter(0, 'X'), '${DCS}pay${ST}Xbb');
    });

    test('all four keep an insertion out of the body', () {
      for (final opener in [DCS, SOS, PM, APC]) {
        expect(
          Parser('aa${opener}pay${ST}bb').insertAfter(2, 'X'),
          'aa${opener}pay${ST}Xbb',
          reason: 'opener ${opener.ansiShowEscapeSequences()}',
        );
      }
    });

    test('no position falls inside a control string, so none is refused', () {
      final parser = Parser('aa${DCS}pay${ST}bb');

      for (var pos = 0; pos <= parser.length; pos++) {
        expect(() => parser.insertBefore(pos, 'X'), returnsNormally);
        expect(() => parser.insertAfter(pos, 'X'), returnsNormally);
      }
    });
  });

  // Showing a code is reading it out, and a reader that does not know a code
  // writes its bytes instead — which for these four means sending the very
  // sequence the caller asked to see. Expectations taken off `OSC` on the
  // same shapes, spaces and all.
  group('control strings, shown:', () {
    test('a string is shown as one code with a body', () {
      expect(
        'aa${DCS}pay${ST}bb'.ansiShowEscapeSequences(),
        'aa[DCS pay ST]bb',
      );
    });

    test('all four are named', () {
      expect('${SOS}x$ST'.ansiShowEscapeSequences(), '[SOS x ST]');
      expect('${PM}x$ST'.ansiShowEscapeSequences(), '[PM x ST]');
      expect('${APC}x$ST'.ansiShowEscapeSequences(), '[APC x ST]');
    });

    test('a string without its terminator shows none', () {
      expect('aa${DCS}pay'.ansiShowEscapeSequences(), 'aa[DCS pay ]');
    });

    test('an empty body is shown the way OSC shows one', () {
      expect('aa$DCS$ST'.ansiShowEscapeSequences(), 'aa[DCS  ST]');
    });

    test('the shown string carries no ESC of its own', () {
      // The point of the whole group: what is shown must be safe to print.
      for (final opener in [DCS, SOS, PM, APC]) {
        expect(
          'aa${opener}pay${ST}bb'.ansiShowEscapeSequences(),
          isNot(contains(ESC)),
          reason: 'opener ${opener.ansiShowEscapeSequences()}',
        );
      }
    });

    test('the parser names them the same way', () {
      expect(
        Parser('aa${DCS}pay${ST}bb').showControlFunctions(),
        'aa[DCS pay ST]bb',
      );
      expect(Parser('aa${DCS}pay').showControlFunctions(), 'aa[DCS pay ]');
    });

    test('the id of a control string is its name, not its bytes', () {
      expect(
        Parser('aa${DCS}pay${ST}bb').replaceAll((code) => '<${code.id}>'),
        'aa<DCS pay ST>bb',
      );
    });
  });

  group('control strings, the opener set:', () {
    test('the pattern and the dispatcher agree on which bytes open one', () {
      // The set is written twice and the copies cannot see each other:
      // `controlStringOpeners` feeds the pattern, and a `case` in
      // `EscapeCode._parse` spells the same bytes out again because a pattern
      // match cannot read them from a string. Widening one copy alone changes
      // no parse at all — the half that is left behind keeps the old reading —
      // so nothing but a test that walks the whole `ESC Fe` range notices.
      const csi = 0x5B; // [
      const osc = 0x5D; // ]
      final openers = controlStringOpeners.codeUnits.toSet();

      for (var byte = 0x40; byte <= 0x5F; byte++) {
        final entity = Parser('aa$ESC${String.fromCharCode(byte)}pay${ST}bb')
            .matches
            .elementAt(1)
            .entity;
        final reason = 'ESC ${String.fromCharCode(byte)} '
            '(0x${byte.toRadixString(16).toUpperCase()})';

        if (openers.contains(byte)) {
          expect(entity, isA<ControlString>(), reason: reason);
          expect(entity, isNot(isA<Osc>()), reason: reason);
        } else if (byte == osc) {
          expect(entity, isA<Osc>(), reason: reason);
        } else if (byte == csi) {
          expect(entity, isA<Csi>(), reason: reason);
        } else {
          expect(entity, isA<Esc>(), reason: reason);
        }
      }
    });

    test('the set is the four the standard puts beside the OSC', () {
      expect(controlStringOpeners.codeUnits, [0x50, 0x58, 0x5E, 0x5F]);
    });

    test('no pattern opens a match on anything but ESC', () {
      // Three more places live on this one assumption. The scanner looks for
      // a single byte — `string.indexOf(ESC)` — and applies the pattern only
      // where it finds one; the shortcuts in `has.dart` and `remove.dart`
      // refuse a string carrying no ESC before the pattern is reached at
      // all. Widen a pattern to some other opener and the parse does not
      // change, because the scanner never offers it the place — so nothing
      // but this notices, and the edit looks as though it did nothing.
      const patterns = {
        'csiPattern': csiPattern,
        'oscPattern': oscPattern,
        'escPattern': escPattern,
        'sgrPattern': sgrPattern,
        'controlStringPattern': controlStringPattern,
      };
      const bodies = ['31m', '[31m', ']0;t$ST', 'Ppay$ST', '7', '(B', '#8'];

      for (final MapEntry(key: name, value: pattern) in patterns.entries) {
        final re = RegExp(pattern);
        for (var byte = 0x00; byte <= 0xFF; byte++) {
          if (byte == 0x1B) {
            continue;
          }

          for (final body in bodies) {
            expect(
              re.matchAsPrefix('${String.fromCharCode(byte)}$body'),
              isNull,
              reason: '$name matched '
                  '0x${byte.toRadixString(16).toUpperCase()} + $body: the '
                  'scanner searches for ESC and will never offer it here',
            );
          }
        }
      }
    });

    test('every ESC Fe pair has a name, so the fallback stays out of reach',
        () {
      // `show_escape_codes.dart` writes an opener's bytes as they came where
      // it cannot name them. That arm is unreachable while every pair in the
      // range has a name — which is what this asks — and an opener taken
      // from outside the range would wake it.
      for (var byte = 0x40; byte <= 0x5F; byte++) {
        expect(
          ControlFunctionsC1.byCode('$ESC${String.fromCharCode(byte)}'),
          isNotNull,
          reason: 'ESC 0x${byte.toRadixString(16).toUpperCase()}',
        );
      }

      for (final unit in controlStringOpeners.codeUnits) {
        expect(
          ControlFunctionsC1.byCode('$ESC${String.fromCharCode(unit)}'),
          isNotNull,
          reason: 'opener 0x${unit.toRadixString(16).toUpperCase()}',
        );
      }
    });
  });
}
