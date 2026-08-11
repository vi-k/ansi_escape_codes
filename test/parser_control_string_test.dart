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
}
