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
      final parser = Parser.debugInsideLink('abcd', OscLink(outer));

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

  group('a seam that steps back over a run:', () {
    const url = 'http://run/';

    // An opening the parser never saw terminated. It is a link all the same:
    // the parameters are all three there and the terminator is optional, so
    // the parser reads a link that runs to the end of the string.
    const opening = '$linkOpen$url';

    // The run itself: that opening, and behind it a `CSI` with no final byte.
    // Two codes is the shortest such run there is — an unterminated opening
    // swallows text up to the next `ESC`, so a code always follows it — and
    // the seam belongs in front of both.
    const run = '$opening${CSI}31';

    test('the seam in front of the run stands outside the link it opens', () {
      final result = Parser('aa$run').insertAfter(2, '@$linkClose');

      expect(
        result,
        'aa@$linkClose$run',
        reason: 'nothing is open where the text goes, so the close it '
            'carries is the last word on the link and no opening is '
            'written back',
      );
      expect(
        result,
        Parser('aa$run').insertBefore(2, '@$linkClose'),
        reason: 'both insertions cut at the same byte, in front of the '
            'whole run, and have nothing left to disagree about',
      );
    });

    test('the marker in front of the run does not join the URL', () {
      final result = Parser('aa$run').insertAfter(2, '@');

      expect(result, 'aa@$run');
      expect(Parser(result).removeAll(), 'aa@31');
      expect(
        Parser(result).linkAt(2),
        isNull,
        reason: 'the marker went in front of the opening, not into it',
      );
      expect(
        Parser(result).linkAt(3)?.url,
        url,
        reason: 'and the URL is the one the input wrote, character for '
            'character',
      );
    });

    test('a finished code in front of the run is passed and opens no link', () {
      final result = Parser('aa$fgRed$run').insertAfter(2, '@$linkClose');

      expect(
        result,
        'aa$fgRed@$linkClose$run',
        reason: 'the run begins behind the colour, so that is where the '
            'seam is — and no link is open there either',
      );
    });

    test('the style in front of the run is the one the marker sits in', () {
      final result = Parser('aa$fgRed$run').insertAfter(2, '$fgGreen@');

      expect(
        result,
        'aa$fgRed$fgGreen@$fgRed$run',
        reason: 'the seam is behind the colour, so the marker is given that '
            'colour back and not a reset — the run carries no style of its '
            'own to read it off',
      );
    });

    test('a close in front of the run leaves the seam outside every link', () {
      final parser = Parser.debugInsideLink(
        'aa$linkClose$run',
        OscLink(outer),
      );

      expect(
        parser.insertAfter(2, '@$linkClose'),
        'aa$linkClose@$linkClose$run',
        reason: 'the string began inside a link and the close in front of '
            'the run ended it, so there is nothing at the seam to hand back',
      );
    });

    test('a run at the head of the string reads what the parser began in', () {
      final parser = Parser.debugInsideLink(run, OscLink(outer));

      expect(
        parser.insertAfter(0, '@$linkClose'),
        '@$linkClose${opens(outer)}$run',
        reason: 'no piece of the string stands in front of the run, so the '
            'link at the seam is the one the parser was seeded with, and '
            'the insertion that closed it hands that one back',
      );
      expect(
        Parser.debugInsideLink(run, OscLink(outer))
            .insertBefore(0, '@$linkClose'),
        '@$linkClose${opens(outer)}$run',
        reason: 'insertBefore at nought answers off the same seed without '
            'walking at all, and the two cut at the same byte',
      );
    });

    test('a link open in front of the run is given back', () {
      // The run opens with a close of its own: `OSC 8;;` with no URL and no
      // terminator, which ends whatever link was open.
      final input = '${opens(outer)}aa$linkOpen${CSI}31';
      final result = Parser(input).insertAfter(2, '@$linkClose');

      expect(
        result,
        '${opens(outer)}aa@$linkClose${opens(outer)}$linkOpen${CSI}31',
        reason: 'the outer link is open at the seam, so the insertion that '
            'closed it hands it back before the run closes it in turn',
      );
      expect(result, Parser(input).insertBefore(2, '@$linkClose'));
    });
  });
}
