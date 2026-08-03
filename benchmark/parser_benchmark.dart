// Measures what the package spends its time on, so that a change which makes
// something much slower is noticed rather than shipped.
//
// ```bash
// dart run benchmark/parser_benchmark.dart
// ```
//
// The numbers are of this machine and this Dart, and mean nothing on their
// own: run it before a change and after it, and compare the two. What does
// mean something on its own is the last section, where a cost is measured at
// three sizes of input — a linear one doubles when the input doubles, and
// anything that does more than that is worth looking at.

import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

/// A line of the kind a coloured log writes, codes and text in the proportion
/// a terminal actually sees.
const _line = '$bold${fgRed}ERROR$resetBoldAndDim$resetFg '
    '${fg256Gray12}2026-08-03 00:00:00$resetFg '
    '${fgCyan}parser$resetFg '
    'something happened, and here is a sentence about it '
    '${underline}with a word underlined$resetUnderline'
    '$reset';

/// The same line with nothing in it but text.
final _plainLine = _line.ansiRemoveEscapeCodes();

/// A line that is more code than text: every word dressed on its own.
final _denseLine = _plainLine
    .split(' ')
    .map((word) => '$fgGreen$bold$word$resetBoldAndDim$resetFg')
    .join(' ');

String _pageOf(String line, [int lines = 200]) =>
    List.filled(lines, line).join('\n');

final _coloured = _pageOf(_line);
final _plain = _pageOf(_plainLine);
final _dense = _pageOf(_denseLine);

void main() {
  _title();

  _group('Reading a page of coloured log');
  _bench('matches, to the end', () {
    for (final _ in Parser(_coloured).matches) {}
  });
  _bench('removeAll', () => Parser(_coloured).removeAll());
  _bench('ansiRemoveEscapeCodes', _removeColoured);
  _bench('optimize', () => Parser(_coloured).optimize());
  _bench(
    'showControlFunctions',
    () => Parser(_coloured).showControlFunctions(),
  );
  _bench('substring, one piece', () {
    Parser(_coloured).substring(1000, maxLength: 200);
  });

  // The three pages differ in length as well as in density, so each says how
  // long it is: a page of dressed words is three times the characters.
  _group('The same, by the shape of the input');
  _bench(
    'a third codes (${_coloured.length} chars)',
    () => Parser(_coloured).removeAll(),
  );
  _bench(
    'no codes at all (${_plain.length} chars)',
    () => Parser(_plain).removeAll(),
  );
  _bench(
    'more code than text (${_dense.length} chars)',
    () => Parser(_dense).removeAll(),
  );
  _bench(
    'one long line, no newlines',
    () => Parser(_coloured.replaceAll('\n', ' ')).removeAll(),
  );

  _group('Writing: dressing a string that is not known until it runs');
  final subject = DateTime.now().toString();
  _bench('by the ready-to-use constants', () {
    _sink = '$fgRed$bold$subject$resetBoldAndDim$resetFg';
  });
  _bench('by a style', () => _sink = red.bold(subject));
  final printer = Printer(output: (_) {});
  _bench('by a printer', () => _sink = printer.prepare(subject));
  final stacked = StackedPrinter(output: (_) {});
  _bench('by a stacked printer', () => _sink = stacked.prepare(subject));

  _group('Keeping the history: Parser against StackedParser');
  _bench('Parser, to the end', () {
    for (final _ in Parser(_coloured).matches) {}
  });
  _bench('StackedParser, to the end', () {
    for (final _ in StackedParser(_coloured).matches) {}
  });

  _group('Printing two hundred lines');
  _bench('a printer', () {
    final p = Printer(output: (_) {});
    _coloured.split('\n').forEach(p.print);
  });
  _bench('a stacked printer', () {
    final p = StackedPrinter(output: (_) {});
    _coloured.split('\n').forEach(p.print);
  });
  _bench('a printer under a zone', () {
    runZonedPrinter(
      output: (_) {},
      () => _coloured.split('\n').forEach(print),
    );
  });

  _group('Asking where the styles are');
  final walk = Parser(_coloured).length ~/ 10;
  _bench('walking the matches by hand', () {
    var pos = 0;
    for (final m in Parser(_coloured).matches) {
      if (m.entity case Text(:final string)) {
        pos += string.length;
      }
    }
    _sink = '$pos';
  });
  _bench('stateAt × 100 over the first sixth', () {
    final parser = Parser(_coloured);
    for (var i = 0; i < 100; i++) {
      parser.stateAt(i * 36);
    }
  });
  _bench('the same, after prepare', () {
    final parser = Parser(_coloured)..prepare();
    for (var i = 0; i < 100; i++) {
      parser.stateAt(i * 36);
    }
  });
  _bench('stateAt × $walk in a progression', () {
    final parser = Parser(_coloured);
    for (var i = 0; i < walk; i++) {
      parser.stateAt(i * 10);
    }
  });
  _bench('the same, after prepare', () {
    final parser = Parser(_coloured)..prepare();
    for (var i = 0; i < walk; i++) {
      parser.stateAt(i * 10);
    }
  });
  _group('Inserting, by where the seam is');
  _bench('at the beginning', () => Parser(_coloured).insertBefore(0, 'x'));
  _bench('in the middle', () {
    Parser(_coloured).insertBefore(_plainLine.length * 100, 'x');
  });
  _bench('at the end', () {
    final parser = Parser(_coloured);
    _sink = parser.insertBefore(parser.length, 'x');
  });

  _growth();

  if (_sink == null) {
    throw StateError('nothing was measured');
  }
}

