import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The pieces a terminal stream is made of, the broken ones included: an
/// unterminated OSC, a CSI with nothing to end it, an ESC on its own.
///
/// The eight-bit CSI is among them because it is text to this package and
/// has to stay text on both paths. Alone it proves little — with no ESC in
/// the string `ansiRemoveEscapeCodes` returns early and never looks at the
/// pattern — but drawn beside any of the sequences here it lands in a string
/// that does reach the regex.
const _fragments = <String>[
  'text',
  '\x9B31m',
  ' ',
  'a',
  '\n',
  '\t',
  '\x7F',
  'ё',
  '𝄞',
  '\x1B[31m',
  '\x1B[0m',
  '\x1B[1;31m',
  '\x1B[m',
  '\x1B[;m',
  '\x1B[38;5;196m',
  '\x1B[38:2::1:2:3m',
  '\x1B[4:3m',
  '\x1B[A',
  '\x1B[12;34H',
  '\x1B[2J',
  '\x1B[?25l',
  '\x1B[?1049h',
  '\x1B[1 q',
  '\x1B[!p',
  '\x1B[99999999999999999999999m',
  '\x1B]8;;https://e.test\x1B\\',
  '\x1B]8;;\x1B\\',
  '\x1B]0;title\x07',
  '\x1B]0;unterminated',
  '\x1B]',
  '\x1B7',
  '\x1B8',
  '\x1Bc',
  '\x1B(B',
  '\x1B#8',
  '\x1B e',
  '\x1B',
  '\x1B[',
  '\x1B[38;5;',
  '\x1B[31',
];

void main() {
  group('taking the escape codes out:', () {
    test('the extension and the parser agree, whatever is thrown at them', () {
      // The seed is fixed so that a failure can be looked at again.
      final random = Random(20260803);

      for (var i = 0; i < 5000; i++) {
        final parts = [
          for (var j = 0; j < random.nextInt(6) + 1; j++)
            _fragments[random.nextInt(_fragments.length)],
        ];
        final text = parts.join();

        expect(
          text.ansiRemoveEscapeCodes(),
          Parser(text).removeAll(),
          reason: 'on ${text.codeUnits}',
        );
      }
    });

    test('a sequence broken in every way it can be', () {
      expect(
        'a\x1B'.ansiRemoveEscapeCodes(),
        'a',
        reason: 'an ESC with nothing after it',
      );
      expect(
        'a\x1Bbc'.ansiRemoveEscapeCodes(),
        'ac',
        reason: 'b can end a sequence, so ESC b is one and goes whole',
      );
      expect(
        'a\x1B\x01b'.ansiRemoveEscapeCodes(),
        'a\x01b',
        reason: 'a byte that cannot end a sequence is left where it was',
      );
      expect(
        'a\x1B]0;title'.ansiRemoveEscapeCodes(),
        'a',
        reason: 'an unterminated OSC runs to the end, as a terminal waits',
      );
      expect(
        'a\x1B]0;title${fgRed}b$reset'.ansiRemoveEscapeCodes(),
        'ab',
        reason: 'or to the next sequence, whichever comes first',
      );
      expect(
        'a\x1B[38;5;b'.ansiRemoveEscapeCodes(),
        'a',
        reason: 'b ends a control sequence, it is not text',
      );
    });

    test('what is not an escape code stays', () {
      expect('a\nb\tc'.ansiRemoveEscapeCodes(), 'a\nb\tc');
      expect('a\x7Fb'.ansiRemoveEscapeCodes(), 'a\x7Fb', reason: 'DEL');
      expect('𝄞${fgRed}x$reset'.ansiRemoveEscapeCodes(), '𝄞x');
      expect(
        'a\x9B31mb'.ansiRemoveEscapeCodes(),
        'a\x9B31mb',
        reason: 'the eight-bit CSI is no escape code in a Dart string',
      );
    });
  });
}
