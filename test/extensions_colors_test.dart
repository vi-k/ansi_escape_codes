import 'package:ansi_escape_codes/extensions.dart';
import 'package:test/test.dart';

void main() {
  group('foreground:', () {
    test('is found whatever else the sequence carries', () {
      const found = [
        '\x1B[31m', // a colour on its own
        '\x1B[1;31m', // after another function
        '\x1B[31;1m', // before another function
        '\x1B[39m', // back to the default colour
        '\x1B[38;5;196m', // from the 256-colour table
        '\x1B[1;38;5;196;3m', // ... between other functions
        '\x1B[38;2;1;2;3m', // by RGB
        '\x1B[38:5:196m', // the colon form
        '\x1B[1;38:2::1:2:3m', // ... with an empty colour space id
        '\x1B[90m', // a high colour
      ];

      for (final text in found) {
        expect(text.ansiHasForeground, isTrue, reason: text);
      }
    });

    test('is not confused with the other functions', () {
      const notFound = [
        '\x1B[m',
        '\x1B[0m', // reset touches every property, not just the colour
        '\x1B[1m',
        '\x1B[41m', // a background colour
        '\x1B[48;5;196m',
        '\x1B[58;5;196m', // an underline colour
        'plain text',
      ];

      for (final text in notFound) {
        expect(text.ansiHasForeground, isFalse, reason: text);
      }
    });

    test('is removed without dropping the functions around it', () {
      const removed = {
        '\x1B[31m': '',
        '\x1B[1;31m': '\x1B[1m',
        '\x1B[31;1m': '\x1B[1m',
        '\x1B[39m': '',
        '\x1B[38;5;196m': '',
        '\x1B[1;38;5;196;3m': '\x1B[1;3m',
        '\x1B[38;2;1;2;3m': '',
        '\x1B[38:5:196m': '',
        '\x1B[1;38:5:196m': '\x1B[1m',
        'a\x1B[1;31mb\x1B[0mc': 'a\x1B[1mb\x1B[0mc',
        '\x1B[41m': '\x1B[41m',
        '\x1B[1m': '\x1B[1m',
      };

      for (final MapEntry(key: text, value: expected) in removed.entries) {
        expect(text.ansiRemoveForeground(), expected, reason: text);
      }
    });
  });

  group('background:', () {
    test('is found whatever else the sequence carries', () {
      const found = [
        '\x1B[41m',
        '\x1B[1;41m',
        '\x1B[49m',
        '\x1B[48;5;196m',
        '\x1B[48;2;1;2;3m',
        '\x1B[48:5:196m',
        '\x1B[100m',
      ];

      for (final text in found) {
        expect(text.ansiHasBackground, isTrue, reason: text);
      }
    });

    test('is removed without dropping the functions around it', () {
      const removed = {
        '\x1B[41m': '',
        '\x1B[1;41m': '\x1B[1m',
        '\x1B[1;48;5;196;3m': '\x1B[1;3m',
        '\x1B[31m': '\x1B[31m',
      };

      for (final MapEntry(key: text, value: expected) in removed.entries) {
        expect(text.ansiRemoveBackground(), expected, reason: text);
      }
    });
  });
}
