import 'dart:io';

import 'package:test/test.dart';

import '../../tool/src/readme_structure.dart';

const _fence = '```';

void main() {
  group('stripping a dart line comment', () {
    test('cuts a trailing comment and the space before it', () {
      expect(stripDartComment("print('a'); // says a"), "print('a');");
    });

    test('leaves a line that has no comment alone', () {
      expect(stripDartComment('final a = 1;'), 'final a = 1;');
    });

    test('empties a line that is only a comment', () {
      expect(stripDartComment('  // a note'), '');
    });

    test('keeps slashes inside a single-quoted literal', () {
      // No example in either readme has one today, which is exactly why
      // this is pinned: the first one that does must not move the gate.
      expect(
        stripDartComment("print('https://a'); // fetch"),
        "print('https://a');",
      );
    });

    test('keeps slashes inside a double-quoted literal', () {
      expect(stripDartComment('print("a//b");'), 'print("a//b");');
    });

    test('keeps slashes inside a raw literal', () {
      expect(stripDartComment(r"print(r'a\//b');"), r"print(r'a\//b');");
    });

    test('reads an escaped quote as part of the literal', () {
      expect(
        stripDartComment(r"print('it\'s //'); // c"),
        r"print('it\'s //');",
      );
    });
  });

  group('reading the shape of a readme', () {
    final markdown = [
      '# Title',
      '',
      'Prose.',
      '',
      '## Section',
      '',
      '${_fence}dart',
      'final a = 1; // one',
      'print(a);',
      _fence,
      '',
      'Prose again.',
      '',
      _fence,
      'plain',
      _fence,
      '',
    ].join('\n');

    test('takes heading levels in document order', () {
      expect(
        readReadmeShape(markdown).headings.map((heading) => heading.level),
        [1, 2],
      );
    });

    test('takes code blocks with their info strings', () {
      final blocks = readReadmeShape(markdown).blocks;

      expect(blocks.map((block) => block.info), ['dart', '']);
      expect(blocks.first.lines, ['final a = 1; // one', 'print(a);']);
    });

    test('does not read a heading inside a code block', () {
      final shape = readReadmeShape(
        ['${_fence}dart', '// # not a heading', _fence, ''].join('\n'),
      );

      expect(shape.headings, isEmpty);
      expect(shape.blocks, hasLength(1));
    });
  });

  group('comparing two readmes', () {
    String page(String code) =>
        ['# T', '', '${_fence}dart', code, _fence, ''].join('\n');

    String? compare(String english, String translation) => compareReadmeShapes(
          readReadmeShape(english),
          readReadmeShape(translation),
          englishPath: 'README.md',
          translationPath: 'README.ru.md',
        );

    test('passes when only prose and comment text differ', () {
      expect(
        compare(
          [
            '# Title',
            '',
            'Hello.',
            '',
            '${_fence}dart',
            'final a = 1; // one',
            _fence,
            '',
          ].join('\n'),
          [
            '# Заголовок',
            '',
            'Привет.',
            '',
            '${_fence}dart',
            'final a = 1; // один',
            _fence,
            '',
          ].join('\n'),
        ),
        isNull,
      );
    });

    test('catches code that differs under the comments', () {
      final diagnostic = compare(
        page('final a = 1; // one'),
        page('final a = 2; // один'),
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('README.md'));
      expect(diagnostic, contains('README.ru.md'));
      expect(diagnostic, contains('final a = 1;'));
      expect(diagnostic, contains('final a = 2;'));
    });

    test('catches a comment line dropped from one side', () {
      // The half that keeps shown output honest: the text of a comment is
      // translated and cannot be compared, but its presence can.
      final diagnostic = compare(
        page('print(a);\n// a'),
        page('print(a);\n'),
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('comment'));
    });

    test('catches a heading missing from the translation', () {
      final diagnostic = compare('# A\n\n## B\n', '# A\n');

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('heading'));
    });

    test('catches a block whose language differs', () {
      final diagnostic = compare(
        ['# T', '', '${_fence}dart', 'a', _fence, ''].join('\n'),
        ['# T', '', '${_fence}bash', 'a', _fence, ''].join('\n'),
      );

      expect(diagnostic, isNotNull);
      expect(diagnostic, contains('dart'));
      expect(diagnostic, contains('bash'));
    });

    test('passes the two readmes this repository ships', () {
      // Not a fixture: the rule is about this pair, so `dart test` alone
      // should catch them drifting apart and not only a run of the tool.
      final diagnostic = compare(
        File('README.md').readAsStringSync(),
        File('README.ru.md').readAsStringSync(),
      );

      expect(diagnostic, isNull, reason: diagnostic ?? '');
    });
  });
}
