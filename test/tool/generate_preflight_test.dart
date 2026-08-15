import 'dart:io';

import 'package:test/test.dart';

const _begin =
    '// BEGIN GENERATED — by tool/generate.dart; edit the generator, not this.';
const _end = '// END GENERATED';

const _registryPaths = [
  'lib/src/ansi/colors.dart',
  'lib/src/ready_to_use/sgr/colors256/fg256.dart',
  'lib/src/ready_to_use/sgr/colors256/bg256.dart',
  'lib/src/ready_to_use/sgr/colors256/underline256.dart',
  'lib/src/parsing/colors/color_indexes.dart',
  'lib/src/parsing/colors/color_256.dart',
  'lib/src/parsing/state/styles.dart',
  'lib/src/parsing/state/style_colors.dart',
];

void main() {
  group('generator registry preflight', () {
    late _GeneratorFixture fixture;

    setUp(() async {
      fixture = await _GeneratorFixture.create();
    });

    tearDown(() => fixture.delete());

    test('rejects an unregistered marker file without rewriting any file',
        () async {
      const extra = 'lib/src/extra.dart';
      await fixture.writeMarkedFile(extra);
      final before = await fixture.bytes([..._registryPaths, extra]);

      final result = await fixture.run();

      expect(result.exitCode, isNonZero);
      expect(result.stderr, contains(extra));
      await fixture.expectBytes([..._registryPaths, extra], before);
    });

    test('rejects a missing registered marker file before writing', () async {
      const missing = 'lib/src/ansi/colors.dart';
      await fixture.deleteFile(missing);
      final before =
          await fixture.bytes(_registryPaths.where((p) => p != missing));

      final result = await fixture.run();

      expect(result.exitCode, isNonZero);
      expect(result.stderr, contains(missing));
      await fixture.expectBytes(
        _registryPaths.where((p) => p != missing),
        before,
      );
    });

    test('rejects a registered file that carries no markers before writing',
        () async {
      // The only state this diagnostic alone catches: the file is where the
      // registry says, so the existence check passes, and nothing else looks
      // at whether it still holds a zone to write into.
      const bare = 'lib/src/parsing/colors/color_256.dart';
      await fixture.write(bare, 'before\nbetween\nafter\n');
      final before = await fixture.bytes(_registryPaths);

      final result = await fixture.run();

      expect(result.exitCode, isNonZero);
      expect(result.stderr, contains('missing registered marker file: $bare'));
      await fixture.expectBytes(_registryPaths, before);
    });

    for (final markerCase in [
      ('BEGIN-only', 'before\n$_begin\nbetween\nafter\n', 1, 0),
      ('END-only', 'before\n$_end\nafter\n', 0, 1),
      ('duplicate BEGIN', 'before\n$_begin\n$_begin\n$_end\nafter\n', 2, 1),
      ('duplicate END', 'before\n$_begin\n$_end\n$_end\nafter\n', 1, 2),
      ('END before BEGIN', 'before\n$_end\n$_begin\nafter\n', 1, 1),
    ]) {
      test('rejects ${markerCase.$1} before writing', () async {
        const path = 'lib/src/ansi/colors.dart';
        await fixture.write(path, markerCase.$2);
        final before = await fixture.bytes(_registryPaths);

        final result = await fixture.run();

        expect(result.exitCode, isNonZero);
        // The exact text, not merely a nonzero exit: an unhandled exception
        // also exits nonzero and names the file in its stack trace.
        expect(
          result.stderr,
          contains(
            '$path: expected exactly one BEGIN before one END '
            '(found ${markerCase.$3} BEGIN and ${markerCase.$4} END)',
          ),
        );
        await fixture.expectBytes(_registryPaths, before);
      });
    }

    test('accepts markers that differ only by surrounding whitespace',
        () async {
      const path = 'lib/src/ansi/colors.dart';
      await fixture.write(
        path,
        'before\n    $_begin\nbetween\n\t$_end\nafter\n',
      );

      final result = await fixture.run();

      expect(result.exitCode, 0);
      expect(result.stdout, 'generated 8 zones\n');
    });

    test('ignores a marked file that is not Dart source', () async {
      await fixture.write(
        'lib/src/notes.txt',
        'before\n$_begin\nbetween\n$_end\nafter\n',
      );

      final result = await fixture.run();

      expect(result.exitCode, 0);
      expect(result.stdout, 'generated 8 zones\n');
    });

    test('sorts its diagnostics rather than reporting them as found', () async {
      // Insertion order is registry first, then discovery, then the set
      // differences; sorted order interleaves them. The two disagree here,
      // so the assertion below fails if the sort is dropped.
      const deleted = 'lib/src/ansi/colors.dart';
      const unpaired = 'lib/src/parsing/state/styles.dart';
      await fixture.deleteFile(deleted);
      await fixture.write(
        unpaired,
        'before\n$_begin\n$_begin\n$_end\nafter\n',
      );

      final result = await fixture.run();

      expect(result.exitCode, isNonZero);
      expect(
        (result.stderr as String).trimRight().split('\n'),
        [
          '$unpaired: expected exactly one BEGIN before one END '
              '(found 2 BEGIN and 1 END)',
          'missing registered file: $deleted',
          'missing registered marker file: $deleted',
        ],
      );
    });

    test('writes all registered zones once and is idempotent', () async {
      final first = await fixture.run();

      expect(first.exitCode, 0);
      expect(first.stdout, 'generated 8 zones\n');
      for (final path in _registryPaths) {
        final text = await fixture.read(path);
        expect(text, contains('before\n$_begin\n'));
        expect(text, contains('$_end\nafter\n'));
      }
      final afterFirst = await fixture.bytes(_registryPaths);

      final second = await fixture.run();

      expect(second.exitCode, 0);
      expect(second.stdout, 'generated 8 zones\n');
      await fixture.expectBytes(_registryPaths, afterFirst);
    });

    test('rejects a duplicate registry path before writing', () async {
      await fixture.duplicateFirstRegistryPath();
      final before = await fixture.bytes(_registryPaths);

      final result = await fixture.run();

      expect(result.exitCode, isNonZero);
      expect(result.stderr, contains('duplicate registered path'));
      expect(result.stderr, contains(_registryPaths.first));
      await fixture.expectBytes(_registryPaths, before);
    });
  });
}

