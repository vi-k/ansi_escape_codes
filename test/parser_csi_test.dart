import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('the cursor sequences:', () {
    test('carry the number of places to move by', () {
      expect(
        Parser(cursorUpN(4)).matches.first.entity,
        isA<CursorUp>().having((e) => e.n, 'n', 4),
      );
      expect(
        Parser(cursorDownN(2)).matches.first.entity,
        isA<CursorDown>().having((e) => e.n, 'n', 2),
      );
      expect(
        Parser(cursorRightN(3)).matches.first.entity,
        isA<CursorRight>().having((e) => e.n, 'n', 3),
      );
      expect(
        Parser(cursorLeftN(5)).matches.first.entity,
        isA<CursorLeft>().having((e) => e.n, 'n', 5),
      );
      expect(
        Parser(cursorNextLineN(6)).matches.first.entity,
        isA<CursorNextLine>().having((e) => e.n, 'n', 6),
      );
      expect(
        Parser(cursorPrevLineN(7)).matches.first.entity,
        isA<CursorPrevLine>().having((e) => e.n, 'n', 7),
      );
      expect(
        Parser(cursorHPosTo(8)).matches.first.entity,
        isA<CursorHPos>().having((e) => e.n, 'n', 8),
      );
    });

    test('stand for one place when the number is left out', () {
      expect(
        Parser(cursorUp).matches.first.entity,
        isA<CursorUp>().having((e) => e.n, 'n', 1),
        reason: 'CSI A moves by one line',
      );
      expect(
        Parser(cursorHPosToBegin).matches.first.entity,
        isA<CursorHPos>().having((e) => e.n, 'n', 1),
        reason: 'CSI G goes to the first column',
      );
    });

    test('carry the row and the column when they take both', () {
      expect(
        Parser(cursorPosTo(3, 7)).matches.first.entity,
        isA<CursorPos>()
            .having((e) => e.row, 'row', 3)
            .having((e) => e.col, 'col', 7),
      );
      expect(
        Parser(cursorHVPosTo(3, 7)).matches.first.entity,
        isA<CursorHVPos>()
            .having((e) => e.row, 'row', 3)
            .having((e) => e.col, 'col', 7),
      );
      expect(
        Parser(cursorPosToTopLeft).matches.first.entity,
        isA<CursorPos>()
            .having((e) => e.row, 'row', 1)
            .having((e) => e.col, 'col', 1),
        reason: 'CSI H goes to the top left corner',
      );
    });
  });

  group('the scrolling sequences:', () {
    test('carry the number of lines to scroll by', () {
      expect(
        Parser(scrollUpN(2)).matches.first.entity,
        isA<ScrollUp>().having((e) => e.n, 'n', 2),
      );
      expect(
        Parser(scrollDownN(3)).matches.first.entity,
        isA<ScrollDown>().having((e) => e.n, 'n', 3),
      );
      expect(
        Parser(scrollUp).matches.first.entity,
        isA<ScrollUp>().having((e) => e.n, 'n', 1),
      );
    });
  });

  group('the erasing sequences:', () {
    test('carry the part they erase', () {
      expect(
        Parser('\x1B[0J').matches.first.entity,
        isA<EraseInPage>().having((e) => e.part, 'part', ErasePart.toEnd),
      );
      expect(
        Parser(eraseInPageToBegin).matches.first.entity,
        isA<EraseInPage>().having((e) => e.part, 'part', ErasePart.toBegin),
      );
      expect(
        Parser(erasePage).matches.first.entity,
        isA<EraseInPage>().having((e) => e.part, 'part', ErasePart.all),
      );
      expect(
        Parser(eraseInLineToBegin).matches.first.entity,
        isA<EraseInLine>().having((e) => e.part, 'part', ErasePart.toBegin),
      );
      expect(
        Parser(eraseLine).matches.first.entity,
        isA<EraseInLine>().having((e) => e.part, 'part', ErasePart.all),
      );
    });

    test('erase to the end when the part is left out', () {
      expect(
        Parser(eraseInPageToEnd).matches.first.entity,
        isA<EraseInPage>().having((e) => e.part, 'part', ErasePart.toEnd),
        reason: 'CSI J erases from the cursor to the end of the page',
      );
      expect(
        Parser(eraseInLineToEnd).matches.first.entity,
        isA<EraseInLine>().having((e) => e.part, 'part', ErasePart.toEnd),
      );
    });

    test('leave the parts they cannot name alone', () {
      // CSI 3 J clears the scrollback in xterm. ECMA-48 knows nothing of it,
      // and neither does ErasePart.
      expect(Parser('\x1B[3J').matches.first.entity, isNot(isA<EraseInPage>()));
      expect(Parser('\x1B[3J').matches.first.entity, isA<CsiCommon>());
    });
  });

  group('the private modes with a name:', () {
    test('are told apart by their type', () {
      expect(Parser(showCursor).matches.first.entity, isA<ShowCursor>());
      expect(Parser(hideCursor).matches.first.entity, isA<HideCursor>());
      expect(
        Parser(useAlternateScreen).matches.first.entity,
        isA<UseAlternateScreen>(),
      );
      expect(
        Parser(useMainScreen).matches.first.entity,
        isA<UseMainScreen>(),
      );
    });

    test('carry the sequence they stand for', () {
      expect(const ShowCursor().string, showCursor);
      expect(const HideCursor().string, hideCursor);
      expect(const UseAlternateScreen().string, useAlternateScreen);
      expect(const UseMainScreen().string, useMainScreen);
    });

    test('are shown by the name they are written with', () {
      expect(Parser(hideCursor).showControlFunctions(), '[hideCursor]');
      expect(
        Parser(useAlternateScreen).showControlFunctions(),
        '[useAlternateScreen]',
      );
    });

    test('say which of the four they are when printed', () {
      expect(const ShowCursor().toString(), 'ShowCursor()');
      expect(const HideCursor().toString(), 'HideCursor()');
      expect(const UseAlternateScreen().toString(), 'UseAlternateScreen()');
      expect(const UseMainScreen().toString(), 'UseMainScreen()');
    });

    test('leave the private sequences they cannot name alone', () {
      expect(
        Parser('\x1B[?7h').matches.first.entity,
        isA<CsiPrivate>(),
        reason: 'autowrap is a mode of its own, and has no name here',
      );
      expect(
        Parser('\x1B[?25;1h').matches.first.entity,
        isA<CsiPrivate>(),
        reason: 'two modes at once is not the sequence showCursor stands for',
      );
    });
  });

  group('the named sequences:', () {
    test('are the common ones with a name, not instead of them', () {
      final entity = Parser(cursorUpN(4)).matches.first.entity;

      expect(entity, isA<CsiCommon>());
      expect(
        (entity as CsiCommon).controlSequence,
        ControlSequencesFunctions.CUU,
      );
      expect(entity.id, 'CSI 4 CUU', reason: 'the name it is shown by stands');
    });

    test('leave what does not fit their shape alone', () {
      expect(
        Parser('\x1B[1;2A').matches.first.entity,
        isNot(isA<CursorUp>()),
        reason: 'CUU takes one parameter, and this one carries two',
      );
      expect(Parser('\x1B[1;2A').matches.first.entity, isA<CsiCommon>());
      expect(
        Parser('\x1B[1:2A').matches.first.entity,
        isNot(isA<CursorUp>()),
        reason: 'and it takes no sub-parameters either',
      );
      expect(
        (Parser('\x1B[1:2A').matches.first.entity as CsiCommon)
            .params
            .single
            .toString(),
        '1:2',
        reason: 'which are kept as they were written',
      );
    });

    test('a parameter too large to be a number is no sequence at all', () {
      expect(
        Parser('\x1B[99999999999999999999999m').matches.first.entity,
        isA<CsiUnknown>(),
        reason: 'the bytes are kept, the meaning is given up on',
      );
    });
  });
}
