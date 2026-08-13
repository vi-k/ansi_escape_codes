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

    test('a stack that only deepens stays linear', () {
      // A log that switches colour and never resets: every code pushes and
      // nothing pops, so the histories a `Stack` keeps grow the whole length
      // of the string. Lists made that quadratic — a push copied the list it
      // grew, and `_copyWith` copied it again to seal it — and since a parse
      // keeps every state it passed, the copies were kept as well. 320 kB of
      // this shape took 15 s and 7.6 GB before frames with a shared tail
      // replaced them, against 51 ms for the same string through `Parser`.
      String page(int runs) => '\x1B[31mfoo\x1B[32mbar' * runs;
      const runs = 4000;
      final small = page(runs);
      final large = page(runs * 2);

      // Warm-up, so the JIT settles before anything is timed.
      StackedParser(page(500)).finalState;

      final tSmall = bestOf(() => StackedParser(small).finalState);
      final tLarge = bestOf(() => StackedParser(large).finalState);

      // The anchor. A guard that only times something goes green when the
      // thing stops being done at all, so this says the parse really walked
      // the string and really kept a history to walk back down.
      final parsed = StackedParser(small);
      expect(parsed.length, 6 * runs, reason: 'foo and bar, once a run');
      var state = parsed.finalState;
      expect(state.foregroundColor, Color16.green);
      for (var i = 0; i < 6; i++) {
        state = state.resetForeground;
        expect(
          state.foregroundColor,
          i.isEven ? Color16.red : Color16.green,
          reason: 'the colours were pushed and are still there to pop, '
              'rather than the last of them standing alone',
        );
      }

      // The threshold sits between two measured figures rather than at a
      // round number. Frames read 1.86, 2.24 and 2.09 over three runs of
      // this very shape — two being what linear looks like — and the lists
      // they replaced read 5.37 for it, put back by hand to see this go red
      // (210 ms against 1127 ms). 3.5 leaves each side about half again of
      // room, which is what a shared runner needs.
      expect(
        tLarge / tSmall,
        lessThan(3.5),
        reason: 'twice the pushes must not cost near four times the parse '
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
