import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a control byte in a url:', () {
    test('link percent-encodes it instead of letting it end the sequence', () {
      expect(
        link('https://example.com/a\x1B\\b', text: 'go'),
        '${OSC}8;;https://example.com/a%1B\\b$ST' 'go' '$linkClose',
      );
    });

    test('linkBel percent-encodes it too, BEL being its own terminator', () {
      expect(
        linkBel('https://example.com/a\x07b', text: 'go'),
        '${OSC}8;;https://example.com/a%07b$BEL' 'go' '${OSC}8;;$BEL',
      );
    });

    test('the whole payload stays inside the url and nothing escapes', () {
      // The bytes that opened this finding: a `ST` closes the sequence, and
      // everything behind it used to reach the terminal as live codes.
      const hostile = 'https://ok.example\x1B\\\x1B[2J\x1B[31mPWNED';
      final parser = Parser(link(hostile, text: 'click me'));

      expect(
        parser.matches.map((m) => m.entity.runtimeType.toString()).toList(),
        ['Link', 'Text', 'Link'],
        reason: 'an opening, the text and a close — no third code in between',
      );
      expect(parser.removeAll(), 'click me');
      expect(parser.finalLink, isNull);
    });

    test('a DEL is encoded as readily as an ESC', () {
      expect(
        link('https://example.com/\x7F', text: 't'),
        '$linkOpen' 'https://example.com/%7F' '$linkTextOpen' 't' '$linkClose',
      );
    });

    test('the text stands for the url encoded, not for the bytes given', () {
      // With no text of its own the url is what is shown, and showing the
      // bytes as they came would put the sequence back through the other
      // door.
      final parser = Parser(link('https://ok.example\x1B\\\x1B[2J'));

      expect(
        parser.matches.map((m) => m.entity.runtimeType.toString()).toList(),
        ['Link', 'Text', 'Link'],
      );
      expect(parser.removeAll(), r'https://ok.example%1B\%1B[2J');
    });
  });

  group('a url with nothing to encode is left alone:', () {
    const untouched = <String>[
      'https://example.com/a?b=1&c=2#frag',
      'https://example.com/already%20encoded',
      'https://example.com/path with spaces',
      'https://пример.рф/путь',
      'https://example.com/😀',
      "https://example.com/~a'b(c)*d!e",
      '',
    ];

    for (final (i, url) in untouched.indexed) {
      test('url #$i comes out byte for byte', () {
        expect(
          link(url, text: 't'),
          '$linkOpen$url$linkTextOpen' 't' '$linkClose',
        );
        expect(
          linkBel(url, text: 't'),
          '${OSC}8;;$url$BEL' 't' '${OSC}8;;$BEL',
        );
      });
    }

    test('an already-encoded url keeps its escapes, and the ESC gets one', () {
      // The reason the encoding is narrow rather than the `Uri.encodeFull`
      // the OSC 8 note asks for: that one escapes the `%` as well, so a url
      // that arrives encoded — the ordinary case — comes out `%2520`.
      expect(
        link('https://example.com/a%20b\x1Bc', text: 't'),
        '$linkOpen'
        'https://example.com/a%20b%1Bc'
        '$linkTextOpen'
        't'
        '$linkClose',
        reason: 'the % is left alone, so encoding twice is encoding once',
      );
    });
  });

  group('the text of a link is display text and is left as it came:', () {
    test('a styled text keeps its codes', () {
      // Styling the text of a link is what the codes are there for; stripping
      // them would take a working thing away.
      final parser = Parser(link('https://ok/', text: '${bold}click$reset'));

      expect(
        parser.showControlFunctions(),
        '[link(https://ok/)][bold]click[reset][linkClose]',
      );
    });

    test('and the link is closed whatever the text left open', () {
      for (final text in <String>[
        'a\x1B]0;title',
        'a\x1B',
        'safe\x1B]8;;https://evil\x1B\\now-evil',
      ]) {
        expect(
          Parser(link('https://ok/', text: text)).finalLink,
          isNull,
          reason: 'the close begins with an ESC and ends what text left open',
        );
      }
    });
  });

  group('Link, the entity:', () {
    test('an ordinary url is built as it always was', () {
      expect(
        const Link('https://example.com').string,
        '${OSC}8;;https://example.com$ST',
      );
      expect(const Link('').string, '${OSC}8;;$ST');
    });

    // A url carrying a control byte goes into `Link` unchecked, and the guard
    // that would catch it is still an open question: a `const` constructor
    // admits no function call and no `contains` in its assert, so the two
    // ways left are dropping `const` or saying so in the dartdoc. Whichever
    // is chosen wants its own test here.
  });
}
