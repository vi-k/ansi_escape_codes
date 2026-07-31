import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('escape code entities:', () {
    test('carry the sequence they stand for', () {
      expect(const SaveCursor().string, '${ESC}7');
      expect(const RestoreCursor().string, '${ESC}8');
      expect(
        const Link('https://example.com').string,
        '${OSC}8;;https://example.com$ST',
      );
      expect(const Link('').string, '${OSC}8;;$ST');
    });

    test('are told apart from each other', () {
      expect(const SaveCursor(), isNot(const RestoreCursor()));
      expect(const SaveCursor(), isNot(const Link('https://example.com')));
      expect(
        const Link('https://example.com'),
        isNot(const Link('https://other.com')),
      );
    });

    test('equal what the parser reads back from the same text', () {
      Entity entityOf(String text) => Parser(text).matches.first.entity;

      expect(entityOf(saveCursor), const SaveCursor());
      expect(entityOf(restoreCursor), const RestoreCursor());
      expect(
        entityOf('${OSC}8;;https://example.com$ST'),
        const Link('https://example.com'),
      );
    });
  });
}
