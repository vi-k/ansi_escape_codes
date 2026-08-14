import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('the stack unwinds one level at a time:', () {
    test('a property put on twice comes back to the first of the two', () {
      final frames = Stack.terminalColors.frame.encircle;
      expect(frames.frameStyle, FrameStyle.encircle);
      expect(frames.resetFrameAndEncircle.frameStyle, FrameStyle.frame);

      final blinks = Stack.terminalColors.blink.blinkRapid;
      expect(blinks.blinkStyle, BlinkStyle.rapid);
      expect(blinks.resetBlink.blinkStyle, BlinkStyle.slow);

      final underlines = Stack.terminalColors.underline.doublyUnderline;
      expect(underlines.underlineStyle, UnderlineStyle.doubly);
      expect(underlines.isDoublyUnderline, isTrue);
      expect(underlines.resetUnderline.underlineStyle, UnderlineStyle.singly);

      final scripts = Stack.terminalColors.superscript.subscript;
      expect(scripts.scriptStyle, ScriptStyle.subscript);
      expect(
        scripts.resetSuperAndSubscript.scriptStyle,
        ScriptStyle.superscript,
      );
    });

    test('and the ones that only count are counted', () {
      final twice = Stack.terminalColors.inverse.inverse;
      expect(twice.isInverse, isTrue);
      expect(
        twice.resetInverse.isInverse,
        isTrue,
        reason: 'one reset undoes one of the two',
      );
      expect(twice.resetInverse.resetInverse.isInverse, isFalse);

      final once = Stack.terminalColors.invisible.overline;
      expect(once.isInvisible, isTrue);
      expect(once.isOverline, isTrue);
      expect(once.resetInvisible.isInvisible, isFalse);
      expect(once.resetOverline.isOverline, isFalse);
    });

    test('a colour of the underline is remembered under the next one', () {
      final colours = Stack.terminalColors
          .underlineColor(Color256.red)
          .underlineColor(Color256.blue);

      expect(colours.underlineColorValue, Color256.blue);
      expect(colours.resetUnderlineColor.underlineColorValue, Color256.red);
      expect(
        colours.resetUnderlineColor.resetUnderlineColor.underlineColorValue,
        isNull,
      );
    });

    test('and says which it is when asked', () {
      expect(Stack.terminalColors.bold.toString(), 'Stack(bold)');
    });
  });

  group('Stack tolerates unbalanced resets:', () {
    test('every reset code alone leaves the state at terminal colors', () {
      const resets = {
        'resetBoldAndDim': resetBoldAndDim,
        'resetFont': primaryFont,
        'resetItalic': resetItalic,
        'resetFontShape': resetFontShape,
        'resetUnderline': resetUnderline,
        'resetBlink': resetBlink,
        'resetProportionalSpacing': resetProportionalSpacing,
        'resetInverse': resetInverse,
        'resetInvisible': resetInvisible,
        'resetStrikethrough': resetStrikethrough,
        'resetFrameAndEncircle': resetFrameAndEncircle,
        'resetOverline': resetOverline,
        'resetSuperAndSubscript': resetSuperAndSubscript,
        'resetFg': resetFg,
        'resetBg': resetBg,
        'resetUnderlineColor': resetUnderlineColor,
        'resetIdeogram': resetIdeogram,
      };

      for (final MapEntry(key: name, value: code) in resets.entries) {
        expect(
          StackedParser('${code}text').finalState,
          Stack.terminalColors,
          reason: name,
        );
      }
    });

    test('reset of a property whose stack is empty keeps other properties', () {
      // The guard of `resetUnderlineColor` used to look at the foreground
      // stack, so a non-empty foreground let it pop an empty underline stack.
      final state =
          StackedParser('${fgRed}text$resetUnderlineColor').finalState;

      expect(state.foregroundColor, Color16.red);
      expect(state.underlineColorValue, isNull);
    });

    test('carries an underline colour through the stack', () {
      expect(
        Stack.terminalColors.underlineColor(Color256.red).underlineColorValue,
        Color256.red,
      );
      expect(
        StackedParser('\x1B[58;5;1m').finalState.underlineColorValue,
        Color256.red,
      );
    });

    test('nesting of the same property still unwinds one level at a time', () {
      expect(
        StackedParser('$bold$bold$resetBoldAndDim').finalState.isBold,
        isTrue,
      );
      expect(
        StackedParser('$bold$bold$resetBoldAndDim$resetBoldAndDim')
            .finalState
            .isBold,
        isFalse,
      );
    });
  });

  group('Style.call on unbalanced input:', () {
    test('keeps the style of the caller', () {
      expect(
        Parser(Styles.red('${resetFg}hello')).showControlFunctions(),
        '[reset][fg256Red]hello[reset]',
      );
    });

    test('keeps an attribute of the caller', () {
      expect(
        Parser(Styles.bold('${resetBoldAndDim}x')).showControlFunctions(),
        '[reset][bold]x[reset]',
      );
    });
  });

  group('Style.call follows terminal resets:', () {
    const foreground = '${fgGreen}a${fgYellow}b${resetFg}c';

    test('matches an ordinary Printer with the same default style', () {
      final styled = Styles.red(foreground);
      final printed = Printer(defaultStyle: Styles.red).prepare(foreground);

      expect(styled, printed);
      expect(
        styled,
        '$reset${fgGreen}a${fgYellow}b${fg256Red}c$reset',
      );
      expect(Parser(styled).stateAt(2).foregroundColor, Color256.red);
    });

    final cases = <(String, String, void Function(Style))>[
      (
        'background',
        '${bgGreen}a${bgYellow}b${resetBg}c',
        (state) => expect(state.backgroundColor, isNull),
      ),
      (
        'counter',
        '${inverse}a${inverse}b${resetInverse}c',
        (state) => expect(state.isInverse, isFalse),
      ),
      (
        'exclusive enum',
        '${underline}a${doublyUnderline}b${resetUnderline}c',
        (state) => expect(state.underlineStyle, isNull),
      ),
      (
        'extended color',
        '${underline256(1)}a'
            '${underline256(2)}b${resetUnderlineColor}c',
        (state) => expect(state.underlineColorValue, isNull),
      ),
      (
        'font',
        '${alternativeFont1}a${alternativeFont2}b${primaryFont}c',
        (state) => expect(state.fontSelection, FontSelection.primary),
      ),
    ];

    for (final (name, input, check) in cases) {
      test('$name reset does not expose the previous inner value', () {
        final state = Parser(Styles.red(input)).stateAt(2);

        expect(
          state.foregroundColor,
          Color256.red,
          reason: input.ansiShowControlFunctions(),
        );
        check(state);
      });
    }

    test('keeps nested Styles byte-for-byte', () {
      expect(
        Styles.red('abc${Styles.green('green')}def'),
        '$reset${fg256Red}abc${fg256Green}green${fg256Red}def$reset',
      );
    });

    test('explicit stacked APIs keep their pop contract', () {
      expect(
        StackedParser(foreground).stateAt(2).foregroundColor,
        Color16.green,
      );

      final output =
          StackedPrinter(defaultStyle: Styles.red).prepare(foreground);
      expect(Parser(output).stateAt(2).foregroundColor, Color16.green);
    });
  });

  test('runZonedStackedPrinter accepts unbalanced input', () {
    final output = interceptZonedPrint(() {
      runZonedStackedPrinter(
        defaultStyle: const Style(foreground: Color256.green),
        () => print('${resetFg}foo'),
      );
    });

    expect(
      output.map((line) => line.ansiShowControlFunctions()).toList(),
      ['[reset][fg256Green]foo[reset]'],
    );
  });
}
