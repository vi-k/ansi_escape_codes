import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('optimize keeps the codes that carry no style:', () {
    test('cursor movement', () {
      const text = '${bold}a$cursorRight b$resetBoldAndDim';

      expect(Parser(text).optimize(), contains(cursorRight));
    });

    test('a hyperlink', () {
      final text = '${link('https://example.com', text: 'site')} and more';
      final optimized = Parser(text).optimize();

      expect(optimized, contains(linkOpen));
      expect(optimized, contains('https://example.com'));
      expect(optimized, contains(linkClose));
      expect(Parser(optimized).length, Parser(text).length);
    });

    test('saving and restoring the cursor', () {
      const text = '$saveCursor${bold}a$resetBoldAndDim$restoreCursor';
      final optimized = Parser(text).optimize();

      expect(optimized, contains(saveCursor));
      expect(optimized, contains(restoreCursor));
    });

    test('but still folds the styles together', () {
      const text = '$fgWhite$bold$resetBoldAndDim$fgGreen$dim'
          '${cursorRight}text$resetBoldAndDim$resetFg';

      expect(
        Parser(Parser(text).optimize()).showControlFunctions(),
        '[fgGreen;dim][CSI CUF]text[reset]',
      );
    });
  });

  group('substring keeps the codes that carry no style:', () {
    test('a hyperlink inside the range', () {
      final text = 'head ${link('https://example.com', text: 'site')} tail';
      final part = Parser(text).substring(5, maxLength: 4); // 'site'

      expect(part, contains('https://example.com'));
      expect(Parser(part).removeAll(), 'site');
    });
  });
}