/// Somewhere for a result to go, so that nothing measured is optimized away,
/// and read once at the end so that it cannot be dropped either.
Object? _sink;

void _removeColoured() => _sink = _coloured.ansiRemoveEscapeCodes();

// ---------------------------------------------------------------------------
// Running and showing
// ---------------------------------------------------------------------------

final bool _inColour = stdout.supportsAnsiEscapes;

String _paint(String text, String open, [String close = reset]) =>
    _inColour ? '$open$text$close' : text;

void _title() {
  final plainLength = Parser(_coloured).length;

  print(_paint('ansi_escape_codes — benchmark', '$bold$fgCyan'));
  print(
    _paint(
      'a page is 200 lines: ${_coloured.length} characters, '
      '$plainLength of them text',
      fg256Gray12,
    ),
  );
}

/// The time the first measurement of a group took, for the rest to be read
/// against.
double? _baseline;

void _group(String title) {
  _baseline = null;
  print('');
  print(_paint(title, '$bold$fgCyan'));
}

/// Runs [body] for a third of a second and shows the best of those runs — the
/// one least disturbed by whatever else the machine was doing.
void _bench(String what, void Function() body) {
  final best = _measure(body);
  _baseline ??= best;

  final relative = best / _baseline!;
  final mark = switch (relative) {
    < 0.95 => _paint('×${relative.toStringAsFixed(2)}', fgGreen),
    > 1.05 => _paint('×${relative.toStringAsFixed(2)}', fgYellow),
    _ => _paint('×${relative.toStringAsFixed(2)}', fg256Gray12),
  };

  final label = Parser('  $what').padRight(44);
  final time = Parser(_paint(_time(best), bold)).padLeft(10);

  print('$label$time  ${_baseline == best ? '' : mark}');
}

double _measure(void Function() body) {
  for (var i = 0; i < 3; i++) {
    body();
  }

  // A single run of a quick thing is below what the clock can see, so it is
  // run in batches large enough to be worth timing, and the batch divided out.
  var batch = 1;
  while (batch < 1 << 22) {
    final watch = Stopwatch()..start();
    for (var i = 0; i < batch; i++) {
      body();
    }
    watch.stop();
    if (watch.elapsedMicroseconds >= 1000) {
      break;
    }
    batch *= 8;
  }

  var best = double.infinity;
  final overall = Stopwatch()..start();

  while (overall.elapsedMilliseconds < 300) {
    final watch = Stopwatch()..start();
    for (var i = 0; i < batch; i++) {
      body();
    }
    watch.stop();
    final micros = watch.elapsedMicroseconds / batch;
    if (micros < best) {
      best = micros;
    }
  }

  return best;
}

String _time(double micros) => switch (micros) {
      < 1 => '${(micros * 1000).toStringAsFixed(0)} ns',
      < 10 => '${micros.toStringAsFixed(2)} µs',
      < 1000 => '${micros.toStringAsFixed(1)} µs',
      _ => '${(micros / 1000).toStringAsFixed(2)} ms',
    };

// ---------------------------------------------------------------------------
// Growth
// ---------------------------------------------------------------------------

/// What each cost does when the input doubles.
///
/// A linear one doubles with it. Anything nearer four is doing the work once
/// per something rather than once in all, which is what a walk that starts
/// over every time looks like.
void _growth() {
  print('');
  print(
    _paint(
      'Growth: what a doubling of the input does to the cost',
      '$bold$fgCyan',
    ),
  );
  print(_paint('  a linear cost gives ×2, a quadratic one ×4', fg256Gray12));

  _grow('matches, to the end', (text) {
    for (final _ in Parser(text).matches) {}
  });
  _grow('ansiRemoveEscapeCodes', (text) {
    _sink = text.ansiRemoveEscapeCodes();
  });
  _grow('optimize', (text) => _sink = Parser(text).optimize());
  _grow('stateAt every tenth character', (text) {
    final parser = Parser(text);
    final steps = parser.length ~/ 10;
    for (var i = 0; i < steps; i++) {
      parser.stateAt(i * 10);
    }
  });
  _grow('insertBefore at the end', (text) {
    final parser = Parser(text);
    _sink = parser.insertBefore(parser.length, 'x');
  });
}

void _grow(String what, void Function(String text) body) {
  final times = [
    for (final lines in [50, 100, 200])
      _measure(() => body(_pageOf(_line, lines))),
  ];

  final factors = [
    for (var i = 1; i < times.length; i++) times[i] / times[i - 1],
  ];
  final worst = factors.reduce((a, b) => a > b ? a : b);

  final verdict = switch (worst) {
    < 2.6 => _paint('linear', fgGreen),
    < 3.4 => _paint('more than linear', fgYellow),
    _ => _paint('quadratic', fgRed),
  };

  final shown = factors.map((f) => '×${f.toStringAsFixed(1)}').join('  ');

  print('${Parser('  $what').padRight(34)}'
      '${Parser(_paint(shown, bold)).padRight(14)}$verdict');
}
