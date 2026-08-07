import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The sequence that opens a link on [url], with no text and no close: what
/// `link` writes whole, taken apart.
String opens(String url) => '$linkOpen$url$linkTextOpen';

void main() {
  const url = 'http://u/';

  group('optimize over a hyperlink:', () {
    test('closes the link the string left open', () {
      final optimized = Parser('${opens(url)}abc').optimize();

      expect(optimized, '${opens(url)}abc$linkClose');
      expect(
        Parser(optimized).finalLink,
        isNull,
        reason: 'what is printed after it is not clickable',
      );
    });

    test('close: false leaves the link open, as it leaves the style', () {
      expect(
        Parser('${opens(url)}abc').optimize(close: false),
        '${opens(url)}abc',
      );
    });

    test('adds nothing when the string closed the link itself', () {
      final text = '${opens(url)}abc$linkClose';

      expect(Parser(text).optimize(), text);
    });

    test('writes no close where no link was ever open', () {
      expect(Parser('${bold}abc').optimize(), isNot(contains(linkClose)));
    });

    test('closes the link before it closes the style', () {
      expect(
        Parser('$bold${opens(url)}abc').optimize(),
        '$bold${opens(url)}abc$linkClose$reset',
      );
    });

    test('closes the link the string was seeded inside', () {
      final parser = Parser.debugInsideLink('abc', const Link(url));

      expect(parser.optimize(), 'abc$linkClose');
    });

    test('an opening whose terminator never came is closed all the same', () {
      // The opening runs to the end of the text, and the close written after
      // it begins with an ESC — which is where the opening ends anyway — so
      // the close is read as a close and not eaten into the url.
      const opening = '${OSC}8;;$url';
      final optimized = Parser(opening).optimize();

      expect(optimized, '$opening$linkClose');
      expect(Parser(optimized).finalLink, isNull);
      expect(
        Parser(optimized).showControlFunctions(),
        '[link($url)][linkClose]',
        reason: 'the url swallowed nothing',
      );
    });
  });
}
