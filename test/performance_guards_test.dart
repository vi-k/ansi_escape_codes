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

    test('slicing a document line by line stays linear', () {
      const line = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
          'a sentence of ordinary words to slice';
      String page(int lines) => List.filled(lines, line).join('\n');
      final width = Parser(line).length;

      double sliceAll(String text, int lines) {
        final parser = Parser(text)..prepare();

        return bestOf(() {
          for (var i = 0; i < lines; i++) {
            parser.substring(i * (width + 1), maxLength: width);
          }
        });
      }

      // Warm-up.
      sliceAll(page(50), 50);

      final tSmall = sliceAll(page(400), 400);
      final tLarge = sliceAll(page(800), 800);

      expect(
        tLarge / tSmall,
        lessThan(2.5),
        reason: 'twice the lines must not cost near four times the walk '
            '(${tSmall.toStringAsFixed(0)} µs → '
            '${tLarge.toStringAsFixed(0)} µs)',
      );
    });

    test('a run of insertions does not read the string again each time', () {
      // A floor rather than a growth ratio. Every insertion builds a whole
      // new string, so a run of them is quadratic in the input however the
      // parser behaves, and a doubling would say nothing about the parser;
      // and the two things that keep a run cheap — the walk carried between
      // the questions and the matches already read — stand in for each
      // other, so neither shows on its own. Measured by mutation: dropping
      // the walk leaves this ratio at 17, dropping the cache of matches
      // leaves it at 21, dropping both puts it at 1.0. This is the floor
      // under the pair.
      const line = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
          'a sentence of ordinary words to insert into';
      const lines = 400;
      final page = List.filled(lines, line).join('\n');
      final width = Parser(line).length;

      // Warm-up, so the JIT settles before anything is timed.
      Parser(page).insertAfter(0, '@');

      final shared = bestOf(() {
        final parser = Parser(page);
        for (var i = 0; i < lines; i++) {
          parser.insertAfter(i * (width + 1), '@');
        }
      });
      final fresh = bestOf(() {
        for (var i = 0; i < lines; i++) {
          Parser(page).insertAfter(i * (width + 1), '@');
        }
      });

      expect(
        fresh / shared,
        greaterThan(4),
        reason: 'a parser asked one insertion after another must not read the '
            'string from the beginning every time '
            '(${shared.toStringAsFixed(0)} µs against '
            '${fresh.toStringAsFixed(0)} µs)',
      );
    });
  });

  group('memory pins', () {
    test('a Text piece materializes its string once', () {
      final parser = Parser('\x1B[31mred\x1B[0m and plain');
      final texts = [
        for (final m in parser.matches)
          if (m.entity case final Text text) text,
      ];

      expect(texts, isNotEmpty);
      for (final text in texts) {
        expect(
          identical(text.string, text.string),
          isTrue,
          reason: 'string must be built once and kept, not rebuilt per read',
        );
      }
    });
  });
}
