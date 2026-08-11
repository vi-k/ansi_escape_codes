import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
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
}
