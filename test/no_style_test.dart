import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('nothing to change answers itself:', () {
    test('a NoStyle stays a NoStyle through a pointless reset', () {
      const noStyle = NoStyle();

      expect(identical(noStyle.resetItalic, noStyle), isTrue);
      expect(identical(noStyle.resetBoldAndDim, noStyle), isTrue);
      expect(identical(noStyle.resetForeground, noStyle), isTrue);
      expect(
        noStyle.resetItalic('x'),
        'x',
        reason: 'still a NoStyle, so still writes nothing',
      );
    });

    test('a Style with nothing to change answers itself too', () {
      const style = Style(bold: true);

      expect(identical(style.bold, style), isTrue);
      expect(identical(style.resetItalic, style), isTrue);

      const red = Style(foreground: Color256.red);
      expect(identical(red.foreground(Color256.red), red), isTrue);
      expect(identical(red.resetBackground, red), isTrue);
    });

    test('a change still makes a new style', () {
      const noStyle = NoStyle();

      expect(noStyle.bold, isNot(same(noStyle)));
      expect(noStyle.bold.isBold, isTrue);
      expect(
        noStyle.bold,
        isNot(isA<NoStyle>()),
        reason: 'a NoStyle that sets something is no NoStyle',
      );
    });
  });

  group('a transition between equal surfaces is empty:', () {
    test('NoStyle to the terminal colours writes nothing', () {
      expect(const NoStyle().transitTo(Style.terminalColors), '');
    });

    test('a loaded style still resets', () {
      expect(
        Style.terminalColors.bold.transitTo(Style.terminalColors),
        '\x1B[0m',
      );
    });
  });
}
