// Fails when a parse keeps materially more memory per match than it keeps
// today, so that a change which quietly grows what a parsed string holds onto
// is caught here rather than in somebody's heap.
//
// ```bash
// dart run benchmark/memory_guard.dart
// ```
//
// It exists because that has happened. A commit swapped the compact copies in
// `Sgr._` for `UnmodifiableListView`s over the builder lists — a view keeps
// its list alive, and a builder list keeps the slack capacity of its backing
// array alive with it — and what a parse tree costs grew by half with every
// test still green. Finding it again cost a bisect of twelve revisions by
// hand, reading RSS at each one. This is that bisect, run once per push.
//
// ## Why this reading says something, where the benchmark's does not
//
// `benchmark/parser_benchmark.dart` calls its own RSS figures a landmark
// rather than a measurement, and for what it does they are: it reads RSS
// several times over in one process, after a page of other benchmarks has
// warmed the JIT and stretched the heap, so what it sees is as much churn as
// retention. The same quantity is read here in the one arrangement that
// leaves retention as the only thing it can be:
//
// * a cold process, with nothing run before the reading but the corpus
//   generation;
// * one reading rather than a series, so that there are no leavings of an
//   earlier measurement to sit in;
// * five times the benchmark's corpus — 4 MiB against its 830 kB — so that
//   what is kept is most of what the process holds;
// * the parser held live past the second reading, so that nothing measured
//   can be collected before it is measured.
//
// What comes out is steady to a fraction of a percent, and the regression it
// exists for moves it by half. Between the two there is room for a band that
// neither flickers nor lets that class of change past.
//
// ## The calibration
//
// Five cold runs of `dart run`, 2026-08-08, Dart 3.12.2 on an Apple M-series,
// all of them over the same 4194391 characters:
//
// | run | matches | rss delta          | bytes per match |
// | --- | ------- | ------------------ | --------------- |
// | 1   | 372727  | 98910208 (94.3 MB) | 265.4           |
// | 2   | 372727  | 98959360 (94.4 MB) | 265.5           |
// | 3   | 372727  | 98975744 (94.4 MB) | 265.5           |
// | 4   | 372727  | 98959360 (94.4 MB) | 265.5           |
// | 5   | 372727  | 98893824 (94.3 MB) | 265.3           |
//
// 265.3 to 265.5: a spread of 0.08%. With the `UnmodifiableListView` put back
// into `Sgr._` and nothing else changed, the same corpus reads 398.7 bytes
// per match — ×1.50 of the worst clean run.
//
// This is the second calibration. The first, taken on 2026-08-05 over the
// same corpus on the same machine, read 229.6 to 230.4, and what moved it was
// deliberate: every `Piece` now carries a `Link?`, the field a slice and a
// printed string reopen a hyperlink from, the way they already reopen a
// style. What the field costs and what the reading rose by are not the same
// number, and the difference is the point. The field is one reference on each
// of 372727 matches — four bytes here, eight once the allocator has rounded
// the object it sits in up to its next step — so three megabytes at the
// outside, against the thirteen the reading moved by. Nothing else per match
// grew, and nothing is pointed at that was not alive already: this corpus
// holds no `OSC 8` at all, so every one of those fields is `null`, and the
// parsing iterator's own held link points into the parse tree.
//
// The other ten megabytes this measurement does not account for and does not
// have to. RSS is the pages the VM holds, not the bytes the objects need, and
// a heap whose every match grew by a word takes its own slack in its own
// steps. The band is drawn on the reading, because the reading is what CI
// compares against; an account of where the reading comes from would be a
// second measurement, and this is not it. So the band below was redrawn by
// the rule at the foot of this comment, from five fresh runs, rather than
// stretched to fit the reading that broke it.
//
// The ×1.50 is the corpus's doing and not the threshold's. Coloured
// word by word, the way `parser_benchmark.dart` colours, the same regression
// moves the same reading by two fifths instead — 4 MiB of that shape reads
// 249.6 bytes per match clean and 349.3 with the view put back — and a
// threshold has to sit under whichever separation is smallest to catch it.
// [_corpus] says what was done about that.
//
// [_ceiling] is the worst clean run plus a quarter, which leaves it about as
// far above that reading as the regression stands above it: a machine, an
// allocator or a Dart that reads a quarter high still passes, and the
// regression, reading half again high, cannot. The spread being 0.08%, a
// quarter is some three hundred times the noise this has to tolerate — and a
// quarter rather than a third because the room above the ceiling is also the
// room a machine reading lower than this one has to hide a regression in.
//
// [_floor] is three fifths of the same figure, and a reading below it is not
// good news to be waved through: it means the measurement has stopped
// measuring — a corpus that no longer holds codes, a parse that no longer
// keeps what it parsed — and the guard would be green from then on whatever
// happened to the parse tree. If the parse really has become that much
// cheaper, that is worth writing down: recalibrate.
//
// The figures are of `dart run`, and belong to it. The same file built with
// `dart compile exe` reads over a quarter lower — 190.8 bytes per match
// against the 265.5 above — so a number from one cannot be checked against a
// band calibrated on the other. That gap was a fifth at the first
// calibration and has widened, the same change costing the AOT heap much
// less than it costs the JIT one; and the warning has widened with it,
// because the regression above, compiled the same way, reads 280.8 and
// passes this ceiling without a word. The CI runs it the way it is
// calibrated here.
//
// They are of this machine, and the runner CI reads them on agrees. The
// ubuntu x64 runner, Dart stable, read 264.0 bytes per match on the first
// green run of this band (2026-08-07, run 31220359984) and 264.8 on the next
// (2026-08-08, run 31251852744) — half a percent under the table above, over
// the same 4194391 characters, which is what the generator at the foot of
// this file is for. Two machines that close together is what makes a band
// worth running anywhere but where it was drawn: they differ by a fiftieth of
// the room between the calibration and the ceiling.
//
// A third reading, of the calibration before this one, is not carried forward
// — 229.3 on the same runner, 2026-08-05, run 31053415705. It belonged to a
// band a sixth lower and says nothing about this one.
//
// ## What this does not guard
//
// A `Parser`, and so a `Style`. `StackedParser` is not read here and its
// `Stack` is not what the band was drawn on, so nothing in this file would
// have noticed the histories a `Stack` keeps growing quadratically — and they
// did, until frames with a shared tail replaced the lists that copied
// themselves on every push. The corpus makes it worse than an oversight: every
// run ends in a `reset`, so the stacks are emptied line by line and never
// deepen at all, which is the one shape in which the two states cost the same.
//
// What guards it instead is `test/performance_guards_test.dart`, 'a stack that
// only deepens stays linear' — a growth ratio over a corpus that never resets,
// with the band taken from both implementations. A ratio rather than a reading
// per match, because what went wrong there was the shape of the growth and not
// the size of a state.
//
// To recalibrate — a deliberate change in what a match keeps, a new corpus, a
// machine the band no longer fits — run it five times cold, take the worst,
// and rewrite the table above along with the two constants: the ceiling is
// that worst run × 1.25, the floor × 0.6. Three more figures go stale with
// the table, and none of them falls out of that arithmetic: the separation
// the regression opens on this corpus, the pair beside it on the word-by-word
// corpus in [_corpus], and how far under `dart run` the AOT build reads.
// Measure all three again — a fixed cost per match moves every one of them,
// and a comment left asserting the old ratios is worse than one asserting
// nothing. The corpus is generated by the linear congruential generator at
// the foot of this file rather than by `dart:math`, so the same characters
// come out of every SDK and the figures stay comparable.

