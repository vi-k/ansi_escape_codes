/// Holds a collected coverage report to two answers: its summaries agree
/// with its own records, and the hand-written part of `lib/` covers at
/// least the floor.
///
/// The report comes from `dart test --coverage` put through
/// `coverage:format_coverage`; the workflow writes both the full report and
/// the gated one, which leaves out the generated `style_colors.dart`.
///
///     dart run tool/check_coverage.dart
///
library;

import 'dart:io';

import 'src/coverage_report.dart';

// The same shape as tool/check_entry_points.dart: the native separator,
// resolved once.
final _sep = Platform.pathSeparator;

void main(List<String> args) {
  exitCode = runCoverageCheck(args, root: _packageRoot());
}

/// Runs the coverage checks under [root].
int runCoverageCheck(List<String> args, {required String root}) {
  var gated = 'coverage/lcov.gated.info';
  var floor = 95.0;

  for (final arg in args) {
    if (arg.startsWith('--gated=')) {
      gated = arg.substring('--gated='.length);
    } else if (arg.startsWith('--floor=')) {
      final value = double.tryParse(arg.substring('--floor='.length));
      if (value == null) {
        stderr.writeln('not a number: $arg');

        return 2;
      }
      floor = value;
    } else {
      stderr.writeln(
        'Usage: dart run tool/check_coverage.dart '
        '[--gated=<lcov>] [--floor=<percent>]',
      );

      return 2;
    }
  }

  final gatedFile = File('$root$_sep$gated');
  if (!gatedFile.existsSync()) {
    stderr.writeln('no report at $gated');

    return 2;
  }

  final files = parseLcov(gatedFile.readAsStringSync(), root: root);
  // Written out rather than as null-aware elements in a list literal:
  // those arrived in Dart 3.8 and this package's floor is 3.6.0, so the
  // floor leg of the matrix would not compile them.
  final diagnostics = <String>[];
  final consistency = checkLcovConsistency(files);
  if (consistency != null) {
    diagnostics.add(consistency);
  }
  final floorDiagnostic = checkCoverageFloor(files, floor);
  if (floorDiagnostic != null) {
    diagnostics.add(floorDiagnostic);
  }
  if (diagnostics.isNotEmpty) {
    diagnostics.forEach(stderr.writeln);

    return 1;
  }

  final coverage = coverageOf(files);
  stdout.writeln(
    'coverage of hand-written lib/: '
    '${coverage.percent.toStringAsFixed(3)}% '
    '(${coverage.hit} of ${coverage.found} lines), '
    'floor ${floor.toStringAsFixed(1)}%',
  );

  return 0;
}

/// The package root: the directory holding the `tool/` this script runs
/// from, so that the check reads the same tree whatever the cwd.
String _packageRoot() {
  final script = File.fromUri(Platform.script).absolute.path;
  final tool = script.lastIndexOf('${_sep}tool$_sep');

  return tool == -1
      ? Directory.current.absolute.path
      : script.substring(0, tool);
}
