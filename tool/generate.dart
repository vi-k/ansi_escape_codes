/// Regenerates the hand-written surfaces of the 256-colour table.
///
/// The list of names below is the one source of truth; every surface —
/// the index constants, the ready-to-use strings, the enum, the statics,
/// the styles and the getters — is emitted from it into the zone between
/// its BEGIN/END markers. Run it after changing the naming policy:
///
///     dart run tool/generate.dart
///
/// The CI keeps the zones and the generator in step.
///
/// One thing to know before raising the SDK floor: `_pageWidth` and every
/// wrapping shape below model the short style `dart format` writes below
/// language version 3.7, which is what a `^3.6.0` constraint still asks
/// for. At language version 3.7 and up it writes the tall style instead,
/// and the shapes have to be derived again — the format gate says so
/// loudly rather than quietly.
library;

import 'dart:io';

const _begin =
    '// BEGIN GENERATED — by tool/generate.dart; edit the generator, not this.';
const _end = '// END GENERATED';

/// The column the formatter wraps at; the emitters wrap by the same one,
/// so that what they write is what `dart format` would have written.
const _pageWidth = 80;

/// The line every RGB section header carries under its title.
const _cubeNote =
    '// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).';

/// The line every grayscale section header carries under its title.
const _grayscaleNote = '// Gray colors from dark to light in 24 steps.';

/// The section headers of `ansi/colors.dart`, keyed by the index each one
/// stands in front of, and each closed by the blank line that follows it.
///
/// Spelled out line by line rather than built from a template: the RGB
/// header keeps a blank line where the other three keep a `//`, and the
/// zone is judged byte for byte.
const _indexSections = {
  0: ['//', '// Standard color indexes.', '//', ''],
  8: ['//', '// High intensity color indexes.', '//', ''],
  16: ['//', '// RGB color indexes.', '', _cubeNote, '//', ''],
  232: ['//', '// Grayscale indexes.', '//', _grayscaleNote, '//', ''],
};

/// The section headers of the three ready-to-use files. Their zones open
/// straight with the first entry, so nothing stands in front of index 0,
/// and their wording is not the wording of `ansi/colors.dart`.
const _readySections = {
  8: ['//', '// Predefined high intensity colors.', '//', ''],
  16: ['//', '// Predefined RGB colors.', '//', _cubeNote, '//', ''],
  232: ['//', '// Predefined grayscale.', '//', _grayscaleNote, '//', ''],
};

void main() {
  final names = _names();

  _replace('lib/src/ansi/colors.dart', _ansiIndexes(names));
  _replace(
    'lib/src/ready_to_use/sgr/colors256/fg256.dart',
    _readyToUse(names, prefix: 'fg256', word: 'Foreground'),
  );
  _replace(
    'lib/src/ready_to_use/sgr/colors256/bg256.dart',
    _readyToUse(names, prefix: 'bg256', word: 'Background'),
  );
  _replace(
    'lib/src/ready_to_use/sgr/colors256/underline256.dart',
    _readyToUse(names, prefix: 'underline256', word: 'Underline'),
  );
  _replace('lib/src/parsing/colors/color_indexes.dart', _enumValues(names));
  _replace('lib/src/parsing/colors/color_256.dart', _statics(names));
  _replace('lib/src/parsing/state/styles.dart', _styles(names));
  _replace('lib/src/parsing/state/style_colors.dart', _getters(names));
}

/// One colour of the table: its place and the pieces its names are
/// built from.
class _Name {
  final int index;

  /// `black`, `highRed`, `rgb113`, `gray5` — the enum spelling.
  final String id;

  /// `BLACK`, `HIGH_RED`, `RGB_113`, `GRAY5` — the constant spelling.
  final String constant;

  /// `Black`, `HighRed`, `Rgb113`, `Gray5` — the spelling after a prefix.
  String get cap => id[0].toUpperCase() + id.substring(1);

  /// The eight repeats of the standard colours, indexes 8 to 15.
  bool get isHigh => index >= 8 && index < 16;

  /// The 6 × 6 × 6 cube, indexes 16 to 231.
  bool get isRgb => index >= 16 && index < 232;

  /// The 24 steps of grey, indexes 232 to 255.
  bool get isGray => index >= 232;

  /// `black` for `highBlack` — the standard colour a high one repeats.
  /// Carried by the high family alone, empty for the other three: the
  /// list states it, nothing here cuts it out of [id].
  final String plain;

  /// `113` for `rgb113`, `5` for `gray5` — the digits a table name ends
  /// with. Meaningful for the RGB and grayscale families alone, and asked
  /// only of them.
  String get digits => isGray ? id.substring(4) : id.substring(3);

  _Name(this.index, this.id, this.constant, {this.plain = ''});
}

List<_Name> _names() {
  // The eight standard colours, then the eight high ones, each of those
  // carrying the standard colour it repeats. The pair is written down
  // rather than cut out of the spelling: renaming the `high` prefix is an
  // edit of this list and of nothing else.
  const named = [
    ('black', ''), ('red', ''), ('green', ''), ('yellow', ''), //
    ('blue', ''), ('magenta', ''), ('cyan', ''), ('white', ''),
    ('highBlack', 'black'), ('highRed', 'red'), ('highGreen', 'green'),
    ('highYellow', 'yellow'), ('highBlue', 'blue'),
    ('highMagenta', 'magenta'), ('highCyan', 'cyan'), ('highWhite', 'white'),
  ];

  String screaming(String id) =>
      id.replaceAllMapped(RegExp('[A-Z]'), (m) => '_${m[0]}').toUpperCase();

  return [
    for (final (i, (id, plain)) in named.indexed)
      _Name(i, id, screaming(id), plain: plain),
    for (var r = 0; r < 6; r++)
      for (var g = 0; g < 6; g++)
        for (var b = 0; b < 6; b++)
          _Name(16 + r * 36 + g * 6 + b, 'rgb$r$g$b', 'RGB_$r$g$b'),
    for (var level = 0; level < 24; level++)
      _Name(232 + level, 'gray$level', 'GRAY$level'),
  ];
}

