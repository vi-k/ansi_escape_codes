import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The best of [runs] timings of [body], in microseconds: the run least
/// disturbed by whatever else the machine was doing.
double bestOf(void Function() body, {int runs = 3}) {
  var best = double.infinity;
  for (var i = 0; i < runs; i++) {
    final watch = Stopwatch()..start();
    body();
    watch.stop();
    final us = watch.elapsedMicroseconds.toDouble();
    if (us < best) {
      best = us;
    }
  }

  return best;
}

/// A page of [lines] plain lines, ESC-free.
String plainPage(int lines) =>
    List.filled(lines, 'an ordinary line of an ordinary log, no codes')
        .join('\n');

void main() {
  group('complexity guards', () {
    test('parsing plain text stays linear', () {
      final small = plainPage(2000);
      final large = plainPage(4000);

      // Warm-up, so the JIT settles before anything is timed.
      Parser(small).removeAll();
      Parser(large).removeAll();

      final tSmall = bestOf(() => Parser(small).removeAll());
      final tLarge = bestOf(() => Parser(large).removeAll());

      expect(
        tLarge / tSmall,
        lessThan(2.5),
        reason: 'doubling the input must not much more than double the cost '
            '(${tSmall.toStringAsFixed(0)} µs → '
            '${tLarge.toStringAsFixed(0)} µs)',
      );
    });
  });
}
