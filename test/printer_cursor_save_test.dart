import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

typedef _Render = String Function(List<String> chunks);

Map<String, _Render> _surfaces() => {
      'Printer': (chunks) {
        final printer = Printer();
        return chunks.map(printer.prepare).join('\n');
      },
      'StackedPrinter': (chunks) {
        final printer = StackedPrinter();
        return chunks.map(printer.prepare).join('\n');
      },
      'SinkPrinter': (chunks) {
        final sink = StringBuffer();
        final printer = SinkPrinter(sink);
        chunks.forEach(printer.writeln);
        return sink.toString();
      },
      'StackedSinkPrinter': (chunks) {
        final sink = StringBuffer();
        final printer = StackedSinkPrinter(sink);
        chunks.forEach(printer.writeln);
        return sink.toString();
      },
    };

Style styleAt(String output, String marker) {
  final parser = Parser(output);
  return parser.stateAt(parser.indexOf(marker));
}

Link? linkAt(String output, String marker) {
  final parser = Parser(output);
  return parser.linkAt(parser.indexOf(marker));
}

void main() {
  group('the cursor save slot crosses printer boundaries:', () {
    for (final MapEntry(key: name, value: render) in _surfaces().entries) {
      test('$name restores a save and carries it onward', () {
        final output = render([
          '$fgRed$saveCursor$fgBlue A',
          '${restoreCursor}B',
          'C',
        ]);

        expect(styleAt(output, 'B').foregroundColor, Color16.red);
        expect(styleAt(output, 'C').foregroundColor, Color16.red);
        expect(output, contains(saveCursor));
        expect(output, contains(restoreCursor));
      });

      test('$name uses terminal defaults before the first save', () {
        final output = render([
          '${fgRed}A',
          '${restoreCursor}B',
          'C',
        ]);

        expect(styleAt(output, 'B'), Style.terminalColors);
        expect(styleAt(output, 'C'), Style.terminalColors);
      });
    }

    for (final defaultStyle in [Styles.bold, Styles.bgGray3]) {
      test('a restore before any save puts $defaultStyle back on', () {
        // `ESC 8` with no `ESC 7` in front of it takes the terminal to its
        // own defaults, not to the printer's: DECRC without DECSC clears the
        // rendition. The style the printer imposes has to be written again
        // behind it, or the printer and its own output disagree about what
        // the text after it is wearing.
        final lines = <String>[];
        Printer(output: lines.add, defaultStyle: defaultStyle)
            .print('a${restoreCursor}b');

        final read = Parser(lines.single);

        expect(
          [for (var i = 0; i < read.length; i++) read.stateAt(i)],
          [defaultStyle, defaultStyle],
          reason: "read back off the printer's own output",
        );
      });

      test('and a sink says the same for $defaultStyle', () {
        final buf = StringBuffer();
        SinkPrinter(buf, defaultStyle: defaultStyle)
          ..write('a${restoreCursor}b')
          ..flush();

        final read = Parser(buf.toString());

        expect(
          [for (var i = 0; i < read.length; i++) read.stateAt(i)],
          [defaultStyle, defaultStyle],
        );
      });
    }
  });

  group('the save slot is one reusable record:', () {
    test('restore does not consume it', () {
      final printer = Printer();
      final output = [
        printer.prepare('$fgRed$saveCursor$fgBlue A'),
        printer.prepare(''),
        printer.prepare('${restoreCursor}B'),
        printer.prepare('$fgGreen${restoreCursor}C'),
        printer.prepare('D'),
      ].join('\n');

      for (final marker in ['B', 'C', 'D']) {
        expect(styleAt(output, marker).foregroundColor, Color16.red);
      }
    });

    test('a later save replaces the earlier one', () {
      final printer = Printer();
      final output = [
        printer.prepare(
          '$fgRed$saveCursor$fgGreen$saveCursor$fgBlue A',
        ),
        printer.prepare('${restoreCursor}B'),
        printer.prepare('C'),
      ].join('\n');

      expect(styleAt(output, 'B').foregroundColor, Color16.green);
      expect(styleAt(output, 'C').foregroundColor, Color16.green);
    });

    test('a stacked save keeps the full foreground history', () {
      final printer = StackedPrinter();
      final output = [
        printer.prepare('$fgRed$fgGreen$saveCursor$fgBlue A'),
        printer.prepare('$restoreCursor$resetFg' 'B'),
        printer.prepare('C'),
      ].join('\n');

      expect(styleAt(output, 'B').foregroundColor, Color16.red);
      expect(styleAt(output, 'C').foregroundColor, Color16.red);
    });
  });

  group('the cursor slot carries every private channel:', () {
    test('a saved link returns across a boundary and stays carried', () {
      final printer = Printer();
      final output = [
        printer.prepare(
          '${linkOpen}http://u/$linkTextOpen'
          '${saveCursor}A$linkClose',
        ),
        printer.prepare('${restoreCursor}B'),
        printer.prepare('C'),
      ].join('\n');

      expect(linkAt(output, 'B')?.url, 'http://u/');
      expect(linkAt(output, 'C')?.url, 'http://u/');
    });

    test('a saved null link wins over a seeded ambient link', () {
      final printer = Printer();
      final output = [
        printer.prepare(
          '$saveCursor${linkOpen}http://u/$linkTextOpen' 'A',
        ),
        printer.prepare('B'),
        printer.prepare('${restoreCursor}C'),
        printer.prepare('D'),
      ].join('\n');

      expect(linkAt(output, 'B')?.url, 'http://u/');
      expect(linkAt(output, 'C'), isNull);
      expect(linkAt(output, 'D'), isNull);
    });

    test('opaque SGR is restored and replayed after the next boundary', () {
      const unknown = '\x1B[99m';
      final printer = Printer();

      expect(
        printer.prepare('$unknown$saveCursor$reset'),
        '$reset$unknown$saveCursor$reset',
      );
      expect(
        printer.prepare('${restoreCursor}B'),
        '$reset$unknown${restoreCursor}B$reset',
      );
      expect(printer.prepare('C'), '$reset$unknown' 'C$reset');
    });
  });

  group('sink probing and bypasses do not create cursor carry:', () {
    test('SinkPrinter rolls prepare back', () {
      final sink = StringBuffer();
      final printer = SinkPrinter(sink)
        ..write('$fgRed$saveCursor')
        ..prepare('$fgGreen$saveCursor')
        ..write('$fgBlue${restoreCursor}B')
        ..writeln();

      expect(styleAt(sink.toString(), 'B').foregroundColor, Color16.red);
      expect(printer.lastState?.foregroundColor, Color16.red);
    });

    test('StackedSinkPrinter rolls prepare back', () {
      final sink = StringBuffer();
      final printer = StackedSinkPrinter(sink)
        ..write('$fgRed$saveCursor')
        ..prepare('$fgGreen$saveCursor')
        ..write('$fgBlue${restoreCursor}B')
        ..writeln();

      expect(styleAt(sink.toString(), 'B').foregroundColor, Color16.red);
      expect(printer.lastState?.foregroundColor, Color16.red);
    });

    test('writeAll, write and writeCharCode share the sink slot', () {
      final sink = StringBuffer();
      SinkPrinter(sink)
        ..writeAll(['$fgRed$saveCursor', '${fgBlue}A'])
        ..write(restoreCursor)
        ..writeCharCode(0x42)
        ..writeln();

      expect(styleAt(sink.toString(), 'B').foregroundColor, Color16.red);
    });

    test('NoStyle leaves both cursor bytes untouched', () {
      final printer = Printer(defaultStyle: const NoStyle());

      expect(printer.prepare('$saveCursor A'), '$saveCursor A');
      expect(printer.prepare('${restoreCursor}B'), '${restoreCursor}B');
    });

    test('disabled ANSI removes both cursor bytes', () {
      final printer = Printer(ansiCodesEnabled: false);

      expect(printer.prepare('$saveCursor A'), ' A');
      expect(printer.prepare('${restoreCursor}B'), 'B');
    });
  });
}
