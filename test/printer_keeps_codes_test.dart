import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a printer keeps the codes that are not about style:', () {
    String printed(String line, {Style? defaultStyle}) {
      final lines = <String>[];
      Printer(
        output: lines.add,
        defaultStyle: defaultStyle ?? Style.terminalColors,
      ).print(line);

      return Parser(lines.single).showControlFunctions();
    }

    test('a cursor move goes through', () {
      expect(printed('$cursorUp x'), '[reset][CSI CUU] x');
      expect(
        printed('a${cursorLeftN(3)}b'),
        '[reset]a[CSI 3 CUB]b',
      );
    });

    test('so does a hyperlink, whole', () {
      expect(
        printed('${linkOpen}https://e.test${linkTextOpen}text$linkClose'),
        '[reset][link(https://e.test)]text[linkClose]',
      );
    });

    test('so do the screen and the cursor pair', () {
      expect(printed('$erasePage x'), '[reset][CSI 2 ED] x');
      expect(printed('$hideCursor x'), '[reset][hideCursor] x');
      expect(
        printed('$saveCursor x$restoreCursor'),
        '[reset][saveCursor] x[restoreCursor]',
      );
    });

    test('and the style is still written by the printer', () {
      expect(
        printed('$cursorUp x', defaultStyle: Styles.red),
        '[reset][fg256Red][CSI CUU] x[reset]',
        reason: 'the default style is put on before the code that reads it',
      );
      expect(
        printed('${fgGreen}x${resetFg}y', defaultStyle: Styles.red),
        '[reset][fgGreen]x[fg256Red]y[reset]',
        reason: 'an SGR sequence is written by the transition, not passed on, '
            'and what it resets to is the default style',
      );
    });

    test('unless the codes are switched off, when nothing survives', () {
      final lines = <String>[];
      Printer(output: lines.add, ansiCodesEnabled: false)
          .print('$cursorUp${fgRed}x$reset');

      expect(lines.single, 'x');
    });
  });
}
