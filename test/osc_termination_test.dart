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
    test('a write that has not ended the line owes nothing', () {
      final buf = StringBuffer();
      SinkPrinter(buf).write('a$title');

      expect(buf.toString(), '${reset}a$title');
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

    test('a writeln of nothing is a line end and pays the debt', () {
      // The write before it was handed the opening and wrote it as it came;
      // the line ends here, with nothing of its own to write, and the
      // terminator is owed all the same.
      final buf = StringBuffer();
      SinkPrinter(buf)
        ..write('a$title')
        ..writeln();

      expect(buf.toString(), '${reset}a$title$ST\n');
    });

    test('a newline written on its own ends the line the same way', () {
      final buf = StringBuffer();
      SinkPrinter(buf)
        ..write('a$title')
        ..write('\n');

      expect(buf.toString(), '${reset}a$title$ST\n');
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
        '$reset${linkOpen}http://u/$linkTextOpen' 'a$title$linkClose\n',
      );
    });

    test('a write that ended the opening leaves no debt behind', () {
      // Every prepared piece opens with a reset, and that `ESC` ends the
      // title already: the line end after it owes nothing.
      final buf = StringBuffer();
      SinkPrinter(buf)
        ..write('a$title')
        ..write('b')
        ..writeln();

      expect(buf.toString(), '${reset}a$title${reset}b\n');
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

    test('the two held things never wait together', () {
      const link = '${OSC}8;;https://a.test$ST';
      const close = '${OSC}8;;$ST';

      // A title, a link, a title, and text: whichever order they come in,
      // each is written out before the other is filled, so nothing is
      // written twice and nothing comes out backwards. The link close is the
      // last thing in front of the text and it carries its own `ST`, so
      // nothing is supplied here; drop either of the two hand-offs and an
      // `ST` appears between the second title and the close.
      expect(
        Parser('$title$link$title$close${reset}word').substring(0),
        '$title$link$title${close}word',
      );
    });
  });
}
