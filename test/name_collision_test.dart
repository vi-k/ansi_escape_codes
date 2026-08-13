import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// What a user of this package can still write beside it.
///
/// The parser used to export a `Match` of its own, which shadowed
/// `dart:core.Match` silently: an explicit import outranks the implicit
/// `dart:core`, so the compiler never asked which was meant and ordinary code
/// with a regular expression failed with two errors that named no package.
/// This file is that ordinary code. It does not test the parser — it tests
/// that the parser leaves the name alone, and it fails to compile where it
/// does not. See `docs/records/2026-08-13[8]`.
///
/// The name is written out in full here on purpose: a search-and-replace over
/// the word during the rename edited this file too, and a guard that says
/// `Piece` where it means `dart:core.Match` guards nothing.
void main() {
  group('a name this package does not take:', () {
    test('dart:core Match is what Match means beside a single import', () {
      final words = <String>[
        for (final Match m in RegExp(r'\w+').allMatches('one two')) m.group(0)!,
      ];

      expect(words, ['one', 'two']);
    });

    test('and the parser hands out pieces under a name of its own', () {
      final pieces = Parser('\x1B[1mbold').pieces.toList();

      expect(pieces, hasLength(2));
      expect(pieces.first.entity, isA<Sgr>());
      expect(pieces.last.entity.string, 'bold');
    });
  });
}
