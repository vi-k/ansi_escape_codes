import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

const _unknown = '\x1B[99m';
const _overflow = '\x1B[999999999999999999999999m';

void main() {
  group('optimize keeps opaque SGR state:', () {
    test('a small unknown is emitted and closed', () {
      expect(
        Parser('${_unknown}A').optimize(),
        '${_unknown}A$reset',
      );
      expect(
        Parser('${_unknown}A').optimize(close: false),
        '${_unknown}A',
      );
    });

    test('a known setter after unknown is never called redundant', () {
      const input = '$bold${_unknown}A${bold}B';
      final output = Parser(input).optimize(close: false);

      expect(output, input);
      expect(RegExp(RegExp.escape(bold)).allMatches(output), hasLength(2));
      expect(Parser(output).optimize(close: false), output);
    });

    test('a real reset prunes everything before it', () {
      expect(
        Parser('\x1B[99;0;31mA').optimize(close: false),
        '${fgRed}A',
      );
      expect(
        Parser('\x1B[0;99mA').optimize(close: false),
        '${_unknown}A',
      );
    });

    test('an unsupported colour keeps its raw function and tail', () {
      expect(
        Parser('\x1B[38;7;1mA').optimize(close: false),
        '\x1B[38;7m${bold}A',
      );
    });

    test('overflow is stateful but keeps CsiUnknown publicly', () {
      final parser = Parser('${_overflow}A');
      expect(parser.pieces.first.entity, isA<CsiUnknown>());
      expect(parser.optimize(), '${_overflow}A$reset');
    });

    test('private and intermediate CSI stay literal, not stateful', () {
      expect(Parser('\x1B[?99mAB').substring(1), 'B');
      expect(Parser('\x1B[1 mAB').substring(1), 'B');
    });

    test('Stack reset reopens the visible lower frame', () {
      const input = '$bold$bold${_unknown}A${resetBoldAndDim}B';
      final output = StackedParser(input).optimize(close: false);
      final reparsed = Parser(output);
      final plain = reparsed.removeAll();

      expect(output, contains('$resetBoldAndDim$bold'));
      expect(reparsed.stateAt(plain.indexOf('B')).isBold, isTrue);
    });

    test('save and restore return to the residual branch', () {
      const input = '${_unknown}A\x1B7${bold}B\x1B8C';
      final output = Parser(input).optimize(close: false);

      expect(output, contains('$reset$_unknown\x1B8C'));
      expect(Parser(output).optimize(close: false), output);
    });
  });

  group('substring restores opaque state:', () {
    test('the opener may stand before the slice', () {
      const input = '$fgRed${_unknown}A${bold}B';

      expect(
        Parser(input).substring(1, maxLength: 1),
        '$fgRed$_unknown${bold}B$reset',
      );
      expect(
        Parser(input).substring(1, maxLength: 1, close: false),
        '$fgRed$_unknown${bold}B',
      );
    });

    test('overflow is replayed when the slice starts later', () {
      expect(
        Parser('${_overflow}AB').substring(1),
        '${_overflow}B$reset',
      );
    });

    test('a restored branch is reconstructed before later text', () {
      const input = '${_unknown}A\x1B7${bold}B\x1B8C';
      final slice = Parser(input).substring(0, close: false);

      expect(slice, contains('$reset$_unknown\x1B8C'));
      expect(Parser(slice).optimize(close: false), slice);
    });

    test('ordinary private CSI before the cut is not replayed', () {
      expect(Parser('\x1B[?99mAB').substring(1), 'B');
      expect(Parser('\x1B[1 mAB').substring(1), 'B');
    });
  });

  group('insertions compose residual branches:', () {
    test('plain text inside an opaque ambient adds no repair', () {
      const input = '${_unknown}AB';
      expect(Parser(input).insertBefore(1, 'X'), '${_unknown}AXB');
      expect(Parser(input).insertAfter(1, 'X'), '${_unknown}AXB');
    });

    test('a reset insertion replays the outer branch', () {
      const input = '${_unknown}AB';
      expect(
        Parser(input).insertBefore(1, '${reset}X'),
        '${_unknown}A${reset}X${_unknown}B',
      );
    });

    test('an unknown insertion is reset before a clean tail', () {
      expect(
        Parser('AB').insertBefore(1, '${_unknown}X'),
        'A${_unknown}X${reset}B',
      );
    });

    test('a child branch returns to its opaque parent', () {
      const input = '${_unknown}AB';
      final result = Parser(input).insertBefore(1, '${bold}X');

      expect(result, '${_unknown}A${bold}X$reset${_unknown}B');
    });

    test('Stack restores the visible parent frame', () {
      const input = '$bold$bold${_unknown}AB';
      final result =
          StackedParser(input).insertBefore(1, '${resetBoldAndDim}X');

      expect(result, contains('$reset$bold${_unknown}B'));
    });
  });

  group('printers carry opaque rendition:', () {
    test('all four concrete printers preserve and close unknown', () {
      const input = '${_unknown}A';

      expect(Printer().prepare(input), '$reset${_unknown}A$reset');
      expect(StackedPrinter().prepare(input), '$reset${_unknown}A$reset');

      final sink = StringBuffer();
      SinkPrinter(sink).writeln(input);
      expect(sink.toString(), '$reset${_unknown}A$reset\n');

      final stackedSink = StringBuffer();
      StackedSinkPrinter(stackedSink).writeln(input);
      expect(stackedSink.toString(), '$reset${_unknown}A$reset\n');
    });

    test('the next line replays the logical tail after printer reset', () {
      final printer = Printer();

      expect(printer.prepare('${_unknown}A'), '$reset${_unknown}A$reset');
      expect(printer.prepare('B'), '$reset${_unknown}B$reset');
      expect(printer.prepare('${reset}C'), '${reset}C');
      expect(printer.prepare('D'), '${reset}D');
    });

    test('default style is repaired after a known reset in residual', () {
      final printer = StackedPrinter(defaultStyle: Styles.bold);
      final output = printer.prepare('${_unknown}A${resetBoldAndDim}B');

      expect(output, contains('$resetBoldAndDim$bold' 'B'));
      expect(output, endsWith(reset));
    });

    test('NoStyle keeps the original bytes and no private carry', () {
      final printer = Printer(defaultStyle: const NoStyle());
      expect(printer.prepare('${_unknown}A'), '${_unknown}A');
      expect(printer.prepare('B'), 'B');
    });
  });
}
