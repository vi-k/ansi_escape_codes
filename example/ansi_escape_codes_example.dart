// ignore_for_file: cascade_invocations

import 'dart:io';

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';
import 'package:ansi_escape_codes/utils.dart';

import '../test/utils.dart';
import 'utils.dart';

/// Usage:
///
/// ```bash
/// dart run example/ansi_escape_codes_example.dart
/// ```
void main() {
  {
    title('Colorize');
    print('');

    print('$fgGreen Green text $resetFg');
    print('$fg256Green Green text $resetFg');
    print('$fg256Open$GREEN$fg256Close Green text $resetFg');

    print('$fg256Rgb050 Rgb050 (#00FF00) $resetFg');
    print('$fg256Open$RGB_050$fg256Close Rgb050 (#00FF00) $resetFg');

    print('${fgRgb(0, 255, 0)} Rgb(0,255,0) (#00FF00) $resetFg');
    print('${fgRgbOpen}0;255;0$fgRgbClose Rgb(0,255,0) (#00FF00) $resetFg');

    {
      print('');
      title('Analysis');

      const text = '$fgYellow Yellow foreground $resetFg'
          '\t$bgYellow Yellow background $resetBg';
      subtitle('As is:');
      print(text);

      subtitle('ansiRemoveEscapeCodes:');
      print(text.ansiRemoveEscapeCodes());

      subtitle('ansiShowControlCodes:');
      subsubtitle(' escapeOrCharCode:');
      print('  ${text.ansiShowControlCodes(
        open: fg256Rgb500,
        close: resetFg,
      )}');
      subsubtitle(' charCode:');
      print('  ${text.ansiShowControlCodes(
        open: fg256Rgb500,
        close: resetFg,
        preferStyle: ControlCodeStyle.charCode,
      )}');
      subsubtitle(' escapeOrAbbr:');
      print('  ${text.ansiShowControlCodes(
        open: fg256Rgb500,
        close: resetFg,
        preferStyle: ControlCodeStyle.escapeOrAbbr,
      )}');
      subsubtitle(' abbr:');
      print('  ${text.ansiShowControlCodes(
        open: fg256Rgb500,
        close: resetFg,
        preferStyle: ControlCodeStyle.abbr,
      )}');
      subsubtitle(' escapeOrUnicode:');
      print('  ${text.ansiShowControlCodes(
        open: fg256Rgb500,
        close: resetFg,
        preferStyle: ControlCodeStyle.escapeOrUnicode,
      )}');
      subsubtitle(' unicode:');
      print('  ${text.ansiShowControlCodes(
        open: fg256Rgb500,
        close: resetFg,
        preferStyle: ControlCodeStyle.unicode,
      )}');

      subtitle('ansiShowEscapeSequences:');
      print(
        ' ${text.ansiShowEscapeSequences(
          open: '$fg256Rgb500[',
          close: ']$resetFg',
        )}',
      );

      subtitle('ansiShowControlFunctions:');
      print(
        ' ${text.ansiShowControlFunctions(
          open: '$fg256Rgb500[',
          close: ']$resetFg',
        )}',
      );
    }
  }

  {
    print('');
    title('Parsing');

    const text = '$fgYellow Yellow foreground $resetFg'
        '$bgYellow Yellow background $resetBg';

    final parser = Parser(text);

    subtitle('As is:');
    print(text);

    subtitle('showControlFunctions:');
    print(
      parser.showControlFunctions(
        open: '$fg256Rgb500[',
        close: ']$resetFg',
      ),
    );

    subtitle('Matches:');
    final buf = StringBuffer();
    for (final m in parser.matches) {
      switch (m.entity) {
        case Text(:final string):
          buf
            ..write(string)
            ..write(reset);

        case EscapeCode(:final id, :final string):
          buf
            ..write('$fg256Rgb500[$id]$reset')
            ..write(string);
      }
    }
    print(buf);
  }

  {
    print('');
    title('Style at position');

    const text = '$fgGreen${bold}bold $fgRed${italic}bold+italic'
        ' $resetBoldAndDim${fgMagenta}italic$resetItalic$reset';
    final parser = Parser(text);

    final stateAt0 = parser.stateAt(0);
    print('');
    print('"$text"');
    subsubtitle(
      ' ^ isBold=${stateAt0.isBold}'
      ', isItalic=${stateAt0.isItalic}'
      ', foreground=${stateAt0.foregroundColor}',
    );

    final stateAt5 = parser.stateAt(5);
    print('');
    print('"$text"');
    subsubtitle(
      ' ${' ' * 5}^ isBold=${stateAt5.isBold}'
      ', isItalic=${stateAt5.isItalic}'
      ', foreground=${stateAt5.foregroundColor}',
    );

    final stateAt17 = parser.stateAt(17);
    print('');
    print('"$text"');
    subsubtitle(
      ' ${' ' * 17}^ isBold=${stateAt17.isBold}'
      ', isItalic=${stateAt17.isItalic}'
      ', foreground=${stateAt17.foregroundColor}',
    );

    final finalState = parser.finalState;
    print('');
    print('"$text"');
    subsubtitle(
      ' ${' ' * 23}^ isBold=${finalState.isBold}'
      ', isItalic=${finalState.isItalic}'
      ', foreground=${finalState.foregroundColor}',
    );
  }

  {
    print('');
    title('Substrings');

    const text = '$fg256Rgb135${bold}Lorem$resetBoldAndDim '
        '$bg256Rgb012${italic}ipsum dolor sit$resetItalic$resetBg'
        ' amet, consectetur'
        ' $bg256Rgb012${underline}adipiscing$resetUnderline$resetBg elit,'
        ' $bg256Rgb012${strikethrough}sed do eiusmod$resetStrikethrough$resetBg'
        ' tempor…$reset';
    subtitle('Original:');
    print('"$text"');

    subtitle('Substrings:');

    final parser = Parser(text);
    for (var i = 0; i < 50; i += 2) {
      print('"${parser.substring(i, maxLength: 40)}"');
    }
  }

  {
    print('');
    title('Default style (Printer)');

    const text = ' default colors'
        ' $fg256Rgb550$bg256Rgb031 yellow on green'
        ' $resetFg$resetBg default colors ';
    subtitle('Standart output (the default colors are set by the terminal):');
    print(text);

    const defaultState = Style(
      foreground: Color256.rgb555,
      background: Color256.rgb320,
    );

    subtitle('With Printer (the default state is overrided):');
    final printer = Printer(defaultStyle: defaultState);
    printer.print(text);

    subtitle('With runZonedPrinter (the default state is overrided):');
    runZonedPrinter(
      defaultStyle: defaultState,
      () {
        print(text);
      },
    );
  }

  {
    print('');
    title('StackedPrinter');

    const template = '${fg256Rgb330}some text {placeholder} some text$reset';
    const highlightedText = '${fg256Rgb550}highlighted text$resetFg';

    subtitle('template:');
    print(template);

    subtitle('text for placeholder:');
    print(highlightedText);

    final text = template.replaceAll('{placeholder}', highlightedText);

    subtitle('Standart output:');
    print(text);
    subsubtitle(
      '                           '
      '^ `resetFg` resets the color to the ${bold}terminal settings',
    );

    subtitle('Stacked Printer:');
    final stackedPrinter = StackedPrinter();
    stackedPrinter.print(text);
    subsubtitle(
      '                           '
      '^ `resetFg` resets the color to the ${bold}previous color',
    );
  }

  if (stdout.hasTerminal) {
    print('');
    title('Tabs');
    const text = '0\t1\t2\t3\t4\t5\t6';

    print('');
    print('${fg256Rgb424}Default tabs:$reset');
    print(text);

    print('');
    print('${fg256Rgb424}Custom tabs (12):$reset');
    tabs(defaultTab: 12);
    print(text);

    print('');
    print('${fg256Rgb424}Custom tabs (4):$reset');
    tabs(defaultTab: 4);
    print(text);

    tabs(); // Reset to defaults
  }
}
