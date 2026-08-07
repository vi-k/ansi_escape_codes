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
}
