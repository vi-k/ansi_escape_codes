// Guards the complexity of parser operations whose results are pinned by
// test/performance_guards_test.dart. Wall-clock ratios belong in this warmed,
// stable-only process rather than in the test scheduler.
import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

const _usage = 'Usage: dart run benchmark/complexity_guard.dart';

// Five pairs admitted a loaded slice outlier at 2.82. Seven remains an odd
// paired median and keeps one scheduler placement from deciding either side.
const _pairs = 7;
const _parseLimit = 2.5;
const _sliceLimit = 2.5;
const _stackLimit = 3.5;
const _insertFloor = 24.0;

const _parseBatch = 20;
const _sliceBatch = 100;
const _stackBatch = 4;
// The planned 10/1 insert batches reached 23.98 under 13 busy workers on a
// 14-core hybrid CPU. Doubling both samples preserves the per-run ratio and
// the 200-line mutation separation while averaging scheduler placement.
const _sharedInsertBatch = 20;
const _freshInsertBatch = 2;
const _insertLines = 200;

const _plainLine = 'an ordinary line of an ordinary log, no codes';
const _insertLine = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
    'a sentence of ordinary words to insert into';

// What each side must produce, taken from a live probe on e29c0e1. A body
// that measures less than its corpus answers differently here, which is the
// point: the timer and the check now read one implementation.
const _parseSmallWitness = '1|91999|a20a9a76';
const _parseLargeWitness = '1|183999|f0470cb6';
const _sliceSmallWitness = '400|24400|b8dc6f45';
const _sliceLargeWitness = '800|48800|b21d4625';
const _stackSmallWitness = '24000|Color16.green,Color16.red,Color16.green,'
    'Color16.red,Color16.green,Color16.red,Color16.green';
const _stackLargeWitness = '48000|Color16.green,Color16.red,Color16.green,'
    'Color16.red,Color16.green,Color16.red,Color16.green';
// Both insert sides must say the same thing: a shared parser and a fresh one
// answer alike, and only the work behind the answer differs.
const _insertWitness = '200|2680000|1dddfc15';

void main(List<String> arguments) {
  if (arguments.isNotEmpty) {
    stderr.writeln(_usage);
    exitCode = 64;
    return;
  }

  final failures = <String>[];

  _runScenario(
    name: 'parse',
    first: _Side(
      label: '2000 lines',
      batch: _parseBatch,
      run: _parseRun(2000),
      observe: _observeStrings,
      expected: _parseSmallWitness,
    ),
    second: _Side(
      label: '4000 lines',
      batch: _parseBatch,
      run: _parseRun(4000),
      observe: _observeStrings,
      expected: _parseLargeWitness,
    ),
    band: '< $_parseLimit',
    inBand: (ratio) => ratio < _parseLimit,
    failures: failures,
  );
  _runScenario(
    name: 'slice',
    first: _Side(
      label: '400 lines',
      batch: _sliceBatch,
      run: _sliceRun(400),
      observe: _observeStrings,
      expected: _sliceSmallWitness,
    ),
    second: _Side(
      label: '800 lines',
      batch: _sliceBatch,
      run: _sliceRun(800),
      observe: _observeStrings,
      expected: _sliceLargeWitness,
    ),
    band: '< $_sliceLimit',
    inBand: (ratio) => ratio < _sliceLimit,
    failures: failures,
  );
  _runScenario(
    name: 'stack',
    first: _Side(
      label: '4000 runs',
      batch: _stackBatch,
      run: _stackRun(4000),
      observe: _observeStack,
      expected: _stackSmallWitness,
    ),
    second: _Side(
      label: '8000 runs',
      batch: _stackBatch,
      run: _stackRun(8000),
      observe: _observeStack,
      expected: _stackLargeWitness,
    ),
    band: '< $_stackLimit',
    inBand: (ratio) => ratio < _stackLimit,
    failures: failures,
  );
  _runScenario(
    name: 'insert',
    first: _Side(
      label: 'shared parser',
      batch: _sharedInsertBatch,
      run: _insertRun(_insertLines, shared: true),
      observe: _observeStrings,
      expected: _insertWitness,
    ),
    second: _Side(
      label: 'fresh parser',
      batch: _freshInsertBatch,
      run: _insertRun(_insertLines, shared: false),
      observe: _observeStrings,
      expected: _insertWitness,
    ),
    band: '> $_insertFloor',
    inBand: (ratio) => ratio > _insertFloor,
    failures: failures,
  );

  failures.forEach(stderr.writeln);
  if (failures.isNotEmpty) {
    exitCode = 1;
  }
}

