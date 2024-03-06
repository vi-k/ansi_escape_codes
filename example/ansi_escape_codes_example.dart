import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const text = '${fgGreen}Lorem$fgDefault'
      ' $fgYellow${bgBrightBlack}ipsum$fgDefault$bgDefault'
      ' $fg256Open$red${fg256Close}dolor$fgDefault'
      ' $fg256Open$rgb531${fg256Close}sit$fgDefault'
      ' $fg256Open$gray9${fg256Close}amet,$fgDefault'
      ' $fg256Open$gray13${fg256Close}consectetur$fgDefault'
      ' $fg256Open$gray17${fg256Close}adipiscing$fgDefault'
      ' ${fgRgbOpen}249;105;14${fgRgbClose}elit,$fgDefault'
      ' ${bold}sed$notBoldNotFaint do ${faint}eiusmod$notBoldNotFaint'
      ' ${italic}tempor$notItalic'
      '$underline256Yellow'
      ' ${underline}incididunt$notUnderlined'
      ' ${strike}ut$notStriked'
      ' ${subscript}labore$notSuperscriptNotSubscript'
      ' et'
      ' ${superscript}dolore$notSuperscriptNotSubscript'
      '${underlineRgbOpen}128;255;128$underlineRgbClose'
      ' ${underline}magna$notUnderlined'
      '$underlineDefault'
      ' ${underline}aliqua$notUnderlined.';

  print(text);
}
