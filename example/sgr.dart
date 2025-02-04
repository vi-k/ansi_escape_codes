import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  stdout
    // Bold and faint.
    ..writeln(
      'Bold: ${bold}Bold$neitherBoldNorFaint / Normal$reset',
    )
    ..writeln()
    ..writeln(
      'Faint: ${faint}Faint$neitherBoldNorFaint / Normal$reset',
    )
    ..writeln()
    // Italic.
    ..writeln(
      'Italic: ${italic}Italic$notItalic / Not italic$reset',
    )
    ..writeln()
    // Underline.
    ..writeln('Underline:')
    ..writeln('  No colors:')
    ..writeln(
      '    Not underlined'
      ' / ${underline}Underlined$notUnderlined'
      ' / Not underlined$reset',
    )
    ..writeln('  underline256Yellow:')
    ..writeln(
      '    Not underlined'
      ' / $underline256Yellow${underline}Underlined$notUnderlined'
      ' / Not underlined$reset',
    )
    ..writeln('  underline256Red:')
    ..writeln(
      '    Not underlined'
      ' / $underline256Red${underline}Underlined$notUnderlined'
      ' / Not underlined$reset',
    )
    ..writeln('  underlineRgb(255, 128, 0): ')
    ..writeln(
      '    Not underlined'
      ' / ${underlineRgb(255, 128, 0)}${underline}Underlined$notUnderlined'
      ' / Not underlined$reset',
    )
    ..writeln('  Transition:')
    ..writeln(
      '    $underline default'
      ' $underline256Magenta underline256Magenta'
      ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
      ' $underline256Cyan underline256Cyan'
      ' $underlineDefault default'
      ' $notUnderlined / Not underlined$reset',
    )
    ..writeln()
    // Blink and rapid blink.
    ..writeln(
      'Blink: ${blink}Blink$notBlinking / Not blink$reset',
    )
    ..writeln()
    ..writeln(
      'Rapid blink: ${rapidBlink}Blink$notBlinking / Not blink$reset',
    )
    ..writeln()
    // Reverse.
    ..writeln('Reverse:')
    ..writeln('  No colors:')
    ..writeln('    Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Background (bgBlue):')
    ..writeln('    $bgBlue Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Background (bg256Blue):')
    ..writeln('    $bg256Blue Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Background (bg256Rgb005):')
    ..writeln('    $bg256Rgb005 Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Background (bgRgb(0,0,255)):')
    ..writeln('    ${bgRgb(0, 0, 255)} Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Foreground (fgYellow):')
    ..writeln('    $fgYellow Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Foreground (fg256Yellow):')
    ..writeln('    $fg256Yellow Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Foreground (fg256Rgb550):')
    ..writeln('    $fg256Rgb550 Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Foreground (fgRgb(255,255,0)):')
    ..writeln('    ${fgRgb(255, 255, 0)} Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Background (bgBlue) + Foreground (fgYellow):')
    ..writeln('    $bgBlue$fgYellow Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Background (bg256Blue) + Foreground (fg256Yellow):')
    ..writeln('    $bg256Blue$fg256Yellow Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Background (bg256Rgb005) + Foreground (fg256550):')
    ..writeln('    $bg256Rgb005$fg256Rgb550 Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln('  Background (bgRgb(0,0,255)) + Foreground (fgRgb(255,255,0)):')
    ..writeln('    ${bgRgb(0, 0, 255)}${fgRgb(255, 255, 0)} Not reversed '
        '$reverse Reversed $notReversed Not reversed $reset')
    ..writeln()
    // Conceal.
    ..writeln(
      'Conceal:'
      ' $conceal Conceal $reveal'
      ' / Reveal $reset',
    )
    ..writeln()
    // Crossed out.
    ..writeln(
      'Crossed out: '
      '$crossedOut Crossed out $notCrossedOut'
      ' / Not crossed out $reset',
    )
    ..writeln()
    ..writeln(
      '  Crossed out + underline: '
      '${crossedOut}Crossed out / ${underline}Underline$reset',
    )
    ..writeln()
    ..writeln(
      '  Underline + crossed out: '
      '${underline}Underline / ${crossedOut}Crossed out$reset',
    )
    ..writeln()
    // Doubly undelined.
    ..writeln(
      'Doubly undelined: '
      '$doublyUnderlined Underlined $notUnderlined'
      ' / Not underlined $reset',
    )
    ..writeln('  No colors:')
    ..writeln(
      '    Not underlined'
      ' / ${doublyUnderlined}Underlined$notUnderlined'
      ' / Not underlined$reset',
    )
    ..writeln('  underline256Yellow:')
    ..writeln(
      '    Not underlined'
      ' / $underline256Yellow${doublyUnderlined}Underlined$notUnderlined'
      ' / Not underlined$reset',
    )
    ..writeln('  underline256Red:')
    ..writeln(
      '    Not underlined'
      ' / $underline256Red${doublyUnderlined}Underlined$notUnderlined'
      ' / Not underlined$reset',
    )
    ..writeln('  underlineRgb(255, 128, 0): ')
    ..writeln(
      '    Not underlined'
      ' / ${underlineRgb(255, 128, 0)}${doublyUnderlined}Underlined$notUnderlined'
      ' / Not underlined$reset',
    )
    ..writeln('  Transition:')
    ..writeln(
      '    $doublyUnderlined default'
      ' $underline256Magenta underline256Magenta'
      ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
      ' $underline256Cyan underline256Cyan'
      ' $underlineDefault default'
      ' $notUnderlined / Not underlined$reset',
    )
    ..writeln()
    // Framed and encircled.
    ..writeln(
      'Framed: '
      '$framed Framed $neitherFramedNorEncircled'
      ' / Not framed $reset',
    )
    ..writeln()
    ..writeln(
      '  Colors (default + fg256Green):'
      ' $framed Fra${fg256Green}med $reset',
    )
    ..writeln()
    ..writeln(
      'Encircled: '
      '$encircled Encircled $neitherFramedNorEncircled'
      ' / Not encircled $reset',
    )
    ..writeln()
    ..writeln(
      '  Colors (default + fg256Cyan):'
      ' $encircled Enci${fg256Cyan}rcled $reset',
    )
    ..writeln()
    // Overlined.
    ..writeln(
      'Overlined: '
      '$overlined Overlined $notOverlined'
      ' / Not overlined $reset',
    )
    ..writeln()
    ..writeln(
      '  Overlined + underline: '
      '${overlined}Overlined / ${underline}Underline$reset',
    )
    ..writeln()
    ..writeln(
      '  Underline + overlined: '
      '${underline}Underline / ${overlined}Overlined$reset',
    )
    ..writeln()
    ..writeln(
      '  Overlined + crossed out: '
      '${overlined}Overlined / ${crossedOut}Crossed out$reset',
    )
    ..writeln()
    ..writeln(
      '  Crossed out + overlined: '
      '${crossedOut}Crossed out / ${overlined}Overlined$reset',
    )
    ..writeln()
    ..writeln('  No colors:')
    ..writeln(
      '    Not overlined'
      ' / ${overlined}Overlined$notOverlined'
      ' / Not overlined$reset',
    )
    ..writeln('  underline256Yellow:')
    ..writeln(
      '    Not overlined'
      ' / $underline256Yellow${overlined}Overlined$notOverlined'
      ' / Not overlined$reset',
    )
    ..writeln('  underline256Red:')
    ..writeln(
      '    Not overlined'
      ' / $underline256Red${overlined}Overlined$notOverlined'
      ' / Not overlined$reset',
    )
    ..writeln('  underlineRgb(255, 128, 0): ')
    ..writeln(
      '    Not overlined'
      ' / ${underlineRgb(255, 128, 0)}${overlined}Overlined$notOverlined'
      ' / Not overlined$reset',
    )
    ..writeln('  Transition:')
    ..writeln(
      '    $overlined default'
      ' $underline256Magenta underline256Magenta'
      ' ${underlineRgb(0, 255, 0)} underlineRgb(0, 255, 0)'
      ' $underline256Cyan underline256Cyan'
      ' $underlineDefault default'
      ' $notOverlined / Not overlined$reset',
    )
    ..writeln()
    // Superscipt and Subscript.
    ..writeln(
      'Superscipt: '
      '$superscript Superscript'
      ' $netherSuperscriptedNorSubscripted'
      ' / Not superscript $reset',
    )
    ..writeln()
    ..writeln(
      'Subscript: '
      '$subscript Subscript'
      ' $netherSuperscriptedNorSubscripted'
      ' / Not subscript $reset',
    );
}
