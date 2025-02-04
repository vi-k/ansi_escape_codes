// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const text = '${fgGreen}fgGreen$fgDefault'
      ' ${fgBrightGreen}fgBrightGreen$fgDefault'
      ' ${fg256Green}fg256Green$fgDefault'
      ' ${fg256HighGreen}fg256HighGreen$fgDefault'
      ' ${fg256Rgb050}fg256Rgb050$fgDefault'
      ' ${fgRgbOpen}0;255;0${fgRgbClose}fgRgbOpen/0;255;0/fgRgbClose$fgDefault'
      '\n'
      '$fgGreen'
      '${bgYellow}bgYellow$bgDefault'
      ' ${bgBrightYellow}bgBrightYellow$bgDefault'
      ' ${bg256Yellow}bg256Yellow$bgDefault'
      ' ${bg256HighYellow}bg256HighYellow$bgDefault'
      ' ${bg256Rgb550}bg256Rgb550$bgDefault'
      ' ${bgRgbOpen}255;255;0${bgRgbClose}bgRgbOpen/255;255;0/bgRgbClose$bgDefault'
      '\n'
      //
      '$reverse'
      '${bgYellow}bgYellow$bgDefault'
      ' ${bgBrightYellow}bgBrightYellow$bgDefault'
      ' ${bg256Yellow}bg256Yellow$bgDefault'
      ' ${bg256HighYellow}bg256HighYellow$bgDefault'
      ' ${bg256Rgb550}bg256Rgb550$bgDefault'
      ' ${bgRgbOpen}255;255;0${bgRgbClose}bgRgbOpen/255;255;0/bgRgbClose$bgDefault'
      '$notReversed$fgDefault$bgDefault\n'
      //
      '${bold}bold$neitherBoldNorFaint'
      ' ${faint}faint$neitherBoldNorFaint'
      ' ${italic}italic$notItalic'
      ' ${underline}underline$notUnderlined'
      ' ${doublyUnderlined}doublyUnderlined$notUnderlined'
      ' ${crossedOut}crossedOut$notCrossedOut'
      ' ${conceal}conceal$reveal'
      ' ${blink}blink ${rapidBlink}rapidBlink$notBlinking.';

  print(text);
  print('length = ${text.length}');

  print('');
  final parser = AnsiParser(text);
  final textWithoutEscapeCodes = parser.removeAll();
  print(textWithoutEscapeCodes);
  print('length = ${parser.length} = ${textWithoutEscapeCodes.length}');

  print('');
  print(parser.replaceAll((ansi) => '[${ansi.id}]'));
  // [fgGreen]fgGreen[fgDefault]
  // [fgBrightGreen]fgBrightGreen[fgDefault]
  // [fg256Green]fg256Green[fgDefault] ...

  print('');
  print('Invalid values:');
  print(
    AnsiParser(
      '${fg256Open}256$fg256Close'
      '${bg256Open}256$bg256Close'
      '${csi}256$sgr'
      '${csi}256y',
    ).replaceAll((ansi) => '[${ansi.id}]'),
  );
  // [unknown_foreground:CSI 38;5;256 SGR]
  // [unknown_background:CSI 48;5;256 SGR]
  // [unknown_sgr:CSI 256 SGR]
  // [unknown_csi:CSI 256 y]

  print('');
  const text2 =
      '${bold}bold ${italic}bold+italic ${neitherBoldNorFaint}italic$notItalic';
  final parser2 = AnsiParser(text2);
  print(text2);
  print('length = ${parser2.length}');
  print(
    'pos 0: isBold=${parser2.stateAtPos(0).isBold}'
    ', isItalic=${parser2.stateAtPos(0).isItalic}',
  );
  print(
    'pos 5: isBold=${parser2.stateAtPos(5).isBold}'
    ', isItalic=${parser2.stateAtPos(5).isItalic}',
  );
  print(
    'pos 17: isBold=${parser2.stateAtPos(17).isBold}'
    ', isItalic=${parser2.stateAtPos(17).isItalic}',
  );
  print(
    'pos 23: isBold=${parser2.stateAtPos(23).isBold}'
    ', isItalic=${parser2.stateAtPos(23).isItalic}',
  );

  print('');
  const saveAndRestoreCursor = '${saveCursor}100%${restoreCursor}2';
  print(saveAndRestoreCursor);
  print(
    AnsiParser(saveAndRestoreCursor).replaceAll((ansi) => '[${ansi.id}]'),
  );

  print('');
  for (var i = 0; i < 20; i++) {
    print('"${parser.substring(i, maxLength: 40)}"');
  }

  print('');
  const text3 = ' default colors'
      ' $fg256Rgb550$bg256Rgb031 yellow on green'
      ' $fgDefault$bgDefault default colors ';
  print('Standart output:');
  print(text3);

  print('');
  print('With AnsiPrinter.stdout():');
  final stdoutPrinter = AnsiPrinter.stdout(
    stdout,
    defaultState: const AnsiPlainState(
      foregroundColor: AnsiForeground256(rgb555),
      backgroundColor: AnsiBackground256(rgb320),
    ),
  );
  stdoutPrinter.print(text3);
  print(text3);
  stdoutPrinter.print(text3);

  print('');
  print('With AnsiPrinter.print():');
  final printer = AnsiPrinter.print(
    defaultState: const AnsiPlainState(
      foregroundColor: AnsiForeground256(rgb555),
      backgroundColor: AnsiBackground256(rgb320),
    ),
    output: print,
  );
  printer.print(text3);
  printer.print(text3);

  print('');
  print('Or ansiPrinter:');
  ansiPrinter(
    defaultState: const AnsiPlainState(
      foregroundColor: AnsiForeground256(rgb555),
      backgroundColor: AnsiBackground256(rgb320),
    ),
    () {
      print(text3);
      print(text3);
    },
  );

  stdout.writeln();

  // const text4 = '${italic}i1 ${italic}i2 ${notItalic}i1 ${notItalic}notItalic';
  const text4 = ' 1 '
      '$bg256Rgb500$italic 2 '
      '$bg256Rgb550$italic 3 '
      '$bg256Rgb050$bold bold '
      '$faint bold+faint '
      '$neitherBoldNorFaint bold '
      '$bgDefault$notItalic$neitherBoldNorFaint 5 '
      '$bgDefault$notItalic 6 '
      '$bgDefault 7 ';
  print('Standart output:');
  print('With AnsiStackedPrinter.print():');
  final printer2 = AnsiStackedPrinter.print(
    defaultState: const AnsiPlainState(
      foregroundColor: AnsiForeground256(rgb555),
      backgroundColor: AnsiBackground256(rgb320),
      // italic: true,
    ),
    // ignore: invalid_use_of_visible_for_testing_member
    debugForTest: true,
    output: print,
  );
  printer2.print(text4);
  // printer.print(text4);

  print('$csi?1049h aaaa $csi?1049l');
}
