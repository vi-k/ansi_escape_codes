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

    test('an opening whose terminator never came is given one', () {
      // The opening runs to the next ESC — the one of the cursorUp — and the
      // slice writes it again in front of its own text, where no ESC follows
      // it. Without a terminator of its own it would swallow that text.
      const opening = '${OSC}8;;http://u/';
      final sliced = Parser('$opening${cursorUp}abcd$linkClose').substring(2);

      expect(sliced, '$opening${ST}cd$linkClose');
      expect(Parser(sliced).removeAll(), 'cd', reason: 'nothing was eaten');
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

    // `ESC 8` goes into the slice verbatim, the way every code that is not an
    // SGR does, and once there it changes what the slice has open. What the
    // slice believes it has written has to follow, or the opening behind the
    // restore says what the bookkeeping thinks is said already and is dropped
    // — leaving the text after it unclickable.
    group('a restore inside the slice moves what the slice has open:', () {
      // Nothing is cut away here: the whole string comes back, and the second
      // opening is what goes missing.
      final source = '${opens('http://u/')}$restoreCursor'
          'a${opens('http://u/')}b';
      final whole = Parser(source);

      test('the opening behind it is not deduplicated away', () {
        final cut = Parser(whole.substring(0, maxLength: 2));

        expect(
          [cut.linkAt(0)?.url, cut.linkAt(1)?.url],
          [whole.linkAt(0)?.url, whole.linkAt(1)?.url],
          reason: 'every character is clickable on what it was clickable on',
        );
        expect(cut.linkAt(1)?.url, 'http://u/', reason: 'and b is one of them');
      });

      test('and with close: false the same', () {
        final cut = Parser(
          Parser(source).substring(0, maxLength: 2, close: false),
        );

        expect(cut.linkAt(1)?.url, 'http://u/');
      });
    });

    // A characterisation of what the slice does, not of what it should do.
    //
    // The slice's own `ESC 8` does not give back what the input's gave back:
    // here the `ESC 7` is inside the slice but saved nothing, because the
    // opening was still held — no text had come to write it in front of yet
    // — and the other subform is an `ESC 7` left outside the slice
    // altogether. Either way the account is right about the input and the
    // bytes are not, and the lazy reopening that used to paper over this by
    // accident no longer fires.
    //
    // The loss is accepted, not wanted: closing it would mean writing an
    // opening with nothing inside it, which the slice deliberately does not
    // do. That machinery is what task 11 rewrites, and it can move this case
    // either way — pinned so that it cannot move in silence.
    test('an ESC 8 the slice cannot reproduce loses the link (accepted)', () {
      final source = '${opens('http://v/')}dea$saveCursor$restoreCursor'
          'b$restoreCursor'
          'de';
      final whole = Parser(source);
      final sliced = Parser(source).substring(3, maxLength: 3);
      final cut = Parser(sliced);

      expect(
        sliced,
        '$saveCursor$restoreCursor' 'b$restoreCursor' 'de$linkClose',
      );
      expect(whole.linkAt(3)?.url, 'http://v/');
      expect(cut.linkAt(0), isNull, reason: 'and the slice has lost it');
      expect(
        cut.stateAt(0),
        whole.stateAt(3),
        reason: 'the style does not go astray beside it: an ESC 8 taken into '
            'the slice is the mark of this class, and the state is not',
      );
    });
  });
}
