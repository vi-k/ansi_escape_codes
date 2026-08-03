import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('taking the control codes out:', () {
    test('takes the C0 set and DEL, and leaves the text', () {
      expect('a\nb\tc'.ansiRemoveControlCodes(), 'abc');
      expect('a\x00b\x1Fc\x7Fd'.ansiRemoveControlCodes(), 'abcd');
      expect('плайн текст'.ansiRemoveControlCodes(), 'плайн текст');
      expect('𝄞'.ansiRemoveControlCodes(), '𝄞', reason: 'a surrogate pair');
    });

    test('answers ansiHasControlCodes afterwards', () {
      const text = 'a\nb\tc\x7Fd';

      expect(text.ansiHasControlCodes, isTrue);
      expect(text.ansiRemoveControlCodes().ansiHasControlCodes, isFalse);
    });

    test('a second time changes nothing', () {
      const text = 'a\nb\x07c';
      final once = text.ansiRemoveControlCodes();

      expect(once.ansiRemoveControlCodes(), once);
    });

    test('leaves the body of an escape code behind, ESC being a C0', () {
      expect(
        '${fgRed}text$reset'.ansiRemoveControlCodes(),
        '[31mtext[0m',
        reason: 'which is why the escape codes come out first',
      );
      expect(
        '${fgRed}text$reset'.ansiRemoveEscapeCodes().ansiRemoveControlCodes(),
        'text',
      );
    });

    test('and the eight-bit C1 controls are not C0', () {
      expect(
        'a\x9Bb'.ansiRemoveControlCodes(),
        'a\x9Bb',
        reason: 'the C0 set ends at 0x1F, and DEL is the one above it',
      );
    });
  });
}
