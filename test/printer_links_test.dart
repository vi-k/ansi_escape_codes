import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a printed line closes the hyperlink it opened:', () {
    test('an unclosed link gets its close', () {
      expect(
        Printer().prepare('\x1B]8;;http://u/\x1B\\click'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\',
      );
    });

    test('a closed link is not closed twice', () {
      expect(
        Printer().prepare('\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\ tail'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\ tail',
      );
    });

    test('the close comes before the style is unwound', () {
      expect(
        Printer().prepare('\x1B[31m\x1B]8;;http://u/\x1B\\click'),
        '\x1B[0m\x1B[31m\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\\x1B[0m',
      );
    });

    test('a stacked printer closes the link the same way', () {
      expect(
        StackedPrinter().prepare('\x1B]8;;http://u/\x1B\\click'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\click\x1B]8;;\x1B\\',
      );
    });

    test('a NoStyle printer still passes the line through untouched', () {
      expect(
        Printer(defaultStyle: const NoStyle())
            .prepare('\x1B]8;;http://u/\x1B\\click'),
        '\x1B]8;;http://u/\x1B\\click',
      );
    });

    test('ansiCodesEnabled: false strips the link with the rest', () {
      expect(
        Printer(ansiCodesEnabled: false)
            .prepare('\x1B]8;;http://u/\x1B\\click'),
        'click',
      );
    });

    test('a link opened, closed and opened again is closed once', () {
      expect(
        Printer().prepare(
          '\x1B]8;;http://u/\x1B\\x\x1B]8;;\x1B\\y\x1B]8;;http://v/\x1B\\z',
        ),
        '\x1B[0m\x1B]8;;http://u/\x1B\\x\x1B]8;;\x1B\\y'
        '\x1B]8;;http://v/\x1B\\z\x1B]8;;\x1B\\',
      );
    });

    test("a line that only closes someone else's link adds nothing", () {
      expect(
        Printer().prepare('click\x1B]8;;\x1B\\'),
        '\x1B[0mclick\x1B]8;;\x1B\\',
      );
    });

    test('a close carrying an id is still a close', () {
      expect(
        Printer().prepare('\x1B]8;;http://u/\x1B\\x\x1B]8;id=1;\x1B\\'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\x\x1B]8;id=1;\x1B\\',
      );
    });

    test('a link opened with BEL is closed with ST', () {
      expect(
        Printer().prepare('\x1B]8;;http://u/\x07click'),
        '\x1B[0m\x1B]8;;http://u/\x07click\x1B]8;;\x1B\\',
      );
    });
  });

  group('a printed line takes the link the line before left open:', () {
    test('the line after reopens it', () {
      final printer = Printer();

      expect(
        printer.prepare('\x1B]8;;http://u/\x1B\\first'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\first\x1B]8;;\x1B\\',
      );
      expect(
        printer.prepare('second'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\second\x1B]8;;\x1B\\',
      );
    });

    test('a closed link is not carried on', () {
      final printer = Printer()
        ..prepare('\x1B]8;;http://u/\x1B\\first\x1B]8;;\x1B\\');

      expect(printer.prepare('second'), '\x1B[0msecond');
    });

    test('a line that closes it ends the carry', () {
      final printer = Printer()..prepare('\x1B]8;;http://u/\x1B\\first');

      expect(
        printer.prepare('second\x1B]8;;\x1B\\'),
        '\x1B[0m\x1B]8;;http://u/\x1B\\second\x1B]8;;\x1B\\',
      );
      expect(printer.prepare('third'), '\x1B[0mthird');
    });

    test('an opening the line never terminated is terminated when reopened',
        () {
      // `OSC 8 ; ; url` with nothing to end it is read to the end of the
      // line. Reopened in front of the next line's text, it would read that
      // text as the rest of the url.
      final printer = Printer()..prepare('\x1B]8;;http://u/');
      final line = printer.prepare('second');

      expect(line, '\x1B[0m\x1B]8;;http://u/\x1B\\second\x1B]8;;\x1B\\');
      expect(Parser(line).removeAll(), 'second', reason: 'nothing was eaten');
    });

    test('a multi-line print carries the link to the line after', () {
      final lines = <String>[];
      Printer(output: lines.add).print('\x1B]8;;http://u/\x1B\\one\ntwo');

      expect(lines, [
        '\x1B[0m\x1B]8;;http://u/\x1B\\one\x1B]8;;\x1B\\',
        '\x1B[0m\x1B]8;;http://u/\x1B\\two\x1B]8;;\x1B\\',
      ]);
    });

    test('runZonedPrinter carries it from one print to the next', () {
      final lines = <String>[];
      runZonedPrinter(
        () {
          print('\x1B]8;;http://u/\x1B\\one');
          print('two');
        },
        output: lines.add,
      );

      expect(lines, [
        '\x1B[0m\x1B]8;;http://u/\x1B\\one\x1B]8;;\x1B\\',
        '\x1B[0m\x1B]8;;http://u/\x1B\\two\x1B]8;;\x1B\\',
      ]);
    });

    test('a multi-line styled call keeps its link', () {
      final lines = Styles.red(
        '\x1B]8;;http://u/\x1B\\one\ntwo\x1B]8;;\x1B\\',
      ).split('\n');

      expect(
        lines,
        [
          '\x1B[0m\x1B[38;5;1m\x1B]8;;http://u/\x1B\\one\x1B]8;;\x1B\\\x1B[0m',
          '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[38;5;1mtwo\x1B]8;;\x1B\\\x1B[0m',
        ],
      );
    });
  });

  group('a sink printer carries the hyperlink across writes:', () {
    test('a link composed of three writes stays intact', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        ..write('\x1B]8;;http://u/\x1B\\')
        ..write('click')
        ..write('\x1B]8;;\x1B\\')
        ..writeln();

      expect(
        sink.toString(),
        '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[0mclick\x1B[0m\x1B]8;;\x1B\\\n',
      );
    });

    test('a link left open is closed where the line ends', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        ..write('\x1B]8;;http://u/\x1B\\')
        ..write('click')
        ..writeln();

      expect(
        sink.toString(),
        '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[0mclick\x1B]8;;\x1B\\\n',
      );
    });

    test('a newline inside a write ends the line and the next reopens', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        ..write('\x1B]8;;http://u/\x1B\\')
        ..write('click\ntail');

      expect(
        sink.toString(),
        '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[0mclick\x1B]8;;\x1B\\\n'
        '\x1B[0m\x1B]8;;http://u/\x1B\\tail',
      );
    });

    test('a link is carried into the next line', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        ..write('\x1B]8;;http://u/\x1B\\')
        ..writeln('click')
        ..writeln('plain');

      expect(
        sink.toString(),
        '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[0mclick\x1B]8;;\x1B\\\n'
        '\x1B[0m\x1B]8;;http://u/\x1B\\plain\x1B]8;;\x1B\\\n',
      );
    });

    test('a stacked sink printer does the same', () {
      final sink = StringBuffer();
      StackedSinkPrinter(sink)
        ..write('\x1B]8;;http://u/\x1B\\')
        ..write('click')
        ..writeln();

      expect(
        sink.toString(),
        '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[0mclick\x1B]8;;\x1B\\\n',
      );
    });

    test('a direct prepare leaves the writes that follow alone', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        // Asked, not written: the piece is prepared and thrown away, so the
        // link it opened is not one the sink has been sent and the writeln
        // below has nothing to close.
        ..prepare('\x1B]8;;http://u/\x1B\\click')
        ..writeln('plain');

      expect(sink.toString(), '\x1B[0mplain\n');
    });

    test('a direct prepare leaves the carry between lines alone', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        ..write('\x1B]8;;http://u/\x1B\\')
        ..writeln('click')
        // The line has ended, so the link is closed in the output and still
        // open logically. Asking about a piece that opens another one must
        // leave that carry as it was: the next line reopens the first link.
        ..prepare('\x1B]8;;http://v/\x1B\\')
        ..writeln('plain');

      expect(
        sink.toString(),
        '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[0mclick\x1B]8;;\x1B\\\n'
        '\x1B[0m\x1B]8;;http://u/\x1B\\plain\x1B]8;;\x1B\\\n',
      );
    });

    test('a NoStyle sink printer still passes the writes through', () {
      final sink = StringBuffer();
      SinkPrinter(sink, defaultStyle: const NoStyle())
        ..write('\x1B]8;;http://u/\x1B\\')
        ..write('click')
        ..writeln();

      expect(sink.toString(), '\x1B]8;;http://u/\x1B\\click\n');
    });
  });
}
