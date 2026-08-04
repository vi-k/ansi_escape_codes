// Compares the benchmark numbers of two versions of this package.
//
// ```bash
// dart run benchmark/compare.dart <baseRef> [headRef]
// ```
//
// Each side is checked out as it was (`git worktree`), runs its own
// `benchmark/parser_benchmark.dart --json`, and the two sets of numbers
// are laid side by side, the delta painted by the package itself. With no
// headRef the working tree as it stands is the head side.
//
// The tool needs git and a second checkout, so it stays out of the
// published archive; see .pubignore.

import 'dart:convert';
import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

Future<void> main(List<String> args) async {
  if (args.isEmpty || args.length > 2) {
    stderr
        .writeln('Usage: dart run benchmark/compare.dart <baseRef> [headRef]');
    exitCode = 64;

    return;
  }

  final base = await _numbersOf(args[0]);
  if (base == null) {
    return;
  }

  final head = args.length == 2 ? await _numbersOf(args[1]) : _numbersHere();
  if (head == null) {
    return;
  }

  _render(args[0], base, args.length == 2 ? args[1] : 'working tree', head);
}

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

void _render(
  String baseName,
  Map<String, double> base,
  String headName,
  Map<String, double> head,
) {
  final styles = stdout.supportsAnsiEscapes;
  String paint(String text, Style style) => styles ? style(text) : text;

  print(paint('$baseName  →  $headName', Styles.bold));

  final shared = [
    for (final scenario in base.keys)
      if (head.containsKey(scenario)) scenario,
  ];
  if (shared.isEmpty) {
    print('no scenarios in common — nothing to compare');

    return;
  }

  for (final scenario in shared) {
    final was = base[scenario]!;
    final now = head[scenario]!;
    final delta = was == 0 ? 0.0 : (now - was) / was;

    final verdict = switch (delta) {
      < -_noise => paint(
          '${(-delta * 100).toStringAsFixed(0)} % faster',
          Styles.green,
        ),
      > _noise => paint(
          '${(delta * 100).toStringAsFixed(0)} % slower',
          Styles.red,
        ),
      _ => paint('the same', Styles.dim),
    };

    print('${scenario.padRight(56)} '
        '${_us(was).padLeft(11)} ${_us(now).padLeft(11)}  $verdict');
  }

  final missing = head.keys.where((s) => !base.containsKey(s)).length;
  if (missing > 0) {
    print(paint('$missing scenario(s) are new and have no base', Styles.dim));
  }
}

String _us(double us) => switch (us) {
      < 1 => '${(us * 1000).toStringAsFixed(0)} ns',
      < 1000 => '${us.toStringAsFixed(1)} µs',
      _ => '${(us / 1000).toStringAsFixed(2)} ms',
    };