class _GeneratorFixture {
  _GeneratorFixture._(this.root);

  final Directory root;

  static Future<_GeneratorFixture> create() async {
    final root = await Directory.systemTemp.createTemp('generate-preflight-');
    final fixture = _GeneratorFixture._(root);
    final script = fixture.file('tool/generate.dart');
    await script.parent.create(recursive: true);
    await File('tool/generate.dart').copy(script.path);
    for (final path in _registryPaths) {
      await fixture.writeMarkedFile(path);
    }
    return fixture;
  }

  Future<void> delete() => root.delete(recursive: true);

  Future<void> deleteFile(String path) => file(path).delete();

  Future<void> duplicateFirstRegistryPath() async {
    final script = file('tool/generate.dart');
    final source = await script.readAsString();
    const original = 'final registry = _registry();';
    expect(source, contains(original));
    await script.writeAsString(
      source.replaceFirst(
        original,
        'final registry = [\n'
        '    ..._registry(),\n'
        '    _registry().first,\n'
        '  ];',
      ),
    );
  }

  Future<Map<String, List<int>>> bytes(Iterable<String> paths) async => {
        for (final path in paths) path: await file(path).readAsBytes(),
      };

  Future<void> expectBytes(
    Iterable<String> paths,
    Map<String, List<int>> before,
  ) async {
    for (final path in paths) {
      expect(await file(path).readAsBytes(), before[path], reason: path);
    }
  }

  File file(String path) => File('${root.path}/$path');

  Future<String> read(String path) => file(path).readAsString();

  Future<ProcessResult> run() => Process.run(
        Platform.resolvedExecutable,
        ['tool/generate.dart'],
        workingDirectory: root.path,
      );

  Future<void> write(String path, String contents) async {
    final target = file(path);
    await target.parent.create(recursive: true);
    await target.writeAsString(contents);
  }

  Future<void> writeMarkedFile(String path) => write(
        path,
        'before\n$_begin\nbetween\n$_end\nafter\n',
      );
}
