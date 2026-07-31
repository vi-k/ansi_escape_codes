import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('the underline sub-parameter:', () {
    test('0 turns the underline off', () {
      final state = Parser('$underline\x1B[4:0m').finalState;

      expect(state.isUnderline, isFalse);
      expect(state.isDoublyUnderline, isFalse);
    });

    test('2 is a double underline', () {
      final state = Parser('\x1B[4:2m').finalState;

      expect(state.isDoublyUnderline, isTrue);
      expect(state.isUnderline, isFalse);
    });

    test('1 and the decorated kinds are an underline', () {
      for (final style in [1, 3, 4, 5]) {
        expect(
          Parser('\x1B[4:${style}m').finalState.isUnderline,
          isTrue,
          reason: '4:$style',
        );
      }
    });

    test('an empty sub-parameter stands for the default value', () {
      // The ITU-T T.416 form, with the colour space id left out. libvte and
      // others write colours this way.
      expect(
        Parser('\x1B[38:2::1:2:3m').finalState.foregroundColor,
        ColorRgb(1, 2, 3),
      );

      // ... and the rest of the sequence survives it.
      expect(Parser('\x1B[1;38:2::1:2:3m').finalState.isBold, isTrue);
    });

    test('an RGB colour does not swallow what follows it', () {
      final state = Parser('\x1B[38;2;1;2;3;1m').finalState;

      expect(state.foregroundColor, ColorRgb(1, 2, 3));
      expect(state.isBold, isTrue);

      // The 256-colour form has always kept the tail; the two agree now.
      expect(Parser('\x1B[38;5;1;1m').finalState.isBold, isTrue);
    });

    test('a colour with no valid kind gives up only itself', () {
      final state = Parser('\x1B[38;9;1;4m').finalState;

      expect(state.foregroundColor, isNull);
      expect(state.isBold, isTrue);
      expect(state.isUnderline, isTrue);
    });

    test('a colour cut short gives up only itself', () {
      // The kind is there, the colour it needs is not.
      expect(Parser('\x1B[38;5m').finalState.foregroundColor, isNull);

      // The introducer with nothing at all after it, so nothing to give up.
      expect(Parser('\x1B[1;38m').finalState.isBold, isTrue);
    });

    test('the valid colour forms still read', () {
      expect(
        Parser('\x1B[38;5;1m').finalState.foregroundColor,
        Color256.red,
      );
      expect(
        Parser('\x1B[38;2;1;2;3m').finalState.foregroundColor,
        ColorRgb(1, 2, 3),
      );
      expect(
        Parser('\x1B[48;5;1m').finalState.backgroundColor,
        Color256.red,
      );
    });

    test('leaves the functions around it alone', () {
      final state = Parser('\x1B[1;4:0;3m').finalState;

      expect(state.isBold, isTrue);
      expect(state.isItalic, isTrue);
      expect(state.isUnderline, isFalse);
    });
  });
}
