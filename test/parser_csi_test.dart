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
    });
  });
}
