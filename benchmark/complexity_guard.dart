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
const _styledLine = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
    'a sentence of ordinary words to slice';
const _insertLine = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
    'a sentence of ordinary words to insert into';

final _unmeasured = Object();
Object _sink = _unmeasured;

void main(List<String> arguments) {
  if (arguments.isNotEmpty) {
    stderr.writeln(_usage);
    exitCode = 64;
    return;
  }

  final failures = <String>[];
  final parseSmall = _timedParse(2000);
  final parseLarge = _timedParse(4000);

  _runScenario(
    name: 'parse',
    first: _TimedSide(
      label: '2000 lines',
      logicalRuns: _parseBatch,
      body: parseSmall,
    ),
    second: _TimedSide(
      label: '4000 lines',
      logicalRuns: _parseBatch,
      body: parseLarge,
    ),
    expectedFirst: (_parseBatch, 2000),
    expectedSecond: (_parseBatch, 4000),
    anchor: _anchorParse,
    band: '< $_parseLimit',
    inBand: (ratio) => ratio < _parseLimit,
    failures: failures,
  );
  final sliceSmall = _timedSlices(400);
  final sliceLarge = _timedSlices(800);
  _runScenario(
    name: 'slice',
    first: _TimedSide(
      label: '400 lines',
      logicalRuns: _sliceBatch,
      body: sliceSmall,
    ),
    second: _TimedSide(
      label: '800 lines',
      logicalRuns: _sliceBatch,
      body: sliceLarge,
    ),
    expectedFirst: (_sliceBatch, 400),
    expectedSecond: (_sliceBatch, 800),
    anchor: _anchorSlice,
    band: '< $_sliceLimit',
    inBand: (ratio) => ratio < _sliceLimit,
    failures: failures,
  );
  final stackSmall = _timedStack(4000);
  final stackLarge = _timedStack(8000);
  _runScenario(
    name: 'stack',
    first: _TimedSide(
      label: '4000 runs',
      logicalRuns: _stackBatch,
      body: stackSmall,
    ),
    second: _TimedSide(
      label: '8000 runs',
      logicalRuns: _stackBatch,
      body: stackLarge,
    ),
    expectedFirst: (_stackBatch, 4000),
    expectedSecond: (_stackBatch, 8000),
    anchor: _anchorStack,
    band: '< $_stackLimit',
    inBand: (ratio) => ratio < _stackLimit,
    failures: failures,
  );
  final insertShared = _timedInsertions(_insertLines, shared: true);
  final insertFresh = _timedInsertions(_insertLines, shared: false);
  _runScenario(
    name: 'insert',
    first: _TimedSide(
      label: 'shared parser',
      logicalRuns: _sharedInsertBatch,
      body: insertShared,
    ),
    second: _TimedSide(
      label: 'fresh parser',
      logicalRuns: _freshInsertBatch,
      body: insertFresh,
    ),
    expectedFirst: (_sharedInsertBatch, _insertLines),
    expectedSecond: (_freshInsertBatch, _insertLines),
    anchor: _anchorInsert,
    band: '> $_insertFloor',
    inBand: (ratio) => ratio > _insertFloor,
    failures: failures,
  );

  if (identical(_sink, _unmeasured)) {
    failures.add('complexity guard performed no observable work');
  }
  failures.forEach(stderr.writeln);
  if (failures.isNotEmpty) {
    exitCode = 1;
  }
}

final class _TimedSide {
  const _TimedSide({
    required this.label,
    required this.logicalRuns,
    required this.body,
  });

  final String label;
  final int logicalRuns;
  final int Function() body;
}

