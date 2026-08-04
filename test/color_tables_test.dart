@TestOn('vm')
library;

import 'dart:io';
import 'dart:mirrors';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// `bgHighRed` and `fg256Rgb013` spell a colour with its first letter up.
String _cap(String name) => name[0].toUpperCase() + name.substring(1);

/// The library a table of top-level constants lives in.
LibraryMirror _library(String pathEnd) => currentMirrorSystem()
    .libraries
    .entries
    .firstWhere((e) => e.key.path.endsWith(pathEnd))
    .value;

void main() {
  group('Styles:', () {
    final styles = reflectClass(Styles);

    test('holds the 15 properties and the 256 colours thrice, nothing else',
        () {
      final consts = styles.declarations.values
          .whereType<VariableMirror>()
          .where((d) => d.isStatic && d.isConst);
      expect(consts, hasLength(783));
    });

    test('each property style carries its own property', () {
      const expected = {
        'bold': Style(bold: true),
        'dim': Style(dim: true),
        'italic': Style(italic: true),
        'underline': Style(underline: true),
        'doublyUnderline': Style(doublyUnderline: true),
        'blink': Style(blink: true),
        'blinkRapid': Style(blinkRapid: true),
        'inverse': Style(inverse: true),
        'invisible': Style(invisible: true),
        'strikethrough': Style(strikethrough: true),
        'frame': Style(frame: true),
        'encircle': Style(encircle: true),
        'overline': Style(overline: true),
        'superscript': Style(superscript: true),
        'subscript': Style(subscript: true),
      };

      for (final MapEntry(key: name, value: style) in expected.entries) {
        expect(
          styles.getField(Symbol(name)).reflectee,
          style,
          reason: 'Styles.$name',
        );
      }
    });

    test('each colour name carries its colour in its slot', () {
      for (final color in Colors.values) {
        final name = color.name;

        expect(
          styles.getField(Symbol(name)).reflectee,
          Style(foreground: Color256(color)),
          reason: 'Styles.$name',
        );
        expect(
          styles.getField(Symbol('bg${_cap(name)}')).reflectee,
          Style(background: Color256(color)),
          reason: 'Styles.bg${_cap(name)}',
        );
        expect(
          styles.getField(Symbol('underline${_cap(name)}')).reflectee,
          Style(underlineColor: Color256(color)),
          reason: 'Styles.underline${_cap(name)}',
        );
      }
    });
  });

  group('Color256:', () {
    final color256 = reflectClass(Color256);

    test('names every colour of the table after its index', () {
      for (final color in Colors.values) {
        expect(
          color256.getField(Symbol(color.name)).reflectee,
          Color256(color),
          reason: 'Color256.${color.name}',
        );
      }
    });

    test('and holds no colour besides', () {
      final consts = color256.declarations.values
          .whereType<VariableMirror>()
          .where((d) => d.isStatic && d.isConst);
      expect(consts, hasLength(256));
    });
  });

  group('the ready-to-use 256-colour strings:', () {
    final tables = <String, (LibraryMirror, String Function(int))>{
      'fg256': (_library('colors256/fg256.dart'), fg256),
      'bg256': (_library('colors256/bg256.dart'), bg256),
      'underline256': (
        _library('colors256/underline256.dart'),
        underline256,
      ),
    };

    for (final MapEntry(key: prefix, value: (lib, func)) in tables.entries) {
      test('$prefix* agree with $prefix()', () {
        for (final color in Colors.values) {
          expect(
            lib.getField(Symbol('$prefix${_cap(color.name)}')).reflectee,
            func(color.index),
            reason: '$prefix${_cap(color.name)}',
          );
        }
      });

      test('$prefix* name all 256 colours and nothing else', () {
        final names = lib.declarations.values
            .whereType<VariableMirror>()
            .where((d) => d.isConst)
            .map((d) => MirrorSystem.getName(d.simpleName))
            .where((n) => n != '${prefix}Open' && n != '${prefix}Close');
        expect(names, hasLength(256));
      });
    }
  });

  group('StyleColors, checked at the source — mirrors cannot see it:', () {
    final source =
        File('lib/src/parsing/state/style_colors.dart').readAsStringSync();

    test('each getter hands its own colour to its own slot, once', () {
      final getters = RegExp(
        r'Style get (\w+) =>\s*(foreground|background)\(Color256\.(\w+)\);',
      ).allMatches(source);

      final seen = <String>{};
      for (final m in getters) {
        final (getter, slot, color) = (m[1]!, m[2]!, m[3]!);

        expect(seen.add(getter), isTrue, reason: 'a second $getter');
        expect(
          getter,
          slot == 'foreground' ? color : 'bg${_cap(color)}',
          reason: '$getter took Color256.$color',
        );
      }

      for (final color in Colors.values) {
        expect(seen, contains(color.name));
        expect(seen, contains('bg${_cap(color.name)}'));
      }
      expect(seen, hasLength(512));
    });

    test('no getter fell outside the pattern', () {
      expect(RegExp('Style get ').allMatches(source), hasLength(512));
    });
  });
}
