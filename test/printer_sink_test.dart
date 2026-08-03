import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a printer as a StringSink:', () {
    test('the one that prints holds the line until it is ended', () {
      final lines = <String>[];

      Printer(output: lines.add, defaultStyle: red)
        ..write('a')
        ..writeAll(['b', 'c'], '-')
        ..writeCharCode(0x64)
        ..writeln('e');

      expect(
        lines,
        hasLength(1),
        reason: 'writeln ends the line, nothing else',
      );
      expect(
        Parser(lines.single).showControlFunctions(),
        '[reset][fg256Red]ab-cde[reset]',
        reason: 'and the whole line is opened and closed once',
      );
    });

    test('the one that writes to a sink lets each piece through', () {
      final buf = StringBuffer();

      SinkPrinter(buf, defaultStyle: red)
        ..write('a')
        ..writeAll(['b', 'c'], '-')
        ..writeCharCode(0x64)
        ..writeln('e');

      expect(
        Parser(buf.toString()).showControlFunctions(),
        '[reset][fg256Red]a[reset]'
        '[reset][fg256Red]b-c[reset]'
        '[reset][fg256Red]d[reset]'
        '[reset][fg256Red]e[reset]\n',
        reason: 'each write is dressed on its own, and the style carries over',
      );
      expect(buf.toString().ansiRemoveEscapeCodes(), 'ab-cde\n');
    });

    test('and neither writes a code with the codes switched off', () {
      final buf = StringBuffer();

      SinkPrinter(buf, ansiCodesEnabled: false)
        ..write('${fgRed}a')
        ..writeAll(['b', '${bold}c'], '-')
        ..writeCharCode(0x64)
        ..writeln('e$reset');

      expect(
        buf.toString(),
        'ab-cde\n',
        reason: 'the codes the text carried are taken out as well',
      );
    });
  });
}
