// Compares the benchmark numbers of two versions of this package.
//
// ```bash
// dart run benchmark/compare.dart <baseRef> [headRef]
// dart run benchmark/compare.dart <baseRef> --color         # colours anyway
// dart run benchmark/compare.dart perf-baseline-4.0.0       # pre-4.0.0 state
// ```
//
// Each side is checked out as it was (`git worktree`), runs its own
// `benchmark/parser_benchmark.dart --json`, and the two sets of numbers
// are laid side by side, the delta painted by the package itself. With no
// headRef the working tree as it stands is the head side. `--color` and
// `--no-color` overrule what stdout says it can do, the way the benchmark's
// own flags do — the terminals built into editors deny the colours they
// show; the `benchmark compare` configuration in `.vscode/launch.json`
// passes it.
//
// The tool needs git and a second checkout, so it stays out of the
// published archive; see .pubignore.

import 'dart:convert';
import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

Future<void> main(List<String> args) async {
  _inColour = stdout.supportsAnsiEscapes;

  final refs = <String>[];
  for (final arg in args) {
    switch (arg) {
      case '--color' || '--colour':
        _inColour = true;
      case '--no-color' || '--no-colour':
        _inColour = false;
      default:
        refs.add(arg);
    }
  }

  if (refs.isEmpty || refs.length > 2) {
    stderr.writeln(
      'Usage: dart run benchmark/compare.dart <baseRef> [headRef] '
      '[--color | --no-color]\n'
      '\n'
      'The base is any git ref: a release tag, a branch, a commit.\n'
      'perf-baseline-4.0.0 is the state before the 4.0.0 performance\n'
      'work, which is the base its numbers were measured against.',
    );
    exitCode = 64;

    return;
  }

  final base = await _numbersOf(refs[0]);
  if (base == null) {
    return;
  }

  final head = refs.length == 2 ? await _numbersOf(refs[1]) : _numbersHere();
  if (head == null) {
    return;
  }

  _render(refs[0], base, refs.length == 2 ? refs[1] : 'working tree', head);
}

/// Whether the table is dressed, which `main` settles from stdout and the
/// flags.
bool _inColour = false;

/// The benchmark numbers of [ref], run in a worktree of it, or null where
/// that version cannot answer (no benchmark, no --json).
Future<Map<String, double>?> _numbersOf(String ref) async {
  final verify = Process.runSync('git', ['rev-parse', '--verify', ref]);
  if (verify.exitCode != 0) {
    stderr.writeln('not a git ref: $ref');
    exitCode = 64;

    return null;
  }

  final dir = Directory.systemTemp.createTempSync('ansi_bench_');
  try {
    final add = Process.runSync(
      'git',
      ['worktree', 'add', '--detach', dir.path, ref],
    );
    if (add.exitCode != 0) {
      stderr.writeln('git worktree add failed:\n${add.stderr}');
      exitCode = 70;

      return null;
    }

    Process.runSync('dart', ['pub', 'get'], workingDirectory: dir.path);

    final run = Process.runSync(
      'dart',
      ['run', 'benchmark/parser_benchmark.dart', '--json'],
      workingDirectory: dir.path,
    );
    if (run.exitCode != 0) {
      stderr.writeln(
        '$ref cannot report json '
        '(no benchmark or no --json at that version):\n${run.stderr}',
      );
      exitCode = 65;

      return null;
    }

    return _parse(run.stdout as String);
  } finally {
    Process.runSync('git', ['worktree', 'remove', '--force', dir.path]);
    if (dir.existsSync()) {
      dir.deleteSync(recursive: true);
    }
  }
}

/// The numbers of the working tree as it stands.
Map<String, double>? _numbersHere() {
  final run = Process.runSync(
    'dart',
    ['run', 'benchmark/parser_benchmark.dart', '--json'],
  );
  if (run.exitCode != 0) {
    stderr.writeln('the working tree failed to run:\n${run.stderr}');
    exitCode = 70;

    return null;
  }

  return _parse(run.stdout as String);
}

Map<String, double> _parse(String jsonLines) => {
      for (final line in LineSplitter.split(jsonLines))
        if (line.startsWith('{'))
          if (jsonDecode(line)
              case {
                'scenario': final String scenario,
                'us': final num us,
              })
            scenario: us.toDouble(),
    };

