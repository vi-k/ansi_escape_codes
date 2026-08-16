import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// `0x20` and `0x2F` name themselves rather than being written as bytes: the
/// two ends of the intermediate range are the whole point of the group below,
/// and a test that says `String.fromCharCode(0x20)` where it means the first
/// of them reads as an arbitrary number.
const _firstIntermediate = 0x20; // SP
const _lastIntermediate = 0x2F; // /

void main() {
  group('the ends of the intermediate range:', () {
    // Both of these survived a mutation with the whole suite green: the
    // corpus ran through the middle of the range and never touched either
    // end. Narrowing `>= 0x20` or `<= 0x2F` makes the parser call `ESC SP`
    // or `ESC /` finished, and then `insertAfter` writes the caller's text
    // where the sequence's own final byte would go --- the terminal swallows
    // it and does whatever the sequence then spells --- while `substring`
    // stops supplying the terminator and lets the slice run into whatever
    // is printed after it.
    for (var byte = _firstIntermediate; byte <= _lastIntermediate; byte++) {
      final code = '$ESC${String.fromCharCode(byte)}';
      final name = '0x${byte.toRadixString(16).padLeft(2, '0')}';

      test('ESC on $name is a sequence still waiting for its ending', () {
        expect(
          Parser('a$code').substring(0),
          'a$code$ST',
          reason: '$name: a slice ends it, or it reads what follows the '
              'slice as its own',
        );
        expect(
          Parser('a$code').insertAfter(1, 'X'),
          'aX$code',
          reason: '$name: there is no place behind it to insert at — the '
              'byte that would end it has not been written',
        );
        expect(Parser('a$code').insertBefore(1, 'X'), 'aX$code', reason: name);
      });
    }

    for (final byte in [0x30, 0x31, 0x37, 0x63, 0x7E]) {
      final code = '$ESC${String.fromCharCode(byte)}';
      final name = '0x${byte.toRadixString(16).padLeft(2, '0')}';

      test('ESC on $name is a sequence that has ended', () {
        expect(
          Parser('a$code').substring(0),
          'a$code',
          reason: '$name: nothing is owed at the end of the slice',
        );
        expect(
          Parser('a$code').insertAfter(1, 'X'),
          'a${code}X',
          reason: '$name: the place behind it is a place to insert at',
        );
        expect(Parser('a$code').insertBefore(1, 'X'), 'aX$code', reason: name);
      });
    }

    test('and a byte below the range leaves the ESC bare', () {
      // `0x1F` cannot be part of any escape sequence, so the `ESC` stands
      // alone and unfinished and the byte behind it is text: the slice ends
      // the `ESC` in front of that text rather than carrying the byte along
      // with it.
      const input = 'a$ESC\x1F';

      expect(Parser(input).removeAll(), 'a\x1F');
      expect(Parser(input).substring(0), 'a$ESC$ST\x1F');
      expect(Parser(input).insertAfter(1, 'X'), 'aX$ESC\x1F');
      expect(Parser(input).insertBefore(1, 'X'), 'aX$ESC\x1F');
    });
  });

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
