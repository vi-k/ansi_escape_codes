import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const text = '${fgBrightGreen}Lorem$fgDefault'
      ' ${fgGreen}ipsum$fgDefault'
      ' $bgBrightBlack${fgWhite}dolor$fgDefault$bgDefault'
      ' $bgBrightWhite${fgBlack}sit$fgDefault$bgDefault'
      ' $fg256Open$highRed${fg256Close}amet$fgDefault,'
      ' ${fg256Red}consectetur$fgDefault'
      ' ${bgRgbOpen}249;105;14$bgRgbClose${fgRgbOpen}64;48;32$fgRgbClose'
      'adipiscing $invert elit,$notInverted$fgDefault$bgDefault'
      ' ${italic}sed$notItalic'
      ' do'
      ' ${bold}eiusmod$notBoldNotFaint'
      ' ${faint}tempor$notBoldNotFaint'
      '$fgCyan'
      ' incididunt'
      ' ${increasedIntensity}ut$normalIntensity'
      ' ${decreasedIntensity}labore$normalIntensity'
      '$fgDefault'
      ' ${underline}et$notUnderlined'
      ' ${strike}dolore$notStriked'
      ' ${fg256Gray10}magna$fgDefault'
      ' ${fg256Gray17}aliqua$fgDefault.';

  print(text);
}
