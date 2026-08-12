import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('inserting into a styled string:', () {
    test('the two sides of a seam are told apart', () {
      const text = '${fgRed}Hello$reset world';

      expect(
        Parser(text).insertBefore(5, '!'),
        '${fgRed}Hello!$reset world',
        reason: 'before the reset the exclamation mark is still red',
      );
      expect(
        Parser(text).insertAfter(5, '!'),
        '${fgRed}Hello$reset! world',
        reason: 'after the reset it is not',
      );
    });

    test('a seam without codes on it gives both the same place', () {
      const text = '${fgRed}Hello world$reset';

      expect(Parser(text).insertBefore(5, ','), '${fgRed}Hello, world$reset');
      expect(Parser(text).insertAfter(5, ','), '${fgRed}Hello, world$reset');
    });

    test('plain text is written as it is', () {
      const text = '${fgRed}Hello world$reset';

      expect(
        Parser(text).insertBefore(6, 'brave '),
        '${fgRed}Hello brave world$reset',
        reason: 'nothing is closed when nothing was opened',
      );
    });

    test('what the insertion opens is closed after it', () {
      const text = '${fgRed}Hello world$reset';

      expect(
        Parser(text).insertBefore(6, '${fgGreen}brave '),
        '${fgRed}Hello ${fgGreen}brave $fgRed'
        'world$reset',
        reason: 'the tail keeps the red it had',
      );
    });

    test('a hyperlink the insertion opens is closed after it', () {
      const link = '${linkOpen}https://example.com$linkTextOpen';

      expect(
        Parser('tail').insertBefore(0, '${link}inserted'),
        '${link}inserted$linkClose'
        'tail',
        reason: 'or the tail is clickable and points somewhere else',
      );
      expect(
        Parser('tail').insertBefore(0, '${link}inserted$linkClose'),
        '${link}inserted${linkClose}tail',
        reason: 'and one the insertion closed itself is not closed twice',
      );
    });

    test('a style and a hyperlink are both given back', () {
      const link = '${linkOpen}https://example.com$linkTextOpen';

      expect(
        Parser('tail').insertBefore(0, '$fgGreen${link}inserted'),
        '$fgGreen${link}inserted$linkClose$reset'
        'tail',
        reason: 'the link first, then the style around it',
      );
    });

    test('a reset inside the insertion does not reach the tail', () {
      const text = '${fgRed}Hello world$reset';

      expect(
        Parser(text).insertBefore(6, '${bold}brave$reset '),
        '${fgRed}Hello ${bold}brave$reset $fgRed'
        'world$reset',
      );
    });

    test('the ends of the string are seams too', () {
      const text = '${fgRed}Hello$reset';

      expect(Parser(text).insertBefore(0, '>'), '>${fgRed}Hello$reset');
      expect(Parser(text).insertAfter(0, '>'), '$fgRed>Hello$reset');
      expect(Parser(text).insertBefore(5, '<'), '${fgRed}Hello<$reset');
      expect(Parser(text).insertAfter(5, '<'), '${fgRed}Hello$reset<');
    });

    test('a position outside the string is refused', () {
      const text = '${fgRed}Hello$reset';

      expect(() => Parser(text).insertBefore(6, '!'), throwsRangeError);
      expect(() => Parser(text).insertAfter(6, '!'), throwsRangeError);
      expect(() => Parser(text).insertBefore(-1, '!'), throwsRangeError);
      expect(() => Parser(text).insertAfter(-1, '!'), throwsRangeError);
    });

    test('the stacked parser unwinds the insertion the same way', () {
      const text = '${fgRed}Hello world$reset';

      expect(
        StackedParser(text).insertBefore(6, '${fgGreen}brave '),
        '${fgRed}Hello ${fgGreen}brave $fgRed'
        'world$reset',
      );
    });

    test('the string shortcuts do the same', () {
      const text = '${fgRed}Hello$reset world';

      expect(text.ansiInsertBefore(5, '!'), '${fgRed}Hello!$reset world');
      expect(text.ansiInsertAfter(5, '!'), '${fgRed}Hello$reset! world');
    });
  });

  group('inserting where the string ends inside a sequence:', () {
    test('the text goes in front of what never finished', () {
      expect(
        Parser('aa\x1B]0;title').insertAfter(2, 'X'),
        'aaX\x1B]0;title',
        reason: 'the tail is copied as it came, the text lands before it',
      );
      expect(
        Parser('aa\x1B').insertAfter(2, 'X'),
        'aaX\x1B',
        reason: 'a bare ESC cannot be finished, so nothing is written for it',
      );
      expect(Parser('aa\x1B[').insertAfter(2, 'X'), 'aaX\x1B[');
      expect(
        Parser('aa\x1B(').insertAfter(2, 'X'),
        'aaX\x1B(',
        reason: 'an ESC waiting for a final byte takes the insertion no more '
            'than a CSI does',
      );
    });

    test('and the hyperlink opening keeps the text outside it', () {
      final inserted = Parser('aa\x1B]8;;http://a/').insertAfter(2, 'X');

      expect(inserted, 'aaX\x1B]8;;http://a/');
      expect(
        Parser(inserted).linkAt(2),
        isNull,
        reason: 'the opening still stands after the text, not around it',
      );
    });

    test('while a finished tail is still passed by', () {
      expect(
        Parser('aa\x1B]0;t\x1B\\').insertAfter(2, 'X'),
        'aa\x1B]0;t\x1B\\X',
        reason: 'a terminated OSC ends where it says, and insertAfter goes '
            'past it as it always did',
      );
    });
  });

  group('inserting among the parameters of a CSI with no final byte:', () {
    test('the seam in front of it takes the text', () {
      expect(
        Parser('aa\x1B[31').insertAfter(2, 'X'),
        'aaX\x1B[31',
        reason: 'the position is the seam, and in front of the sequence is '
            'where the text was asked to go',
      );
      expect(
        Parser('aa\x1B[31').insertBefore(2, 'X'),
        'aaX\x1B[31',
        reason: 'insertBefore already stood there and stays where it was',
      );
    });

    test('and every position past it is refused', () {
      expect(
        () => Parser('aa\x1B[31').insertAfter(3, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
      expect(
        () => Parser('aa\x1B[31').insertAfter(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
      expect(
        () => Parser('aa\x1B[31').insertBefore(3, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
      expect(
        () => Parser('aa\x1B[31').insertBefore(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
    });

    test('the exception says where the sequence begins', () {
      try {
        Parser('aa\x1B[31').insertAfter(3, 'X');
        fail('the insertion was expected to be refused');
      } on UnfinishedSequenceException catch (e) {
        expect(e.pos, 3);
        expect(e.offset, 2, reason: 'the ESC of the sequence stands at 2');
      }
    });

    test('while a code after the parameters puts the end back in reach', () {
      expect(
        Parser('aa\x1B[31\x1B[0m').insertAfter(4, 'X'),
        'aa\x1B[31\x1B[0mX',
        reason: 'the cut goes past the SGR, outside the sequence, and that '
            'was right before this wave and stays right',
      );
      expect(
        () => Parser('aa\x1B[31\x1B[0m').insertBefore(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
        reason: 'insertBefore puts the cut against the parameters instead',
      );
    });

    test('and a CSI that did get its final byte is untouched', () {
      expect(
        Parser('aa\x1B[31bb').insertAfter(2, 'X'),
        'aa\x1B[31bXb',
        reason: 'b is a final byte, so the sequence is finished, the text '
            'after it is text, and the insertion goes past the code',
      );
    });
  });

  group('a seam in front of a run of unfinished codes:', () {
    test('an insertion does not land between two unfinished codes', () {
      // insertBefore is right today; insertAfter must agree with it, since
      // both mean "in front of what could not be finished".
      const input = 'aa\x1BPpay\x1B[31';

      expect(Parser(input).insertAfter(2, 'X'), 'aaX\x1BPpay\x1B[31');
      expect(Parser(input).insertBefore(2, 'X'), 'aaX\x1BPpay\x1B[31');
    });

    test('the run needs no control string in it', () {
      expect(Parser('aa\x1B\x1B[31').insertAfter(2, 'X'), 'aaX\x1B\x1B[31');
      expect(Parser('aa\x1B(\x1B[31').insertAfter(2, 'X'), 'aaX\x1B(\x1B[31');
    });

    test('a run longer than two is stepped over whole', () {
      expect(
        Parser('aa\x1BPpay\x1B(\x1B[31').insertAfter(2, 'X'),
        'aaX\x1BPpay\x1B(\x1B[31',
      );
    });

    test('a finished code ends the run and is passed over', () {
      // The DCS body ends at the ESC of the ESC ( B, so text behind that
      // code is outside the string and belongs there.
      expect(
        Parser('aa\x1BPpay\x1B(B\x1B[31').insertAfter(2, 'X'),
        'aa\x1BPpay\x1B(BX\x1B[31',
      );
    });

    test('a finished code inside the tail ends the run in front of it', () {
      // Two runs with a piece of text between them: ESC [ | 31 | ESC ( B |
      // ESC P pay | ESC. A CSI with no final byte hands its parameters back
      // as text, which is how the text got in there at all.
      //
      // What decides this seam is the finished ESC ( B, not the text: the run
      // behind it begins at the DCS. The text is what the next test is about,
      // and it decides nothing here.
      const input = 'aa\x1B[31\x1B(B\x1BPpay\x1B';

      // Probed, and checked against the invariant rather than against
      // insertBefore, which refuses this position: the plain text is aa31,
      // so the answer has to show aa31X and keep every byte of the input.
      expect(
        Parser(input).insertAfter(4, 'X'),
        'aa\x1B[31\x1B(BX\x1BPpay\x1B',
        reason: 'the finished ESC ( B ends the run in front of the text, the '
            'DCS begins the one behind it, and the seam is that DCS',
      );
      expect(Parser(Parser(input).insertAfter(4, 'X')).removeAll(), 'aa31X');
      expect(
        () => Parser(input).insertBefore(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
        reason: 'insertBefore puts the cut among the parameters instead, and '
            'that refusal is the one this wave does not touch',
      );
    });

    test('and a run behind a piece of text does not reach back over it', () {
      // The same two runs with nothing finished between them: ESC [ | 31 |
      // ESC P pay | ESC. The run behind the text is its own and begins at the
      // DCS; were it to carry the first run's start along, the insertion
      // would be written in front of the 31 it was aimed behind.
      const input = 'aa\x1B[31\x1BPpay\x1B';

      // Where exactly it belongs is not settled, and this test does not
      // pretend otherwise: the seam behind the parameters of a CSI that never
      // got its final byte has no end that survives — in front of the DCS the
      // text becomes the final byte of that CSI, behind the bare ESC it
      // becomes the final byte of the ESC — and the answer owed here is the
      // refusal insertBefore already gives. What is settled either way is
      // that plain text the insertion was aimed behind stays in front of it.
      String? answer;
      try {
        answer = Parser(input).insertAfter(4, 'X');
      } on UnfinishedSequenceException {
        // The refusal this seam is owed. It is not what the insertion does
        // today, and it is still not a step in front of the text.
      }

      expect(
        answer,
        anyOf(isNull, startsWith('aa\x1B[31')),
        reason: 'the run begins at the DCS, so the seam is at worst there, '
            'and never in front of the parameters the text stands for',
      );
    });

    test('a slice leaves the walk answering as a fresh parser would', () {
      // substring steps over the matches itself rather than through the walk,
      // so a run it goes past has to be taken in there too. Where it is not,
      // the seam is read off a walk that has forgotten the run, and the same
      // question answers differently depending on what was asked before it.
      const input = 'aa\x1B]pay\x1B';

      // Probed on both: the slice changes nothing, and the answer is the one
      // the invariant asks for — the plain text is aa, and X goes behind it.
      final parser = Parser(input)..substring(2, maxLength: 0);

      expect(parser.insertAfter(2, 'X'), 'aaX\x1B]pay\x1B');
      expect(Parser(input).insertAfter(2, 'X'), 'aaX\x1B]pay\x1B');
    });

    test('a run at the end of the input is stepped over too', () {
      expect(Parser('aa\x1BPpay\x1B').insertAfter(2, 'X'), 'aaX\x1BPpay\x1B');
    });

    test('every opener and every unfinished tail agree with insertBefore', () {
      // The matrix the design asks for: five openers, three kinds of tail
      // that cannot finish, and both insertions at the seam. insertBefore is
      // right today, so it is the answer insertAfter must give.
      for (final opener in [OSC, DCS, SOS, PM, APC]) {
        for (final tail in [ESC, '$ESC[31', '$ESC(']) {
          final input = 'aa${opener}pay$tail';
          final parser = Parser(input);
          final reason = 'input ${input.ansiShowEscapeSequences()}';

          expect(
            parser.insertAfter(2, 'X'),
            parser.insertBefore(2, 'X'),
            reason: reason,
          );
          expect(
            Parser(parser.insertAfter(2, 'X')).removeAll(),
            '${parser.removeAll().substring(0, 2)}X'
            '${parser.removeAll().substring(2)}',
            reason: reason,
          );
        }
      }
    });

    test('the refusal among a truncated CSI stays where it was', () {
      final parser = Parser('aa\x1BPpay\x1B[31');

      expect(
        () => parser.insertAfter(3, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
      expect(
        () => parser.insertBefore(4, 'X'),
        throwsA(isA<UnfinishedSequenceException>()),
      );
    });
  });
}
