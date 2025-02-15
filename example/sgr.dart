// ignore_for_file: lines_longer_than_80_chars

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  // Bold and faint.
  print('Bold/faint:');
  print('  No colors:');
  print(
    '    Normal'
    ' / ${bold}Bold$resetBoldAndFaint'
    ' / ${faint}Faint$resetBoldAndFaint'
    ' / $bold${faint}Bold+faint$resetBoldAndFaint'
    ' / $faint${bold}Faint+bold$resetBoldAndFaint'
    ' / Normal$reset',
  );
  print('  With colors:');
  print(
    '    $bgGreen${fgYellow}Normal'
    ' / ${bold}Bold$resetBoldAndFaint'
    ' / ${faint}Faint$resetBoldAndFaint'
    ' / $bold${faint}Bold+faint$resetBoldAndFaint'
    ' / $faint${bold}Faint+bold$resetBoldAndFaint'
    ' / Normal$reset',
  );

  // Italicized.
  print('Italicized: ');
  print(
    '    Normal'
    ' / ${italicized}Italicized$resetItalicized'
    ' / Normal$reset',
  );

  // Underlined.
  print('Underlined:');
  print('  No colors:');
  print(
    '    Normal'
    ' / ${underlined}Underlined$resetUnderlined'
    ' / Normal$reset',
  );
  print('  underline256Yellow:');
  print(
    '    Normal'
    ' / $underline256Yellow${underlined}Underlined$resetUnderlined'
    ' / Normal$reset',
  );
  print('  underline256Red:');
  print(
    '    Normal'
    ' / $underline256Red${underlined}Underlined$resetUnderlined'
    ' / Normal$reset',
  );
  print('  underlineRgb(255, 128, 0): ');
  print(
    '    Normal'
    ' / ${underlineRgb(255, 128, 0)}${underlined}Underlined$resetUnderlined'
    ' / Normal$reset',
  );
  print('  Transition:');
  print(
    '    Normal'
    ' / $underlined default'
    ' $underline256Magenta underline256Magenta'
    ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
    ' $underline256Cyan underline256Cyan'
    ' $resetUnderlineColor default $resetUnderlined'
    ' / Normal$reset',
  );

  // Doubly undelined.
  print('Doubly undelined:');
  print('  No colors:');
  print(
    '    Normal'
    ' / ${doublyUnderlined}Underlined$resetUnderlined'
    ' / Normal$reset',
  );
  print('  underline256Yellow:');
  print(
    '    Normal'
    ' / $underline256Yellow${doublyUnderlined}Underlined$resetUnderlined'
    ' / Normal$reset',
  );
  print('  underline256Red:');
  print(
    '    Normal'
    ' / $underline256Red${doublyUnderlined}Underlined$resetUnderlined'
    ' / Normal$reset',
  );
  print('  underlineRgb(255, 128, 0): ');
  print(
    '    Normal'
    ' / ${underlineRgb(255, 128, 0)}${doublyUnderlined}Underlined$resetUnderlined'
    ' / Normal$reset',
  );
  print('  Transition:');
  print(
    '    Normal'
    ' / $doublyUnderlined default'
    ' $underline256Magenta underline256Magenta'
    ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
    ' $underline256Cyan underline256Cyan'
    ' $resetUnderlineColor default $resetUnderlined'
    ' / Normal$reset',
  );

  // Blinking.
  print('Blinking:');
  print('    Normal'
      ' / ${slowlyBlinking}Slowly blinking$resetBlinking'
      ' / ${rapidlyBlinking}Rapidly blinking$resetBlinking'
      ' / Normal$reset');

  // Reverse.
  print('Negative:');
  print('  No colors:');
  print(
    '     Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Background (bgGreen):');
  print(
    '    $bgGreen Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Background (bg256Green):');
  print(
    '    $bg256Green Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Background (bg256Rgb050):');
  print(
    '    $bg256Rgb050 Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Background (bgRgb(0,255,255)):');
  print(
    '    ${bgRgb(0, 255, 0)} Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Foreground (fgYellow):');
  print(
    '    $fgYellow Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Foreground (fg256Yellow):');
  print(
    '    $fg256Yellow Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Foreground (fg256Rgb550):');
  print(
    '    $fg256Rgb550 Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Foreground (fgRgb(255,255,0)):');
  print(
    '    ${fgRgb(255, 255, 0)} Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Background (bgGreen) + foreground (fgYellow):');
  print(
    '    $bgGreen$fgYellow Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Background (bg256Green) + foreground (fg256Yellow):');
  print(
    '    $bg256Green$fg256Yellow Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Background (bg256Rgb050) + foreground (fg256Rgb550):');
  print(
    '    $bg256Rgb050$fg256Rgb550 Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );
  print('  Background (bgRgb(0,255,0)) + foreground (fgRgb(255,255,0)):');
  print(
    '    ${bgRgb(0, 255, 0)}${fgRgb(255, 255, 0)} Normal '
    '$negative Negative $resetNegative'
    ' Normal $reset',
  );

  // Conceal.
  print('Conceal:');
  print(
    '  Normal'
    ' / $concealed Conceal $resetConcealed'
    ' / Normal $reset',
  );

  // Crossed out.
  print('Crossed out:');
  print(
    '  Normal'
    ' / $crossedOut Crossed out $resetCrossedOut'
    ' / $crossedOut${underlined}Crossed out+underlined$resetUnderlined$resetCrossedOut'
    ' / $underlined${crossedOut}Underlined+crossed out$resetCrossedOut$resetUnderlined'
    ' / Normal $reset',
  );

  // Framed and encircled.
  print('Framed: ');
  print(
    '  Normal'
    ' / $framed Framed $resetFramedAndEncircled'
    ' / $framed Framed$fg256Green+colors $resetFg$resetFramedAndEncircled'
    ' / Normal $reset',
  );
  print('Encircled: ');
  print(
    '  Normal'
    ' / $encircled Encircled $resetFramedAndEncircled'
    ' / $encircled Encircled$fg256Green+colors $resetFg$resetFramedAndEncircled'
    ' / Normal $reset',
  );

  // Overlined.
  print('Overlined: ');
  print('  No colors:');
  print(
    '    Normal'
    ' / $overlined Overlined $resetOverlined'
    ' / $overlined${underlined}Overlined+underlined$resetUnderlined$resetOverlined'
    ' / $overlined${crossedOut}Overlined+crossed out$resetCrossedOut$resetOverlined'
    ' / $overlined$underlined${crossedOut}Overlined+underlined+crossed out$resetCrossedOut$resetUnderlined$resetOverlined'
    ' / Normal $reset',
  );
  print('  underline256Yellow:');
  print(
    '    ${underline256Yellow}Normal'
    ' / $overlined Overlined $resetOverlined'
    ' / $overlined${underlined}Overlined+underlined$resetUnderlined$resetOverlined'
    ' / $overlined${crossedOut}Overlined+crossed out$resetCrossedOut$resetOverlined'
    ' / $overlined$underlined${crossedOut}Overlined+underlined+crossed out$resetCrossedOut$resetUnderlined$resetOverlined'
    ' / Normal $reset',
  );
  print('  underlineRgb(255, 128, 0): ');
  print(
    '    ${underlineRgb(255, 128, 0)}Normal'
    ' / $overlined Overlined $resetOverlined'
    ' / $overlined${underlined}Overlined+underlined$resetUnderlined$resetOverlined'
    ' / $overlined${crossedOut}Overlined+crossed out$resetCrossedOut$resetOverlined'
    ' / $overlined$underlined${crossedOut}Overlined+underlined+crossed out$resetCrossedOut$resetUnderlined$resetOverlined'
    ' / Normal $reset',
  );
  print('  Transition:');
  print(
    '    Normal'
    ' / $overlined default'
    ' $underline256Magenta underline256Magenta'
    ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
    ' $underline256Cyan underline256Cyan'
    ' $resetUnderlineColor default $resetOverlined'
    ' / Normal$reset',
  );

  // Superscipt and Subscript.
  print('Superscipt: ');
  print(
    '    Normal'
    ' / $superscripted Superscript $resetSuperAndSubscripted'
    ' / Normal $reset',
  );
  print('Subscript: ');
  print(
    '    Normal'
    ' / $subscripted Subscript $resetSuperAndSubscripted'
    ' / Normal $reset',
  );
}