final class _Side {
  const _Side({
    required this.label,
    required this.batch,
    required this.run,
    required this.observe,
    required this.expected,
  });

  /// How this side reads in the output: '800 lines', 'fresh parser'.
  final String label;

  /// Logical runs inside one timed sample.
  final int batch;

  /// The only implementation of this side's work. This is what is timed,
  /// and this is what the observation reads — they cannot drift, because
  /// there is nothing to drift from.
  final Object Function() run;

  /// Renders a result of [run] to a comparable string. Never timed.
  final String Function(Object) observe;

  /// What [observe] must say, taken from a live probe.
  final String expected;
}

/// Runs [side] once and answers whether it produced what it must.
///
/// Called before the timing series and again after it. The second call
/// catches an answer that decayed along the way: a corpus the series
/// consumed, a state the runs left somewhere else, a body that stops
/// producing what its first run did. It does not catch a body that caches
/// the *right* answer and hands it back for free — that one passes both
/// calls, and only the ratio has anything left to say about it.
bool _observed(
  String name,
  _Side side,
  String when,
  List<String> failures,
) {
  final String witness;
  try {
    witness = side.observe(side.run());
  } on Object catch (error) {
    failures.add('$name ${side.label} $when: observation failed: $error');
    return false;
  }
  if (witness != side.expected) {
    failures.add(
      '$name ${side.label} $when: expected ${side.expected}, got $witness',
    );
    return false;
  }
  return true;
}

void _runScenario({
  required String name,
  required _Side first,
  required _Side second,
  required String band,
  required bool Function(double ratio) inBand,
  required List<String> failures,
}) {
  var valid = true;
  for (final side in [first, second]) {
    valid = _observed(name, side, 'before', failures) && valid;
  }
  if (!valid) {
    return;
  }

  final (firstSamples, secondSamples) = _measureScenario(first, second);

  for (final side in [first, second]) {
    valid = _observed(name, side, 'after', failures) && valid;
  }
  if (!valid) {
    return;
  }

  final PairedRatios ratios;
  try {
    ratios = pairedRatios(firstSamples, secondSamples);
  } on Object catch (error) {
    // Recorded rather than thrown: the later scenarios still have something
    // to say, and the process reports every failure it collected.
    failures.add('$name pairs failed: $error');
    return;
  }
  final firstMedian = _median(firstSamples);
  final secondMedian = _median(secondSamples);
  final ratio = ratios.median.toStringAsFixed(2);
  final low = ratios.min.toStringAsFixed(2);
  final high = ratios.max.toStringAsFixed(2);

  stdout.writeln(
    '$name: ${first.label} median ${firstMedian.toStringAsFixed(1)} us/run, '
    '${second.label} median ${secondMedian.toStringAsFixed(1)} us/run; '
    'ratio $ratio (pairs $low..$high); '
    'band $band',
  );

  if (!inBand(ratios.median)) {
    failures.add('$name complexity band failed: ratio $ratio, '
        'expected $band');
  }
}

(List<double>, List<double>) _measureScenario(_Side first, _Side second) {
  _measurePair(first);
  _measurePair(second);

  final firstSamples = <double>[];
  final secondSamples = <double>[];
  for (var pair = 0; pair < _pairs; pair++) {
    if (pair.isEven) {
      firstSamples.add(_measurePair(first));
      secondSamples.add(_measurePair(second));
    } else {
      secondSamples.add(_measurePair(second));
      firstSamples.add(_measurePair(first));
    }
  }
  return (firstSamples, secondSamples);
}

