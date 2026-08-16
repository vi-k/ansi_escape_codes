import 'dart:convert';

/// One fenced code block: where it opens, its info string and its lines.
typedef CodeBlock = ({int line, String info, List<String> lines});

/// One heading: where it stands and how deep it is.
typedef Heading = ({int line, int level});

/// What of a readme is held to its translation: headings and code, in
/// document order. The prose between them is translated and is not here.
typedef ReadmeShape = ({List<Heading> headings, List<CodeBlock> blocks});

final _opening = RegExp(r'^\s*(`{3,}|~{3,})(.*)$');
final _heading = RegExp(r'^(#{1,6})\s');

/// Reads the shape of [markdown].
ReadmeShape readReadmeShape(String markdown) {
  final headings = <Heading>[];
  final blocks = <CodeBlock>[];
  final lines = const LineSplitter().convert(markdown);
  String? fence;
  var openedAt = 0;
  var info = '';
  var body = <String>[];

  for (var index = 0; index < lines.length; index++) {
    final line = lines[index];
    final number = index + 1;

    if (fence != null) {
      if (line.trimRight() == fence) {
        blocks.add((line: openedAt, info: info, lines: body));
        fence = null;
        body = <String>[];
      } else {
        body.add(line);
      }
      continue;
    }

    final opening = _opening.firstMatch(line);
    if (opening != null) {
      fence = opening.group(1);
      info = opening.group(2)!.trim();
      openedAt = number;
      continue;
    }

    final heading = _heading.firstMatch(line);
    if (heading != null) {
      headings.add((line: number, level: heading.group(1)!.length));
    }
  }

  return (headings: headings, blocks: blocks);
}

/// [line] with its Dart line comment removed, respecting string literals.
///
/// A `//` inside a literal is not a comment. No example in either readme
/// has one today; the scanner is here so that the first one that does
/// cannot move this gate quietly.
String stripDartComment(String line) {
  var quote = '';
  var raw = false;

  for (var index = 0; index < line.length; index++) {
    final char = line[index];

    if (quote.isEmpty) {
      if (char == "'" || char == '"') {
        quote = line.startsWith(char * 3, index) ? char * 3 : char;
        raw = index > 0 && line[index - 1] == 'r';
        index += quote.length - 1;
      } else if (line.startsWith('//', index)) {
        return line.substring(0, index).trimRight();
      }
      continue;
    }

    if (!raw && char == r'\') {
      index++;
    } else if (line.startsWith(quote, index)) {
      index += quote.length - 1;
      quote = '';
    }
  }

  return line.trimRight();
}

/// Holds [translation] to [english], returning a diagnostic when the two
/// disagree on anything that is not translated.
///
/// Four answers: the same heading levels in the same order, the same code
/// blocks in the same languages, the same code under the comments, and
/// comments in the same places. The text of a comment is not compared —
/// prose inside an example is translated — but its presence is, so an
/// example whose shown output was corrected on one side only is caught.
String? compareReadmeShapes(
  ReadmeShape english,
  ReadmeShape translation, {
  required String englishPath,
  required String translationPath,
}) {
  final diagnostics = <String>[];

  if (english.headings.length != translation.headings.length) {
    diagnostics.add(
      'heading count: $englishPath has ${english.headings.length}, '
      '$translationPath has ${translation.headings.length}',
    );
  }
  for (var i = 0;
      i < english.headings.length && i < translation.headings.length;
      i++) {
    final left = english.headings[i];
    final right = translation.headings[i];
    if (left.level != right.level) {
      diagnostics.add(
        'heading ${i + 1} is level ${left.level} at $englishPath:${left.line} '
        'and level ${right.level} at $translationPath:${right.line}',
      );
    }
  }

  if (english.blocks.length != translation.blocks.length) {
    diagnostics.add(
      'code block count: $englishPath has ${english.blocks.length}, '
      '$translationPath has ${translation.blocks.length}',
    );
  }
  for (var i = 0;
      i < english.blocks.length && i < translation.blocks.length;
      i++) {
    diagnostics.addAll(
      _compareBlocks(
        english.blocks[i],
        translation.blocks[i],
        ordinal: i + 1,
        englishPath: englishPath,
        translationPath: translationPath,
      ),
    );
  }

  return diagnostics.isEmpty ? null : diagnostics.join('\n');
}

List<String> _compareBlocks(
  CodeBlock left,
  CodeBlock right, {
  required int ordinal,
  required String englishPath,
  required String translationPath,
}) {
  if (left.info != right.info) {
    final mismatch =
        'code block $ordinal is "${left.info}" at $englishPath:${left.line} '
        'and "${right.info}" at $translationPath:${right.line}';

    return [mismatch];
  }

  final leftCode = left.lines.map(stripDartComment).toList();
  final rightCode = right.lines.map(stripDartComment).toList();
  if (leftCode.length != rightCode.length) {
    final mismatch = 'code block $ordinal has ${leftCode.length} lines at '
        '$englishPath:${left.line} and ${rightCode.length} at '
        '$translationPath:${right.line}';

    return [mismatch];
  }

  final diagnostics = <String>[];
  for (var line = 0; line < leftCode.length; line++) {
    final leftAt = left.line + 1 + line;
    final rightAt = right.line + 1 + line;

    if (leftCode[line] != rightCode[line]) {
      diagnostics.add(
        'code differs at $englishPath:$leftAt and $translationPath:$rightAt\n'
        '  $englishPath: ${leftCode[line]}\n'
        '  $translationPath: ${rightCode[line]}',
      );
    }

    final leftHasComment = leftCode[line] != left.lines[line].trimRight();
    final rightHasComment = rightCode[line] != right.lines[line].trimRight();
    if (leftHasComment != rightHasComment) {
      final where = leftHasComment ? englishPath : translationPath;
      final other = leftHasComment ? translationPath : englishPath;
      final at = leftHasComment ? leftAt : rightAt;
      diagnostics.add(
        'a comment stands at $where:$at and not at the same place in $other',
      );
    }
  }

  return diagnostics;
}
