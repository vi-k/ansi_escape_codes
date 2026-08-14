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
      expect(Styles.black.foregroundColor, Color256.black);
      expect(Styles.highWhite.foregroundColor, Color256.highWhite);
      expect(Styles.rgb000.foregroundColor, Color256.rgb000);
      expect(Styles.rgb555.foregroundColor, Color256.rgb555);
      expect(Styles.gray0.foregroundColor, Color256.gray0);
      expect(Styles.gray23.foregroundColor, Color256.gray23);
    });

    test('put the bg ones behind the text and nowhere else', () {
      expect(Styles.bgBlack.backgroundColor, Color256.black);
      expect(Styles.bgRgb531.backgroundColor, Color256.rgb531);
      expect(Styles.bgGray23.backgroundColor, Color256.gray23);
      expect(Styles.bgHighRed.foregroundColor, isNull);
    });

    test('chain onto whatever they are asked of', () {
      final both = Styles.red.bold.bgGray5;

      expect(both.foregroundColor, Color256.red);
      expect(both.backgroundColor, Color256.gray5);
      expect(both.isBold, isTrue);
    });

    test('the underline has constants of its own', () {
      expect(Styles.underlineRed.underlineColorValue, Color256.red);
      expect(Styles.underlineGray12.underlineColorValue, Color256.gray12);
      expect(Styles.underlineRgb531.foregroundColor, isNull);
    });

    test('and the constructor takes a Color of any kind', () {
      expect(const Style(foreground: Color16.red).foregroundColor, Color16.red);
      expect(
        Style(background: ColorRgb(1, 2, 3)).backgroundColor,
        ColorRgb(1, 2, 3),
      );
      expect(
        const Style(underlineColor: Color256.gray5).underlineColorValue,
        Color256.gray5,
      );
    });
  });

  group('going from one state to another:', () {
    test('writes the difference and nothing besides', () {
      final transitions = <String, (Style, Style, String)>{
        'a second underline replaces the single one, it is not added to it': (
          Styles.underline,
          Styles.doublyUnderline,
          '\x1B[21m',
        ),
        'and back the same way': (
          Styles.doublyUnderline,
          Styles.underline,
          '\x1B[4m',
        ),
        'a curly underline replaces the single one': (
          Styles.underline,
          Styles.curlyUnderline,
          '\x1B[4:3m',
        ),
        'a dotted underline replaces the curly one': (
          Styles.curlyUnderline,
          Styles.dottedUnderline,
          '\x1B[4:4m',
        ),
        'a dashed underline replaces the dotted one': (
          Styles.dottedUnderline,
          Styles.dashedUnderline,
          '\x1B[4:5m',
        ),
        'one blink replaces the other': (
          Styles.blink,
          Styles.blinkRapid,
          '\x1B[6m',
        ),
        'the circle replaces the frame': (
          Styles.frame,
          Styles.encircle,
          '\x1B[52m',
        ),
        'and the frame the circle': (
          Styles.encircle,
          Styles.frame,
          '\x1B[51m',
        ),
        'the text goes from raised to lowered in one code': (
          Styles.superscript,
          Styles.subscript,
          '\x1B[74m',
        ),
        'a property nothing carried before is simply put on': (
          Style.terminalColors,
          Styles.overline,
          '\x1B[53m',
        ),
        'a new colour of the underline is set over the old': (
          Styles.underlineRed,
          Styles.underlineBlue,
          '\x1B[58;5;4m',
        ),
        'and dropping it takes the code that drops it': (
          Styles.underlineRed,
          Styles.bold,
          '\x1B[59;1m',
        ),
        'what is taken off comes before what is put on': (
          Styles.inverse,
          Styles.invisible,
          '\x1B[27;8m',
        ),
      };

      for (final MapEntry(key: what, value: (from, to, expected))
          in transitions.entries) {
        expect(from.transitTo(to), expected, reason: what);
      }
    });

    test('and nothing at all where there is no difference', () {
      expect(Styles.bold.transitTo(Styles.bold), isEmpty);
      expect(Style.terminalColors.transitTo(Style.terminalColors), isEmpty);
      expect(
        Styles.bold.transitTo(const NoStyle()),
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
