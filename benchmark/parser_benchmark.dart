// Measures the operations that walk a string, so that a change which makes
// one of them much slower is noticed rather than shipped.
//
// ```bash
// dart run benchmark/parser_benchmark.dart
// ```
//
// The numbers are of this machine and this Dart, and mean nothing on their
// own: run it before a change and after it, and compare the two.

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

/// A line of the kind a coloured log writes, codes and text in the proportion
/// a terminal actually sees.
const _line = '$bold${fgRed}ERROR$resetBoldAndDim$resetFg '
    '${fg256Gray12}2026-08-03 00:00:00$resetFg '
    '${fgCyan}parser$resetFg '
    'something happened, and here is a sentence about it '
    '${underline}with a word underlined$resetUnderline'
    '$reset';

final _text = List.filled(200, _line).join('\n');

void main() {
  print('input: ${_text.length} characters, '
      '${Parser(_text).length} of them text\n');

  _bench('Parser.matches, read to the end', () {
    for (final _ in Parser(_text).matches) {}
  });

  _bench('Parser.removeAll', () => Parser(_text).removeAll());

  _bench('ansiRemoveEscapeCodes (the same, by regexp)', _removeByRegExp);

  _bench('Parser.optimize', () => Parser(_text).optimize());

  _bench('Parser.substring, one piece', () {
    Parser(_text).substring(1000, maxLength: 200);
  });

  _bench('Parser.insertBefore', () => Parser(_text).insertBefore(1000, 'x'));

  // Two questions about the first sixth of the string, and two about the
  // whole of it: prepare reads everything, which is a loss where the
  // questions are not going to.
  _bench('stateAt × 100 over the first sixth', () {
    final parser = Parser(_text);
    for (var i = 0; i < 100; i++) {
      parser.stateAt(i * 36);
    }
  });

  _bench('  the same, after prepare', () {
    final parser = Parser(_text)..prepare();
    for (var i = 0; i < 100; i++) {
      parser.stateAt(i * 36);
    }
  });

  _bench('stateAt × 100 over the whole string', () {
    final parser = Parser(_text);
    for (var i = 0; i < 100; i++) {
      parser.stateAt(i * 215);
    }
  });

  _bench('  the same, after prepare', () {
    final parser = Parser(_text)..prepare();
    for (var i = 0; i < 100; i++) {
      parser.stateAt(i * 215);
    }
  });

  // Walking a string position by position — asking about every tenth
  // character of it, in order — which is what laying text out looks like.
  final walk = Parser(_text).length ~/ 10;

  _bench('stateAt × $walk in a progression', () {
    final parser = Parser(_text);
    for (var i = 0; i < walk; i++) {
      parser.stateAt(i * 10);
    }
  });

  _bench('  the same, after prepare', () {
    final parser = Parser(_text)..prepare();
    for (var i = 0; i < walk; i++) {
      parser.stateAt(i * 10);
    }
  });

  _bench('  the same, walking the matches instead', () {
    final parser = Parser(_text);
    var pos = 0;
    for (final m in parser.matches) {
      if (m.entity case Text(:final string)) {
        pos += string.length;
      }
    }
    if (pos == 0) {
      throw StateError('nothing was read');
    }
  });

  _bench('Printer.prepare, one line', () {
    Printer().prepare(_line);
  });

  _bench('showControlFunctions', () => Parser(_text).showControlFunctions());
}

void _removeByRegExp() => _text.ansiRemoveEscapeCodes();

/// Runs [body] until it has had a second of the clock, and reports the best
/// time of the runs — the one least disturbed by everything else the machine
/// was doing.
void _bench(String what, void Function() body) {
  // Let the compiler see it working before the clock is started.
  for (var i = 0; i < 3; i++) {
    body();
  }

  var best = double.infinity;
  var runs = 0;
  final overall = Stopwatch()..start();

  while (overall.elapsedMilliseconds < 300) {
    final watch = Stopwatch()..start();
    body();
    watch.stop();
    final micros = watch.elapsedMicroseconds.toDouble();
    if (micros < best) {
      best = micros;
    }
    runs++;
  }

  print('${what.padRight(44)} ${_micros(best).padLeft(10)}  '
      '(best of $runs)');
}

String _micros(double micros) => micros < 1000
    ? '${micros.toStringAsFixed(1)} µs'
    : '${(micros / 1000).toStringAsFixed(2)} ms';
