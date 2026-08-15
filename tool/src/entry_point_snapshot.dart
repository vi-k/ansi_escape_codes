import 'dart:convert';

/// The public names exported by each entry point, keyed by its path.
typedef NamesByEntryPoint = Map<String, Set<String>>;

/// Compares [expected] and [actual], returning a diagnostic when they differ.
String? compareEntryPointSnapshot(
  NamesByEntryPoint expected,
  NamesByEntryPoint actual,
) {
  final normalizedExpected = _normalizePaths(expected);
  final normalizedActual = _normalizePaths(actual);
  final expectedPaths = normalizedExpected.keys.toSet();
  final actualPaths = normalizedActual.keys.toSet();
  final missingPaths = (expectedPaths.difference(actualPaths).toList()..sort());
  final unexpectedPaths =
      (actualPaths.difference(expectedPaths).toList()..sort());
  final diagnostics = <String>[];

  if (missingPaths.isNotEmpty) {
    diagnostics.add('missing entry points:');
    for (final path in missingPaths) {
      diagnostics.add(
        '  $path (expected ${normalizedExpected[path]!.length} names)',
      );
    }
  }
  if (unexpectedPaths.isNotEmpty) {
    diagnostics.add('unexpected entry points:');
    for (final path in unexpectedPaths) {
      diagnostics.add(
        '  $path (actual ${normalizedActual[path]!.length} names)',
      );
    }
  }

  for (final path in (expectedPaths.intersection(actualPaths).toList()
    ..sort())) {
    final expectedNames = normalizedExpected[path]!;
    final actualNames = normalizedActual[path]!;
    final missingNames =
        (expectedNames.difference(actualNames).toList()..sort());
    final unexpectedNames =
        (actualNames.difference(expectedNames).toList()..sort());
    if (missingNames.isEmpty && unexpectedNames.isEmpty) {
      continue;
    }

    diagnostics.add(
      '$path: expected ${expectedNames.length} names, '
      'actual ${actualNames.length} names',
    );
    for (final name in missingNames) {
      diagnostics.add('  missing $name');
    }
    for (final name in unexpectedNames) {
      diagnostics.add('  unexpected $name');
    }
  }

  return diagnostics.isEmpty ? null : diagnostics.join('\n');
}

/// Encodes [names] as a stable, readable JSON snapshot.
String encodeEntryPointSnapshot(NamesByEntryPoint names) {
  final sorted = <String, List<String>>{};
  final normalizedNames = _normalizePaths(names);
  for (final path in (normalizedNames.keys.toList()..sort())) {
    sorted[path] = normalizedNames[path]!.toList()..sort();
  }

  return '${const JsonEncoder.withIndent('  ').convert(sorted)}\n';
}

NamesByEntryPoint _normalizePaths(NamesByEntryPoint names) {
  final normalized = <String, Set<String>>{};
  for (final entry in names.entries) {
    normalized
        .putIfAbsent(entry.key.replaceAll(r'\', '/'), () => <String>{})
        .addAll(entry.value);
  }
  return normalized;
}