import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

/// What a parsed match may retain, in bytes of resident memory, before this
/// fails: the worst of the calibration runs plus a quarter.
const _ceiling = 332;

/// What a parsed match is expected to retain at the least: three fifths of
/// the calibration.
///
/// Below this the reading is not a cheaper parse, it is a reading that has
/// come loose from what it was measuring. See the file comment.
const _floor = 159;

/// How much text to parse.
///
/// Four mebibytes: enough that the parse tree is most of what the process
/// holds, so that the reading is of retention rather than of churn, and
/// little enough to run in a couple of seconds.
const _corpusChars = 4 * 1024 * 1024;

/// How many matches that corpus parses to — the figure in every row of the
/// table above.
///
/// A fixed string read by a fixed walk comes to a fixed number, so this is a
/// fact about the file rather than a measurement, and it is checked because
/// the reading is a quotient. A corpus that came out other than it always
/// has divides by another number and cannot be held against the calibration;
/// a corpus that came out empty divides by zero, and hands both edges of the
/// band a value that neither of them can fail.
const _matchCount = 372727;

/// The seed of [_Lcg], so that the corpus is one string rather than a family
/// of them.
const _seed = 20260805;

void main(List<String> args) {
  if (args.isNotEmpty) {
    stderr.writeln(
      'Usage: dart run benchmark/memory_guard.dart\n'
      '\n'
      'Takes no arguments: the corpus, the reading and the band it has to\n'
      'land in are all fixed, a guard that can be talked into a different\n'
      'answer being no guard at all.',
    );
    exitCode = 64;

    return;
  }

  final corpus = _corpus();

  // Everything the reading is of is allocated between these two lines, and
  // read after the second of them, so that none of it can be collected in
  // between.
  final before = ProcessInfo.currentRss;
  final parser = Parser(corpus)..prepare();
  final after = ProcessInfo.currentRss;

  final matches = parser.pieces.length;
  final retained = after - before;
  final perMatch = retained / matches;

  print('memory guard — a full parse of ${corpus.length} characters');
  print('  matches:  $matches');
  print('  rss:      ${_signedMb(retained)} ($retained bytes)');
  print('  retained: ${perMatch.toStringAsFixed(1)} bytes per match '
      '(the band is $_floor to $_ceiling)');

  if (matches != _matchCount) {
    _fail(
      'The corpus came to $matches matches, where it has always come to '
      '$_matchCount.\n'
      '\n'
      'That is not news about what a parse keeps, it is news about what was\n'
      'parsed: the generator at the foot of this file, or what the parser\n'
      'counts as a match, is no longer what the calibration was taken over.\n'
      'A figure per match cannot be held against the table until the two\n'
      'agree on how many there are.',
    );

    return;
  }

  if (perMatch > _ceiling) {
    _fail(
      'A parsed match now keeps ${perMatch.toStringAsFixed(1)} bytes, '
      '×${(perMatch / _ceiling).toStringAsFixed(2)} of what it is allowed.\n'
      '\n'
      'Something in the parse tree is holding onto more than it needs to.\n'
      'The last time this happened it was a view where a copy belonged: an\n'
      'UnmodifiableListView keeps the list under it alive, and a builder\n'
      'list keeps the slack capacity of its backing array alive with it.\n'
      'Look at what the entities in lib/src/parsing/parser/entities/ store,\n'
      'and at anything newly reachable from a Piece, a Text or a Style.',
    );

    return;
  }

  if (perMatch < _floor) {
    _fail(
      'A parsed match now keeps ${perMatch.toStringAsFixed(1)} bytes, well '
      'under the $_floor this expects.\n'
      '\n'
      'That is not a parse that got cheaper by itself. Either the corpus is\n'
      'no longer what it was — codes it no longer holds are codes this no\n'
      'longer guards — or the parse no longer keeps what it parses, and the\n'
      'guard has been passing on nothing at all.',
    );
  }
}

