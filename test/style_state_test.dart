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
