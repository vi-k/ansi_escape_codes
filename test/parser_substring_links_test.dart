import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The sequence that opens a link on [url], with no text and no close: what
/// `link` writes whole, taken apart.
String opens(String url) => '$linkOpen$url$linkTextOpen';

/// The same opening in the older form [linkBel] writes, closed by a `BEL`.
String opensBel(String url) => '$linkOpen$url$BEL';

void main() {
  const url = 'https://example.com/';
  final linked = '${link(url, text: 'click')} tail';

  group('substring over a hyperlink:', () {
    test('closes the link the slice opened', () {
      expect(
        Parser(linked).substring(0, maxLength: 3),
        '$linkOpen$url$linkTextOpen' 'cli' '$linkClose',
      );
    });

    test('adds nothing when the slice closed it itself', () {
      expect(
        Parser(linked).substring(0, maxLength: 5),
        '$linkOpen$url$linkTextOpen' 'click' '$linkClose',
      );
    });

    test('gives the whole string back as it was', () {
      expect(Parser(linked).substring(0), linked);
    });

    test('opens the link the slice began inside', () {
      expect(
        Parser(linked).substring(2, maxLength: 2),
        '$linkOpen$url$linkTextOpen' 'ic' '$linkClose',
      );
    });

    test('close: false leaves the link open, as it leaves the style', () {
      expect(
        Parser(linked).substring(0, maxLength: 3, close: false),
        '$linkOpen$url$linkTextOpen' 'cli',
      );
    });

    test('a resumed walk opens the link it began inside', () {
      final parser = Parser(linked);

      expect(
        parser.substring(0, maxLength: 3),
        '$linkOpen$url$linkTextOpen' 'cli' '$linkClose',
      );
      // maxLength: 1 so that the end of the slice does not reach the
      // input's own linkClose, which stands on the boundary: codes on the
      // boundary of a slice are taken in by design.
      expect(
        parser.substring(3, maxLength: 1),
        '$linkOpen$url$linkTextOpen' 'c' '$linkClose',
      );
    });

    test('a slice inside a link opens it in the form it was opened', () {
      final parser = Parser('ab${opensBel('http://u/')}cdef$linkClose');

      expect(
        parser.substring(3, maxLength: 2),
        '${opensBel('http://u/')}de$linkClose',
      );
    });

    test('a slice inside a link keeps the parameters of the opening', () {
      const opening = '${OSC}8;id=7;http://u/$ST';
      final parser = Parser('ab${opening}cdef$linkClose');

      expect(parser.substring(3, maxLength: 2), '${opening}de$linkClose');
    });

    test('a slice with close: false reopens but does not close', () {
      final parser = Parser('ab${opens('http://u/')}cdef$linkClose');

      expect(
        parser.substring(3, maxLength: 2, close: false),
        '${opens('http://u/')}de',
      );
    });

    test('a close that closes nothing is not written', () {
      final parser = Parser('ab${opens('http://u/')}cd${linkClose}ef');

      expect(parser.substring(4, maxLength: 2), 'ef');
    });

    test('an empty slice of a linked string is empty', () {
      final parser = Parser('${opens('http://u/')}abc$linkClose');

      expect(parser.substring(0, maxLength: 0), '');
    });

    test('a close the slice stepped over is written before the text after it',
        () {
      final parser = Parser('${opens('http://u/')}ab${linkClose}cd');

      expect(
        parser.substring(0),
        '${opens('http://u/')}ab${linkClose}cd',
        reason: 'the slice gives a closed link back as it was',
      );
    });

    test('close: false leaves the link where the string leaves it', () {
      final parser = Parser('${opens('http://u/')}ab${linkClose}cd');

      expect(
        parser.substring(0, maxLength: 2, close: false),
        '${opens('http://u/')}ab$linkClose',
        reason: 'the close on the boundary belongs to the slice, so that '
            'what is stitched after it is not clickable',
      );
    });
  });
}
