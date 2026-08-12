import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  // These pass on the day they are written, and that is what they are for.
  // The package reads decoded Dart strings, not byte streams, and in one of
  // those a lone U+009B is far likelier to be a character than a CSI — so
  // not recognizing the eight-bit C1 as openers is a position, not an
  // oversight. Prose cannot hold it: the next reader meets "the package does
  // not recognize the eight-bit C1", takes it for a defect and fixes it.
  // These tests are what a fix would have to argue with.
  //
  // The class of openers is written down twice — the alternatives of
  // `escapeCodesRe` and the `indexOf(ESC)` scan in `ParserIterator` that
  // decides where the regex is even applied — so widening the pattern alone
  // moves nothing here.
  group('the eight-bit C1 open nothing:', () {
    test('an eight-bit CSI stays text, and the length counts it', () {
      final parser = Parser('aa\u{9B}31mbb');

      expect(parser.matches.map((m) => m.entity.runtimeType).toList(), [Text]);
      expect(parser.removeAll(), 'aa\u{9B}31mbb');
      expect(parser.length, 8);
    });

    test('the other eight-bit openers stay text too', () {
      for (final byte in [0x9D, 0x90, 0x98, 0x9E, 0x9F]) {
        final opener = String.fromCharCode(byte);
        final input = 'aa${opener}pay\u{9C}bb';
        final parser = Parser(input);

        expect(
          parser.matches.map((m) => m.entity.runtimeType).toList(),
          [Text],
          reason: 'byte 0x${byte.toRadixString(16)}',
        );
        expect(parser.removeAll(), input);
      }
    });

    test(
      'a seven-bit opener is not closed by an eight-bit ST, as in a '
      'UTF-8 terminal',
      () {
        expect(Parser('aa\x1B]0;t\u{9C}bb').removeAll(), 'aa');
      },
    );

    test('the seven-bit forms are read as they always were', () {
      expect(Parser('aa\x1B[31mbb').removeAll(), 'aabb');
      expect(Parser('aa\x1B]0;t\x1B\\bb').removeAll(), 'aabb');
    });
  });
}
