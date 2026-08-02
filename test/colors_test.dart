import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a colour describes itself:', () {
    test('by the name it is written with, once it knows where it goes', () {
      expect(
        Color16.red.id,
        '?Red',
        reason: 'a colour on its own does not know what it is being set on',
      );
      expect(Color16.red.on(ColorTarget.foreground).id, 'fgRed');
      expect(
        Color256.gray5.on(ColorTarget.background).id,
        'bg256Gray5',
        reason: 'the 256 that says which table it comes from is its own',
      );
      expect(
        ColorRgb(1, 2, 3).on(ColorTarget.underline).id,
        'underlineRgb(1,2,3)',
      );
    });

    test('by the name of the constant that writes it, whoever set it', () {
      const red = Color256.red;

      expect(style.foreground(red).foregroundColor?.id, 'fg256Red');
      expect(style.background(red).backgroundColor?.id, 'bg256Red');
      expect(
        style.underlineColor(red).underlineColorValue?.id,
        'underline256Red',
        reason: 'the constant is underline256Red, not underlineColor256Red',
      );

      expect(
        Stack.terminalColors.foreground(red).foregroundColor?.id,
        'fg256Red',
        reason: 'and a stack names it the same as a style does',
      );
      expect(
        Stack.terminalColors.underlineColor(red).underlineColorValue?.id,
        'underline256Red',
      );
      expect(
        StackedParser(underline256(1)).finalState.underlineColorValue?.id,
        'underline256Red',
        reason: 'as does the state a parser ends in',
      );
    });

    test('and says which kind it is when printed', () {
      expect(Color16.red.toString(), 'Color16.red');
      expect(Color256.gray5.toString(), 'Color256.gray5');
      expect(ColorRgb(1, 2, 3).toString(), 'ColorRgb(1, 2, 3)');
    });

    test('two of the same colour are one to a Set', () {
      const sixteen = [Color16.red, Color16.red];
      const table = [Color256.gray5, Color256.gray5];
      final rgb = [ColorRgb(1, 2, 3), ColorRgb(1, 2, 3)];
      final different = [ColorRgb(1, 2, 3), ColorRgb(3, 2, 1)];

      expect(sixteen.toSet(), hasLength(1));
      expect(table.toSet(), hasLength(1));
      expect(rgb.toSet(), hasLength(1));
      expect(different.toSet(), hasLength(2));
    });
  });

  group('Colors:', () {
    test('order by their place in the palette', () {
      expect(Colors.red < Colors.blue, isTrue);
      expect(Colors.blue > Colors.red, isTrue);
      expect(Colors.red <= Colors.red, isTrue);
      expect(Colors.red >= Colors.red, isTrue);
    });

    test('sort, now that the ordering is one Dart knows about', () {
      final palette = [Colors.gray0, Colors.red, Colors.rgb555, Colors.black]
        ..sort();

      expect(palette, [
        Colors.black,
        Colors.red,
        Colors.rgb555,
        Colors.gray0,
      ]);
      expect(palette.reduce((a, b) => a < b ? a : b), Colors.black);
    });

    test('are found by their index, all of them', () {
      expect(Colors.byIndex(0), Colors.black);
      expect(Colors.byIndex(255), Colors.gray23);
      expect(Colors.byIndex(256), isNull);
      expect(Colors.byIndex(-1), isNull);
      expect(Colors.values, hasLength(256));
    });
  });

  group('Color256:', () {
    test('refuses a component outside the colour cube', () {
      expect(() => Color256.rgb(6, 0, 0), throwsA(isA<RangeError>()));
      expect(() => Color256.rgb(0, -1, 0), throwsA(isA<RangeError>()));
      expect(() => Color256.rgb(0, 0, 6), throwsA(isA<RangeError>()));
    });

    test('refuses a level outside the grayscale', () {
      expect(() => Color256.gray(24), throwsA(isA<RangeError>()));
      expect(() => Color256.gray(-1), throwsA(isA<RangeError>()));
    });

    test('maps the valid values onto the palette', () {
      expect(Color256.rgb(0, 0, 0).color, Colors.rgb000);
      expect(Color256.rgb(5, 5, 5).color, Colors.rgb555);
      expect(Color256.rgb(1, 2, 3).color, Colors.rgb123);
      expect(Color256.gray(0).color, Colors.gray0);
      expect(Color256.gray(23).color, Colors.gray23);
    });
  });
}
