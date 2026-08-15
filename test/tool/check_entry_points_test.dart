import 'dart:io';

import 'package:test/test.dart';

import '../../tool/src/entry_point_snapshot.dart';

void main() {
  group('entry point namespace snapshot', () {
    test('reports name and entry point differences', () {
      final diagnostic = compareEntryPointSnapshot(
        {
          'lib/extensions.dart': {'A', 'StringHasEscapeCodesExtension'},
          'lib/utils.dart': {'currentCursorPos'},
        },
        {
          'lib/extensions.dart': {'A', 'Extra'},
          'lib/style.dart': {'Style'},
        },
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('lib/extensions.dart'));
      expect(diagnostic, contains('StringHasEscapeCodesExtension'));
      expect(diagnostic, contains('Extra'));
      expect(diagnostic, contains('missing entry points'));
      expect(diagnostic, contains('lib/utils.dart'));
      expect(diagnostic, contains('unexpected entry points'));
      expect(diagnostic, contains('lib/style.dart'));
    });

    test('encodes paths and names in sorted indented JSON', () {
      final snapshot = encodeEntryPointSnapshot({
        'lib/z.dart': {'Z', 'Y'},
        'lib/a.dart': {'B', 'A'},
      });

      expect(
        snapshot,
        '{\n'
        '  "lib/a.dart": [\n'
        '    "A",\n'
        '    "B"\n'
        '  ],\n'
        '  "lib/z.dart": [\n'
        '    "Y",\n'
        '    "Z"\n'
        '  ]\n'
        '}\n',
      );
    });

    test('normalizes a native path against a slash-keyed snapshot', () {
      final diagnostic = compareEntryPointSnapshot(
        {
          'lib/extensions.dart': {'StringHasEscapeCodesExtension'},
        },
        {
          'lib${Platform.pathSeparator}extensions.dart': {
            'StringHasEscapeCodesExtension',
          },
        },
      );

      expect(diagnostic, isNull);
    });
  });

  group('entry point checker', () {
    late _CheckerFixture fixture;

    setUp(() async {
      fixture = await _CheckerFixture.create();
    });

    tearDown(() => fixture.delete());

    test('reports a removed independent extension from the snapshot', () async {
      await fixture.removeExport(
        'lib/extensions.dart',
        "export 'src/extensions/has.dart';\n",
      );

      final result = await fixture.run();

      expect(result.exitCode, 1);
      expect(result.stderr, contains('lib/extensions.dart'));
      expect(result.stderr, contains('StringHasEscapeCodesExtension'));
      expect(result.stderr, contains('expected 8 names, actual 7 names'));
    });

    test('keeps the signature closure diagnostic', () async {
      await fixture.removeExport(
        'lib/extensions.dart',
        "export 'src/parsing/control_functions/control_functions_c0.dart';\n",
      );

      final result = await fixture.run();

      expect(result.exitCode, 1);
      expect(result.stderr, contains('lib/extensions.dart'));
      expect(result.stderr, contains('ControlFunctionsC0'));
    });

    test('does not update a snapshot when the signature closure fails',
        () async {
      await fixture.removeExport(
        'lib/extensions.dart',
        "export 'src/parsing/control_functions/control_functions_c0.dart';\n",
      );
      final snapshot = File('${fixture.root.path}/tool/entry_point_names.json');
      await snapshot.writeAsString('kept as it was\n');

      final result = await fixture.run(['--update-snapshot']);

      expect(result.exitCode, 1);
      expect(await snapshot.readAsString(), 'kept as it was\n');
    });

    test('does not update a snapshot when analysis reports an error', () async {
      await fixture.appendTo(
        'lib/extensions.dart',
        '\nconst undefinedSnapshotName = missingSnapshotName;\n',
      );
      final snapshot = File('${fixture.root.path}/tool/entry_point_names.json');
      final before = await snapshot.readAsBytes();

      final result = await fixture.run(['--update-snapshot']);

      expect(result.exitCode, isNonZero);
      expect(result.stderr, contains('lib/extensions.dart'));
      expect(result.stderr, contains("Undefined name 'missingSnapshotName'"));
      expect(await snapshot.readAsBytes(), before);
    });

    test('does not update a snapshot when an exported source fails analysis',
        () async {
      await fixture.appendTo(
        'lib/src/extensions/has.dart',
        '\nconst _brokenSourceName = missingSourceName;\n',
      );
      final snapshot = File('${fixture.root.path}/tool/entry_point_names.json');
      final before = await snapshot.readAsBytes();

      final result = await fixture.run(['--update-snapshot']);

      expect(result.exitCode, isNonZero);
      expect(result.stderr, contains('lib/src/extensions/has.dart'));
      expect(result.stderr, contains("Undefined name 'missingSourceName'"));
      expect(await snapshot.readAsBytes(), before);
    });

    test('rejects unknown arguments with usage', () async {
      final result = await fixture.run(['--unexpected']);

      expect(result.exitCode, 64);
      expect(
        result.stderr,
        contains(
          'Usage: dart run tool/check_entry_points.dart [--update-snapshot]',
        ),
      );
    });
  });
}

class _CheckerFixture {
  _CheckerFixture._(this.root);

  final Directory root;

  static Future<_CheckerFixture> create() async {
    final root = await Directory.systemTemp.createTemp('entry-points-');
    final fixture = _CheckerFixture._(root);
    await fixture._copyTree(Directory('lib'), Directory('${root.path}/lib'));
    await fixture._copyTree(Directory('tool'), Directory('${root.path}/tool'));
    final packageConfig = File('.dart_tool/package_config.json');
    final target = File('${root.path}/.dart_tool/package_config.json');
    await target.parent.create(recursive: true);
    await packageConfig.copy(target.path);
    return fixture;
  }

  Future<void> delete() => root.delete(recursive: true);

  Future<void> removeExport(String path, String export) async {
    final file = File('${root.path}/$path');
    final before = await file.readAsString();
    expect(before, contains(export));
    await file.writeAsString(before.replaceFirst(export, ''));
  }

  Future<void> appendTo(String path, String text) =>
      File('${root.path}/$path').writeAsString(text, mode: FileMode.append);

  Future<ProcessResult> run([List<String> arguments = const []]) => Process.run(
        Platform.resolvedExecutable,
        ['run', 'tool/check_entry_points.dart', ...arguments],
        workingDirectory: root.path,
      );

  Future<void> _copyTree(Directory source, Directory target) async {
    await target.create(recursive: true);
    await for (final entity in source.list(recursive: true)) {
      final relative = entity.path.substring(source.path.length + 1);
      final destination = '${target.path}/$relative';
      if (entity is Directory) {
        await Directory(destination).create(recursive: true);
      } else if (entity is File) {
        await File(destination).parent.create(recursive: true);
        await entity.copy(destination);
      }
    }
  }
}
