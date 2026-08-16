import 'dart:io';

import 'package:test/test.dart';

/// Which platform libraries each entry point can reach.
///
/// pub.dev works this out for itself and tags the package by it: a library
/// that reaches `dart:io` is not one the web can run, and the tag is read off
/// the primary entry point. Two of this package's five functions talk to a
/// terminal in person and cannot be anything but native; the rest is string
/// work that runs anywhere, and it is the umbrella import that decides which
/// of the two the package looks like from outside.
///
/// The graph is walked over the source rather than asked of the analyser: the
/// question is which files reach which, and the directives say that in as many
/// words. `part` files carry no directives of their own, so their library's
/// count for them — they are followed for the `part` list alone.
Set<String> _platformLibrariesOf(String entryPoint) {
  const lib = 'lib';
  final reached = <String>{};
  final seen = <String>{};
  final queue = <String>['$lib/$entryPoint'];

  while (queue.isNotEmpty) {
    final path = queue.removeLast();
    if (!seen.add(path)) {
      continue;
    }

    final source = File(path).readAsStringSync();
    final directive = RegExp(
      r"^\s*(?:import|export|part)\s+'([^']+)'",
      multiLine: true,
    );

    for (final m in directive.allMatches(source)) {
      final target = m.group(1)!;

      if (target.startsWith('dart:')) {
        reached.add(target);
        continue;
      }

      if (target.startsWith('package:')) {
        // Nothing outside this package is followed: `meta` carries no
        // platform of its own, and a dependency that did would be a
        // question for the pubspec rather than for this walk.
        continue;
      }

      queue.add(File(path).parent.uri.resolve(target).toFilePath());
    }
  }

  return reached;
}

void main() {
  group('what each entry point can reach:', () {
    test('the umbrella import runs anywhere the string work does', () {
      expect(
        _platformLibrariesOf('ansi_escape_codes.dart'),
        isNot(contains('dart:io')),
        reason: 'pub.dev reads the platforms off this one, and a package '
            'tagged native-only for two terminal functions is one the web '
            'cannot be told it may use for the other thousand names',
      );
    });

    for (final entryPoint in ['ansi.dart', 'style.dart', 'extensions.dart']) {
      test('$entryPoint runs anywhere too', () {
        expect(_platformLibrariesOf(entryPoint), isNot(contains('dart:io')));
      });
    }

    test('utils.dart is where the terminal is talked to in person', () {
      expect(
        _platformLibrariesOf('utils.dart'),
        contains('dart:io'),
        reason: 'and that is the whole of why it stands apart',
      );
    });

    test('the walk reaches something, so an empty answer is no answer', () {
      expect(
        _platformLibrariesOf('ansi_escape_codes.dart'),
        contains('dart:async'),
        reason: 'the parser imports it, and a walk finding nothing at all '
            'would pass every test above without looking',
      );
    });
  });
}
