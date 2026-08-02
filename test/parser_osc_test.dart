import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('OSC:', () {
    test('a hyperlink keeps a url that carries a semicolon', () {
      const url = 'https://example.com/?a=1;b=2';
      final entity = Parser('$linkOpen$url$linkTextOpen text$linkClose')
          .matches
          .first
          .entity;

      expect(entity, isA<Link>());
      expect((entity as Link).url, url);
    });

    test('an unterminated one does not spill into the text', () {
      expect(
        Parser('before${OSC}8;;https://example.com').removeAll(),
        'before',
      );
    });

    test('an unterminated one ends where the next sequence starts', () {
      expect(Parser('${OSC}0;title${fgRed}x$reset').removeAll(), 'x');
    });

    test('an unterminated one can still be shown', () {
      expect(
        () => '${OSC}0;title'.ansiShowEscapeSequences(),
        returnsNormally,
      );
    });
  });
}
