import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

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

    test('does not close what it did not open', () {
      expect(Parser(linked).substring(2, maxLength: 2), 'ic');
    });

    test('close: false leaves the link open, as it leaves the style', () {
      expect(
        Parser(linked).substring(0, maxLength: 3, close: false),
        '$linkOpen$url$linkTextOpen' 'cli',
      );
    });

    test('a resumed walk stays outside a link it did not open', () {
      final parser = Parser(linked);

      expect(
        parser.substring(0, maxLength: 3),
        '$linkOpen$url$linkTextOpen' 'cli' '$linkClose',
      );
      // maxLength: 1 so that the end of the slice does not reach the
      // input's own linkClose, which stands on the boundary: codes on the
      // boundary of a slice are taken in by design.
      expect(parser.substring(3, maxLength: 1), 'c');
    });
  });
}
