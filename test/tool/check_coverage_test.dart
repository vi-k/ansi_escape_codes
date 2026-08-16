import 'package:test/test.dart';

import '../../tool/src/coverage_report.dart';

const _root = '/pkg';

String _record(String path, List<(int, int)> lines) {
  final hit = lines.where((line) => line.$2 != 0).length;

  return [
    'SF:$_root/$path',
    for (final (number, count) in lines) 'DA:$number,$count',
    'LF:${lines.length}',
    'LH:$hit',
    'end_of_record',
  ].join('\n');
}

void main() {
  group('lcov parsing', () {
    test('keys records by a path relative to the package root', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1), (2, 0)]),
        root: _root,
      );

      expect(files, hasLength(1));
      expect(files.single.path, 'lib/a.dart');
      expect(files.single.found, 2);
      expect(files.single.hit, 1);
      expect(files.single.daFound, 2);
      expect(files.single.daHit, 1);
    });

    test('reads every record of a report, not only the first', () {
      final files = parseLcov(
        [
          _record('lib/a.dart', [(1, 1)]),
          _record('lib/b.dart', [(1, 0), (2, 3)]),
        ].join('\n'),
        root: _root,
      );

      expect(files.map((file) => file.path), ['lib/a.dart', 'lib/b.dart']);
      expect(files.last.hit, 1);
    });
  });

  group('lcov consistency', () {
    test('passes a report whose summaries match its records', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1), (2, 0)]),
        root: _root,
      );

      expect(checkLcovConsistency(files), isNull);
    });

    test('catches a summary that disagrees with the records under it', () {
      final files = parseLcov(
        'SF:$_root/lib/a.dart\n'
        'DA:1,1\n'
        'DA:2,0\n'
        'LF:9\n'
        'LH:9\n'
        'end_of_record',
        root: _root,
      );

      final diagnostic = checkLcovConsistency(files);

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/a.dart'));
      expect(diagnostic, contains('9'));
    });
  });

  group('coverage floor', () {
    test('passes coverage standing on the floor exactly', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1), (2, 1), (3, 1), (4, 0)]),
        root: _root,
      );

      expect(checkCoverageFloor(files, 75), isNull);
    });

    test('catches coverage a hair under the floor', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1), (2, 1), (3, 1), (4, 0)]),
        root: _root,
      );

      final diagnostic = checkCoverageFloor(files, 75.001);

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('75.000%'));
    });

    test('catches a report that counted nothing at all', () {
      expect(
        checkCoverageFloor(const [], 95),
        'the report counted no lines at all',
      );
    });
  });

  group('report provenance', () {
    test('passes a report whose paths sit under the root', () {
      final files = parseLcov(
        _record('lib/a.dart', [(1, 1)]),
        root: _root,
      );

      expect(checkReportRoot(files, root: _root), isNull);
    });

    test('catches a report collected under a different root', () {
      // Found by a probe that copied a report into a scratch tree: the
      // prefix did not match, every path stayed absolute, and the file-set
      // oracles then answered with one bogus line per file in lib/ — twice.
      // The cause has to be named where it happens, or the diagnosis is a
      // hundred lines that do not say it.
      final files = parseLcov(
        'SF:/somewhere/else/lib/a.dart\n'
        'DA:1,1\n'
        'LF:1\n'
        'LH:1\n'
        'end_of_record',
        root: _root,
      );

      final diagnostic = checkReportRoot(files, root: _root);

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('/somewhere/else/lib/a.dart'));
      expect(diagnostic, contains(_root));
    });
  });

  group('report completeness', () {
    test('passes a report holding every file that has code', () {
      expect(
        checkReportedFiles(
          reported: const ['lib/a.dart', 'lib/b.dart'],
          onDisk: const ['lib/a.dart', 'lib/b.dart', 'lib/barrel.dart'],
          exempt: const ['lib/barrel.dart'],
        ),
        isNull,
      );
    });

    test('catches a library that no test loaded', () {
      final diagnostic = checkReportedFiles(
        reported: const ['lib/a.dart'],
        onDisk: const ['lib/a.dart', 'lib/lonely.dart'],
        exempt: const [],
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/lonely.dart'));
      expect(diagnostic, contains('absent from the report'));
    });

    test('catches a record for a file the tree no longer has', () {
      final diagnostic = checkReportedFiles(
        reported: const ['lib/a.dart', 'lib/gone.dart'],
        onDisk: const ['lib/a.dart'],
        exempt: const [],
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/gone.dart'));
      expect(diagnostic, contains('not on disk'));
    });

    test('catches an exemption for a file the tree no longer has', () {
      final diagnostic = checkReportedFiles(
        reported: const ['lib/a.dart'],
        onDisk: const ['lib/a.dart'],
        exempt: const ['lib/gone.dart'],
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/gone.dart'));
      expect(diagnostic, contains('exempted'));
    });

    test('catches an exemption for a file that has grown code', () {
      // The half that makes the exemption self-expiring: without it the
      // list would be the same blind spot this gate exists to close.
      final diagnostic = checkReportedFiles(
        reported: const ['lib/a.dart', 'lib/barrel.dart'],
        onDisk: const ['lib/a.dart', 'lib/barrel.dart'],
        exempt: const ['lib/barrel.dart'],
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/barrel.dart'));
      expect(diagnostic, contains('present in the report'));
    });

    test('reports every disagreement at once, sorted', () {
      final diagnostic = checkReportedFiles(
        reported: const ['lib/z.dart'],
        onDisk: const ['lib/a.dart'],
        exempt: const [],
      );

      expect(
        diagnostic!.split('\n'),
        [
          'on disk but absent from the report: lib/a.dart',
          'reported but not on disk: lib/z.dart',
        ],
      );
    });

    test('the exemption list names the files that have no code', () {
      // Pinned, so that a file quietly joining or leaving the list is a
      // decision and not a drift. The fifteen were probed on deca8ca.
      expect(librariesWithoutExecutableLines, hasLength(15));
      expect(librariesWithoutExecutableLines, contains('lib/ansi.dart'));
      expect(
        librariesWithoutExecutableLines,
        contains('lib/src/parsing/state/styles.dart'),
      );
      expect(
        librariesWithoutExecutableLines,
        List<String>.from(librariesWithoutExecutableLines)..sort(),
        reason: 'the list is kept sorted so a diff to it reads',
      );
    });
  });
}
