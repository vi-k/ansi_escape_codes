import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('the underline sub-parameter:', () {
    test('0 through 5 keep their exact semantic kind', () {
      const expected = <int, UnderlineStyle?>{
        0: null,
        1: UnderlineStyle.singly,
        2: UnderlineStyle.doubly,
        3: UnderlineStyle.curly,
        4: UnderlineStyle.dotted,
        5: UnderlineStyle.dashed,
      };

      for (final MapEntry(key: parameter, value: style) in expected.entries) {
        final parser = Parser('\x1B[4:${parameter}m');
        final function = (parser.pieces.single.entity as Sgr).functions.single;

        expect(function, isA<SgrUnderlineFunction>(), reason: '4:$parameter');
        expect(
          (function as SgrUnderlineFunction).style,
          style,
          reason: '4:$parameter',
        );
        expect(parser.finalState.underlineStyle, style, reason: '4:$parameter');
      }
    });

    test('a kind beyond 5 stays unknown and does not change state', () {
      final parser = Parser('\x1B[4:3m\x1B[4:6m');
      final function = (parser.pieces.last.entity as Sgr).functions.single;

      expect(function, isA<SgrUnknownParamsFunction>());
      expect(
        (function as SgrUnknownParamsFunction).numbers,
        [4, 6],
      );
      expect(parser.finalState.underlineStyle, UnderlineStyle.curly);
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

    test('a value out of range is refused in either form', () {
      const outOfRange = [
        '\x1B[38;5;256m', // no such entry in the palette
        '\x1B[38:5:256m',
        '\x1B[38;2;0;128;256m', // no such component
        '\x1B[38:2:0:128:256m',
        '\x1B[38;2;0;128m', // a component short
        '\x1B[38:2:0:128m',
      ];

      for (final text in outOfRange) {
        expect(Parser(text).finalState.foregroundColor, isNull, reason: text);
      }
    });

    test('leaves the functions around it alone', () {
      final state = Parser('\x1B[1;4:0;3m').finalState;

      expect(state.isBold, isTrue);
      expect(state.isItalic, isTrue);
      expect(state.isUnderline, isFalse);
    });
  });

  group('what the parser cannot name, it keeps:', () {
    String describe(String text) => Parser(text).pieces.first.entity.toString();

    test('sub-parameters that name no function are kept as they were', () {
      expect(describe('\x1B[99:1m'), 'Sgr(99:1)');
    });

    test('a colour out of the table keeps the number it was given', () {
      expect(describe('\x1B[38;5;999m'), 'Sgr(fg256?999)');
      expect(
        describe('\x1B[38:5:999m'),
        'Sgr(fg256?999)',
        reason: 'whichever way it was written',
      );
    });

    test('a colour space nothing knows keeps its parameters', () {
      expect(
        describe('\x1B[38;7;1m'),
        'Sgr(fg?7,bold)',
        reason: 'and the 1 after it is still read as bold',
      );
    });
  });
}
