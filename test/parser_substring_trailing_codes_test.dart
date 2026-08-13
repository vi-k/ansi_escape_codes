import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Strings whose last piece is an escape code rather than text.
///
/// A parser that keeps its place keeps it in a piece of text, and whatever
/// stands after the last piece is behind every place there is. These are the
/// strings that tell a parser which remembers that from one which does not:
/// the text of `parser_substring_differential_test.dart` ends in plain text,
/// so every position in it has a piece of text after it and the question
/// never comes up.
const fixtures = <String, String>{
  'an erase after the last piece': 'abc\x1B[2J',
  'a link closed after the last piece':
      '\x1B]8;;http://u\x1B\\link\x1B]8;;\x1B\\',
  'a lone ESC after the last piece': 'abc\x1B',
  'a reset after the last piece':
      '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m text\x1B[0m',
};

void main() {
  fixtures.forEach((name, text) {
    group('a reused parser answers as a fresh one: $name', () {
      final total = Parser(text).length;

      test('slicing again after a slice that read the whole string', () {
        // The first slice reads to the end and so takes the codes standing
        // after the last piece out of the pieces; the slices after it must
        // write those codes out all the same.
        final reused = Parser(text)..substring(0);

        for (var start = 1; start <= total; start++) {
          expect(
            reused.substring(start),
            Parser(text).substring(start),
            reason: 'slice at $start, after one that read to the end',
          );
        }
      });

      test('over every start, length and close there is', () {
        final reused = Parser(text);

        for (var start = 0; start <= total; start++) {
          for (final maxLength in <int?>[
            null,
            for (var n = 0; n <= total + 1; n++) n,
          ]) {
            for (final close in [true, false]) {
              expect(
                reused.substring(start, maxLength: maxLength, close: close),
                Parser(text).substring(
                  start,
                  maxLength: maxLength,
                  close: close,
                ),
                reason: 'start: $start, maxLength: $maxLength, close: $close',
              );
            }
          }
        }
      });

      test('over every seam there is', () {
        final reused = Parser(text)..substring(0);

        for (var pos = 0; pos <= total; pos++) {
          expect(
            reused.insertBefore(pos, 'x'),
            Parser(text).insertBefore(pos, 'x'),
            reason: 'insertBefore at $pos',
          );
          expect(
            reused.insertAfter(pos, 'x'),
            Parser(text).insertAfter(pos, 'x'),
            reason: 'insertAfter at $pos',
          );
        }
      });

      test('with stateAt interleaved, at random', () {
        final random = Random(20260804);
        final reused = Parser(text);

        for (var i = 0; i < 200; i++) {
          switch (random.nextInt(3)) {
            case 0:
              final pos = random.nextInt(total);
              expect(
                reused.stateAt(pos),
                Parser(text).stateAt(pos),
                reason: 'stateAt $pos',
              );
            case 1:
              final pos = random.nextInt(total + 1);
              expect(
                reused.substring(pos),
                Parser(text).substring(pos),
                reason: 'substring $pos, to the end',
              );
            case _:
              final pos = random.nextInt(total + 1);
              expect(
                reused.substring(pos, maxLength: 2),
                Parser(text).substring(pos, maxLength: 2),
                reason: 'substring $pos, two long',
              );
          }
        }
      });
    });
  });
}