/// [bytes] as `+81.7 MB` or `-0.1 MB`, so that a delta which came out
/// negative — RSS does fall sometimes, a collection mid-parse being what it
/// is — does not print as `+-0.1 MB`.
String _signedMb(int bytes) {
  final mb = bytes / (1024 * 1024);

  return '${mb >= 0 ? '+' : ''}${mb.toStringAsFixed(1)} MB';
}

/// Says why, points at what to read, and leaves with a non-zero status.
void _fail(String why) {
  stderr.writeln(
    '\n$why\n'
    '\n'
    'If the change is deliberate, recalibrate: the file comment on\n'
    'benchmark/memory_guard.dart says how, and the numbers in it are what\n'
    'this one has to be written down beside.',
  );
  exitCode = 1;
}

// ---------------------------------------------------------------------------
// The corpus
// ---------------------------------------------------------------------------

/// [_corpusChars] characters of the log an over-eager writer produces: a
/// burst of codes before each stretch of text, and the text itself left
/// plain.
///
/// The shape is chosen for what it measures rather than for what it looks
/// like. Codes are where a change in the parse tree is felt, so there are a
/// great many of them; plain text is what dilutes the reading, every stretch
/// of it being a match of its own that such a change does not touch, so it
/// comes in long stretches rather than word by word. Colouring word by word —
/// the corpus `parser_benchmark.dart` reads — puts a text match between every
/// pair of code matches, and costs a fifth of what the reading can see: the
/// ×1.50 of separation measured above falls to ×1.40.
String _corpus() {
  final random = _Lcg(_seed);
  final buffer = StringBuffer();

  while (buffer.length < _corpusChars) {
    _writeRun(buffer, random);
  }

  return buffer.toString();
}

