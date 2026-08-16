import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('OSC:', () {
    test('a hyperlink keeps a url that carries a semicolon', () {
      const url = 'https://example.com/?a=1;b=2';
      final entity = Parser('$linkOpen$url$linkTextOpen text$linkClose')
          .pieces
          .first
          .entity;

      expect(entity, isA<OscLink>());
      expect((entity as OscLink).url, url);
    });

    test('linkBel writes the older form, closed by a BEL', () {
      expect(
        linkBel('https://example.com', text: 'go'),
        '${OSC}8;;https://example.com${BEL}go${OSC}8;;$BEL',
      );
      expect(
        linkBel('https://example.com'),
        '${OSC}8;;https://example.com$BEL'
        'https://example.com'
        '${OSC}8;;$BEL',
        reason: 'the url stands for its own text where none is given',
      );
      expect(
        Parser(linkBel('https://example.com', text: 'go')).removeAll(),
        'go',
      );
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

    test('an unterminated one is shown without a terminator named', () {
      expect('${OSC}0;title'.ansiShowEscapeSequences(), '[OSC 0;title]');
      expect(
        '${OSC}0;title$ST'.ansiShowEscapeSequences(),
        '[OSC 0;title ST]',
        reason: 'and the separator goes with the name rather than standing '
            'in front of the place one would have been',
      );
    });
  });
}
