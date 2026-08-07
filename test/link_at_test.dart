import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The sequence that opens a link on [url], with no text and no close: what
/// `link` writes whole, taken apart.
String opens(String url) => '$linkOpen$url$linkTextOpen';

/// The same opening in the older form [linkBel] writes, closed by a `BEL`.
String opensBel(String url) => '$linkOpen$url$BEL';

/// The link each position of the plain text sits in, as a picture: a letter
/// per link, `-` where none is open.
String _picture(Parser parser, Map<String, String> names) {
  final buf = StringBuffer();
  for (var i = 0; i < parser.length; i++) {
    final url = parser.linkAt(i)?.url;
    buf.write(url == null ? '-' : names[url]);
  }

  return buf.toString();
}

void main() {
  group('linkAt answers for the position, not the piece after it:', () {
    const a = 'http://a/';
    const b = 'http://b/';
    const names = {a: 'A', b: 'B'};

    test('a link closed in the middle', () {
      final parser = Parser('ab${opens(a)}cd${linkClose}ef');

      expect(_picture(parser, names), '--AA--');
    });

    test('a link left open to the end', () {
      final parser = Parser('ab${opens(a)}cdef');

      expect(_picture(parser, names), '--AAAA');
    });

    test('a link superseded by another', () {
      final parser = Parser('ab${opens(a)}cd${opens(b)}ef');

      expect(_picture(parser, names), '--AABB');
    });

    test('a link opened the BEL way', () {
      final parser = Parser('ab${opensBel(a)}cd${linkClose}ef');

      expect(_picture(parser, names), '--AA--');
    });

    test('a close standing on its own', () {
      final parser = Parser('ab${linkClose}cdef');

      expect(_picture(parser, names), '------');
    });

    test('a link that opens at nought', () {
      final parser = Parser('${opens(a)}abcd${linkClose}ef');

      expect(_picture(parser, names), 'AAAA--');
    });

    test('the end of the text and past it, the way stateAt answers', () {
      final parser = Parser('ab${opens(a)}cd');

      expect(
        parser.linkAt(parser.length)?.url,
        a,
        reason: 'the position behind the text takes the final link',
      );
      expect(() => parser.linkAt(parser.length + 1), throwsRangeError);
      expect(() => parser.linkAt(-1), throwsRangeError);
      expect(
        parser.linkAt(0),
        isNull,
        reason: 'and the walk still answers after the refusal',
      );
    });

    test('an empty string has the one position and no link at it', () {
      expect(Parser('').linkAt(0), isNull);
    });

    test('reading only as far as it must is still true', () {
      final parser = Parser('${opens(a)}head$linkClose${'tail ' * 200}');

      expect(parser.linkAt(2)?.url, a);
      expect(
        parser.isParsed,
        isFalse,
        reason: 'the walk stops at the answer, link or no link',
      );
    });

    test('other questions in between leave the answers alone', () {
      final text = 'ab${opens(a)}cd${linkClose}ef';
      String? fresh(int pos) => Parser(text).linkAt(pos)?.url;
      final parser = Parser(text);

      expect(parser.linkAt(1)?.url, fresh(1));
      expect(parser.substring(3, maxLength: 1), isNotEmpty);
      expect(parser.linkAt(3)?.url, fresh(3));
      expect(parser.stateAt(4), Parser(text).stateAt(4));
      expect(parser.linkAt(4)?.url, fresh(4));
      expect(parser.linkAt(0)?.url, fresh(0));
    });
  });

  group('finalLink is what the string leaves open:', () {
    test('nothing, where the string closed it', () {
      expect(Parser('${opens('http://u/')}x$linkClose').finalLink, isNull);
    });

    test('the link, where it did not', () {
      expect(Parser('${opens('http://u/')}x').finalLink?.url, 'http://u/');
    });

    test('nothing, where the string closed one it inherited', () {
      final parser = Parser.debugInsideLink(
        'abc${linkClose}def',
        const Link('http://outer/'),
      );

      expect(parser.finalLink, isNull);
    });

    test('the inherited link, where the string never touched it', () {
      final parser = Parser.debugInsideLink('abc', const Link('http://u/'));

      expect(parser.finalLink?.url, 'http://u/');
    });
  });

  test('linkAt keeps its place the way stateAt does', () {
    final text = List.generate(
      50,
      (i) => 'line $i ${opens('http://$i/')}word$linkClose\n',
    ).join();
    final resumed = Parser(text);
    final answers = <String?>[];
    for (var i = 0; i < resumed.length; i += 7) {
      answers.add(resumed.linkAt(i)?.url);
    }

    final fresh = <String?>[];
    for (var i = 0; i < Parser(text).length; i += 7) {
      fresh.add(Parser(text).linkAt(i)?.url);
    }

    expect(answers, fresh);
  });
}
