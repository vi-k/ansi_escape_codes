import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Inputs whose last code cannot be finished, so that the seam of an
/// insertion is the place in front of the run rather than the end of the
/// string — with something finished standing between that run and the text
/// before it, which is what tells the seam's own state and link apart from
/// the ones the piece of text leaves behind.
const _inputs = <String>[
  'aa\x1B[31m\x1B]8;;http://u/\x1B[',
  'aa\x1B]8;;http://o/\x1B\\\x1BPpay',
  'aa\x1BPpay\x1B',
  'aa\x1B[31m\x1BPpay\x1B',
  'aa\x1B[31\x1B[31\x1BPpay\x1B',
  '\x1BPpay\x1B',
  'aa\x1B]8;;http://u/\x1B\\bb\x1BPpay',
  'aa\x1B[1m\x1B(B\x1B[',
  'aa\x1B[31mbb\x1B[0m\x1B[',
  'aabb\x1B[',
  '\x1B[31maa\x1B[',
  'aa\x1B]8;;http://u/\x1B\\\x1B[32m\x1BPpay\x1B',
];

/// Texts that leave the two channels in every state they can be left in:
/// untouched, restyled and closed, a link closed, a link opened.
const _texts = <String>[
  '@',
  '\x1B[32m@\x1B[0m',
  '@\x1B]8;;\x1B\\',
  '\x1B]8;;http://n/\x1B\\@',
];

void main() {
  test('an insertion leaves the string ending where it ended', () {
    for (final input in _inputs) {
      final before = Parser(input);
      final wasState = before.finalState;
      final wasLink = before.finalLink;

      for (var pos = 0; pos <= Parser(input).length; pos++) {
        for (final text in _texts) {
          for (final after in [true, false]) {
            final String result;
            try {
              final parser = Parser(input);
              result = after
                  ? parser.insertAfter(pos, text)
                  : parser.insertBefore(pos, text);
            } on UnfinishedSequenceException {
              continue;
            }

            final now = Parser(result);
            final reason = 'input ${input.ansiShowEscapeSequences()}, '
                'pos $pos, after: $after, '
                'text ${text.ansiShowEscapeSequences()}';

            expect(now.finalState, wasState, reason: reason);
            expect(now.finalLink, wasLink, reason: reason);
          }
        }
      }
    }
  });
}
