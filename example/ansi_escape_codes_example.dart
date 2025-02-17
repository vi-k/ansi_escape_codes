// ignore_for_file: cascade_invocations, lines_longer_than_80_chars

import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/controls.dart';

void main() {
  {
    const text1 = '$fgGreen(fgGreen)$resetFg'
        ' $fgHighGreen(fgHighGreen)$resetFg'
        ' $fg256Green(fg256Green)$resetFg'
        ' $fg256Open$HIGH_GREEN$fg256Close(fg256Open highGreen fg256Close)$resetFg'
        ' $fg256Rgb050(fg256Rgb050)$resetFg'
        ' ${fgRgbOpen}0;255;0$fgRgbClose(fgRgbOpen 0;255;0 fgRgbClose)$resetFg';
    const text2 = '$fgGreen'
        '$bgYellow(bgYellow)$resetBg'
        ' $bgHighYellow(bgHighYellow)$resetBg'
        ' $bg256Yellow(bg256Yellow)$resetBg'
        ' $bg256Open$HIGH_YELLOW$bg256Close(bg256Open highYellow bg256Close)$resetBg'
        ' $bg256HighYellow(bg256HighYellow)$resetBg'
        ' $bg256Rgb550(bg256Rgb550)$resetBg'
        ' ${bgRgbOpen}255;255;0$bgRgbClose(bgRgbOpen 255;255;0 bgRgbClose)$resetBg'
        '$resetFg';
    const text3 = '$negative$text2$resetNegative';
    const text4 = 'default $bold(bold)$resetBoldAndFaint'
        ' $faint(faint)$resetBoldAndFaint'
        ' $italicized(italicized)$resetItalicized'
        ' $underlined(underlined)$resetUnderlined'
        ' $doublyUnderlined(doublyUnderlined)$resetUnderlined'
        ' $crossedOut(crossedOut)$resetCrossedOut'
        ' $concealed(concealed)$resetConcealed'
        ' $slowlyBlinking(slowlyBlinking)'
        ' $rapidlyBlinking(rapidlyBlinking)$resetBlinking';
    const text5 = '$negative$text4$resetNegative';
    const texts = [text1, text2, text3, text4, text5];

    for (final (index, text) in texts.indexed) {
      print('${index + 1}: $text (${text.length})');
    }

    print('');
    for (final (index, text) in texts.indexed) {
      final parser = AnsiParser(text);
      final textWithoutEscapeCodes = parser.removeAll();
      print('${index + 1}: $textWithoutEscapeCodes (${parser.length})');
    }

    // showControlFunctions.
    print('');
    final parser = AnsiParser(text4);
    print(
      '4: '
      '${parser.showControlFunctions(
        open: '$faint[',
        close: ']$resetBoldAndFaint',
      )}',
    );

    // matches.
    print('');
    final buf = StringBuffer('4: ');
    for (final m in parser.matches) {
      switch (m.entity) {
        case Text(:final string):
          buf.write(string);

        case EscapeCode():
        // no-op
      }
    }
    print(buf);
  }

  // Invalid values.
  {
    print('');
    print('Invalid values:');
    print(
      AnsiParser(
        '$CSI$FOREGROUND;$COLOR_256;256$SGR'
        '$CSI$UNDERLINE_COLOR;3;1;2;3$SGR'
        '$CSI$BACKGROUND;$COLOR_RGB;100$SGR'
        '$CSI$BACKGROUND;$COLOR_RGB;200$SGR'
        '$CSI$BACKGROUND;$COLOR_RGB;200;$SGR'
        '$CSI$BACKGROUND;$COLOR_RGB;200;;$SGR'
        '$CSI$BACKGROUND;$COLOR_RGB;200;0$SGR'
        '$CSI$BACKGROUND;$COLOR_RGB;200;0;$SGR'
        '${CSI}256%',
      ).showControlFunctions(),
    );
  }

  // stateAtPos.
  {
    print('');
    const text =
        '${bold}bold ${italicized}bold+italic ${resetBoldAndFaint}italic$resetItalicized';
    final parser = AnsiParser(text);
    print(text);
    final stateAtPos0 = parser.stateAtPos(0);
    print(
      '^-- isBold=${stateAtPos0.isBold}'
      ', isItalicized=${stateAtPos0.isItalicized}',
    );
    final stateAtPos5 = parser.stateAtPos(5);
    print(
      '${' ' * 5}^-- isBold=${stateAtPos5.isBold}'
      ', isItalicized=${stateAtPos5.isItalicized}',
    );
    final stateAtPos17 = parser.stateAtPos(17);
    print(
      '${' ' * 17}^-- isBold=${stateAtPos17.isBold}'
      ', isItalicized=${stateAtPos17.isItalicized}',
    );
    final stateAtPos23 = parser.stateAtPos(23);
    print(
      '${' ' * 23}^-- isBold=${stateAtPos23.isBold}'
      ', isItalicized=${stateAtPos23.isItalicized}',
    );
  }

  // substring.
  {
    print('');
    final parser = AnsiParser(
      '$fgWhite${bold}Lorem$resetBoldAndFaint '
      '$bgHighRed$fgHighWhite${italicized}ipsum dolor sit$resetItalicized$resetBg$resetFg'
      '$fgWhite amet, consectetur $fgRed${underlined}adipiscing$resetUnderlined'
      '$fgWhite elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.$reset',
    );
    for (var i = 0; i < 40; i += 2) {
      print('"${parser.substring(i, maxLength: 40)}"');
    }
  }

  // AnsiPrinter.
  {
    print('');
    const text = ' default colors'
        ' $fg256Rgb550$bg256Rgb031 yellow on green'
        ' $resetFg$resetBg default colors ';
    print('Standart output (the default colors are set by the terminal):');
    print(text);

    const defaultState = SgrPlainState(
      foreground: Color256(Colors.rgb555),
      background: Color256(Colors.rgb320),
    );

    print('');
    print('With AnsiPrinter (the default state is overrided):');
    final printer = AnsiPrinter(
      defaultState: defaultState,
    );
    printer.print(text);

    print('');
    print('With runZonedAnsiPrinter (the default state is overrided):');
    runZonedAnsiPrinter(
      defaultState: defaultState,
      () {
        print(text);
      },
    );
  }

  // Stacked AnsiPrinter.
  {
    const importantNote = '${italicized}Important note$resetItalicized';
    const text1 = 'Normal text $importantNote Normal text';
    const text2 =
        '${italicized}Important text $importantNote Important text$resetItalicized';

    print('');
    print(text1); // Normal text <i>Important</i> note Normal text

    print('');
    print('Insertion breaks the style of the text:');
    print(text2); // <i>Important text Important note</i> Important text

    print('');
    print('The state is accumulated in the stack:');
    final stackedPrinter = AnsiPrinter(stacked: true);
    stackedPrinter
        .print(text2); // <i>Important text Important note Important text</i>
  }

  // Tabs.
  if (stdout.hasTerminal) {
    print('');
    const text = '0\t1\t2\t3\t4\t5\t6\t7\t8\t9';
    print(text);
    tabs(defaultTab: 12);
    print(text);
    tabs();
  }
}
