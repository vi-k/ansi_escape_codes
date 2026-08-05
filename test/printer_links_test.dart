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

    test('a newline inside a write ends the line there', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        ..write('\x1B]8;;http://u/\x1B\\')
        ..write('click\ntail');

      expect(
        sink.toString(),
        '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[0mclick\x1B]8;;\x1B\\\n'
        '\x1B[0mtail',
      );
    });

    test('a link is not carried into the next line', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        ..write('\x1B]8;;http://u/\x1B\\')
        ..writeln('click')
        ..writeln('plain');

      expect(
        sink.toString(),
        '\x1B[0m\x1B]8;;http://u/\x1B\\\x1B[0mclick\x1B]8;;\x1B\\\n'
        '\x1B[0mplain\n',
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