void _runScenario({
  required String name,
  required _TimedSide first,
  required _TimedSide second,
  required (int, int) expectedFirst,
  required (int, int) expectedSecond,
  required void Function() anchor,
  required String band,
  required bool Function(double ratio) inBand,
  required List<String> failures,
}) {
  var valid = true;
  try {
    anchor();
  } on Object catch (error) {
    failures.add('$name anchor failed: $error');
    valid = false;
  }

  for (final (side, expected) in [
    (first, expectedFirst),
    (second, expectedSecond),
  ]) {
    int actualOperations;
    try {
      actualOperations = side.body();
    } on Object catch (error) {
      failures.add(
        '$name operation count failed for ${side.label}: $error',
      );
      valid = false;
      continue;
    }
    if (side.logicalRuns != expected.$1 || actualOperations != expected.$2) {
      failures.add(
        '$name operation count failed for ${side.label}: '
        'expected ${expected.$1} x ${expected.$2}, '
        'actual ${side.logicalRuns} x $actualOperations',
      );
      valid = false;
    }
  }

  if (!valid) {
    return;
  }

  final result = _measureScenario(first, second);
  final ratio = result.$2 / result.$1;
  stdout.writeln(
    '$name: ${first.label} median ${result.$1.toStringAsFixed(1)} us/run, '
    '${second.label} median ${result.$2.toStringAsFixed(1)} us/run; '
    'ratio ${ratio.toStringAsFixed(2)}; band $band',
  );

  if (!inBand(ratio)) {
    failures.add(
      '$name complexity band failed: ratio ${ratio.toStringAsFixed(2)}, '
      'expected $band',
    );
  }
}

(double, double) _measureScenario(_TimedSide first, _TimedSide second) {
  _measurePair(first.body, first.logicalRuns);
  _measurePair(second.body, second.logicalRuns);

  final firstSamples = <double>[];
  final secondSamples = <double>[];
  for (var pair = 0; pair < _pairs; pair++) {
    if (pair.isEven) {
      firstSamples.add(_measurePair(first.body, first.logicalRuns));
      secondSamples.add(_measurePair(second.body, second.logicalRuns));
    } else {
      secondSamples.add(_measurePair(second.body, second.logicalRuns));
      firstSamples.add(_measurePair(first.body, first.logicalRuns));
    }
  }

  firstSamples.sort();
  secondSamples.sort();
  return (firstSamples[_pairs ~/ 2], secondSamples[_pairs ~/ 2]);
}

