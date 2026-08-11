import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('inserting into a styled string:', () {
    test('the two sides of a seam are told apart', () {
      const text = '${fgRed}Hello$reset world';

      expect(
        Parser(text).insertBefore(5, '!'),
        '${fgRed}Hello!$reset world',
        reason: 'before the reset the exclamation mark is still red',
      );
      expect(
        Parser(text).insertAfter(5, '!'),
        '${fgRed}Hello$reset! world',
        reason: 'after the reset it is not',
      );
    });

    test('a seam without codes on it gives both the same place', () {
      const text = '${fgRed}Hello world$reset';

      expect(Parser(text).insertBefore(5, ','), '${fgRed}Hello, world$reset');
      expect(Parser(text).insertAfter(5, ','), '${fgRed}Hello, world$reset');
    });

    test('plain text is written as it is', () {
      const text = '${fgRed}Hello world$reset';

      expect(
        Parser(text).insertBefore(6, 'brave '),
        '${fgRed}Hello brave world$reset',
        reason: 'nothing is closed when nothing was opened',
      );
    });

    test('what the insertion opens is closed after it', () {
      const text = '${fgRed}Hello world$reset';

      expect(
        Parser(text).insertBefore(6, '${fgGreen}brave '),
        '${fgRed}Hello ${fgGreen}brave $fgRed'
        'world$reset',
        reason: 'the tail keeps the red it had',
      );
    });

    test('a hyperlink the insertion opens is closed after it', () {
      const link = '${linkOpen}https://example.com$linkTextOpen';

      expect(
        Parser('tail').insertBefore(0, '${link}inserted'),
        '${link}inserted$linkClose'
        'tail',
        reason: 'or the tail is clickable and points somewhere else',
      );
      expect(
        Parser('tail').insertBefore(0, '${link}inserted$linkClose'),
        '${link}inserted${linkClose}tail',
        reason: 'and one the insertion closed itself is not closed twice',
      );
    });

    test('a style and a hyperlink are both given back', () {
      const link = '${linkOpen}https://example.com$linkTextOpen';

      expect(
        Parser('tail').insertBefore(0, '$fgGreen${link}inserted'),
        '$fgGreen${link}inserted$linkClose$reset'
        'tail',
        reason: 'the link first, then the style around it',
      );
    });

    test('a reset inside the insertion does not reach the tail', () {
      const text = '${fgRed}Hello world$reset';

      expect(
        Parser(text).insertBefore(6, '${bold}brave$reset '),
        '${fgRed}Hello ${bold}brave$reset $fgRed'
        'world$reset',
      );
    });

    test('the ends of the string are seams too', () {
      const text = '${fgRed}Hello$reset';

      expect(Parser(text).insertBefore(0, '>'), '>${fgRed}Hello$reset');
      expect(Parser(text).insertAfter(0, '>'), '$fgRed>Hello$reset');
      expect(Parser(text).insertBefore(5, '<'), '${fgRed}Hello<$reset');
      expect(Parser(text).insertAfter(5, '<'), '${fgRed}Hello$reset<');
    });

    test('a position outside the string is refused', () {
      const text = '${fgRed}Hello$reset';

      expect(() => Parser(text).insertBefore(6, '!'), throwsRangeError);
      expect(() => Parser(text).insertAfter(6, '!'), throwsRangeError);
      expect(() => Parser(text).insertBefore(-1, '!'), throwsRangeError);
      expect(() => Parser(text).insertAfter(-1, '!'), throwsRangeError);
    });

    test('the stacked parser unwinds the insertion the same way', () {
      const text = '${fgRed}Hello world$reset';

      expect(
        StackedParser(text).insertBefore(6, '${fgGreen}brave '),
        '${fgRed}Hello ${fgGreen}brave $fgRed'
        'world$reset',
      );
    });

    test('the string shortcuts do the same', () {
      const text = '${fgRed}Hello$reset world';

      expect(text.ansiInsertBefore(5, '!'), '${fgRed}Hello!$reset world');
      expect(text.ansiInsertAfter(5, '!'), '${fgRed}Hello$reset! world');
    });
  });

  group('inserting where the string ends inside a sequence:', () {
    test('the text goes in front of what never finished', () {
      expect(
        Parser('aa\x1B]0;title').insertAfter(2, 'X'),
        'aaX\x1B]0;title',
        reason: 'the tail is copied as it came, the text lands before it',
      );
      expect(
        Parser('aa\x1B').insertAfter(2, 'X'),
        'aaX\x1B',
        reason: 'a bare ESC cannot be finished, so nothing is written for it',
      );
      expect(Parser('aa\x1B[').insertAfter(2, 'X'), 'aaX\x1B[');
      expect(
        Parser('aa\x1B(').insertAfter(2, 'X'),
        'aaX\x1B(',
        reason: 'an ESC waiting for a final byte takes the insertion no more '
            'than a CSI does',
      );
    });

    test('and the hyperlink opening keeps the text outside it', () {
      final inserted = Parser('aa\x1B]8;;http://a/').insertAfter(2, 'X');

      expect(inserted, 'aaX\x1B]8;;http://a/');
      expect(
        Parser(inserted).linkAt(2),
        isNull,
        reason: 'the opening still stands after the text, not around it',
      );
    });

    test('while a finished tail is still passed by', () {
      expect(
        Parser('aa\x1B]0;t\x1B\\').insertAfter(2, 'X'),
        'aa\x1B]0;t\x1B\\X',
        reason: 'a terminated OSC ends where it says, and insertAfter goes '
            'past it as it always did',
      );
    });
  });
}
