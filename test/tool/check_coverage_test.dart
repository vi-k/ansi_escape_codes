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
}
