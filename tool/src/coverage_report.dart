import 'dart:convert';

/// One `SF:` record of an lcov report: its file and its line counts.
///
/// `found` and `hit` are the report's own `LF:` and `LH:` summaries;
/// `daFound` and `daHit` are the same two numbers counted from the `DA:`
/// records beneath them. A report whose summaries disagree with its own
/// records is not one to measure a floor against, so the two are carried
/// apart and held against each other.
typedef LcovFile = ({
  String path,
  int found,
  int hit,
  int daFound,
  int daHit,
});

/// Parses [lcov], returning one record per file with paths as they read
/// from [root].
///
/// `format_coverage` writes absolute paths, so every path is made relative
/// to [root] and separators are normalised to `/`; a report collected on
/// Windows otherwise compares against nothing.
List<LcovFile> parseLcov(String lcov, {required String root}) {
  final prefix = '${_normalize(root)}/';
  final files = <LcovFile>[];
  String? path;
  var found = 0;
  var hit = 0;
  var daFound = 0;
  var daHit = 0;

  void flush() {
    final current = path;
    if (current == null) {
      return;
    }
    final file = (
      path: current,
      found: found,
      hit: hit,
      daFound: daFound,
      daHit: daHit,
    );
    files.add(file);
    path = null;
    found = 0;
    hit = 0;
    daFound = 0;
    daHit = 0;
  }

  for (final line in const LineSplitter().convert(lcov)) {
    if (line.startsWith('SF:')) {
      flush();
      final source = _normalize(line.substring(3));
      path =
          source.startsWith(prefix) ? source.substring(prefix.length) : source;
    } else if (line.startsWith('LF:')) {
      found += int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      hit += int.parse(line.substring(3));
    } else if (line.startsWith('DA:')) {
      final counts = line.substring(3).split(',');
      daFound++;
      if (counts.length > 1 && int.parse(counts[1]) != 0) {
        daHit++;
      }
    } else if (line == 'end_of_record') {
      flush();
    }
  }
  flush();

  return files;
}

/// Holds each file's `LF:`/`LH:` summaries to its own `DA:` records,
/// returning a diagnostic when they disagree.
String? checkLcovConsistency(List<LcovFile> files) {
  final diagnostics = <String>[];
  for (final file in files) {
    if (file.found != file.daFound || file.hit != file.daHit) {
      diagnostics.add(
        '${file.path}: the summary says ${file.hit} of ${file.found} lines, '
        'the records say ${file.daHit} of ${file.daFound}',
      );
    }
  }

  return diagnostics.isEmpty ? null : diagnostics.join('\n');
}

/// What [files] cover, as a percentage and the counts behind it.
({double percent, int hit, int found}) coverageOf(List<LcovFile> files) {
  var found = 0;
  var hit = 0;
  for (final file in files) {
    found += file.found;
    hit += file.hit;
  }

  return (percent: found == 0 ? 0 : 100 * hit / found, hit: hit, found: found);
}

/// Holds the coverage of [files] to [floor] percent, returning a
/// diagnostic when it falls through.
String? checkCoverageFloor(List<LcovFile> files, double floor) {
  final coverage = coverageOf(files);
  if (coverage.found == 0) {
    return 'the report counted no lines at all';
  }
  if (coverage.percent >= floor) {
    return null;
  }

  // Three decimals, not one: the boundary is where this does its work, and
  // one decimal prints the same "95.0%" for the run that passes and the run
  // just under it that does not.
  return 'the coverage has fallen through the floor: '
      '${coverage.percent.toStringAsFixed(3)}% '
      '(${coverage.hit} of ${coverage.found} lines), '
      'floor ${floor.toStringAsFixed(1)}%';
}

String _normalize(String path) {
  final slashed = path.replaceAll(r'\', '/');

  return slashed.endsWith('/')
      ? slashed.substring(0, slashed.length - 1)
      : slashed;
}
