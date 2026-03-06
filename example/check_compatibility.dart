import 'package:ansi_escape_codes/ansi_escape_codes.dart';

import 'utils.dart';

/// Usage:
///
/// ```bash
/// dart run example/sgr.dart
/// ```
void main() {
  // Bold and dim.
  title('Bold/dim:');
  subsubtitle('  No colors:');
  print(
    '    Normal'
    ' / ${bold}Bold$resetBoldAndDim'
    ' / ${dim}Dim$resetBoldAndDim'
    ' / $bold${dim}Bold+dim$resetBoldAndDim'
    ' / $dim${bold}Dim+bold$resetBoldAndDim'
    ' / Normal$reset',
  );
  subsubtitle('  With colors:');
  print(
    '    $bgGreen${fgYellow}Normal'
    ' / ${bold}Bold$resetBoldAndDim'
    ' / ${dim}Dim$resetBoldAndDim'
    ' / $bold${dim}Bold+dim$resetBoldAndDim'
    ' / $dim${bold}Dim+bold$resetBoldAndDim'
    ' / Normal$reset',
  );

  // Italic.
  title('Italic: ');
  print(
    '    Normal'
    ' / ${italic}Italic$resetItalic'
    ' / Normal$reset',
  );

  // Underline.
  title('Underline:');
  subsubtitle('  No colors:');
  print(
    '    Normal'
    ' / ${underline}Underline$resetUnderline'
    ' / Normal$reset',
  );
  subsubtitle('  underline256Yellow:');
  print(
    '    Normal'
    ' / $underline256Yellow${underline}Underline$resetUnderline'
    ' / Normal$reset',
  );
  subsubtitle('  underline256Red:');
  print(
    '    Normal'
    ' / $underline256Red${underline}Underline$resetUnderline'
    ' / Normal$reset',
  );
  subsubtitle('  underlineRgb(255, 128, 0): ');
  print(
    '    Normal'
    ' / ${underlineRgb(255, 128, 0)}${underline}Underline$resetUnderline'
    ' / Normal$reset',
  );
  subsubtitle('  Transition:');
  print(
    '    Normal'
    ' / $underline default'
    ' $underline256Magenta underline256Magenta'
    ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
    ' $underline256Cyan underline256Cyan'
    ' $resetUnderlineColor default $resetUnderline'
    ' / Normal$reset',
  );

  // Doubly undeline.
  title('Doubly undeline:');
  subsubtitle('  No colors:');
  print(
    '    Normal'
    ' / ${doublyUnderline}Underline$resetUnderline'
    ' / Normal$reset',
  );
  subsubtitle('  underline256Yellow:');
  print(
    '    Normal'
    ' / $underline256Yellow${doublyUnderline}Underline$resetUnderline'
    ' / Normal$reset',
  );
  subsubtitle('  underline256Red:');
  print(
    '    Normal'
    ' / $underline256Red${doublyUnderline}Underline$resetUnderline'
    ' / Normal$reset',
  );
  subsubtitle('  underlineRgb(255, 128, 0): ');
  print(
    '    Normal'
    ' / ${underlineRgb(255, 128, 0)}${doublyUnderline}Underline$resetUnderline'
    ' / Normal$reset',
  );
  subsubtitle('  Transition:');
  print(
    '    Normal'
    ' / $doublyUnderline default'
    ' $underline256Magenta underline256Magenta'
    ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
    ' $underline256Cyan underline256Cyan'
    ' $resetUnderlineColor default $resetUnderline'
    ' / Normal$reset',
  );

  // Blink.
  title('Blink:');
  print(
    '    Normal'
    ' / ${blink}Blink$resetBlink'
    ' / ${blinkRapid}Blink rapid$resetBlink'
    ' / Normal$reset',
  );

  // Inverse.
  title('Inverse:');
  subsubtitle('  No colors:');
  print(
    '     Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Background (bgGreen):');
  print(
    '    $bgGreen Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Background (bg256Green):');
  print(
    '    $bg256Green Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Background (bg256Rgb050):');
  print(
    '    $bg256Rgb050 Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Background (bgRgb(0,255,255)):');
  print(
    '    ${bgRgb(0, 255, 0)} Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Foreground (fgYellow):');
  print(
    '    $fgYellow Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Foreground (fg256Yellow):');
  print(
    '    $fg256Yellow Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Foreground (fg256Rgb550):');
  print(
    '    $fg256Rgb550 Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Foreground (fgRgb(255,255,0)):');
  print(
    '    ${fgRgb(255, 255, 0)} Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Background (bgGreen) + foreground (fgYellow):');
  print(
    '    $bgGreen$fgYellow Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Background (bg256Green) + foreground (fg256Yellow):');
  print(
    '    $bg256Green$fg256Yellow Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Background (bg256Rgb050) + foreground (fg256Rgb550):');
  print(
    '    $bg256Rgb050$fg256Rgb550 Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );
  subsubtitle('  Background (bgRgb(0,255,0)) + foreground (fgRgb(255,255,0)):');
  print(
    '    ${bgRgb(0, 255, 0)}${fgRgb(255, 255, 0)} Normal '
    '$inverse Inverse $resetInverse'
    ' Normal $reset',
  );

  // Invisible.
  title('Invisible:');
  print(
    '  Normal'
    ' / $invisible Invisible $resetInvisible'
    ' / Normal $reset',
  );

  // Strikethrough.
  title('Strikethrough:');
  print(
    '  Normal'
    ' / $strikethrough Strikethrough $resetStrikethrough'
    ' / $strikethrough${underline}Strikethrough+underline$resetUnderline$resetStrikethrough'
    ' / $underline${strikethrough}Underline+strikethrough$resetStrikethrough$resetUnderline'
    ' / Normal $reset',
  );

  // Frame and encircle.
  title('Frame: ');
  print(
    '  Normal'
    ' / $frame Frame $resetFrameAndEncircle'
    ' / $frame Frame$fg256Green+colors $resetFg$resetFrameAndEncircle'
    ' / Normal $reset',
  );
  title('Encircle: ');
  print(
    '  Normal'
    ' / $encircle Encircle $resetFrameAndEncircle'
    ' / $encircle Encircle$fg256Green+colors $resetFg$resetFrameAndEncircle'
    ' / Normal $reset',
  );

  // Overline.
  title('Overline: ');
  subsubtitle('  No colors:');
  print(
    '    Normal'
    ' / $overline Overline $resetOverline'
    ' / $overline${underline}Overline+underline$resetUnderline$resetOverline'
    ' / $overline${strikethrough}Overline+strikethrough$resetStrikethrough$resetOverline'
    ' / $overline$underline${strikethrough}Overline+underline+strikethrough$resetStrikethrough$resetUnderline$resetOverline'
    ' / Normal $reset',
  );
  subsubtitle('  underline256Yellow:');
  print(
    '    ${underline256Yellow}Normal'
    ' / $overline Overline $resetOverline'
    ' / $overline${underline}Overline+underline$resetUnderline$resetOverline'
    ' / $overline${strikethrough}Overline+strikethrough$resetStrikethrough$resetOverline'
    ' / $overline$underline${strikethrough}Overline+underline+strikethrough$resetStrikethrough$resetUnderline$resetOverline'
    ' / Normal $reset',
  );
  subsubtitle('  underlineRgb(255, 128, 0): ');
  print(
    '    ${underlineRgb(255, 128, 0)}Normal'
    ' / $overline Overline $resetOverline'
    ' / $overline${underline}Overline+underline$resetUnderline$resetOverline'
    ' / $overline${strikethrough}Overline+strikethrough$resetStrikethrough$resetOverline'
    ' / $overline$underline${strikethrough}Overline+underline+strikethrough$resetStrikethrough$resetUnderline$resetOverline'
    ' / Normal $reset',
  );
  subsubtitle('  Transition:');
  print(
    '    Normal'
    ' / $overline default'
    ' $underline256Magenta underline256Magenta'
    ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
    ' $underline256Cyan underline256Cyan'
    ' $resetUnderlineColor default $resetOverline'
    ' / Normal$reset',
  );

  // Superscipt and Subscript.
  title('Superscipt: ');
  print(
    '    Normal'
    ' / $superscript Superscript $resetSuperAndSubscript'
    ' / Normal $reset',
  );
  title('Subscript: ');
  print(
    '    Normal'
    ' / $subscript Subscript $resetSuperAndSubscript'
    ' / Normal $reset',
  );
}
