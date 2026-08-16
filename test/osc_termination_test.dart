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

  group('a printed line terminates an OSC it would leave open', () {
    test('a title in front of the line text', () {
      final lines = <String>[];
      Printer(output: lines.add).print('$title${reset}word');

      // Every prepared piece opens with a reset — that is the printer's own
      // doing and not this rule's.
      expect(lines, ['$reset$title${ST}word']);
    });

    test('a title at the end of the line', () {
      // The line is over, and a newline follows it into the terminal: the
      // terminator is owed here the way a link close is.
      final lines = <String>[];
      Printer(output: lines.add).print('a$title');

      expect(lines, ['${reset}a$title$ST']);
    });

    test('a line that got its terminator is left alone', () {
      final lines = <String>[];
      Printer(output: lines.add).print('$title$ST${reset}word');

      expect(lines, ['$reset$title${ST}word']);
    });

    test('a title carried to the end of the first line of two', () {
      final lines = <String>[];
      Printer(output: lines.add).print('$title${reset}one\ntwo');

      expect(lines, ['$reset$title${ST}one', '${reset}two']);
    });
  });

  group('a sink terminates where the line really ends', () {
    test('a write that has not ended the line holds the title back', () {
      // The title has no terminator, so what follows it belongs to it — and
      // what follows it is whatever the next write brings. Sending it now
      // would settle that question early and wrongly: the next write opens
      // with a reset of its own, whose `ESC` would end the title where the
      // caller never did.
      final buf = StringBuffer();
      SinkPrinter(buf).write('a$title');

      expect(buf.toString(), '${reset}a');
    });

    test('a writeln ends the line and owes the terminator', () {
      final buf = StringBuffer();
      SinkPrinter(buf).writeln('a$title');

      expect(buf.toString(), '${reset}a$title$ST\n');
    });

    test('a newline inside a write ends the line there', () {
      final buf = StringBuffer();
      SinkPrinter(buf).write('a$title${reset}word\nnext');

      expect(buf.toString(), '${reset}a$title${ST}word\n${reset}next');
    });

    test('a writeln of nothing is a line end and lets the title out', () {
      // The write before it held the title back; the line ends here, so
      // nothing more can be part of it, and it goes out terminated. It is
      // dressed as the piece it now is, which is where its reset comes from.
      final buf = StringBuffer();
      SinkPrinter(buf)
        ..write('a$title')
        ..writeln();

      expect(buf.toString(), '${reset}a$reset$title$ST\n');
    });

    test('a newline written on its own ends the line the same way', () {
      final buf = StringBuffer();
      SinkPrinter(buf)
        ..write('a$title')
        ..write('\n');

      expect(buf.toString(), '${reset}a$reset$title$ST\n');
    });

    test('a link close at that seam pays for both', () {
      // The close begins with an `ESC`, and an `ESC` ends an `OSC` that never
      // got its terminator — so no `ST` is written on top of it.
      final buf = StringBuffer();
      SinkPrinter(buf)
        ..write('${linkOpen}http://u/$linkTextOpen' 'a$title')
        ..writeln();

      expect(
        buf.toString(),
        '$reset${linkOpen}http://u/$linkTextOpen' 'a$reset$title$linkClose\n',
      );
    });

    test('a write after it goes on with the title, not past it', () {
      // The title was never terminated, so a `b` written behind it is part of
      // it — which is what the same bytes written in one go say. The reset
      // this write opens with used to land between them and end the title
      // early, leaving `b` on the screen and `0;title` in the title bar.
      final buf = StringBuffer();
      SinkPrinter(buf)
        ..write('a$title')
        ..write('b')
        ..writeln();

      expect(buf.toString(), '${reset}a$reset$title' 'b$ST\n');

      final whole = StringBuffer();
      SinkPrinter(whole).writeln('a${title}b');

      expect(
        Parser(buf.toString()).removeAll(),
        Parser(whole.toString()).removeAll(),
        reason: 'and the two agree on what is text and what is title',
      );
    });
  });

  group('a slice terminates an OSC that would swallow its text', () {
    test('a title in front of the text of the slice', () {
      expect(
        Parser('$title${reset}word').substring(0),
        '$title${ST}word',
      );
    });

    test('and with close: false, where the text follows all the same', () {
      // `close` decides what is owed at the end of the slice, not what is
      // owed in front of text inside it.
      expect(
        Parser('$title${reset}word').substring(0, close: false),
        '$title${ST}word',
      );
    });

    test('a title at the end of a closed slice is terminated', () {
      expect(Parser('a$title').substring(0), 'a$title$ST');
    });

    test('a title at the end of an unclosed slice is left as it came', () {
      expect(Parser('a$title').substring(0, close: false), 'a$title');
    });

    test('a title behind a link, with the text behind both', () {
      // The link opening is written first and its `ESC` ends nothing, so the
      // title is the one that needs the terminator.
      const link = '${OSC}8;;https://a.test$ST';

      expect(
        Parser('$link$title${reset}word').substring(0),
        '$link$title${ST}word$linkClose',
      );
    });

    test('a link behind a title changes nothing: the ESC ends it', () {
      // The link opening begins with an `ESC`, so it ends the title itself
      // and nothing is supplied. A regression pin: this is what must not
      // move.
      const link = '${OSC}8;;https://a.test$ST';

      expect(
        Parser('$title$link${reset}word').substring(0),
        '$title${link}word$linkClose',
      );
    });

    test('a title behind held link codes that the close then drops', () {
      // The link is read and held, and a closed slice drops what it held —
      // nothing follows it to be shown inside. So the `ESC` those bytes
      // begin with is never written, and the title behind them is the last
      // thing in the slice: the terminator is owed after all.
      const link = '${OSC}8;;https://a.test$ST';

      expect(Parser('a$title$link').substring(0), 'a$title$ST');
    });

    test('and the same where the link is opened and closed again', () {
      const link = '${OSC}8;;https://a.test$ST';
      const close = '${OSC}8;;$ST';

      expect(Parser('a$title$link$close').substring(0), 'a$title$ST');
    });

    test('a title in front of another title', () {
      // The second one ends the first with its `ESC`, and the second is the
      // one left waiting for the text.
      expect(
        Parser('$title$title${reset}word').substring(0),
        '$title$title${ST}word',
      );
    });

    test('a title in front of a code that is copied over as it stands', () {
      // The `CSI` is written where it stands and its `ESC` ends the title,
      // which must go out ahead of it and not behind it.
      expect(
        Parser('$title\x1B[2Cword').substring(0),
        '$title\x1B[2Cword',
      );
    });

    test('an insertion is not touched by any of this', () {
      // `insertBefore` and `insertAfter` copy the input around the seam byte
      // for byte, so the title keeps whatever it had there. A regression pin.
      expect(
        Parser('$title${reset}word').insertBefore(2, 'X'),
        '$title${reset}woXrd',
      );
      expect(
        Parser('$title${reset}word').insertAfter(2, 'X'),
        '$title${reset}woXrd',
      );
    });

    test('the two held things come out in the order they were read', () {
      const link = '${OSC}8;;https://a.test$ST';
      const close = '${OSC}8;;$ST';

      // A title, a link, a title, and text. The two wait side by side, and
      // the opening is always the older of them: it goes out first, and the
      // link codes behind it end it with their own `ESC`. The link close is
      // the last thing in front of the text and carries its own `ST`, so
      // nothing is supplied here either. Drop the escape-code branch's
      // hand-off and the second title takes the slot the first is still
      // waiting in, and the first is lost altogether. A title coming out
      // behind the link rather than in front of it is the other way this can
      // go, and `a link behind a title changes nothing` is what catches it.
      expect(
        Parser('$title$link$title$close${reset}word').substring(0),
        '$title$link$title${close}word',
      );
    });
  });
}
