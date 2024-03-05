import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;

void main() {
  stdout
    ..writeln(
      'Bold: ${ansi.bold}Bold${ansi.normalIntensity} / Normal${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Faint: ${ansi.faint}Faint${ansi.normalIntensity} / Normal${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Italic: ${ansi.italic}Italic${ansi.notItalic} / Not italic${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Underline: ${ansi.underline}Underlined${ansi.notUnderlined} / Not underlined${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Underline (rgb): '
      '${ansi.underline}${ansi.underlineRgb(255, 128, 0)} Test '
      '${ansi.underline256(ansi.yellow)} Test '
      '${ansi.notUnderlined}${ansi.reset}'
      ' | '
      '${ansi.underline} Test '
      '${ansi.underlineColorDefault} Test '
      '${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Blink: ${ansi.blink}Blink${ansi.notBlinking} / Not blink${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Rapid blink: ${ansi.rapidBlink}Blink${ansi.notBlinking} / Not blink${ansi.reset}',
    )
    ..writeln()
    ..writeln('Invert: '
        ' Not inverted '
        '${ansi.reverse} Inverted ${ansi.notReversed}'
        ' Not inverted ${ansi.reset}')
    ..writeln('        '
        '${ansi.bgBlue} Not inverted '
        '${ansi.reverse} Inverted ${ansi.notReversed}'
        ' Not inverted ${ansi.reset}')
    ..writeln('        '
        '${ansi.fgYellow} Not inverted '
        '${ansi.reverse} Inverted ${ansi.notReversed}'
        ' Not inverted ${ansi.reset}')
    ..writeln('        '
        '${ansi.bgBlue}${ansi.fgYellow} Not inverted '
        '${ansi.reverse} Inverted ${ansi.notReversed}'
        ' Not inverted ${ansi.reset}')
    ..writeln()
    ..writeln(
      'Hide:'
      ' ${ansi.hide} Hidden ${ansi.notHide}'
      ' / Not hidden ${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Strike: '
      '${ansi.strike} Strike ${ansi.notStrike}'
      ' / Not strike ${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Doubly undeline: '
      '${ansi.doublyUnderlined} Underlined ${ansi.notUnderlined}'
      ' / Not underlined ${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Frame: '
      '${ansi.framed} Framed ${ansi.notFramedNotEncircled}'
      ' / Not framed ${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Encircle: '
      '${ansi.encircled} Encircled ${ansi.notFramedNotEncircled}'
      ' / Not encircled ${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Overline: '
      '${ansi.overlined} Overlined ${ansi.notOverlined}'
      ' / Not overlined ${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Superscipt: '
      '${ansi.superscript} Superscript ${ansi.notSuperscriptNotSubscript}'
      ' / Not superscript ${ansi.reset}',
    )
    ..writeln()
    ..writeln(
      'Subscript: '
      '${ansi.subscript} Subscript ${ansi.notSuperscriptNotSubscript}'
      ' / Not subscript ${ansi.reset}',
    );
}
