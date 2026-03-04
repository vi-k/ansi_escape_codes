// ignore_for_file: missing_whitespace_between_adjacent_strings, lines_longer_than_80_chars

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/parsing.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Parsing', () {
    test('parsing', () {
      const text = '$bold Bold $resetBoldAndFaint';

      final parser1 = Parser(text);
      expect(parser1.isParsed, isFalse);
      parser1.prepare();
      expect(parser1.isParsed, isTrue);
      expect(parser1.removeAll(), ' Bold ');

      final parser2 = Parser(text);
      expect(parser2.isParsed, isFalse);
      expect(parser2.removeAll(), ' Bold ');
      expect(parser2.isParsed, isTrue);
    });
  });

  group('SGR:', () {
    test('all SGR values', () {
      final buf = StringBuffer(CSI);

      for (var i = 0; i < ControlFunctionsSGR.values.length; i++) {
        if (i == 38 || i == 48 || i == 58) {
          buf
            ..write(';')
            ..write(i)
            ..write(':5:7')
            ..write(';')
            ..write(i)
            ..write(':2:0:128:255')
            ..write(';')
            ..write(i)
            ..write(':5:256') // invalid value
            ..write(';')
            ..write(i)
            ..write(':2:0:128:256') // invalid value
            ..write(';')
            ..write(i)
            ..write(':2:0:128') // invalid value
            ..write(';')
            ..write(i)
            ..write(':3:0:128:255'); // invalid value
        } else {
          buf
            ..write(';')
            ..write(i);
        }
      }
      buf.write(SGR);

      print('');
      final parser = Parser(buf.toString());

      expect(
        parser.showControlFunctions(),
        '['
        ';reset;bold;faint;italicized;underlined'
        ';slowlyBlinking;rapidlyBlinking;negative;concealed;crossedOut'
        ';10;11;12;13;14;15;16;17;18;19;20'
        ';doublyUnderlined;resetBoldAndFaint;resetItalicized;resetUnderlined'
        ';resetBlinking;26;resetNegative;resetConcealed;resetCrossedOut'
        // fg...
        ';fgBlack;fgRed;fgGreen;fgYellow;fgBlue;fgMagenta;fgCyan;fgWhite'
        ';fg256White;fgRgb(0,128,255)'
        // ... invalid values.
        ';fg256?256;fgRgb?0:128:256;fgRgb?0:128;fg?3:0:128:255'
        ';resetFg'
        // bg...
        ';bgBlack;bgRed;bgGreen;bgYellow;bgBlue;bgMagenta;bgCyan;bgWhite'
        ';bg256White;bgRgb(0,128,255)'
        // ... invalid values.
        ';bg256?256;bgRgb?0:128:256;bgRgb?0:128;bg?3:0:128:255'
        ';resetBg'
        ';50'
        ';framed;encircled;overlined;resetFramedAndEncircled;resetOverlined'
        ';56;57'
        // underline...
        ';underline256White;underlineRgb(0,128,255)'
        // ... invalid values.
        ';underline256?256;underlineRgb?0:128:256;underlineRgb?0:128'
        ';underline?3:0:128:255'
        ';resetUnderlineColor'
        ';60;61;62;63;64;65;66;67;68;69;70;71;72'
        ';superscripted;subscripted;resetSuperAndSubscripted'
        ';76;77;78;79;80;81;82;83;84;85;86;87;88;89'
        // fgHigh...
        ';fgHighBlack;fgHighRed;fgHighGreen;fgHighYellow'
        ';fgHighBlue;fgHighMagenta;fgHighCyan;fgHighWhite'
        ';98;99'
        // bgHigh...
        ';bgHighBlack;bgHighRed;bgHighGreen;bgHighYellow'
        ';bgHighBlue;bgHighMagenta;bgHighCyan;bgHighWhite'
        ']',
      );

      final entity = parser.matches.first.entity as Sgr;
      for (final code in ControlFunctionsSGR.values) {
        expect(entity.contains(code), !code.isUnused);
      }
    });

    test('stateAtPos', () {
      const text = '$fgRed ${bold}bold $fgGreen$bgYellow'
          ' ${italicized}bold+italic$resetBoldAndFaint'
          ' $resetBg italic$resetItalicized $reset';
      final parser = Parser(text);

      expect(parser.removeAll(), ' bold  bold+italic  italic ');

      expect(
        parser.showControlFunctions(),
        '[fgRed] [bold]bold [fgGreen][bgYellow]'
        ' [italicized]bold+italic[resetBoldAndFaint]'
        ' [resetBg] italic[resetItalicized] [reset]',
      );

      expect(parser.length, 27);

      // " bold  bold+italic  italic "
      //  ^--
      final styleAtPos0 = parser.stateAt(0);
      expect(styleAtPos0.colorOfForeground, Color16.red);
      expect(styleAtPos0.colorOfBackground, isNull);
      expect(styleAtPos0.isBold, isFalse);
      expect(styleAtPos0.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //   ^--
      final styleAtPos1 = parser.stateAt(1);
      expect(styleAtPos1.colorOfForeground, Color16.red);
      expect(styleAtPos1.colorOfBackground, isNull);
      expect(styleAtPos1.isBold, isTrue);
      expect(styleAtPos1.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //       ^--
      final styleAtPos5 = parser.stateAt(5);
      expect(styleAtPos5.colorOfForeground, Color16.red);
      expect(styleAtPos5.colorOfBackground, isNull);
      expect(styleAtPos5.isBold, isTrue);
      expect(styleAtPos5.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //        ^--
      final styleAtPos6 = parser.stateAt(6);
      expect(styleAtPos6.colorOfForeground, Color16.green);
      expect(styleAtPos6.colorOfBackground, Color16.yellow);
      expect(styleAtPos6.isBold, isTrue);
      expect(styleAtPos6.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //         ^--
      final styleAtPos7 = parser.stateAt(7);
      expect(styleAtPos7.colorOfForeground, Color16.green);
      expect(styleAtPos7.colorOfBackground, Color16.yellow);
      expect(styleAtPos7.isBold, isTrue);
      expect(styleAtPos7.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                   ^--
      final styleAtPos17 = parser.stateAt(17);
      expect(styleAtPos17.colorOfForeground, Color16.green);
      expect(styleAtPos17.colorOfBackground, Color16.yellow);
      expect(styleAtPos17.isBold, isTrue);
      expect(styleAtPos17.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                    ^--
      final styleAtPos18 = parser.stateAt(18);
      expect(styleAtPos18.colorOfForeground, Color16.green);
      expect(styleAtPos18.colorOfBackground, Color16.yellow);
      expect(styleAtPos18.isBold, isFalse);
      expect(styleAtPos18.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                     ^--
      final styleAtPos19 = parser.stateAt(19);
      expect(styleAtPos19.colorOfForeground, Color16.green);
      expect(styleAtPos19.colorOfBackground, null);
      expect(styleAtPos19.isBold, isFalse);
      expect(styleAtPos19.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                           ^--
      final styleAtPos25 = parser.stateAt(25);
      expect(styleAtPos25.colorOfForeground, Color16.green);
      expect(styleAtPos25.colorOfBackground, null);
      expect(styleAtPos25.isBold, isFalse);
      expect(styleAtPos25.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                            ^--
      final styleAtPos26 = parser.stateAt(26);
      expect(styleAtPos26.colorOfForeground, Color16.green);
      expect(styleAtPos26.colorOfBackground, null);
      expect(styleAtPos26.isBold, isFalse);
      expect(styleAtPos26.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //                             ^--
      final styleAtPos27 = parser.stateAt(27);
      expect(styleAtPos27.colorOfForeground, null);
      expect(styleAtPos27.colorOfBackground, null);
      expect(styleAtPos27.isBold, isFalse);
      expect(styleAtPos27.isItalicized, isFalse);

      expect(
        () => parser.stateAt(-1),
        throwsA(
          predicate(
            (e) =>
                e is RangeError &&
                '$e' ==
                    'RangeError (pos): Invalid value:'
                        ' Not greater than or equal to 0: -1',
          ),
        ),
      );

      expect(
        () => parser.stateAt(28),
        throwsA(
          predicate(
            (e) =>
                e is RangeError &&
                '$e' ==
                    'RangeError (pos): Index out of range:'
                        ' index should be less than 28: 28',
          ),
        ),
      );
    });

    test('isClosed', () {
      const closedStrings = <String>[
        '$bold $resetBoldAndFaint',
        '$bold $reset',
        '$faint $resetBoldAndFaint',
        '$faint $reset',
        '$italicized $resetItalicized',
        '$italicized $reset',
        '$underlined $resetUnderlined',
        '$underlined $reset',
        '$doublyUnderlined $resetUnderlined',
        '$doublyUnderlined $reset',
        '$slowlyBlinking $resetBlinking',
        '$slowlyBlinking $reset',
        '$rapidlyBlinking $resetBlinking',
        '$rapidlyBlinking $reset',
        '$negative $resetNegative',
        '$negative $reset',
        '$concealed $resetConcealed',
        '$concealed $reset',
        '$crossedOut $resetCrossedOut',
        '$crossedOut $reset',
        '$framed $resetFramedAndEncircled',
        '$framed $reset',
        '$encircled $resetFramedAndEncircled',
        '$encircled $reset',
        '$overlined $resetOverlined',
        '$overlined $reset',
        '$superscripted $resetSuperAndSubscripted',
        '$superscripted $reset',
        '$subscripted $resetSuperAndSubscripted',
        '$subscripted $reset',
        '$fgRed $resetFg',
        '$fgRed $reset',
        '$fg256Red $resetFg',
        '$fg256Red $reset',
        '${fgRgbOpen}255;0;0$fgRgbClose $resetFg',
        '${fgRgbOpen}255;0;0$fgRgbClose $reset',
        '$bgGreen $resetBg',
        '$bgGreen $reset',
        '$bg256Green $resetBg',
        '$bg256Green $reset',
        '${bgRgbOpen}0;255;0$bgRgbClose $resetBg',
        '${bgRgbOpen}0;255;0$bgRgbClose $reset',
        '$underline256Blue $resetUnderlineColor',
        '$underline256Blue $reset',
        '${underlineRgbOpen}255;0;0$underlineRgbClose $resetUnderlineColor',
        '${underlineRgbOpen}255;0;0$underlineRgbClose $reset',
      ];

      for (final string in closedStrings) {
        expect(Parser(string).isClosed, isTrue);
      }

      const openedStrings = <String>[
        '$bold ',
        '$bold $resetItalicized',
        '$faint ',
        '$faint $resetItalicized',
        '$italicized ',
        '$italicized $resetUnderlined',
        '$underlined ',
        '$underlined $resetBlinking',
        '$doublyUnderlined ',
        '$doublyUnderlined $resetBlinking',
        '$slowlyBlinking ',
        '$slowlyBlinking $resetNegative',
        '$rapidlyBlinking ',
        '$rapidlyBlinking $resetNegative',
        '$negative ',
        '$negative $resetConcealed',
        '$concealed ',
        '$concealed $resetCrossedOut',
        '$crossedOut ',
        '$crossedOut $resetFramedAndEncircled',
        '$framed ',
        '$framed $resetOverlined',
        '$encircled ',
        '$encircled $resetOverlined',
        '$overlined ',
        '$overlined $resetSuperAndSubscripted',
        '$superscripted ',
        '$superscripted $resetFg',
        '$subscripted ',
        '$subscripted $resetFg',
        '$fgRed ',
        '$fgRed $resetBg',
        '$fg256Red ',
        '$fg256Red $resetBg',
        '${fgRgbOpen}255;0;0$fgRgbClose ',
        '${fgRgbOpen}255;0;0$fgRgbClose $resetBg',
        '$bgGreen ',
        '$bgGreen $resetUnderlineColor',
        '$bg256Green ',
        '$bg256Green $resetUnderlineColor',
        '${bgRgbOpen}0;255;0$bgRgbClose ',
        '${bgRgbOpen}0;255;0$bgRgbClose $resetUnderlineColor',
        '$underline256Blue ',
        '$underline256Blue $resetBoldAndFaint',
        '${underlineRgbOpen}255;0;0$underlineRgbClose ',
        '${underlineRgbOpen}255;0;0$underlineRgbClose $resetBoldAndFaint',
      ];

      for (final string in openedStrings) {
        expect(Parser(string).isClosed, isFalse);
      }
    });

    test('substring and optimize', () {
      final text = ' '
          '$fgWhite$bold${faint}first$resetBoldAndFaint'
          ' $bg256Green$fg256Yellow'
          '${italicized}second$resetItalicized'
          '$resetBg$resetFg'
          ' ${fgRgb(255, 128, 0)}${bgRgb(48, 64, 128)}'
          '$underlined$slowlyBlinking${negative}third$resetUnderlined'
          '$resetFg$resetBg'
          ' ';

      final parser = Parser(text);
      expect(parser.removeAll(), ' first second third ');
      expect(
        parser.showControlFunctions(),
        ' [fgWhite][bold][faint]first[resetBoldAndFaint]'
        ' [bg256Green][fg256Yellow][italicized]second[resetItalicized][resetBg][resetFg]'
        ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined][slowlyBlinking][negative]third[resetUnderlined][resetFg][resetBg]'
        ' ',
      );
      expect(parser.isClosed, isFalse);

      final optimizedText = parser.optimize();
      {
        final parser2 = Parser(optimizedText);
        expect(
          parser2.showControlFunctions(),
          ' [fgWhite;bold;faint]first[resetBoldAndFaint]'
          ' [fg256Yellow][bg256Green][italicized]second[reset]'
          ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined;slowlyBlinking;negative]third[resetFg;resetBg;resetUnderlined]'
          ' [reset]',
        );
        expect(parser2.isClosed, isTrue);
      }

      final unclosedOptimizedText = parser.optimize(close: false);
      {
        final parser2 = Parser(unclosedOptimizedText);
        expect(
          parser2.showControlFunctions(),
          ' [fgWhite;bold;faint]first[resetBoldAndFaint]'
          ' [fg256Yellow][bg256Green][italicized]second[reset]'
          ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined;slowlyBlinking;negative]third[resetFg;resetBg;resetUnderlined]'
          ' ',
        );
        expect(parser2.isClosed, isFalse);
      }

      // All.
      {
        final substring = parser.substring(0);
        expect(substring, optimizedText);
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(0, close: false);
        expect(
          unclosed,
          optimizedText.substring(
            0,
            optimizedText.length - 4, // ESC+[+0+SGR=reset
          ),
        );
        expect(unclosed.ansiOptimizeControlFunctions(), optimizedText);
      }

      // " first"
      {
        final substring = parser.substring(0, maxLength: 6);
        expect(
          substring.ansiShowControlFunctions(),
          ' [fgWhite;bold;faint]first[reset]',
        );
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(0, maxLength: 6, close: false);
        expect(
          unclosed.ansiShowControlFunctions(),
          ' [fgWhite;bold;faint]first[resetBoldAndFaint]',
        );
        expect(unclosed.ansiOptimizeControlFunctions(close: false), unclosed);
      }

      // " first "
      {
        final substring = parser.substring(0, maxLength: 7);
        expect(
          substring.ansiShowControlFunctions(),
          ' [fgWhite;bold;faint]first[resetBoldAndFaint] [reset]',
        );
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(0, maxLength: 7, close: false);
        expect(
          unclosed.ansiShowControlFunctions(),
          ' [fgWhite;bold;faint]first[resetBoldAndFaint] ',
        );
        expect(unclosed.ansiOptimizeControlFunctions(close: false), unclosed);
      }

      // "first"
      {
        final substring = parser.substring(1, maxLength: 5);
        expect(
          substring.ansiShowControlFunctions(),
          '[fgWhite;bold;faint]first[reset]',
        );
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(1, maxLength: 5, close: false);
        expect(
          unclosed.ansiShowControlFunctions(),
          '[fgWhite;bold;faint]first[resetBoldAndFaint]',
        );
        expect(unclosed.ansiOptimizeControlFunctions(close: false), unclosed);
      }

      // "second"
      {
        final substring = parser.substring(7, maxLength: 6);
        expect(
          substring.ansiShowControlFunctions(),
          '[fg256Yellow][bg256Green][italicized]second[reset]',
        );
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(7, maxLength: 6, close: false);
        expect(
          unclosed.ansiShowControlFunctions(),
          '[fg256Yellow][bg256Green][italicized]second[reset]',
        );
        expect(unclosed.ansiOptimizeControlFunctions(close: false), unclosed);
      }

      // "third"
      {
        final substring = parser.substring(14, maxLength: 5);
        expect(
          substring.ansiShowControlFunctions(),
          '[fgRgb(255,128,0)][bgRgb(48,64,128)]'
          '[underlined;slowlyBlinking;negative]'
          'third[reset]',
        );
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(14, maxLength: 5, close: false);
        expect(
          unclosed.ansiShowControlFunctions(),
          '[fgRgb(255,128,0)][bgRgb(48,64,128)]'
          '[underlined;slowlyBlinking;negative]'
          'third[resetFg;resetBg;resetUnderlined]',
        );
        expect(unclosed.ansiOptimizeControlFunctions(close: false), unclosed);
      }

      // "rst sec"
      {
        final substring = parser.substring(3, maxLength: 7);
        expect(
          substring.ansiShowControlFunctions(),
          '[fgWhite;bold;faint]rst[resetBoldAndFaint]'
          ' [fg256Yellow][bg256Green][italicized]sec'
          '[reset]',
        );
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(3, maxLength: 7, close: false);
        expect(
          unclosed.ansiShowControlFunctions(),
          '[fgWhite;bold;faint]rst[resetBoldAndFaint]'
          ' [fg256Yellow][bg256Green][italicized]sec',
        );
        expect(unclosed.ansiOptimizeControlFunctions(close: false), unclosed);
      }

      // "ond thi"
      {
        final substring = parser.substring(10, maxLength: 7);
        expect(
          substring.ansiShowControlFunctions(),
          '[fg256Yellow][bg256Green][italicized]ond[reset]'
          ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined;slowlyBlinking;negative]thi[reset]',
        );
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(10, maxLength: 7, close: false);
        expect(
          unclosed.ansiShowControlFunctions(),
          '[fg256Yellow][bg256Green][italicized]ond[reset]'
          ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined;slowlyBlinking;negative]thi',
        );
        expect(unclosed.ansiOptimizeControlFunctions(close: false), unclosed);
      }

      // "rd "
      {
        final substring = parser.substring(17);
        expect(
          substring.ansiShowControlFunctions(),
          '[fgRgb(255,128,0)][bgRgb(48,64,128)]'
          '[underlined;slowlyBlinking;negative]'
          'rd[resetFg;resetBg;resetUnderlined] [reset]',
        );
        expect(substring.ansiOptimizeControlFunctions(), substring);

        final unclosed = parser.substring(17, close: false);
        expect(
          unclosed.ansiShowControlFunctions(),
          '[fgRgb(255,128,0)][bgRgb(48,64,128)]'
          '[underlined;slowlyBlinking;negative]'
          'rd[resetFg;resetBg;resetUnderlined] ',
        );
        expect(unclosed.ansiOptimizeControlFunctions(close: false), unclosed);
      }

      final splicedText1 = parser.substring(0, maxLength: 1) +
          parser.substring(1, maxLength: 5) + // first
          parser.substring(6, maxLength: 1) +
          parser.substring(7, maxLength: 6) + // second
          parser.substring(13, maxLength: 1) +
          parser.substring(14, maxLength: 5) + // third
          parser.substring(19, maxLength: 1);
      expect(splicedText1.ansiOptimizeControlFunctions(), optimizedText);

      final splicedText2 = parser.substring(0, maxLength: 1, close: false) +
          parser.substring(1, maxLength: 5, close: false) + // first
          parser.substring(6, maxLength: 1, close: false) +
          parser.substring(7, maxLength: 6, close: false) + // second
          parser.substring(13, maxLength: 1, close: false) +
          parser.substring(14, maxLength: 5, close: false) + // third
          parser.substring(19, maxLength: 1, close: false);
      expect(
        splicedText2.ansiOptimizeControlFunctions(close: false),
        unclosedOptimizedText,
      );

      final splicedText3 = parser.substring(0, maxLength: 3) + // ' fi'
          parser.substring(3, maxLength: 7) + // rst sec
          parser.substring(10, maxLength: 7) + // ond thi
          parser.substring(17, maxLength: 3); // 'rd '
      expect(splicedText3.ansiOptimizeControlFunctions(), optimizedText);

      final splicedText4 =
          parser.substring(0, maxLength: 3, close: false) + // ' fi'
              parser.substring(3, maxLength: 7, close: false) + // rst sec
              parser.substring(10, maxLength: 7, close: false) + // ond thi
              parser.substring(17, maxLength: 3, close: false); // 'rd '
      expect(
        splicedText4.ansiOptimizeControlFunctions(close: false),
        unclosedOptimizedText,
      );
    });

    group('Printer', () {
      test('print', () {
        final output1 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedPrinter(
              defaultStyle: const Style(
                foreground: Color16.black,
                background: Color16.white,
              ),
              () => print(
                'default colors'
                '$fgYellow$bgGreen$underlined$bold$italicized yellow on green'
                ' $resetItalicized$resetBoldAndFaint$resetUnderlined$resetBg$resetFg'
                'default colors',
              ),
            );
          },
        );

        expect(
          Parser(output1[0]).showControlFunctions(),
          '[reset][fgBlack;bgWhite]default colors'
          '[fgYellow;bgGreen;bold;italicized;underlined] yellow on green'
          ' [resetBoldAndFaint;resetItalicized;resetUnderlined;fgBlack;bgWhite]'
          'default colors[reset]',
        );

        final output2 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedPrinter(
              defaultStyle: const Style(
                foreground: Color16.black,
                background: Color16.white,
              ),
              () => print(
                'default colors'
                '$fgYellow$bgGreen$underlined$bold$italicized yellow on green'
                ' $reset'
                'default colors',
              ),
            );
          },
        );

        expect(
          Parser(output2[0]).showControlFunctions(),
          '[reset][fgBlack;bgWhite]default colors'
          '[fgYellow;bgGreen;bold;italicized;underlined] yellow on green'
          ' [resetBoldAndFaint;resetItalicized;resetUnderlined;fgBlack;bgWhite]'
          'default colors[reset]',
        );

        final output3 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedPrinter(
              defaultStyle: const Style(
                foreground: Color16.yellow,
                background: Color16.green,
                bold: true,
                italicized: true,
                singlyUnderlined: true,
              ),
              () => print(
                'default colors'
                '$fgYellow$bgGreen$underlined$bold$italicized yellow on green'
                ' $reset'
                'default colors',
              ),
            );
          },
        );

        expect(
          Parser(output3[0]).showControlFunctions(),
          '[reset][fgYellow;bgGreen;bold;italicized;underlined]default colors'
          ' yellow on green default colors[reset]',
        );
      });

      test('multiline', () {
        final output1 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedPrinter(() => print('\nTitle\nSubtitle\n'));
          },
        );

        expect(
          output1.join('\n').ansiShowControlFunctions(),
          '\n'
          '[reset]Title\n'
          '[reset]Subtitle\n',
        );

        final output2 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedPrinter(
              defaultStyle: const Style(
                foreground: Color16.yellow,
                background: Color16.green,
              ),
              () => print('\nTitle\nSubtitle\n'),
            );
          },
        );

        expect(
          output2.join('\n').ansiShowControlFunctions(),
          '\n'
          '[reset][fgYellow;bgGreen]Title[reset]\n'
          '[reset][fgYellow;bgGreen]Subtitle[reset]\n',
        );
      });

      test('sink multiline', () {
        final buf = StringBuffer();

        SinkPrinter(
          buf,
          defaultStyle: const Style(
            foreground: Color16.yellow,
            background: Color16.green,
          ),
        ).write('\nTitle\nSubtitle\n');

        expect(
          buf.toString().ansiShowControlFunctions(),
          '\n'
          '[reset][fgYellow;bgGreen]Title[reset]\n'
          '[reset][fgYellow;bgGreen]Subtitle[reset]\n',
        );
      });
    });

    test('StackedPrinter', () {
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

      final output = interceptZonedPrint(
        // debugPrint: true,
        () {
          runZonedStackedPrinter(
            defaultStyle: const Style(
              foreground: Color256.rgb555,
              background: Color256.rgb320,
            ),
            () => print(text),
          );
        },
      );

      expect(
        Parser(output[0]).showControlFunctions(),
        '[reset]'
        '[fg256Rgb555][bg256Rgb320]def('
        '[bgCyan;bold;italicized]bi('
        '[fgYellow;bgMagenta;underlined]iu('
        '[fgCyan;bgBlue;crossedOut]us('
        '[fgYellow;bgGreen;faint]sf('
        '[fgWhite;bgRed]fb'
        '[fgYellow;bgGreen])'
        '[resetBoldAndFaint;fgCyan;bgBlue;bold])'
        '[resetCrossedOut;fgYellow;bgMagenta])'
        '[resetUnderlined][fg256Rgb555][bgCyan])'
        '[resetBoldAndFaint;resetItalicized][bg256Rgb320])'
        '[reset]',
      );
    });
  });
}
