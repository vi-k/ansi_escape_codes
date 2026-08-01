import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';
import 'package:ansi_escape_codes/parsing.dart';
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

    test('describe themselves without mangling what they hold', () {
      expect(
        Parser('a\nb').matches.first.entity.toString(),
        r"Text('a\nb')",
      );
      expect(
        const Link('https://example.com').toString(),
        contains('https://example.com'),
      );
    });

    test('an SGR with no parameters is a reset', () {
      expect(Parser('\x1B[m').showControlFunctions(), '[reset]');
      expect(Parser('\x1B[;1m').showControlFunctions(), '[reset;bold]');
    });

    test('DEL is shown, not passed through as it is', () {
      const text = 'a\x7Fb';

      expect(text.ansiHasControlCodes, isTrue);
      expect(
        text.ansiShowControlCodes(preferStyle: ControlCodeStyle.charCode),
        r'a\x7Fb',
      );
      expect(
        text.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr),
        'a[DEL]b',
      );
    });

    test('every control code of the C0 set is described', () {
      for (final code in ControlFunctionsC0.values) {
        expect(code.description, isNotEmpty, reason: code.name);
      }
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
