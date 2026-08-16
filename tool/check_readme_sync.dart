/// Holds `README.ru.md` to `README.md`: the same headings, the same code
/// blocks, the same code under the comments.
///
/// The English readme is the source and the Russian one its translation,
/// and AGENTS.md calls a divergence between them a defect. Until this
/// existed the rule was kept by attention alone. What is compared is only
/// what is not translated: the prose, and the text of the comments inside
/// examples, are meant to differ. Where a comment stands is not.
///
///     dart run tool/check_readme_sync.dart
///
library;

import 'dart:io';

import 'src/readme_structure.dart';

// The same shape as tool/check_entry_points.dart.
final _sep = Platform.pathSeparator;
const _english = 'README.md';
const _translation = 'README.ru.md';

void main(List<String> args) {
  exitCode = runReadmeSyncCheck(args, root: _packageRoot());
}

/// Runs the readme comparison under [root].
int runReadmeSyncCheck(List<String> args, {required String root}) {
  if (args.isNotEmpty) {
    stderr.writeln('Usage: dart run tool/check_readme_sync.dart');

    return 2;
  }

  final shapes = <String, ReadmeShape>{};
  for (final name in const [_english, _translation]) {
    final file = File('$root$_sep$name');
    if (!file.existsSync()) {
      stderr.writeln('no $name under $root');

      return 2;
    }
    shapes[name] = readReadmeShape(file.readAsStringSync());
  }

  final english = shapes[_english]!;
  final diagnostic = compareReadmeShapes(
    english,
    shapes[_translation]!,
    englishPath: _english,
    translationPath: _translation,
  );
  if (diagnostic != null) {
    stderr.writeln(diagnostic);

    return 1;
  }

  stdout.writeln(
    'the two readmes agree: ${english.headings.length} headings, '
    '${english.blocks.length} code blocks',
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
