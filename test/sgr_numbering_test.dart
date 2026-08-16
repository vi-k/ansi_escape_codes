import 'dart:io';

import 'package:test/test.dart';

/// The SGR code each member of `ControlFunctionsSGR` is annotated with is a
/// hand-written copy of a constant that already exists in `lib/src/ansi/sgr.dart`.
/// A copy drifts: nine of them did, and the drift outlived a review before
/// anyone noticed — the eight background colours were labelled with the
/// foreground codes, and `bgHighBlue` carried 1010 for 104.
///
/// So the copy is held to its source here. The annotation is read off the
/// enum, the constant it names is read off `sgr.dart`, and the two have to
/// agree. Nothing else can catch this: the numbers live in comments, which no
/// amount of exercising the code will exercise.
const _enumPath = 'lib/src/parsing/control_functions/sgr.dart';
const _constantsPath = 'lib/src/ansi/sgr.dart';

/// `const int NAME = 42;`
final _constantRe = RegExp('^const int ([A-Z_0-9]+) = ([0-9]+);');

/// `  bgBlack, // 40`
final _memberRe = RegExp(r'^\s*([a-zA-Z_0-9]+), // ([0-9]+)$');

/// The last `[sgr.UPPER_SNAKE]` of a `/// See ...` line.
///
/// Two shapes occur. Most members name one constant, as in
/// `See [sgr.bgBlack] and [sgr.BG_BLACK].`, while `fg` and `bg` name several
/// links and put the constant last, as in
/// `See [sgr.fg256Open], ... and [sgr.FOREGROUND].`. Taking the last
/// upper-case link covers both.
final _seeRe = RegExp(r'^\s*/// See .*\[sgr\.([A-Z_0-9]+)\]\.\s*$');

typedef _Annotation = ({String member, int line, String constant, int code});

Map<String, int> _readConstants() {
  final constants = <String, int>{};
  for (final line in File(_constantsPath).readAsLinesSync()) {
    final match = _constantRe.firstMatch(line);
    if (match != null) {
      constants[match.group(1)!] = int.parse(match.group(2)!);
    }
  }

  return constants;
}

List<_Annotation> _readAnnotations() {
  final lines = File(_enumPath).readAsLinesSync();
  final annotations = <_Annotation>[];

  for (var i = 0; i < lines.length; i++) {
    final member = _memberRe.firstMatch(lines[i]);
    if (member == null) {
      continue;
    }

    // The `See` line stands in the member's own doc comment, so the search
    // back stops at the blank line that separates one member from the last.
    String? constant;
    for (var j = i - 1; j >= 0; j--) {
      if (lines[j].trim().isEmpty) {
        break;
      }
      final see = _seeRe.firstMatch(lines[j]);
      if (see != null) {
        constant = see.group(1);
        break;
      }
    }

    final annotation = (
      member: member.group(1)!,
      line: i + 1,
      constant: constant ?? '',
      code: int.parse(member.group(2)!),
    );
    annotations.add(annotation);
  }

  return annotations;
}

void main() {
  group('the SGR codes written into ControlFunctionsSGR', () {
    late Map<String, int> constants;
    late List<_Annotation> annotations;

    setUp(() {
      constants = _readConstants();
      annotations = _readAnnotations();
    });

    test('are read off the enum at all', () {
      // Pinned, so that a member losing its annotation — or the shape of the
      // file changing under this test — is a failure and not a silent drop to
      // checking nothing.
      expect(annotations, hasLength(73));
      expect(constants.length, greaterThanOrEqualTo(annotations.length));
    });

    test('each name a constant that exists', () {
      final unnamed =
          annotations.where((a) => a.constant.isEmpty).map((a) => a.member);
      expect(unnamed, isEmpty, reason: 'no `See [sgr.CONSTANT].` line');

      final missing = annotations
          .where((a) => !constants.containsKey(a.constant))
          .map((a) => '${a.member} -> ${a.constant}');
      expect(
        missing,
        isEmpty,
        reason: 'named a constant sgr.dart does not have',
      );
    });

    test('agree with the constants they name', () {
      String describe(_Annotation annotation) =>
          '$_enumPath:${annotation.line}: ${annotation.member} is annotated '
          '${annotation.code}, ${annotation.constant} is '
          '${constants[annotation.constant]}';

      final wrong = annotations
          .where((a) => constants[a.constant] != a.code)
          .map(describe);

      expect(wrong, isEmpty);
    });
  });
}
