import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const text =
      // 4-bit colors.
      '${fgBrightGreen}Lorem'
      ' ${fgGreen}ipsum'
      ' $bgBrightBlack${fgWhite}dolor$bgDefault'
      ' $bgBrightWhite${fgBlack}sit$bgDefault'
      // 8-bit colors.
      ' ${fg256HighRed}amet,'
      ' ${fg256Red}consectetur$fgDefault'
      // 24-bit colors.
      ' ${bgRgbOpen}249;105;14$bgRgbClose'
      '${fgRgbOpen}64;48;32$fgRgbClose'
      'adipiscing'
      // Inverted colors.
      ' $invert elit,$notInverted'
      '$fgDefault$bgDefault'
      // Italic.
      ' ${italic}sed$notItalic'
      ' do'
      // Bold and faint.
      ' ${bold}eiusmod$notBoldNotFaint'
      ' ${faint}tempor$notBoldNotFaint'
      '$fgCyan'
      ' incididunt'
      ' ${increasedIntensity}ut$normalIntensity'
      ' ${decreasedIntensity}labore$normalIntensity'
      '$fgDefault'
      // Etc.
      ' ${underline}et$notUnderlined'
      ' ${strike}dolore$notStriked'
      ' ${hide}magna$notHidden'
      ' ${blink}aliqua$notBlinking.';

  print(text);

  print(removeBackgroundColors(text));
  print(removeEscapeSequences(text));
  print(
    showEscapeSequences(
      text,
      recognizeSequences: true,
    ),
  );
  print(
    handleEscapeSequences(
      text,
      (seq) => '$seq${showEscapeSequences(seq, recognizeSequences: true)}',
    ),
  );
}
