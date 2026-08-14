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
}