double _measurePair(_Side side) {
  final stopwatch = Stopwatch()..start();
  for (var run = 0; run < side.batch; run++) {
    side.run();
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds / side.batch;
}

/// The middle sample of [samples], printed beside the ratios for reference.
///
/// Sorts a copy. [pairedRatios] divides within a pair and reads the samples
/// by position, so the order they were measured in has to survive this.
double _median(List<double> samples) {
  final sorted = [...samples]..sort();
  return sorted[sorted.length ~/ 2];
}

/// The median of the per-pair ratios of [second] to [first], with the
/// extremes the pairs reached.
///
/// The pairing is the whole point. Each ratio divides two samples measured
/// beside each other, so a burst of scheduler noise that lands inside one
/// pair moves that pair's ratio and leaves the rest alone. Taking a median
/// of each side on its own and dividing lets the two medians come from
/// different pairs — from different moments — and reports their ratio as
/// though it were one measurement.
///
/// The extremes are returned rather than printed away: a wide spread is
/// what a loaded machine looks like, and a reader deserves to tell that
/// apart from a moved median, which is what a regression looks like.
PairedRatios pairedRatios(List<double> first, List<double> second) {
  if (first.length != second.length) {
    throw ArgumentError(
      'the sides differ in length: ${first.length} and ${second.length}',
    );
  }
  if (first.isEmpty) {
    throw ArgumentError('there are no pairs to compare');
  }
  if (first.length.isEven) {
    throw ArgumentError(
      'an even number of pairs has no single median: ${first.length}',
    );
  }

  final ratios = <double>[];
  for (var i = 0; i < first.length; i++) {
    if (!first[i].isFinite ||
        !second[i].isFinite ||
        first[i] <= 0 ||
        second[i] <= 0) {
      throw ArgumentError(
        'pair $i holds a sample the timer could not resolve: '
        '${first[i]} and ${second[i]}',
      );
    }
    ratios.add(second[i] / first[i]);
  }
  ratios.sort();

  return (
    median: ratios[ratios.length ~/ 2],
    min: ratios.first,
    max: ratios.last,
  );
}

/// What a scenario's pairs said: the median ratio and the extremes.
typedef PairedRatios = ({double median, double min, double max});

/// A slice corpus line carrying its own number.
///
/// The number is what makes the digest positional: a walk that answers
/// every question from the wrong offset changes it. A corpus of identical
/// lines cannot tell the difference, and this one was identical until now.
/// Three digits keep the plain width equal on both sides, 400 and 800.
String _sliceLine(int i) => '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
    'a sentence of ordinary words to slice, no. '
    '${i.toString().padLeft(3, '0')}';

String _parsePage(int lines) =>
    List.filled(lines, '\x1B[31m$_plainLine\x1B[0m').join('\n');

String _stackPage(int runs) => '\x1B[31mfoo\x1B[32mbar' * runs;

List<String> Function() _parseRun(int lines) {
  final page = _parsePage(lines);
  return () => [Parser(page).removeAll()];
}

List<String> Function() _sliceRun(int lines) {
  final page = [for (var i = 0; i < lines; i++) _sliceLine(i)].join('\n');
  final parser = Parser(page)..prepare();
  final width = Parser(_sliceLine(0)).length;
  return () => [
        for (var i = 0; i < lines; i++)
          parser.substring(i * (width + 1), maxLength: width),
      ];
}

/// The stack side hands back the state it walked to, not only the parser.
///
/// [StackedParser] reads lazily and keeps what it read, so a parser alone is
/// no evidence of a walk: an observation that asked it for `finalState`
/// would do the walk itself, and a body that had walked nowhere would still
/// answer correctly — which is how a body measuring six thousand times less
/// than it should stayed green. The record carries the state out of the
/// timed call, where only the timed call could have produced it.
(StackedParser, Stack) Function() _stackRun(int runs) {
  final page = _stackPage(runs);
  return () {
    final parsed = StackedParser(page);
    return (parsed, parsed.finalState);
  };
}

List<String> Function() _insertRun(int lines, {required bool shared}) {
  final page = List.filled(lines, _insertLine).join('\n');
  final width = Parser(_insertLine).length;
  return () {
    final reused = shared ? Parser(page) : null;
    return [
      for (var i = 0; i < lines; i++)
        (reused ?? Parser(page)).insertAfter(i * (width + 1), '@'),
    ];
  };
}

String _observeStrings(Object produced) {
  final strings = produced as List<String>;
  final total = strings.fold<int>(0, (sum, s) => sum + s.length);
  return '${strings.length}|$total|${_fnv1a32(strings)}';
}

String _observeStack(Object produced) {
  // The state is read out of the record rather than off the parser: asking
  // the parser again would let this observation do the walk the timer was
  // there to measure.
  final (parsed, finalState) = produced as (StackedParser, Stack);
  final colors = <String>[];
  var state = finalState;
  colors.add('${state.foregroundColor}');
  for (var i = 0; i < 6; i++) {
    state = state.resetForeground;
    colors.add('${state.foregroundColor}');
  }
  return '${parsed.length}|${colors.join(',')}';
}

String _fnv1a32(Iterable<String> strings) {
  var hash = 0x811c9dc5;

  void mix(int byte) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }

  for (final string in strings) {
    string.codeUnits.forEach(mix);
    mix(0xff);
  }

  return hash.toRadixString(16).padLeft(8, '0');
}
