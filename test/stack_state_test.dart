import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';
import 'package:ansi_escape_codes/style.dart' as styles;
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Stack tolerates unbalanced resets:', () {
    test('every reset code alone leaves the state at terminal colors', () {
      const resets = {
        'resetBoldAndDim': resetBoldAndDim,
        'resetItalic': resetItalic,
        'resetUnderline': resetUnderline,
        'resetBlink': resetBlink,
        'resetInverse': resetInverse,
        'resetInvisible': resetInvisible,
        'resetStrikethrough': resetStrikethrough,
        'resetFrameAndEncircle': resetFrameAndEncircle,
        'resetOverline': resetOverline,
        'resetSuperAndSubscript': resetSuperAndSubscript,
        'resetFg': resetFg,
        'resetBg': resetBg,
        'resetUnderlineColor': resetUnderlineColor,
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
        Parser(styles.red('${resetFg}hello')).showControlFunctions(),
        '[reset][fg256Red]hello[reset]',
      );
    });

    test('keeps an attribute of the caller', () {
      expect(
        Parser(styles.bold('${resetBoldAndDim}x')).showControlFunctions(),
        '[reset][bold]x[reset]',
      );
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
