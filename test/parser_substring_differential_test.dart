import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  const text = '\x1B[1m\x1B[31mERROR\x1B[22m\x1B[39m '
      '\x1B]8;;http://u\x1B\\link\x1B]8;;\x1B\\ '
      'plain middle \x1B[4munderlined\x1B[24m tail\x1B[0m trailing';

  group('sequential slices equal fresh-parser slices', () {
    test('forward line-by-line', () {
      final reused = Parser(text);
      final total = reused.length;

      var start = 0;
      while (start <= total) {
        final expected = Parser(text).substring(start, maxLength: 7);
        expect(
          reused.substring(start, maxLength: 7),
          expected,
          reason: 'slice at $start diverged on the reused parser',
        );
        start += 7;
      }
    });

    test('randomized starts, lengths and close, fixed seed', () {
      final random = Random(20260804);
      final reused = Parser(text);
      final total = reused.length;

      for (var i = 0; i < 300; i++) {
        final start = random.nextInt(total + 1);
        final maxLength = random.nextBool() ? null : random.nextInt(total + 1);
        final close = random.nextBool();

        final expected =
            Parser(text).substring(start, maxLength: maxLength, close: close);
        expect(
          reused.substring(start, maxLength: maxLength, close: close),
          expected,
          reason: 'start: $start, maxLength: $maxLength, close: $close',
        );
      }
    });

    test('sequential inserts equal fresh-parser inserts', () {
      final random = Random(20260804);
      final reused = Parser(text);
      final total = reused.length;

      for (var i = 0; i < 100; i++) {
        final pos = random.nextInt(total + 1);
        final after = random.nextBool();

        final expected = after
            ? Parser(text).insertAfter(pos, 'x')
            : Parser(text).insertBefore(pos, 'x');
        final actual = after
            ? reused.insertAfter(pos, 'x')
            : reused.insertBefore(pos, 'x');
        expect(actual, expected, reason: 'pos: $pos, after: $after');
      }
    });

    test('stateAt interleaved with substring stays consistent', () {
      final random = Random(20260804);
      final reused = Parser(text);
      final total = reused.length;

      for (var i = 0; i < 200; i++) {
        final pos = random.nextInt(total);
        if (random.nextBool()) {
          expect(reused.stateAt(pos), Parser(text).stateAt(pos));
        } else {
          expect(
            reused.substring(pos, maxLength: 5),
            Parser(text).substring(pos, maxLength: 5),
          );
        }
      }
    });
  });
}
