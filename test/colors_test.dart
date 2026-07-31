import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/parsing.dart';
import 'package:test/test.dart';

void main() {
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
