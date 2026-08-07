import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The sequence that opens a link on [url], with no text and no close: what
/// `link` writes whole, taken apart.
String opens(String url) => '$linkOpen$url$linkTextOpen';

void main() {
  const outer = 'http://outer/';
  const inner = 'http://inner/';

  group('an insertion gives the link back:', () {
    test('text inserted inside a link stays inside it', () {
      final parser = Parser('${opens(outer)}abcd$linkClose');
      final result = parser.insertBefore(2, 'X');

      expect(result, '${opens(outer)}abXcd$linkClose');
      expect(Parser(result).linkAt(2)?.url, outer);
      expect(
        Parser(result).linkAt(3)?.url,
        outer,
        reason: 'the text after the insertion is clickable as it was',
      );
    });

    test('an insertion with its own link reopens the outer one', () {
      final parser = Parser('${opens(outer)}abcd$linkClose');
      final result = parser.insertBefore(2, '${opens(inner)}X$linkClose');

      expect(
        result,
        '${opens(outer)}ab'
        '${opens(inner)}X$linkClose'
        '${opens(outer)}cd$linkClose',
      );
      expect(Parser(result).linkAt(2)?.url, inner);
      expect(Parser(result).linkAt(3)?.url, outer);
    });

    test('an insertion that leaves its link open is cut off all the same', () {
      final parser = Parser('${opens(outer)}abcd$linkClose');
      final result = parser.insertBefore(2, '${opens(inner)}X');

      expect(
        result,
        '${opens(outer)}ab${opens(inner)}X${opens(outer)}cd$linkClose',
        reason: 'an opening supersedes, so no close is wanted in front of it',
      );
      expect(Parser(result).linkAt(3)?.url, outer);
    });

    test('the outer link is given back in the bytes it was opened with', () {
      const opening = '${OSC}8;id=7;$outer$ST';
      final parser = Parser('${opening}abcd$linkClose');

      expect(
        parser.insertBefore(2, '${opens(inner)}X$linkClose'),
        '${opening}ab${opens(inner)}X$linkClose${opening}cd$linkClose',
        reason: 'the parameters of the opening ride along',
      );
    });

    test('the link is given back first, and the style around it', () {
      final parser = Parser('${opens(outer)}abcd$linkClose');

      expect(
        parser.insertBefore(2, '$fgGreen${opens(inner)}X'),
        '${opens(outer)}ab'
        '$fgGreen${opens(inner)}X'
        '${opens(outer)}$reset'
        'cd$linkClose',
      );
    });

    test('an insertion that ends inside the same link is left alone', () {
      final parser = Parser('${opens(outer)}abcd$linkClose');

      expect(
        parser.insertBefore(2, '${opens(outer)}X'),
        '${opens(outer)}ab${opens(outer)}Xcd$linkClose',
        reason: 'the tail is inside the link it was inside already, and '
            'nothing has to be said twice',
      );
    });

    test('a string that begins inside a link gives that one back', () {
      final parser = Parser.debugInsideLink('abcd', const Link(outer));

      expect(
        parser.insertBefore(0, '${opens(inner)}X$linkClose'),
        '${opens(inner)}X$linkClose${opens(outer)}abcd',
        reason: 'the seam at nought stands in the link the string was '
            'read as starting inside',
      );
    });

    test('an opening whose terminator never came is given one back', () {
      // `OSC 8 ; ; url` with nothing to end it runs to the next ESC — here
      // the one of the fgRed — and the input is read that way on purpose.
      // Written again in front of the tail, those same bytes would eat it.
      const opening = '${OSC}8;;$outer';
      final parser = Parser('$opening${fgRed}abcd$linkClose');
      final result = parser.insertBefore(2, '${linkClose}X');

      expect(
        result,
        '$opening${fgRed}ab${linkClose}X$opening${ST}cd$linkClose',
      );
      expect(
        Parser(result).removeAll(),
        'abXcd',
        reason: 'the text after the insertion is text, not url',
      );
      expect(Parser(result).linkAt(3)?.url, outer);
    });

    test('an opening terminated with BEL is given back in that form', () {
      const opening = '${OSC}8;;$outer$BEL';
      final parser = Parser('${opening}abcd$linkClose');

      expect(
        parser.insertBefore(2, '${opens(inner)}X$linkClose'),
        '${opening}ab${opens(inner)}X$linkClose${opening}cd$linkClose',
        reason: 'the form of the terminator is the form it was written in',
      );
    });

    test('an empty insertion is a no-op, byte for byte', () {
      final text = '${opens(outer)}abcd$linkClose';

      expect(Parser(text).insertBefore(2, ''), text);
      expect(Parser(text).insertAfter(2, ''), text);
    });

    test('an insertion outside any link opens none', () {
      final parser = Parser('abcd');

      expect(Parser(parser.insertBefore(2, 'X')).linkAt(2), isNull);
      expect(parser.insertBefore(2, 'X'), 'abXcd');
    });

    test('an insertion behind a close stays outside the link', () {
      final parser = Parser('${opens(outer)}ab${linkClose}cd');
      final result = parser.insertAfter(2, '${opens(inner)}X');

      expect(
        result,
        '${opens(outer)}ab$linkClose${opens(inner)}X${linkClose}cd',
        reason: 'nothing was open at the seam, so the link is closed, '
            'not reopened',
      );
      expect(Parser(result).linkAt(2)?.url, inner);
      expect(Parser(result).linkAt(3), isNull);
    });

    test('an insertion in front of a close stays inside the link', () {
      final parser = Parser('${opens(outer)}ab${linkClose}cd');
      final result = parser.insertBefore(2, 'X');

      expect(result, '${opens(outer)}abX${linkClose}cd');
      expect(Parser(result).linkAt(2)?.url, outer);
    });

    test('the end of the string is a seam like any other', () {
      final parser = Parser('${opens(outer)}abcd');
      final result = parser.insertAfter(4, '${opens(inner)}X$linkClose');

      expect(
        result,
        '${opens(outer)}abcd${opens(inner)}X$linkClose${opens(outer)}',
        reason: 'the string left the outer link open, and so does the '
            'string with the insertion in it',
      );
      expect(Parser(result).finalLink?.url, outer);
    });

    test('the stacked parser gives the link back the same way', () {
      final parser = StackedParser('${opens(outer)}abcd$linkClose');

      expect(
        parser.insertBefore(2, '${opens(inner)}X$linkClose'),
        '${opens(outer)}ab'
        '${opens(inner)}X$linkClose'
        '${opens(outer)}cd$linkClose',
      );
    });

    test('the string shortcuts give it back too', () {
      final text = '${opens(outer)}abcd$linkClose';

      expect(
        text.ansiInsertBefore(2, '${opens(inner)}X$linkClose'),
        '${opens(outer)}ab'
        '${opens(inner)}X$linkClose'
        '${opens(outer)}cd$linkClose',
      );
    });
  });
}
