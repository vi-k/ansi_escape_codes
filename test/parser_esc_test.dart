import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';
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
      expect(Parser('\x1B7').matches.first.entity, const SaveCursor());
      expect(Parser('\x1B8').matches.first.entity, const RestoreCursor());
      expect(Parser('\x1B 7').matches.first.entity, isA<EscUnknown>());
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
      expect(Parser('\x1Be').matches.first.entity, isA<EscUnknown>());
    });

    test('do not take the cursor sequences with them', () {
      expect(Parser(saveCursor).matches.first.entity, const SaveCursor());
      expect(Parser(restoreCursor).matches.first.entity, const RestoreCursor());
    });

    test('are counted as escape codes, not as text', () {
      expect('a${RIS}b'.ansiRemoveEscapeCodes(), 'ab');
      expect(Parser('a${RIS}b').length, 2);
    });

    test('resetTerminal is the ready-to-use name of RIS', () {
      expect(resetTerminal, RIS);
    });
  });

  group('a broken ESC:', () {
    test('is not left in the text', () {
      expect('a\x1B'.ansiRemoveEscapeCodes(), 'a');
      expect('\x1B\x1B'.ansiRemoveEscapeCodes(), '');
      expect('a\x1B\nb'.ansiRemoveEscapeCodes(), 'a\nb');
    });
  });
}
