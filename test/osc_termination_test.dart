import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Setting the window title, and never terminated: no `ST`, no `BEL`. The
/// parser reads a sequence like this to the next `ESC` or to the end of the
/// text — `oscPattern` is written that way on purpose — so whatever is
/// written straight after it is read as more of the title.
const title = '$ESC]0;title';

void main() {
  group('optimize terminates an OSC that would swallow what follows', () {
    test('a title the input never terminated, in front of text', () {
      // The `reset` ends the title in the input, and is written again as a
      // transition to the default style — which changes nothing here and so
      // writes nothing, leaving the title against the text.
      expect(Parser('$title${reset}word').optimize(), '$title${ST}word');
    });

    test('a transition that does write something ends it already', () {
      expect(
        Parser('$title${fgRed}word').optimize(),
        '$title${fgRed}word$reset',
      );
    });

    test('a code copied over as it stands ends it already', () {
      expect(
        Parser('$title\x1B[2Cword').optimize(),
        '$title\x1B[2Cword',
      );
    });

    test('a title that got its BEL is left alone', () {
      expect(
        Parser('$title\x07${reset}word').optimize(),
        '$title\x07word',
      );
    });

    test('a title at the end of a closed string is terminated', () {
      // Nothing follows it here, and that is the point: what the caller
      // prints after this string follows it.
      expect(Parser('a$title').optimize(), 'a$title$ST');
    });

    test('a title at the end of an unclosed string is left as it came', () {
      expect(Parser('a$title').optimize(close: false), 'a$title');
    });
  });
}
