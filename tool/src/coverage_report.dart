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

/// Holds every path in [files] to having sat under [root], returning a
/// diagnostic when one did not.
///
/// [parseLcov] makes a path relative only when it starts with the root it
/// is given, and leaves it alone otherwise. That is the right thing to do
/// there — it has no business rewriting a path it does not recognise — but
/// it means a report collected somewhere else arrives as a set of absolute
/// paths, and the file-set answers below would then disagree with the tree
/// about every file in it, twice over. The cause is worth one line rather
/// than a hundred consequences.
String? checkReportRoot(List<LcovFile> files, {required String root}) {
  final strays = files
      .map((file) => file.path)
      .where((path) => path.startsWith('/') || _driveLetter.hasMatch(path))
      .toList()
    ..sort();
  if (strays.isEmpty) {
    return null;
  }

  final header = 'the report was collected somewhere other than $root, '
      'so ${strays.length} of its paths cannot be read as this tree:';

  return [
    header,
    for (final path in strays.take(3)) '  $path',
    if (strays.length > 3) '  ... and ${strays.length - 3} more',
  ].join('\n');
}

/// The files under `lib/` that hold no executable line, and so leave no
/// record in a coverage report however thoroughly they are used.
///
/// A file appears in the report if and only if it has a line to execute:
/// neither `part of` nor living under `lib/src/` changes that — 20 of the
/// 21 part files in this package are reported, and the one that is not is
/// the one holding only constants.
///
/// Three kinds sit here, and sorting interleaves them, so they are named
/// once rather than as headings the sort would scatter: the five entry
/// points directly under `lib/`, which hold `export` directives and
/// nothing else; the `lib/src/ansi/` names, which are `const String`; and
/// the ready-made sequences and styles, which are `const` again — one of
/// them, `styles.dart`, a part file.
///
/// Kept sorted, and held by [checkReportedFiles] to still being absent:
/// the moment one of these grows a line of code it starts being reported,
/// and an exemption nobody revisits would be the same blind spot this
/// gate exists to close.
const librariesWithoutExecutableLines = <String>[
  'lib/ansi.dart',
  'lib/ansi_escape_codes.dart',
  'lib/extensions.dart',
  'lib/src/ansi/c0.dart',
  'lib/src/ansi/c1.dart',
  'lib/src/ansi/colors.dart',
  'lib/src/ansi/csi.dart',
  'lib/src/ansi/esc_fs.dart',
  'lib/src/ansi/sgr.dart',
  'lib/src/parsing/state/styles.dart',
  'lib/src/ready_to_use/esc.dart',
  'lib/src/ready_to_use/sgr/sgr.dart',
  'lib/src/ready_to_use/sgr/standard_colors/standard_colors.dart',
  'lib/style.dart',
  'lib/utils.dart',
];

/// Holds the report's file set against the tree, returning a diagnostic
/// when they disagree.
///
/// `format_coverage --report-on=lib` builds its report from the hitmap of
/// the run, so a library no test ever loaded leaves no record at all. It
/// does not read as nought per cent — it reads as absent, and a floor
/// measured over what is present cannot see it. Three answers close that:
/// everything reported is on disk, everything on disk is reported or
/// exempted, and everything exempted is on disk and still unreported.
String? checkReportedFiles({
  required Iterable<String> reported,
  required Iterable<String> onDisk,
  required Iterable<String> exempt,
}) {
  final reportedSet = reported.toSet();
  final onDiskSet = onDisk.toSet();
  final exemptSet = exempt.toSet();
  final diagnostics = <String>[];

  for (final path in reportedSet.difference(onDiskSet)) {
    diagnostics.add('reported but not on disk: $path');
  }
  for (final path in onDiskSet.difference(reportedSet).difference(exemptSet)) {
    diagnostics.add('on disk but absent from the report: $path');
  }
  for (final path in exemptSet.difference(onDiskSet)) {
    diagnostics.add('exempted but not on disk: $path');
  }
  for (final path in exemptSet.intersection(reportedSet)) {
    diagnostics.add('exempted but present in the report: $path');
  }

  return diagnostics.isEmpty ? null : (diagnostics..sort()).join('\n');
}

final _driveLetter = RegExp('^[A-Za-z]:');

String _normalize(String path) {
  final slashed = path.replaceAll(r'\', '/');

  return slashed.endsWith('/')
      ? slashed.substring(0, slashed.length - 1)
      : slashed;
}
