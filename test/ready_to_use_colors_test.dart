import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('the index of a colour in the 256-colour table:', () {
    test('is counted off the cube the table keeps at 16', () {
      // 16 + 36r + 6g + b, the 6x6x6 cube of ITU-T T.416.
      expect(rgb(0, 0, 0), 16, reason: 'the first colour of the cube');
      expect(rgb(0, 0, 1), 17);
      expect(rgb(0, 1, 0), 22);
      expect(rgb(1, 0, 0), 52);
      expect(rgb(2, 3, 4), 110);
      expect(rgb(5, 5, 5), 231, reason: 'the last colour of the cube');
    });

    test('takes six levels of each and no more', () {
      expect(() => rgb(6, 0, 0), throwsA(isA<IndexError>()));
      expect(() => rgb(0, 6, 0), throwsA(isA<IndexError>()));
      expect(() => rgb(0, 0, 6), throwsA(isA<IndexError>()));
      expect(() => rgb(-1, 0, 0), throwsA(isA<IndexError>()));
    });

    test('is counted off 232 for the greys', () {
      expect(gray(0), 232, reason: 'the darkest grey');
      expect(gray(23), 255, reason: 'the lightest grey');
    });

    test('takes twenty-four greys and no more', () {
      expect(() => gray(24), throwsA(isA<IndexError>()));
      expect(() => gray(-1), throwsA(isA<IndexError>()));
    });
  });

  group('setting a colour from the 256-colour table:', () {
    test('writes the sequence the table is read by', () {
      expect(fg256(196), '\x1B[38;5;196m');
      expect(bg256(0), '\x1B[48;5;0m');
      expect(underline256(255), '\x1B[58;5;255m');
    });

    test('takes an index the table has', () {
      expect(() => fg256(256), throwsA(isA<IndexError>()));
      expect(() => bg256(256), throwsA(isA<IndexError>()));
      expect(() => underline256(256), throwsA(isA<IndexError>()));
      expect(() => fg256(-1), throwsA(isA<IndexError>()));
    });

    test('and the parser reads it back', () {
      expect(
        Parser(fg256(rgb(5, 0, 0))).finalState.foregroundColor,
        Color256.rgb(5, 0, 0),
        reason: 'the far red corner of the cube',
      );
      expect(
        Parser(bg256(gray(0))).finalState.backgroundColor,
        Color256.gray(0),
      );
    });
  });

  group('setting a colour by its RGB:', () {
    test('writes the sequence the colour is read by', () {
      expect(fgRgb(1, 2, 3), '\x1B[38;2;1;2;3m');
      expect(bgRgb(0, 0, 0), '\x1B[48;2;0;0;0m');
      expect(underlineRgb(255, 0, 0), '\x1B[58;2;255;0;0m');
    });

    test('takes a byte for each of the three', () {
      expect(() => fgRgb(256, 0, 0), throwsA(isA<IndexError>()));
      expect(() => bgRgb(0, 256, 0), throwsA(isA<IndexError>()));
      expect(() => underlineRgb(0, 0, 256), throwsA(isA<IndexError>()));
      expect(() => underlineRgb(-1, 0, 0), throwsA(isA<IndexError>()));
    });

    test('and the parser reads it back', () {
      expect(
        Parser(fgRgb(1, 2, 3)).finalState.foregroundColor,
        ColorRgb(1, 2, 3),
      );
    });
  });
}
