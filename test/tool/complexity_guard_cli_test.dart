import 'dart:io';

import 'package:test/test.dart';

void main() {
  group('complexity guard CLI', () {
    test('rejects unexpected arguments with usage', () async {
      final result = await _runGuard(['--unexpected']);

      expect(result.exitCode, 64);
      expect(
        result.stderr,
        contains('Usage: dart run benchmark/complexity_guard.dart'),
      );
    });
  });
}

Future<ProcessResult> _runGuard(List<String> arguments) => Process.run(
      Platform.resolvedExecutable,
      ['run', 'benchmark/complexity_guard.dart', ...arguments],
    );
