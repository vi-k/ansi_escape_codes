import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The sequence that opens a link on [url], with no text and no close: what
/// `link` writes whole, taken apart.
String opens(String url) => '$linkOpen$url$linkTextOpen';

void main() {
  group('a match says which link it stands in:', () {
    test('the text inside a link carries it, the text after does not', () {
      final parser = Parser('a${opens('http://u/')}in${linkClose}out');
      final links = [for (final m in parser.matches) m.link?.url];

      expect(links, [null, 'http://u/', 'http://u/', null, null]);
    });

    test('an opening supersedes the one before it', () {
      final parser = Parser('${opens('http://a/')}x${opens('http://b/')}y');
      final urls = [
        for (final m in parser.matches)
          if (m.entity is Text) m.link?.url,
      ];

      expect(urls, ['http://a/', 'http://b/']);
    });

    test('a link left open runs to the end', () {
      final parser = Parser('${opens('http://u/')}tail');

      expect(parser.matches.last.link?.url, 'http://u/');
    });

    test('a close with nothing open leaves nothing open', () {
      final parser = Parser('${linkClose}x');

      expect(parser.matches.last.link, isNull);
    });

    test('the same answers come back from the cache', () {
      final parser = Parser('a${opens('http://u/')}b${linkClose}c');
      final first = [for (final m in parser.matches) m.link?.url];
      final second = [for (final m in parser.matches) m.link?.url];

      expect(second, first);
    });
  });

  group('a string told a link was open before it:', () {
    test('a close ends the link the string inherited', () {
      final parser = Parser.debugInsideLink(
        'abc${linkClose}def',
        const Link('http://outer/'),
      );
      final links = [for (final m in parser.matches) m.link?.url];

      expect(links, ['http://outer/', null, null]);
      expect(
        [for (final m in parser.matches) m.link?.url],
        links,
        reason: 'the seeded walk answers the same from the cache',
      );
    });

    test('a string that touches no link carries the seed to the end', () {
      final parser = Parser.debugInsideLink('abc', const Link('http://u/'));

      expect(parser.matches.last.link?.url, 'http://u/');
    });
  });

  group('the cursor pair carries the link along with the style:', () {
    test('what was open at the save is open again after the restore', () {
      final parser = Parser(
        '${opens('http://u/')}a${saveCursor}b$linkClose'
        'c${restoreCursor}d',
      );

      expect(parser.linkAt(2), isNull, reason: 'the close ends the link');
      expect(parser.linkAt(parser.length - 1)?.url, 'http://u/');
    });

    test('and the style goes on coming back with it', () {
      final parser = Parser(
        '$fgRed${opens('http://u/')}$saveCursor'
        '$fgBlue${linkClose}x$restoreCursor',
      );

      expect(parser.finalState.foregroundColor, Color16.red);
      expect(parser.finalLink?.url, 'http://u/');
    });

    test('a save outside a link takes the outside back in', () {
      final parser = Parser(
        'a$saveCursor${opens('http://u/')}b${restoreCursor}c',
      );

      expect(parser.linkAt(1)?.url, 'http://u/');
      expect(parser.linkAt(2), isNull, reason: 'nothing was open at the save');
    });

    test('a restore with nothing saved goes back to the beginning', () {
      final parser = Parser('${opens('http://u/')}a${restoreCursor}b');

      expect(parser.linkAt(0)?.url, 'http://u/');
      expect(parser.linkAt(1), isNull);
    });

    test('and the beginning of a seeded string is the seed', () {
      final parser = Parser.debugInsideLink(
        '${opens('http://u/')}a${restoreCursor}b',
        const Link('http://outer/'),
      );

      expect(parser.linkAt(1)?.url, 'http://outer/');
    });

    test('a string read in two goes remembers the link across the pause', () {
      final parser = Parser(
        '${opens('http://u/')}$saveCursor'
        'text$linkClose$restoreCursor',
      );

      expect(parser.linkAt(1)?.url, 'http://u/');
      expect(parser.isParsed, isFalse, reason: 'stopping short of the restore');
      expect(
        parser.finalLink?.url,
        'http://u/',
        reason: 'reading on still knows what was open before the pause',
      );
    });

    test('the second walk over the cache answers as the first one did', () {
      final input = '${opens('http://u/')}a${saveCursor}b$linkClose'
          'c${restoreCursor}d';
      final first = [for (final m in Parser(input).matches) m.link?.url];

      final parser = Parser(input);
      final stopped = parser.matches.iterator;
      while (stopped.moveNext()) {
        if (stopped.current.entity is SaveCursor) {
          break;
        }
      }

      expect(parser.isParsed, isFalse, reason: 'the walk stopped at the save');
      expect([for (final m in parser.matches) m.link?.url], first);
    });
  });
}
