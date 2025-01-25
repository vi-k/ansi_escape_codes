// ignore_for_file: lines_longer_than_80_chars

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;

void main() {
  const text =
      // 4-bit colors.
      '${ansi.fgBrightGreen}Lorem'
      ' ${ansi.fgGreen}ipsum'
      ' ${ansi.bgBrightBlack}${ansi.fgWhite}dolor${ansi.bgDefault}'
      ' ${ansi.bgBrightWhite}${ansi.fgBlack}sit${ansi.bgDefault}'
      // 8-bit colors.
      ' ${ansi.fg256HighRed}amet,'
      ' ${ansi.fg256Red}consectetur${ansi.fgDefault}'
      // 24-bit colors.
      ' ${ansi.bgRgbOpen}249;105;14${ansi.bgRgbClose}'
      '${ansi.fgRgbOpen}64;48;32${ansi.fgRgbClose}'
      'adipiscing'
      // Inverted colors.
      ' ${ansi.invert} elit,${ansi.notInverted}'
      '${ansi.fgDefault}${ansi.bgDefault}'
      // Italic.
      ' ${ansi.italic}sed${ansi.notItalic}'
      ' do'
      // Bold and faint.
      ' ${ansi.bold}eiusmod${ansi.notBoldNotFaint}'
      ' ${ansi.faint}tempor${ansi.notBoldNotFaint}'
      '${ansi.fgCyan}'
      ' incididunt'
      ' ${ansi.increasedIntensity}ut${ansi.normalIntensity}'
      ' ${ansi.decreasedIntensity}labore${ansi.normalIntensity}'
      '${ansi.fgDefault}'
      // Etc.
      ' ${ansi.underline}et${ansi.notUnderlined}'
      ' ${ansi.strike}dolore${ansi.notStriked}'
      ' ${ansi.hide}magna${ansi.notHidden}'
      ' ${ansi.blink}aliqua${ansi.notBlinking}.';

  print(text);

  print(ansi.removeBackgroundColors(text));
  print(ansi.removeEscapeSequences(text));
  print(
    ansi.showEscapeSequences(
      text,
      recognizeSequences: true,
    ),
  );
  print(ansi.showEscapeSequences(text));
}
