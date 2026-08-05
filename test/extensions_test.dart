import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('asking a string what it carries:', () {
    test('tells the kinds of escape code apart', () {
      expect('plain'.ansiHasEscapeCodes, isFalse);
      expect('${fgRed}x$reset'.ansiHasEscapeCodes, isTrue);
      expect(
        'a\x1B(Bb'.ansiHasEscapeCodes,
        isTrue,
        reason: 'an ESC sequence is an escape code too',
      );

      expect('${cursorUp}x'.ansiHasCsi, isTrue);
      expect(
        '${cursorUp}x'.ansiHasSgr,
        isFalse,
        reason: 'CUU is a control sequence, but no graphic rendition',
      );
      expect('${fgRed}x'.ansiHasSgr, isTrue);
      expect(
        'a\x1B(Bb'.ansiHasCsi,
        isFalse,
        reason: 'and an ESC sequence is no control sequence',
      );
    });
  });

  group('taking escape codes back out:', () {
    const text = '$cursorUp${fgRed}text$reset';

    test('by the kind asked for', () {
      expect(
        text.ansiRemoveCsi(),
        'text',
        reason: 'an SGR sequence is a control sequence as well',
      );
      expect(
        text.ansiRemoveSgr().ansiShowEscapeSequences(),
        '[CSI CUU]text',
        reason: 'and the cursor move is not one, so it stays',
      );
      expect(text.ansiRemoveEscapeCodes(), 'text');
    });

    test('and counting what is left of the string', () {
      expect('${fgRed}SEVERE$reset'.lengthWithoutEscapeCodes, 6);
      expect('plain'.lengthWithoutEscapeCodes, 5);
    });

    test('the count agrees with the string it never builds', () {
      const inputs = [
        '',
        'plain',
        '\x1B[31mred\x1B[0m',
        '\x1B[38;5;196mx',
        'a\x1B]8;;http://u/\x1B\\link\x1B]8;;\x1B\\b',
        '\x1B',
        'a\x1B[',
        '𝄞\x1B[31m𝄞',
      ];

      for (final text in inputs) {
        expect(
          text.lengthWithoutEscapeCodes,
          text.ansiRemoveEscapeCodes().length,
          reason: 'on ${text.codeUnits}',
        );
      }
    });
  });

  group('showing what would otherwise be obeyed:', () {
    test('a control code in each of the six styles', () {
      const text = 'a\nb';

      expect(
        text.ansiShowControlCodes(preferStyle: ControlCodeStyle.charCode),
        r'a\x0Ab',
      );
      expect(
        text.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr),
        'a[LF]b',
      );
      expect(
        text.ansiShowControlCodes(preferStyle: ControlCodeStyle.unicode),
        'a␊b',
      );
      expect(
        text.ansiShowControlCodes(preferStyle: ControlCodeStyle.escapeOrAbbr),
        r'a\nb',
        reason: 'the line feed is one Dart has an escape for',
      );
    });

    test('and a control code Dart has no escape for', () {
      const text = 'a\x01b';

      expect(
        text.ansiShowControlCodes(),
        r'a\x01b',
        reason: 'escapeOrCharCode is what it does without being asked',
      );
      expect(
        text.ansiShowControlCodes(preferStyle: ControlCodeStyle.escapeOrAbbr),
        'a[SOH]b',
      );
      expect(
        text.ansiShowControlCodes(
          preferStyle: ControlCodeStyle.escapeOrUnicode,
        ),
        'a␁b',
      );
    });

    test('keeps the text after the last escape code', () {
      expect('${fgRed}a'.ansiShowEscapeSequences(), '[CSI 31 SGR]a');
      expect('a${fgRed}b'.ansiShowEscapeSequences(), 'a[CSI 31 SGR]b');
    });
  });
}
