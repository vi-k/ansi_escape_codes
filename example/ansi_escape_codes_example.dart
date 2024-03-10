import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';

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

  // print(hasSgr(fgGreen));
  // print(hasSgr(fgBrightGreen));
  // print(hasSgr(fgDefault));
  // print(hasSgr(fg256Red));
  // print(hasSgr(fg256Rgb000));
  // print(hasSgr('${fgRgbOpen}0;0;0$fgRgbClose'));

  // print(hasForegroundColor(fgGreen));
  // print(hasForegroundColor(fgBrightGreen));
  // print(hasForegroundColor(fgDefault));
  // print(hasForegroundColor(fg256Red));
  // print(hasForegroundColor(fg256Rgb000));
  // print(hasForegroundColor('${fgRgbOpen}0;0;0$fgRgbClose'));

  // print(hasBackgroundColor(bgGreen));
  // print(hasBackgroundColor(bgBrightGreen));
  // print(hasBackgroundColor(bgDefault));
  // print(hasBackgroundColor(bg256Red));
  // print(hasBackgroundColor(bg256Rgb000));
  // print(hasBackgroundColor('${bgRgbOpen}0;0;0$bgRgbClose'));

  // const fg = '$fgGreen${fgRgbOpen}0;0;0$fgRgbClose';
  // const bg = '123$bgGreen$bg256Gray0';
  // const colors = '$fg$bg';
  // print(foregroundColors(colors).showEsc);
  // print(backgroundColors(colors).showEsc);
  // print(allSgr(colors).showEsc);
}

extension on List<String> {
  List<String> get showEsc => map((e) => e.showEsc).toList();
}
