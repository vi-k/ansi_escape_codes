// ignore_for_file: lines_longer_than_80_chars

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;

void main() {
  const text = '${ansi.fgBrightGreen}Lorem${ansi.fgDefault}'
      ' ${ansi.fgGreen}ipsum${ansi.fgDefault}'
      ' ${ansi.bgBrightBlack}${ansi.fgWhite}dolor${ansi.fgDefault}${ansi.bgDefault}'
      ' ${ansi.bgBrightWhite}${ansi.fgBlack}sit${ansi.fgDefault}${ansi.bgDefault}'
      ' ${ansi.fg256Open}${ansi.highRed}${ansi.fg256Close}amet${ansi.fgDefault},'
      ' ${ansi.fg256Red}consectetur${ansi.fgDefault}'
      ' ${ansi.bgRgbOpen}249;105;14${ansi.bgRgbClose}${ansi.fgRgbOpen}64;48;32${ansi.fgRgbClose}'
      'adipiscing ${ansi.invert} elit,${ansi.notInverted}${ansi.fgDefault}${ansi.bgDefault}'
      ' ${ansi.italic}sed${ansi.notItalic}'
      ' do'
      ' ${ansi.bold}eiusmod${ansi.notBoldNotFaint}'
      ' ${ansi.faint}tempor${ansi.notBoldNotFaint}'
      '${ansi.fgCyan}'
      ' incididunt'
      ' ${ansi.increasedIntensity}ut${ansi.normalIntensity}'
      ' ${ansi.decreasedIntensity}labore${ansi.normalIntensity}'
      '${ansi.fgDefault}'
      ' ${ansi.underline}et${ansi.notUnderlined}'
      ' ${ansi.strike}dolore${ansi.notStriked}'
      ' ${ansi.fg256Gray10}magna${ansi.fgDefault}'
      ' ${ansi.fg256Gray17}aliqua${ansi.fgDefault}.';

  print(text);
}