/// The text between the bursts, written a stretch at a time.
const _sentence = 'opened a connection and wrote seventeen bytes to it '
    'before the other side went away again';

/// A burst of codes, and the stretch of text it dresses.
///
/// The burst holds the shapes of sequence whose parameter and function lists
/// come out at different lengths — one parameter, four of them, the three of
/// a 256-colour and the five of a truecolour — since the length of those
/// lists is what a change in how they are stored is felt in.
void _writeRun(StringBuffer buffer, _Lcg random) {
  final codes = 4 + random.next(9);

  for (var i = 0; i < codes; i++) {
    switch (random.next(8)) {
      case 0:
        // Four parameters, and four functions, in the one sequence.
        buffer.write(
          _combined([1, 4, 30 + random.next(8), 40 + random.next(8)]),
        );
      case 1:
        buffer.write(fg256(232 + random.next(24)));
      case 2:
        buffer.write(
          fgRgb(random.next(256), random.next(256), random.next(256)),
        );
      default:
        // One parameter: the commonest thing a coloured log writes.
        buffer.write(_combined([30 + random.next(8)]));
    }
  }

  buffer
    ..write(_sentence.substring(0, 20 + random.next(_sentence.length - 20)))
    ..writeln(reset);
}

/// `CSI 1;4;31;41 m` and its like: a sequence written out by its parameters.
///
/// The ready-to-use constants would do for the one-parameter ones, at the
/// price of a switch over eight names to pick a colour by number, and cannot
/// spell the rest at all: each of them is a sequence of its own, where what
/// is wanted here is one sequence carrying several functions — the shape
/// whose lists are longest.
String _combined(List<int> params) => '$_csi${params.join(';')}m';

/// The two characters a control sequence opens with.
///
/// Spelled out rather than imported: `CSI` lives in a part of the package the
/// public library does not export.
const _csi = '\u001b[';

/// A generator of its own, so that the corpus does not move if `dart:math`'s
/// `Random` ever does.
///
/// The multiplier and the increment are the usual ones. What comes out of it
/// is a corpus, not statistics, and it is used for nothing else.
final class _Lcg {
  int _state;

  _Lcg(this._state);

  /// The next number below [bound].
  int next(int bound) {
    _state = (_state * 1664525 + 1013904223) & 0xFFFFFFFF;

    // The low bits of an LCG cycle far sooner than the high ones, so the
    // number is taken from the top.
    return (_state >> 8) % bound;
  }
}