/// `Black`, `High black`, `RGB 113`, `Gray 5` — how `ansi/colors.dart`
/// opens the sentence of a doc comment.
String _indexName(_Name name) {
  if (name.isRgb) {
    return 'RGB ${name.digits}';
  }

  if (name.isGray) {
    return 'Gray ${name.digits}';
  }

  if (name.isHigh) {
    return 'High ${name.plain}';
  }

  return name.cap;
}

/// `black`, `high intensity black`, `RGB 113`, `gray color 5` — how the
/// ready-to-use files name a colour after `Foreground`, `Background` or
/// `Underline`. The wording is not that of `ansi/colors.dart`: the high
/// colours spell out «intensity» and a grey is a «gray color N».
String _colorName(_Name name) {
  if (name.isRgb) {
    return 'RGB ${name.digits}';
  }

  if (name.isGray) {
    return 'gray color ${name.digits}';
  }

  if (name.isHigh) {
    return 'high intensity ${name.plain}';
  }

  return name.id;
}

/// `lib/src/ansi/colors.dart`: the 256 indexes as documented constants,
/// in four sections, one blank line between neighbours.
List<String> _ansiIndexes(List<_Name> names) {
  final lines = <String>[];

  for (final name in names) {
    lines
      ..addAll(_indexSections[name.index] ?? const <String>[])
      ..add('/// ${_indexName(name)} index from 256-color table.')
      ..add('const int ${name.constant} = ${name.index};')
      ..add('');
  }

  return lines..removeLast();
}

/// `fg256.dart`, `bg256.dart`, `underline256.dart`: the same 256 strings
/// under three prefixes. The long names of `underline256` push nine of
/// the declarations past the page width, and those wrap after the `=`
/// exactly as the formatter wraps them.
List<String> _readyToUse(
  List<_Name> names, {
  required String prefix,
  required String word,
}) {
  final lines = <String>[];

  for (final name in names) {
    final head = 'const String $prefix${name.cap} =';
    final value = "'\$${prefix}Open\$${name.constant}\$${prefix}Close';";

    lines
      ..addAll(_readySections[name.index] ?? const <String>[])
      ..add('/// $word ${_colorName(name)} from 256-color table.');

    if (head.length + 1 + value.length <= _pageWidth) {
      lines.add('$head $value');
    } else {
      lines
        ..add(head)
        ..add('    $value');
    }

    lines.add('');
  }

  return lines..removeLast();
}

/// `color_indexes.dart`: the bare enum values, the last one closing the
/// list with a semicolon instead of a comma.
List<String> _enumValues(List<_Name> names) => [
      for (final (i, name) in names.indexed)
        '  ${name.id}${i == names.length - 1 ? ';' : ','}',
    ];

/// `color_256.dart`: one static per colour, wrapping its index.
List<String> _statics(List<_Name> names) => [
      for (final name in names)
        '  static const Color256 ${name.id} = Color256(Colors.${name.id});',
    ];

/// `styles.dart`: three blocks of 256 — foreground, background and
/// underline — a blank line between them.
List<String> _styles(List<_Name> names) => [
      ..._styleBlock(names, field: 'foreground', target: 'foreground'),
      '',
      ..._styleBlock(
        names,
        prefix: 'bg',
        field: 'background',
        target: 'background',
      ),
      '',
      ..._styleBlock(
        names,
        prefix: 'underline',
        field: 'underlineColor',
        target: 'underline',
      ),
    ];

/// One of the three blocks of `styles.dart`.
///
/// No declaration fits on a single line, so the short form is already the
/// two-line one. When even the continuation overflows the page — nine
/// times, all of them long `high…` names — the formatter splits the
/// argument list instead, and so does this.
List<String> _styleBlock(
  List<_Name> names, {
  required String field,
  required String target,
  String prefix = '',
}) {
  final lines = <String>[];

  for (final name in names) {
    final id = prefix.isEmpty ? name.id : '$prefix${name.cap}';
    final call = '$field: Color256.on(Colors.${name.id}, ColorTarget.$target)';
    final continuation = '      Style($call);';

    if (continuation.length <= _pageWidth) {
      lines
        ..add('  static const Style $id =')
        ..add(continuation);
    } else {
      lines
        ..add('  static const Style $id = Style(')
        ..add('    $call,')
        ..add('  );');
    }
  }

  return lines;
}

/// `style_colors.dart`: two blocks of 256 getters — foreground first,
/// background after a blank line.
List<String> _getters(List<_Name> names) => [
      for (final name in names)
        '  Style get ${name.id} => foreground(Color256.${name.id});',
      '',
      for (final name in names)
        '  Style get bg${name.cap} => background(Color256.${name.id});',
    ];

void _replace(String path, List<String> zone) {
  final file = File(path);
  final lines = file.readAsLinesSync();

  // The first BEGIN and the first END: one pair per file is what is meant.
  final begin = lines.indexWhere((l) => l.trim() == _begin);
  final end = lines.indexWhere((l) => l.trim() == _end);

  if (begin < 0 || end < 0 || end < begin) {
    stderr.writeln('$path: BEGIN/END markers missing or unpaired');
    exit(1);
  }

  file.writeAsStringSync(
    [...lines.take(begin + 1), ...zone, ...lines.skip(end), ''].join('\n'),
  );
}
