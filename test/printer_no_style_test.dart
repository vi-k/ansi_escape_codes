import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a printer given NoStyle imposes nothing:', () {
    test('a plain line goes out as it came', () {
      final printer = Printer(defaultStyle: const NoStyle());

      expect(printer.prepare('text'), 'text');
    });

    test('a styled line keeps its own codes, byte for byte', () {
      final printer = Printer(defaultStyle: const NoStyle());
      const line = 'a${fgRed}b$reset c';

      expect(printer.prepare(line), line);
    });

    test('a StackedPrinter the same way', () {
      final printer = StackedPrinter(defaultStyle: const NoStyle());
      const line = '${bold}x$reset';

      expect(printer.prepare(line), line);
    });

    test('ansiCodesEnabled: false still takes the codes out', () {
      final printer = Printer(
        defaultStyle: const NoStyle(),
        ansiCodesEnabled: false,
      );

      expect(printer.prepare('a${fgRed}b'), 'ab');
    });
  });
}
