import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('the string methods of the parser:', () {
    // 'Hello world' once the codes are taken out of it.
    const text = '${fgRed}Hello$reset world';

    test('look for the pattern where the codes are not', () {
      final parser = Parser(text);

      expect(parser.indexOf('Hello'), 0);
      expect(parser.indexOf('world'), 6);
      expect(parser.lastIndexOf('o'), 7);
      expect(parser.contains('Hello world'), isTrue);
      expect(parser.startsWith('Hello'), isTrue);
      expect(parser.endsWith('world'), isTrue);
    });

    test('do not find the codes themselves', () {
      final parser = Parser(text);

      expect(parser.contains('\x1B'), isFalse);
      expect(parser.indexOf('31'), -1);
      expect(parser.startsWith('\x1B['), isFalse);
    });

    test('count the same as the length does', () {
      expect(
        Parser(text).indexOf('world') + 'world'.length,
        Parser(text).length,
      );
    });
  });

  group('padding a string with codes in it:', () {
    const level = '${fgRed}SEVERE$reset';

    test('goes by the width the text is seen at', () {
      expect(level.length, 15, reason: 'the codes are counted by String');
      expect(Parser(level).length, 6, reason: 'and not by Parser');

      expect(Parser(level).padRight(10), '$level    ');
      expect(Parser(level).padLeft(10), '    $level');
    });

    test('leaves a string that is wide enough alone', () {
      expect(Parser(level).padRight(6), level);
      expect(Parser(level).padLeft(3), level);
    });

    test('overshoots on a padding of several characters, as String does', () {
      // Dart pads by repeating the padding once per character still wanted,
      // which puts two characters where one was asked for. Parser follows it
      // rather than inventing a second rule.
      expect(Parser('ab').padRight(6, '--'), 'ab--------');
      expect('ab'.padRight(6, '--'), 'ab--------');
    });
  });

  group('replacing what the parser reads:', () {
    const text = '${fgRed}Hello$reset world';

    test('hands every escape code to the function', () {
      expect(
        Parser(text).replaceAll((e) => '<${e.id}>'),
        '<fgRed>Hello<reset> world',
      );
    });

    test('leaves the text alone unless asked otherwise', () {
      expect(Parser(text).replaceAll((e) => ''), 'Hello world');
      expect(
        Parser(text).replaceAll(
          (e) => '',
          replacePlainText: (t) => t.string.toUpperCase(),
        ),
        'HELLO WORLD',
      );
    });
  });
}
