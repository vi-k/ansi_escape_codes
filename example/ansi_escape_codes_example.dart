// ignore_for_file: cascade_invocations, lines_longer_than_80_chars, prefer_single_quotes

import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/controls.dart';
import 'package:ansi_escape_codes/extensions.dart';

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
    print('With AnsiPrinter.print (the default state is overrided):');
    final printer = AnsiPrinter.print(
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
    String b(String text) => '$bold$text$resetBoldAndFaint';
    String i(String text) => '$italicized$text$resetItalicized';
    String u(String text) => '$underlined$text$resetUnderlined';
    String s(String text) => '$crossedOut$text$resetCrossedOut';
    String f(String text) => '$faint$text$resetBoldAndFaint';
    String bg(String color, String text) => '$color$text$resetBg';
    String fg(String color, String text) => '$color$text$resetFg';

    final stacked1 = bg(bgRed, fg(fgWhite, f(b('fb'))));
    final stacked2 = bg(bgGreen, fg(fgYellow, s(f('sf($stacked1)'))));
    final stacked3 = bg(bgBlue, fg(fgCyan, u(s('us($stacked2)'))));
    final stacked4 = bg(bgMagenta, fg(fgYellow, i(u('iu($stacked3)'))));
    final stacked5 = bg(bgCyan, b(i('bi($stacked4)')));
    final text = 'def($stacked5)';

    const defaultState = SgrPlainState(
      foreground: Color256(Colors.rgb555),
      background: Color256(Colors.rgb320),
    );

    print('');
    print('Standart output:');
    print(AnsiParser(text).removeAll());
    print(text);

    print('');
    print('With AnsiPrinter.print (the default state is overrided):');
    final simplePrinter = AnsiPrinter.print(
      defaultState: defaultState,
    );
    simplePrinter.print(text);

    print('');
    print(
      'With stacked AnsiPrinter.print (the state is accumulated in the stack):',
    );
    final printer = AnsiPrinter.print(
      defaultState: defaultState,
      stacked: true,
      // ignore: invalid_use_of_visible_for_testing_member
      debugForTest: true,
    );
    printer.print(text);
  }

  // Tabs.
  if (stdout.hasTerminal) {
    print('');
    const text = '0\t1\t2\t3\t4\t5\t6\t7\t8\t9';
    print(text);
    tabs(defaultTab: 12);
    print(text);
    print('${CSI}2Ia${CSI}2Ia');
    tabs();
  }

  // print('${CSI}17${ControlSequencesFunctions.SM.code}aaaaaa');
  // print('${CSI}17${ControlSequencesFunctions.RM.code}');
  // print('123${CSI}4${ControlSequencesFunctions.DSR.code}');

  // final str = stdin.readLineSync();
  // if (str != null) {
  //   print(AnsiParser(str).showControlFunctions());
  // }

  // print('$ESC[?47h');
  // print('aaaaaaaa');
  // final str = stdin.readLineSync();
  // print('$ESC[?47l');

  // print('$ESC[0;134;"F12"p');
  // final str = stdin.readLineSync();

  // print('${CSI}?0${ControlSequencesFunctions.MC.code}');
  // final str = stdin.readLineSync();
  final texts = [
    '${CSI}38:2:255:128:0mOrange${CSI}39m',
    '${CSI}38:2:0:255:128:0mOrange${CSI}39m',
    '${CSI}s1234567890$CSI p---',
    '${OSC}7$ST',
  ];

  for (final text in texts) {
    print(text);
    print(AnsiParser(text).showControlFunctions());
  }

  // print('1234567890\r${CSI}10@a');
  // print('1234567890\fabcd');

  // const text = 'Column 1\tColumn 2\tColumn 3\n';
  // print(text.showControlCodes());
  // print(text.showControlCodes(preferStyle: AnsiControlCodeStyle.unicodeSymbol));

  // const text2 = '${ESC}F12345${ESC}G67890'; // selected
  // const text3 = '${ESC}V12345${ESC}W67890'; // protected
  // print('${CSI}1h');
  // print('${CSI}4h'); // INSERT
  // print('${CSI}6l');
  // print('$text2\r${CSI}2X');
  // print('$text3\r${CSI}2X');
  // print('$text2\r+---!');
  // print('$text3\r+---${CSI}5P!');
  // print('${CSI}1l');
  // print('${CSI}4l');
  // print('${CSI}6l');

  // print('\t\r\n' == '$HT$CR$LF');
  // print('123${ESC}T456');

  print('$HTS        $HTS    $HTS  $HTS    $HTS        $HTS');
  print('1\t2\t3\t4\t5\t6');

  const text1 = '\x1B[38;2;255;128;0m Orange text \x1B[0m';
  const text2 = '$ESC[38;2;255;128;0m Orange text $ESC[0m';
  const text3 = '${CSI}38;2;255;128;0$SGR Orange text ${CSI}0$SGR';
  const text4 = '$CSI$FOREGROUND;2;255;128;0$SGR Orange text $CSI$RESET$SGR';
  const text5 =
      '$CSI$FOREGROUND;$COLOR_RGB;255;128;0$SGR Orange text $CSI$RESET$SGR';
  print(text1 == text2); // true
  print(text2 == text3); // true
  print(text3 == text4); // true
  print(text4 == text5); // true
  print(text1);
  print(text2);
  print(text3);
  print(text4);
  print(text5);

  // Set new tabulation stops
  print('$HTS        $HTS    $HTS  $HTS');
  print('1\t2\t3\t4'); // 1       2   3 4
  print('${CSI}3g'); // Reset tabulations stops to default

  print(
    'Go to ${OSC}8;;https://pub.dev/packages/ansi_escape_codes${ST}pub.dev${OSC}8;;$ST',
  );

  print(link('https://pub.dev/packages/ansi_escape_codes', text: 'pub.dev'));

  print('1234${CSI}4$CUB$CSI$DCH$CSI$CUF$CSI$ECH'); // "2 4"

  print('${CSI}4${SM}tree${CSI}3${CUB}h'); // three
  print('${CSI}4${RM}tree${CSI}3${CUB}h'); // thee
  print('${CSI}3$SGR Italicized text ${CSI}0$SGR');
  print('${CSI}4$CUU' == cursorUpN(4));
  print('${CSI}4$CUU' == '${cursorUpOpen}4$cursorUpClose');
  print('$CSI$CUU' == cursorUp);

  {
    print('${CSI}4$SGR' == underlined);
    print('$CSI$UNDERLINED$SGR' == underlined);
    print('$underlined Underlined text $resetUnderlined');

    const text1 =
        '$CSI$FOREGROUND;$COLOR_256;$YELLOW$SGR Yellow text $CSI$FG_DEFAULT$SGR';
    const text2 = '$fg256Open$YELLOW$fg256Close Yellow text $resetFg';
    final text3 = '${fg256(YELLOW)} Yellow text $resetFg';
    const text4 = '$fg256Yellow Yellow text $resetFg';
    print(text1 == text2);
    print(text2 == text3);
    print(text3 == text4);
    print(text4 == text5);
    print(text5);
    // print('$fgYellow$bgGreen Yellow on green $resetBg$resetFg');
  }
  {
    const text1 = '$fg256Rgb550 Yellow text $resetFg';
    const text2 = '$fg256Open$RGB_550$fg256Close Yellow text $resetFg';
    final text3 = '${fg256(RGB_550)} Yellow text $resetFg';
    final text4 = '${fg256(rgb(5, 5, 0))} Yellow text $resetFg';
    print(text1 == text2);
    print(text2 == text3);
    print(text3 == text4);
  }

  {
    const text1 =
        '$CSI$BACKGROUND;$COLOR_RGB;44;44;124$SGR Ultramarine $CSI$FG_DEFAULT$SGR';
    const text2 = '${bgRgbOpen}44;44;124$fg256Close Ultramarine $resetFg';
    final text3 = '${bgRgb(44, 44, 124)} Ultramarine $resetFg'; // Not constant!
    print(text1 == text2); // true
    print(text2 == text3); // true
  }

  {
    const text = '$bold Bold '
        '$fgCyan Bold+cyan '
        '$resetBoldAndFaint Cyan ';
    final parser = AnsiParser(text);
    parser.matches.forEach(print);

    final buf2 = StringBuffer();
    for (final m in parser.matches) {
      final result = switch (m.entity) {
        EscapeCode() => '',
        Text(:final string) => string,
      };

      buf2.write(result);
    }

    print(buf2); // " Bold  Bold+cyan  Cyan "
    print(parser.removeAll());

    final buf = StringBuffer();
    for (final m in parser.matches) {
      final result = switch (m.entity) {
        EscapeCode(:final id) => '[$id]',
        Text(:final string) => string,
      };

      buf.write(result);
    }
    print(buf);

    print(parser.replaceAll((e) => '[${e.id}]'));
    print(parser.showControlFunctions());

    print(parser.length == parser.removeAll().length);
    print(parser.length);

    final state = parser.stateAtPos(7);
    print(state);
    print(state.isBold);
    print(state.isItalicized);
    print(state.foreground?.id);
    print(state.background?.id);

    print(parser.stateAtPos(23) == parser.finalState);
    print(parser.finalState);

    print(parser.isClosed);

    const closedText = '$text$reset';
    print(AnsiParser(closedText).isClosed); // true

    final substring = parser.substring(7, maxLength: 9);
    print(AnsiParser(substring).showControlFunctions());

    print(substring.showEscapeCodes());

    const test1 = '$bold$fgCyan';
    final test2 = substring.substring(0, substring.indexOf('Bold'));

    print(test1.showEscapeCodes());
    print(test2.showEscapeCodes());

    print(AnsiParser(test1).showControlFunctions());
    print(AnsiParser(test2).showControlFunctions());

    print(test1.length);
    print(test2.length);

    const st2 = '$bold$fgCyan';
    print(st2.showEscapeCodes());
  }
  {
    const text = "$fgWhite$bold$resetBoldAndFaint$fgGreen$underlined"
        "$resetUnderlined$faint$faint"
        " What's in here? "
        "$resetBoldAndFaint$resetFg";
    print(text.length);
    final parser = AnsiParser(text);
    print(parser.showControlFunctions());

    final optimizedText = parser.optimize();
    print(optimizedText.length);
    print(AnsiParser(optimizedText).showControlFunctions());
  }

  {
    const text = '${fgRed}ERROR$reset';
    print(text.hasEscapeCodes);
    print(text.hasCsi);
    print(text.hasSgr);
    print(text.hasForeground);
    print(text.hasBackground);
    print(text.showEscapeCodes());
  }

  {
    const text = 'Tab: \t Line feed: \n Carriage return: \r Bell: \x07';
    print(text.showControlCodes());
    print(text.showControlCodes(preferStyle: ControlCodeStyle.abbr));
    print(text.showControlCodes(preferStyle: ControlCodeStyle.charCode));
    print(text.showControlCodes(preferStyle: ControlCodeStyle.unicodeSymbol));
  }

  {
    const text =
        '$saveCursor$cursorRight$italicized$bgGreen$fgYellow Text $resetFg$resetBg$resetItalicized$restoreCursor';
    print(AnsiParser(text)
        .showControlFunctions()); // [saveCursor][CSI CUF][italicized][bgGreen][fgYellow] Text [resetFg][resetBg][resetItalicized][restoreCursor]

    print(AnsiParser(text.removeBackground())
        .showControlFunctions()); // [saveCursor][CSI CUF][italicized][fgYellow] Text [resetFg][resetItalicized][restoreCursor]
    print(AnsiParser(text.removeBackground().removeForeground())
        .showControlFunctions()); // [saveCursor][CSI CUF][italicized] Text [resetItalicized][restoreCursor]
    print(AnsiParser(text.removeSgr())
        .showControlFunctions()); // [saveCursor][CSI CUF] Text [restoreCursor]
    print(AnsiParser(text.removeCsi())
        .showControlFunctions()); // [saveCursor] Text [restoreCursor]
    print(text.removeEscapeCodes().showEscapeCodes()); // " Text "
  }

  {
    const text =
        '${bgRgbOpen}44;43;124$bgRgbClose${fgRgbOpen}224;192;64$fgRgbClose Default text '
        '$bgWhite$fgBlack Highlighted text '
        '${bgRgbOpen}44;43;124$bgRgbClose${fgRgbOpen}224;192;64$fgRgbClose Default text again $reset';
    print(text);
  }

  {
    const bgDefault = '${bgRgbOpen}44;43;124$bgRgbClose';
    const fgDefault = '${fgRgbOpen}224;192;64$fgRgbClose';
    const text = '$bgDefault$fgDefault Default text '
        '$bgWhite$fgBlack Highlighted text '
        '$bgDefault$fgDefault Default text again $reset';
    print(text);
  }

  {
    const text = ' Default text '
        '$bgWhite$fgBlack Highlighted text '
        '$resetBg$resetFg Default text again $reset';
    final printer = AnsiPrinter.print(
      defaultState: SgrPlainState(
        background: ColorRgb(44, 43, 124),
        foreground: ColorRgb(224, 192, 64),
      ),
    );
    printer.print(text);
  }

  {
    void main() {
      runZonedAnsiPrinter(
        defaultState: SgrPlainState(
          background: ColorRgb(44, 43, 124),
          foreground: ColorRgb(224, 192, 64),
          // background: Color16.green,
          // foreground: Color16.yellow,
        ),
        ansiCodesEnabled: !Platform.isIOS,
        // output: log,
        () {
          const text = ' Default text '
              '$bgWhite$fgBlack Highlighted text '
              '$resetBg$resetFg Default text again $reset';
          print(text);
        },
      );
    }

    main();
  }

  log(
    '1234567890123456789012345678901234567890'
    '1234567890123456789012345678901234567890'
    '1234567890123456789012345678901234567890'
    '12345678',
    // name: 'aaaaa',
    // sequenceNumber: 1,
    // zone: Zone.root,
    // level: 1200,
  );

  // stdout.s
}
