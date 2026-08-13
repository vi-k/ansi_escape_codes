import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('escape code entities:', () {
    test('carry the sequence they stand for', () {
      expect(const SaveCursor().string, '${ESC}7');
      expect(const RestoreCursor().string, '${ESC}8');
      expect(
        Link('https://example.com').string,
        '${OSC}8;;https://example.com$ST',
      );
      expect(Link('').string, '${OSC}8;;$ST');
    });

    test('are told apart from each other', () {
      expect(const SaveCursor(), isNot(const RestoreCursor()));
      expect(const SaveCursor(), isNot(Link('https://example.com')));
      expect(
        Link('https://example.com'),
        isNot(Link('https://other.com')),
      );
    });

    test('describe themselves without mangling what they hold', () {
      expect(
        Parser('a\nb').matches.first.entity.toString(),
        r"Text('a\nb')",
      );
      expect(
        Link('https://example.com').toString(),
        contains('https://example.com'),
      );
    });

    test('name themselves by what they stand for', () {
      String describe(String text) =>
          Parser(text).matches.first.entity.toString();

      expect(describe(RIS), 'Esc(RIS)');
      expect(describe('\x1B(B'), 'Esc("[ESC (B]")');
      expect(describe('${OSC}0;title$ST'), 'Osc("[OSC 0;title ST]")');
      expect(describe(fgRed), 'Sgr(fgRed)');
      expect(describe(cursorUp), 'CursorUp(1)');
      expect(describe(cursorUpN(4)), 'CursorUp(4)');
      expect(describe(cursorPosTo(3, 7)), 'CursorPos(3, 7)');
      expect(describe(erasePage), 'EraseInPage(ErasePart.all)');
      expect(
        describe('\x1B[1;2A'),
        'Csi([CSI 1;2 CUU])',
        reason: 'one that fits no type still reads itself out',
      );
      expect(describe('\x1B[?7h'), 'Csi([CSI ?7 SM])');
      expect(describe('\x1B[!p'), 'Csi([CSI !p])');
      expect(const SaveCursor().toString(), 'SaveCursor()');
      expect(const RestoreCursor().toString(), 'RestoreCursor()');
    });

    test('a link that closes says so, and one that opens says where', () {
      expect(Link('').id, 'linkClose');
      expect(Link('https://example.com').id, 'link(https://example.com)');
    });

    test('a match says where it was found and in what state', () {
      expect(
        Parser('a$fgRed').matches.first.toString(),
        "Match<Style>(start: 0, end: 1, entity: Text('a'), state: Style(), "
        'link: null)',
      );
    });

    test('an escape code reads itself out either way', () {
      final code = Parser(fgRed).matches.first.entity as EscapeCode;

      expect(code.toStringAsControlCodes(), '[ESC][31m');
      expect(code.toStringAsEscapeSequences(), '[CSI 31 SGR]');
    });

    test('two that carry the same string are one to a Set', () {
      const same = [SaveCursor(), SaveCursor()];
      final different = [Link('a'), Link('b')];

      expect(same.toSet(), hasLength(1));
      expect(different.toSet(), hasLength(2));
      expect(
        const SaveCursor().hashCode,
        Parser(saveCursor).matches.first.entity.hashCode,
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
        Link('https://example.com'),
      );
    });
  });
}