double _measurePair(int Function() body, int logicalRuns) {
  final stopwatch = Stopwatch()..start();
  for (var run = 0; run < logicalRuns; run++) {
    body();
  }
  stopwatch.stop();
  return stopwatch.elapsedMicroseconds / logicalRuns;
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
// Only test/tool/complexity_guard_ratio_test.dart calls this today, and the
// lint counts callers inside this executable library alone.
// ignore: unreachable_from_main
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
    if (first[i] <= 0 || second[i] <= 0) {
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
// ignore: unreachable_from_main
typedef PairedRatios = ({double median, double min, double max});

String _parsePage(int lines) =>
    List.filled(lines, '\x1B[31m$_plainLine\x1B[0m').join('\n');

int Function() _timedParse(int lines) {
  final page = _parsePage(lines);
  return () {
    _sink = Parser(page).removeAll();
    return lines;
  };
}

List<String> _slices(int lines) {
  final page = List.filled(lines, _styledLine).join('\n');
  final parser = Parser(page)..prepare();
  final width = Parser(_styledLine).length;
  return [
    for (var i = 0; i < lines; i++)
      parser.substring(i * (width + 1), maxLength: width),
  ];
}

int Function() _timedSlices(int lines) {
  final page = List.filled(lines, _styledLine).join('\n');
  final parser = Parser(page)..prepare();
  final width = Parser(_styledLine).length;
  return () {
    var operations = 0;
    for (var i = 0; i < lines; i++) {
      _sink = parser.substring(i * (width + 1), maxLength: width);
      operations++;
    }
    return operations;
  };
}

String _stackPage(int runs) => '\x1B[31mfoo\x1B[32mbar' * runs;

int Function() _timedStack(int runs) {
  final page = _stackPage(runs);
  return () {
    _sink = StackedParser(page).finalState;
    return runs;
  };
}

List<String> _sharedInsertions(int lines) {
  final page = List.filled(lines, _insertLine).join('\n');
  final width = Parser(_insertLine).length;
  final parser = Parser(page);
  return [
    for (var i = 0; i < lines; i++) parser.insertAfter(i * (width + 1), '@'),
  ];
}

List<String> _freshInsertions(int lines) {
  final page = List.filled(lines, _insertLine).join('\n');
  final width = Parser(_insertLine).length;
  return [
    for (var i = 0; i < lines; i++)
      Parser(page).insertAfter(i * (width + 1), '@'),
  ];
}

int Function() _timedInsertions(int lines, {required bool shared}) {
  final page = List.filled(lines, _insertLine).join('\n');
  final width = Parser(_insertLine).length;
  return () {
    final parser = shared ? Parser(page) : null;
    var operations = 0;
    for (var i = 0; i < lines; i++) {
      _sink = (parser ?? Parser(page)).insertAfter(i * (width + 1), '@');
      operations++;
    }
    return operations;
  };
}

void _anchorParse() {
  const lines = 2000;
  final plainPage = List.filled(lines, _plainLine).join('\n');
  final cleaned = Parser(_parsePage(lines)).removeAll();

  _require(cleaned == plainPage, 'cleaned output differs from plain corpus');
  _require(
    cleaned.length == 91999,
    'expected length 91999, got ${cleaned.length}',
  );
  _require(
    _fnv1a32([cleaned]) == 'a20a9a76',
    'expected digest a20a9a76, got ${_fnv1a32([cleaned])}',
  );
}

void _anchorSlice() {
  const first = '\x1B[31;1mtag\x1B[0m '
      'a sentence of ordinary words to slice';
  final slices = _slices(400);
  final width = Parser(_styledLine).length;

  _require(width == 41, 'expected width 41, got $width');
  _require(slices.length == 400, 'expected 400 slices, got ${slices.length}');
  _require(slices.first == first, 'first slice differs from anchor');
  _require(slices.first.length == 52, 'expected first length 52');
  _require(slices.last.length == 52, 'expected last length 52');
  _require(
    _fnv1a32(slices) == '39ef6bc5',
    'expected digest 39ef6bc5, got ${_fnv1a32(slices)}',
  );
}

void _anchorStack() {
  const runs = 4000;
  final parsed = StackedParser(_stackPage(runs));

  _require(
    parsed.length == 24000,
    'expected length 24000, got ${parsed.length}',
  );
  var state = parsed.finalState;
  _require(
    state.foregroundColor == Color16.green,
    'final foreground is not green',
  );
  for (var i = 0; i < 6; i++) {
    state = state.resetForeground;
    final expected = i.isEven ? Color16.red : Color16.green;
    _require(state.foregroundColor == expected, 'foreground pop $i differs');
  }
}

void _anchorInsert() {
  const lines = 400;
  final page = List.filled(lines, _insertLine).join('\n');
  final plainPage = Parser(page).removeAll();
  final width = Parser(_insertLine).length;
  final shared = _sharedInsertions(lines);
  final fresh = _freshInsertions(lines);

  _require(shared.length == 400, 'expected 400 shared results');
  _require(fresh.length == 400, 'expected 400 fresh results');
  _require(_sameStrings(shared, fresh), 'shared and fresh results differ');
  _require(_fnv1a32(shared) == '7879f6e5', 'shared digest differs');
  _require(_fnv1a32(fresh) == '7879f6e5', 'fresh digest differs');
  _require(
    Parser(shared.first).removeAll() == '@$plainPage',
    'first insertion differs from anchor',
  );
  _require(
    Parser(shared.last).removeAll() ==
        '${plainPage.substring(0, (lines - 1) * (width + 1))}'
            '@${plainPage.substring((lines - 1) * (width + 1))}',
    'last insertion differs from anchor',
  );
}

bool _sameStrings(List<String> first, List<String> second) {
  if (first.length != second.length) {
    return false;
  }
  for (var i = 0; i < first.length; i++) {
    if (first[i] != second[i]) {
      return false;
    }
  }
  return true;
}

void _require(bool condition, String message) {
  if (!condition) {
    throw StateError(message);
  }
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
