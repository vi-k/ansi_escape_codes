// ignore_for_file: missing_whitespace_between_adjacent_strings, lines_longer_than_80_chars

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/controls.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Parsing', () {
    test('parsing', () {
      const text = '$bold Bold $resetBoldAndFaint';

      final parser1 = AnsiParser(text);
      expect(parser1.isParsed, isFalse);
      parser1.prepare();
      expect(parser1.isParsed, isTrue);
      expect(parser1.removeAll(), ' Bold ');

      final parser2 = AnsiParser(text);
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
      final parser = AnsiParser(buf.toString());

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
          ']');

      final entity = parser.matches.first.entity as Sgr;
      for (final code in ControlFunctionsSGR.values) {
        expect(entity.contains(code), !code.isUnused);
      }
    });

    test('stateAtPos', () {
      const text = '$fgRed ${bold}bold $fgGreen$bgYellow'
          ' ${italicized}bold+italic$resetBoldAndFaint'
          ' $resetBg italic$resetItalicized $reset';
      final parser = AnsiParser(text);

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
      final stateAtPos0 = parser.stateAtPos(0);
      expect(stateAtPos0.foreground, Color16.red);
      expect(stateAtPos0.background, isNull);
      expect(stateAtPos0.isBold, isFalse);
      expect(stateAtPos0.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //   ^--
      final stateAtPos1 = parser.stateAtPos(1);
      expect(stateAtPos1.foreground, Color16.red);
      expect(stateAtPos1.background, isNull);
      expect(stateAtPos1.isBold, isTrue);
      expect(stateAtPos1.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //       ^--
      final stateAtPos5 = parser.stateAtPos(5);
      expect(stateAtPos5.foreground, Color16.red);
      expect(stateAtPos5.background, isNull);
      expect(stateAtPos5.isBold, isTrue);
      expect(stateAtPos5.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //        ^--
      final stateAtPos6 = parser.stateAtPos(6);
      expect(stateAtPos6.foreground, Color16.green);
      expect(stateAtPos6.background, Color16.yellow);
      expect(stateAtPos6.isBold, isTrue);
      expect(stateAtPos6.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //         ^--
      final stateAtPos7 = parser.stateAtPos(7);
      expect(stateAtPos7.foreground, Color16.green);
      expect(stateAtPos7.background, Color16.yellow);
      expect(stateAtPos7.isBold, isTrue);
      expect(stateAtPos7.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                   ^--
      final stateAtPos17 = parser.stateAtPos(17);
      expect(stateAtPos17.foreground, Color16.green);
      expect(stateAtPos17.background, Color16.yellow);
      expect(stateAtPos17.isBold, isTrue);
      expect(stateAtPos17.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                    ^--
      final stateAtPos18 = parser.stateAtPos(18);
      expect(stateAtPos18.foreground, Color16.green);
      expect(stateAtPos18.background, Color16.yellow);
      expect(stateAtPos18.isBold, isFalse);
      expect(stateAtPos18.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                     ^--
      final stateAtPos19 = parser.stateAtPos(19);
      expect(stateAtPos19.foreground, Color16.green);
      expect(stateAtPos19.background, null);
      expect(stateAtPos19.isBold, isFalse);
      expect(stateAtPos19.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                           ^--
      final stateAtPos25 = parser.stateAtPos(25);
      expect(stateAtPos25.foreground, Color16.green);
      expect(stateAtPos25.background, null);
      expect(stateAtPos25.isBold, isFalse);
      expect(stateAtPos25.isItalicized, isTrue);

      // " bold  bold+italic  italic "
      //                            ^--
      final stateAtPos26 = parser.stateAtPos(26);
      expect(stateAtPos26.foreground, Color16.green);
      expect(stateAtPos26.background, null);
      expect(stateAtPos26.isBold, isFalse);
      expect(stateAtPos26.isItalicized, isFalse);

      // " bold  bold+italic  italic "
      //                             ^--
      final stateAtPos27 = parser.stateAtPos(27);
      expect(stateAtPos27.foreground, null);
      expect(stateAtPos27.background, null);
      expect(stateAtPos27.isBold, isFalse);
      expect(stateAtPos27.isItalicized, isFalse);

      expect(
        () => parser.stateAtPos(-1),
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
        () => parser.stateAtPos(28),
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
        expect(AnsiParser(string).isClosed, isTrue);
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
        expect(AnsiParser(string).isClosed, isFalse);
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

      final parser = AnsiParser(text);
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
        final parser2 = AnsiParser(optimizedText);
        expect(
            parser2.showControlFunctions(),
            ' [fgWhite;bold;faint]first[resetBoldAndFaint]'
            ' [fg256Yellow][bg256Green][italicized]second[reset]'
            ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined;slowlyBlinking;negative]third[resetFg;resetBg;resetUnderlined]'
            ' [reset]');
        expect(parser2.isClosed, isTrue);
      }

      final unclosedOptimizedText = parser.optimize(close: false);
      {
        final parser2 = AnsiParser(unclosedOptimizedText);
        expect(
            parser2.showControlFunctions(),
            ' [fgWhite;bold;faint]first[resetBoldAndFaint]'
            ' [fg256Yellow][bg256Green][italicized]second[reset]'
            ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined;slowlyBlinking;negative]third[resetFg;resetBg;resetUnderlined]'
            ' ');
        expect(parser2.isClosed, isFalse);
      }

      // All.
      {
        final substring = parser.substring(0);
        expect(substring, optimizedText);
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(0, close: false);
        expect(
          unclosed,
          optimizedText.substring(
            0,
            optimizedText.length - 4, // ESC+[+0+SGR=reset
          ),
        );
        expect(
          unclosed.optimizeAnsiControlFunctions(),
          optimizedText,
        );
      }

      // " first"
      {
        final substring = parser.substring(0, maxLength: 6);
        expect(
          substring.showAnsiControlFunctions(),
          ' [fgWhite;bold;faint]first[reset]',
        );
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(0, maxLength: 6, close: false);
        expect(
          unclosed.showAnsiControlFunctions(),
          ' [fgWhite;bold;faint]first[resetBoldAndFaint]',
        );
        expect(unclosed.optimizeAnsiControlFunctions(close: false), unclosed);
      }

      // " first "
      {
        final substring = parser.substring(0, maxLength: 7);
        expect(
          substring.showAnsiControlFunctions(),
          ' [fgWhite;bold;faint]first[resetBoldAndFaint] [reset]',
        );
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(0, maxLength: 7, close: false);
        expect(
          unclosed.showAnsiControlFunctions(),
          ' [fgWhite;bold;faint]first[resetBoldAndFaint] ',
        );
        expect(unclosed.optimizeAnsiControlFunctions(close: false), unclosed);
      }

      // "first"
      {
        final substring = parser.substring(1, maxLength: 5);
        expect(
          substring.showAnsiControlFunctions(),
          '[fgWhite;bold;faint]first[reset]',
        );
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(1, maxLength: 5, close: false);
        expect(
          unclosed.showAnsiControlFunctions(),
          '[fgWhite;bold;faint]first[resetBoldAndFaint]',
        );
        expect(unclosed.optimizeAnsiControlFunctions(close: false), unclosed);
      }

      // "second"
      {
        final substring = parser.substring(7, maxLength: 6);
        expect(
          substring.showAnsiControlFunctions(),
          '[fg256Yellow][bg256Green][italicized]second[reset]',
        );
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(7, maxLength: 6, close: false);
        expect(
          unclosed.showAnsiControlFunctions(),
          '[fg256Yellow][bg256Green][italicized]second[reset]',
        );
        expect(unclosed.optimizeAnsiControlFunctions(close: false), unclosed);
      }

      // "third"
      {
        final substring = parser.substring(14, maxLength: 5);
        expect(
          substring.showAnsiControlFunctions(),
          '[fgRgb(255,128,0)][bgRgb(48,64,128)]'
          '[underlined;slowlyBlinking;negative]'
          'third[reset]',
        );
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(14, maxLength: 5, close: false);
        expect(
          unclosed.showAnsiControlFunctions(),
          '[fgRgb(255,128,0)][bgRgb(48,64,128)]'
          '[underlined;slowlyBlinking;negative]'
          'third[resetFg;resetBg;resetUnderlined]',
        );
        expect(unclosed.optimizeAnsiControlFunctions(close: false), unclosed);
      }

      // "rst sec"
      {
        final substring = parser.substring(3, maxLength: 7);
        expect(
          substring.showAnsiControlFunctions(),
          '[fgWhite;bold;faint]rst[resetBoldAndFaint]'
          ' [fg256Yellow][bg256Green][italicized]sec'
          '[reset]',
        );
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(3, maxLength: 7, close: false);
        expect(
          unclosed.showAnsiControlFunctions(),
          '[fgWhite;bold;faint]rst[resetBoldAndFaint]'
          ' [fg256Yellow][bg256Green][italicized]sec',
        );
        expect(unclosed.optimizeAnsiControlFunctions(close: false), unclosed);
      }

      // "ond thi"
      {
        final substring = parser.substring(10, maxLength: 7);
        expect(
          substring.showAnsiControlFunctions(),
          '[fg256Yellow][bg256Green][italicized]ond[reset]'
          ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined;slowlyBlinking;negative]thi[reset]',
        );
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(10, maxLength: 7, close: false);
        expect(
          unclosed.showAnsiControlFunctions(),
          '[fg256Yellow][bg256Green][italicized]ond[reset]'
          ' [fgRgb(255,128,0)][bgRgb(48,64,128)][underlined;slowlyBlinking;negative]thi',
        );
        expect(unclosed.optimizeAnsiControlFunctions(close: false), unclosed);
      }

      // "rd "
      {
        final substring = parser.substring(17);
        expect(
          substring.showAnsiControlFunctions(),
          '[fgRgb(255,128,0)][bgRgb(48,64,128)]'
          '[underlined;slowlyBlinking;negative]'
          'rd[resetFg;resetBg;resetUnderlined] [reset]',
        );
        expect(substring.optimizeAnsiControlFunctions(), substring);

        final unclosed = parser.substring(17, close: false);
        expect(
          unclosed.showAnsiControlFunctions(),
          '[fgRgb(255,128,0)][bgRgb(48,64,128)]'
          '[underlined;slowlyBlinking;negative]'
          'rd[resetFg;resetBg;resetUnderlined] ',
        );
        expect(unclosed.optimizeAnsiControlFunctions(close: false), unclosed);
      }

      final splicedText1 = parser.substring(0, maxLength: 1) +
          parser.substring(1, maxLength: 5) + // first
          parser.substring(6, maxLength: 1) +
          parser.substring(7, maxLength: 6) + // second
          parser.substring(13, maxLength: 1) +
          parser.substring(14, maxLength: 5) + // third
          parser.substring(19, maxLength: 1);
      expect(splicedText1.optimizeAnsiControlFunctions(), optimizedText);

      final splicedText2 = parser.substring(0, maxLength: 1, close: false) +
          parser.substring(1, maxLength: 5, close: false) + // first
          parser.substring(6, maxLength: 1, close: false) +
          parser.substring(7, maxLength: 6, close: false) + // second
          parser.substring(13, maxLength: 1, close: false) +
          parser.substring(14, maxLength: 5, close: false) + // third
          parser.substring(19, maxLength: 1, close: false);
      expect(
        splicedText2.optimizeAnsiControlFunctions(close: false),
        unclosedOptimizedText,
      );

      final splicedText3 = parser.substring(0, maxLength: 3) + // ' fi'
          parser.substring(3, maxLength: 7) + // rst sec
          parser.substring(10, maxLength: 7) + // ond thi
          parser.substring(17, maxLength: 3); // 'rd '
      expect(splicedText3.optimizeAnsiControlFunctions(), optimizedText);

      final splicedText4 =
          parser.substring(0, maxLength: 3, close: false) + // ' fi'
              parser.substring(3, maxLength: 7, close: false) + // rst sec
              parser.substring(10, maxLength: 7, close: false) + // ond thi
              parser.substring(17, maxLength: 3, close: false); // 'rd '
      expect(
        splicedText4.optimizeAnsiControlFunctions(close: false),
        unclosedOptimizedText,
      );
    });

    group('AnsiPrinter', () {
      test('print', () {
        final output1 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedAnsiPrinter(
              defaultState: const SgrPlainState(
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
          AnsiParser(output1[0]).showControlFunctions(),
          '[reset][fgBlack;bgWhite]default colors'
          '[fgYellow;bgGreen;bold;italicized;underlined] yellow on green'
          ' [resetBoldAndFaint;resetItalicized;resetUnderlined;fgBlack;bgWhite]'
          'default colors[reset]',
        );

        final output2 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedAnsiPrinter(
              defaultState: const SgrPlainState(
                foreground: Color16.black,
                background: Color16.white,
              ),
              () => print('default colors'
                  '$fgYellow$bgGreen$underlined$bold$italicized yellow on green'
                  ' $reset'
                  'default colors'),
            );
          },
        );

        expect(
          AnsiParser(output2[0]).showControlFunctions(),
          '[reset][fgBlack;bgWhite]default colors'
          '[fgYellow;bgGreen;bold;italicized;underlined] yellow on green'
          ' [resetBoldAndFaint;resetItalicized;resetUnderlined;fgBlack;bgWhite]'
          'default colors[reset]',
        );

        final output3 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedAnsiPrinter(
              defaultState: const SgrPlainState(
                foreground: Color16.yellow,
                background: Color16.green,
                bold: true,
                italicized: true,
                singlyUnderlined: true,
              ),
              () => print('default colors'
                  '$fgYellow$bgGreen$underlined$bold$italicized yellow on green'
                  ' $reset'
                  'default colors'),
            );
          },
        );

        expect(
          AnsiParser(output3[0]).showControlFunctions(),
          '[reset][fgYellow;bgGreen;bold;italicized;underlined]default colors'
          ' yellow on green default colors[reset]',
        );
      });

      test('multiline', () {
        final output1 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedAnsiPrinter(
              () => print('\nTitle\nSubtitle\n'),
            );
          },
        );

        expect(
          output1.join('\n').showAnsiControlFunctions(),
          '\n'
          '[reset]Title\n'
          '[reset]Subtitle\n',
        );

        final output2 = interceptZonedPrint(
          // debugPrint: true,
          () {
            runZonedAnsiPrinter(
              defaultState: const SgrPlainState(
                foreground: Color16.yellow,
                background: Color16.green,
              ),
              () => print('\nTitle\nSubtitle\n'),
            );
          },
        );

        expect(
          output2.join('\n').showAnsiControlFunctions(),
          '\n'
          '[reset][fgYellow;bgGreen]Title[reset]\n'
          '[reset][fgYellow;bgGreen]Subtitle[reset]\n',
        );
      });

      test('sink multiline', () {
        final buf = StringBuffer();

        AnsiPrinter.sink(
          buf,
          defaultState: const SgrPlainState(
            foreground: Color16.yellow,
            background: Color16.green,
          ),
        ).write('\nTitle\nSubtitle\n');

        expect(
          buf.toString().showAnsiControlFunctions(),
          '\n'
          '[reset][fgYellow;bgGreen]Title[reset]\n'
          '[reset][fgYellow;bgGreen]Subtitle[reset]\n',
        );
      });
    });

    test('stacked AnsiPrinter', () {
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
          runZonedAnsiPrinter(
            defaultState: const SgrPlainState(
              foreground: Color256(Colors.rgb555),
              background: Color256(Colors.rgb320),
            ),
            stacked: true,
            () => print(text),
          );
        },
      );

      expect(
        AnsiParser(output[0]).showControlFunctions(),
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