/// The threshold under which a delta is noise rather than news.
const _noise = 0.05;

/// A scenario name longer than this is wrapped by its spaces, so that the
/// numbers stay in their columns whatever the name does; the numbers stand
/// on the last line of the name.
const _nameWidth = 44;

/// Greedy wrap of [text] by its spaces into lines of at most [width]
/// characters; a word longer than the width takes a line of its own.
List<String> _wrap(String text, int width) {
  final lines = <String>[];
  var line = StringBuffer();
  for (final word in text.split(' ')) {
    if (line.isEmpty) {
      line.write(word);
    } else if (line.length + 1 + word.length <= width) {
      line.write(' $word');
    } else {
      lines.add(line.toString());
      line = StringBuffer(word);
    }
  }
  lines.add(line.toString());

  return lines;
}

/// Whether [scenario]'s number is an amount — megabytes or a count — rather
/// than a time: an amount grows and shrinks, it does not get faster.
bool _isAmount(String scenario) =>
    scenario.endsWith(', mb') || scenario.endsWith('/ matches');

void _render(
  String baseName,
  Map<String, double> base,
  String headName,
  Map<String, double> head,
) {
  String paint(String text, Style style) => _inColour ? style(text) : text;

  final shared = [
    for (final scenario in base.keys)
      if (head.containsKey(scenario)) scenario,
  ];
  if (shared.isEmpty) {
    print('no scenarios in common — nothing to compare');

    return;
  }

  // A scenario the base has never heard of — added since — is still shown,
  // with nothing in the base column: a number with no past is better than
  // a row that silently is not there.
  final scenarios = [
    ...shared,
    for (final scenario in head.keys)
      if (!base.containsKey(scenario)) scenario,
  ];

  // The columns are as wide as the names above them ask, and the names
  // stand right over their numbers.
  final valueWidth = [12, baseName.length + 2, headName.length + 2]
      .reduce((a, b) => a > b ? a : b);
  print('${''.padRight(_nameWidth)}'
      '${Parser(paint(baseName, Styles.bold)).padLeft(valueWidth)}'
      '${Parser(paint(headName, Styles.bold)).padLeft(valueWidth)}');

  for (final scenario in scenarios) {
    final was = base[scenario];
    final now = head[scenario]!;

    final String verdict;
    if (was == null) {
      verdict = paint('new', Styles.dim);
    } else {
      final delta = was == 0 ? 0.0 : (now - was) / was;
      final (better, worse) =
          _isAmount(scenario) ? ('less', 'more') : ('faster', 'slower');
      verdict = switch (delta) {
        < -_noise => paint(
            '${(-delta * 100).toStringAsFixed(0)} % $better',
            Styles.green,
          ),
        > _noise => paint(
            '${(delta * 100).toStringAsFixed(0)} % $worse',
            Styles.red,
          ),
        _ => paint('the same', Styles.dim),
      };
    }

    final wasText = was == null
        ? paint('—', Styles.dim)
        : paint(_value(scenario, was), Styles.cyan);
    final nowText = paint(_value(scenario, now), Styles.cyan);
    final values = '${Parser(wasText).padLeft(valueWidth)}'
        '${Parser(nowText).padLeft(valueWidth)}'
        '  $verdict';

    final lines = _wrap(scenario, _nameWidth - 2);
    for (var i = 0; i < lines.length - 1; i++) {
      print(i == 0 ? lines[i] : '  ${lines[i]}');
    }
    final last = lines.length == 1 ? lines.first : '  ${lines.last}';
    print('${last.padRight(_nameWidth)}$values');
  }
}

/// The JSON carries every number under one key; the scenario's own name
/// says what the number is — megabytes, a count, or the default,
/// microseconds.
String _value(String scenario, double value) {
  if (scenario.endsWith(', mb')) {
    return '${value.toStringAsFixed(1)} MB';
  }
  if (scenario.endsWith('/ matches')) {
    return value.toStringAsFixed(0);
  }

  return _us(value);
}

String _us(double us) => switch (us) {
      < 1 => '${(us * 1000).toStringAsFixed(0)} ns',
      < 10 => '${us.toStringAsFixed(2)} µs',
      < 1000 => '${us.toStringAsFixed(1)} µs',
      _ => '${(us / 1000).toStringAsFixed(2)} ms',
    };
