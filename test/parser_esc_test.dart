import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('ESC sequences with intermediate bytes:', () {
    test('are consumed whole', () {
      const sequences = {
        '\x1B(B': 'designate ASCII as G0, sent by ncurses and tput',
        '\x1B)0': 'designate the line drawing set as G1',
        '\x1B#8': 'DEC screen alignment test',
        '\x1B%G': 'select UTF-8',
      };

      for (final MapEntry(key: text, value: what) in sequences.entries) {
        expect('a${text}b'.ansiRemoveEscapeCodes(), 'ab', reason: what);
        expect(Parser('a${text}b').length, 2, reason: what);
      }
    });

    test('are not mistaken for the cursor sequences', () {
      expect(Parser('\x1B7').pieces.first.entity, const SaveCursor());
      expect(Parser('\x1B8').pieces.first.entity, const RestoreCursor());
      expect(Parser('\x1B 7').pieces.first.entity, isA<EscUnknown>());
    });

    test('keep those bytes when they are shown', () {
      expect('\x1B(B'.ansiShowEscapeSequences(), '[ESC (B]');
      expect('\x1B)0'.ansiShowEscapeSequences(), '[ESC )0]');
      expect('\x1B#8'.ansiShowEscapeSequences(), '[ESC #8]');
      expect(Parser('\x1B%G').showControlFunctions(), '[ESC %G]');
    });

    test('are told apart from the sequences without them', () {
      expect(
        '\x1B(B'.ansiShowEscapeSequences(),
        isNot('\x1B)B'.ansiShowEscapeSequences()),
        reason: 'G0 and G1 are designated by different sequences',
      );
      expect(
        '\x1B 7'.ansiShowEscapeSequences(),
        '[ESC ␠7]',
        reason: 'the space is shown, or this reads as the cursor save',
      );
      expect('\x1B7'.ansiShowEscapeSequences(), '[ESC 7]');
    });
  });

  group('the independent control functions:', () {
    test('are named when they are read', () {
      expect(Parser(RIS).showControlFunctions(), '[ESC RIS]');
      expect(Parser(LS2).showControlFunctions(), '[ESC LS2]');
      expect(Parser(LS1R).showControlFunctions(), '[ESC LS1R]');
    });

    test('leave the bytes reserved beside them unnamed', () {
      // 0x65 lies between CMD and LS2, and the standard keeps it back.
      expect(Parser('\x1Be').pieces.first.entity, isA<EscUnknown>());
    });

    test('do not take the cursor sequences with them', () {
      expect(Parser(saveCursor).pieces.first.entity, const SaveCursor());
      expect(Parser(restoreCursor).pieces.first.entity, const RestoreCursor());
    });

    test('are counted as escape codes, not as text', () {
      expect('a${RIS}b'.ansiRemoveEscapeCodes(), 'ab');
      expect(Parser('a${RIS}b').length, 2);
    });

    test('resetTerminal is the ready-to-use name of the RIS bytes', () {
      expect(resetTerminal, '\x1Bc');
    });
  });

  group('the cursor pair carries the style with it:', () {
    test('what was saved comes back', () {
      final parser = Parser('$fgRed$saveCursor$fgBlue$restoreCursor');

      expect(
        parser.finalState.foregroundColor,
        Color16.red,
        reason: 'ESC 8 restores the rendition ESC 7 put away',
      );
    });

    test('and the whole of it, not just the colour', () {
      final parser = Parser(
        '$bold$fgRed$saveCursor$resetBoldAndDim$fgBlue$restoreCursor',
      );

      expect(parser.finalState.isBold, isTrue);
      expect(parser.finalState.foregroundColor, Color16.red);
    });

    test('a restore with nothing saved goes back to the beginning', () {
      final parser = Parser('$fgRed$restoreCursor');

      expect(parser.finalState, Style.terminalColors);
    });

    test('the stacked parser does the same', () {
      final parser = StackedParser('$fgRed$saveCursor$fgBlue$restoreCursor');

      expect(parser.finalState.foregroundColor, Color16.red);
    });

    test('and a string read in two goes remembers across the pause', () {
      final parser = Parser('$fgRed$saveCursor' 'text$fgBlue$restoreCursor');

      expect(parser.stateAt(1).foregroundColor, Color16.red);
      expect(parser.isParsed, isFalse, reason: 'stopping short of the restore');
      expect(
        parser.finalState.foregroundColor,
        Color16.red,
        reason: 'and reading on still knows what was saved before the pause',
      );
    });

    test('the sequences are still the entities they were', () {
      final pieces = Parser('$saveCursor$restoreCursor').pieces.toList();

      expect(pieces.first.entity, const SaveCursor());
      expect(pieces.last.entity, const RestoreCursor());
    });
  });

  group('a broken ESC:', () {
    test('is not left in the text', () {
      expect('a\x1B'.ansiRemoveEscapeCodes(), 'a');
      expect('\x1B\x1B'.ansiRemoveEscapeCodes(), '');
      expect('a\x1B\nb'.ansiRemoveEscapeCodes(), 'a\nb');
    });

    test('is shown instead of throwing', () {
      expect('a\x1B'.ansiShowEscapeSequences(), 'a[ESC]');
      expect(Parser('a\x1B').showControlFunctions(), 'a[ESC]');
    });
  });
}
