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

  group('going from one state to another:', () {
    test('writes the difference and nothing besides', () {
      final transitions = <String, (Style, Style, String)>{
        'a second underline replaces the single one, it is not added to it': (
          style.underline,
          style.doublyUnderline,
          '\x1B[21m',
        ),
        'and back the same way': (
          style.doublyUnderline,
          style.underline,
          '\x1B[4m',
        ),
        'one blink replaces the other': (
          style.blink,
          style.blinkRapid,
          '\x1B[6m',
        ),
        'the circle replaces the frame': (
          style.frame,
          style.encircle,
          '\x1B[52m',
        ),
        'and the frame the circle': (
          style.encircle,
          style.frame,
          '\x1B[51m',
        ),
        'the text goes from raised to lowered in one code': (
          style.superscript,
          style.subscript,
          '\x1B[74m',
        ),
        'a property nothing carried before is simply put on': (
          Style.terminalColors,
          style.overline,
          '\x1B[53m',
        ),
        'a new colour of the underline is set over the old': (
          underlineColor(Color256.red),
          underlineColor(Color256.blue),
          '\x1B[58;5;4m',
        ),
        'and dropping it takes the code that drops it': (
          underlineColor(Color256.red),
          style.bold,
          '\x1B[59;1m',
        ),
        'what is taken off comes before what is put on': (
          style.inverse,
          style.invisible,
          '\x1B[27;8m',
        ),
      };

      for (final MapEntry(key: what, value: (from, to, expected))
          in transitions.entries) {
        expect(from.transitTo(to), expected, reason: what);
      }
    });

    test('and nothing at all where there is no difference', () {
      expect(style.bold.transitTo(style.bold), isEmpty);
      expect(Style.terminalColors.transitTo(Style.terminalColors), isEmpty);
      expect(
        style.bold.transitTo(const NoStyle()),
        isEmpty,
        reason: 'nothing is ever written to reach a NoStyle',
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
