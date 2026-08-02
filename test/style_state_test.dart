import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('NoStyle:', () {
    test('is not the same as the colours of the terminal', () {
      expect(const NoStyle(), isNot(Style.terminalColors));
      expect(Style.terminalColors, isNot(const NoStyle()));
      expect({const NoStyle(), Style.terminalColors}, hasLength(2));
    });

    test('wraps text in nothing at all', () {
      const style = NoStyle();

      expect(style.open, isEmpty);
      expect(style.close, isEmpty);
      expect(style('text'), 'text');
    });
  });

  group('the colours a style is chained with:', () {
    test('stand for the same colours the table names', () {
      expect(style.black.foregroundColor, Color256.black);
      expect(style.highWhite.foregroundColor, Color256.highWhite);
      expect(style.rgb000.foregroundColor, Color256.rgb000);
      expect(style.rgb555.foregroundColor, Color256.rgb555);
      expect(style.gray0.foregroundColor, Color256.gray0);
      expect(style.gray23.foregroundColor, Color256.gray23);
    });

    test('put the bg ones behind the text and nowhere else', () {
      expect(style.bgBlack.backgroundColor, Color256.black);
      expect(style.bgRgb531.backgroundColor, Color256.rgb531);
      expect(style.bgGray23.backgroundColor, Color256.gray23);
      expect(style.bgHighRed.foregroundColor, isNull);
    });

    test('chain onto whatever they are asked of', () {
      final both = red.bold.bgGray5;

      expect(both.foregroundColor, Color256.red);
      expect(both.backgroundColor, Color256.gray5);
      expect(both.isBold, isTrue);
    });

    test('and the three functions take a Color of any kind', () {
      expect(foreground(Color16.red).foregroundColor, Color16.red);
      expect(background(ColorRgb(1, 2, 3)).backgroundColor, ColorRgb(1, 2, 3));
      expect(
        underlineColor(Color256.gray5).underlineColorValue,
        Color256.gray5,
      );
    });
  });

  group('the terminal colours:', () {
    test('compare equal whichever state holds them', () {
      expect(Stack.terminalColors, Style.terminalColors);
      expect(Style.terminalColors, Stack.terminalColors);
    });

    test('mean a string is closed', () {
      expect(Parser('${fgRed}text$reset').isClosed, isTrue);
      expect(StackedParser('${fgRed}text$reset').isClosed, isTrue);
      expect(Parser('${fgRed}text').isClosed, isFalse);
    });
  });
}
