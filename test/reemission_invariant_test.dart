import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

import 'adversarial_inputs.dart';

/// What the four outputs promise, over the corpus the parse is run on.
///
/// `round_trip_invariant_test.dart` asks whether a string is *read* back as
/// it came. This asks the other half: whether what is *written* back shows
/// the same text. For a long time nothing asked it, and four outputs were
/// swallowing characters — a code the parser could not finish went out with
/// no `ESC` behind it once the `SGR` that had been holding it off the text
/// was rewritten away. See `docs/records/2026-08-13[6]`.
void main() {
  group('what removeAll calls text is what comes out of', () {
    for (final (i, input) in adversarialInputs.indexed) {
      final want = Parser(input).removeAll();

      test('optimize, input #$i', () {
        expect(Parser(Parser(input).optimize()).removeAll(), want);
        expect(
          Parser(Parser(input).optimize(close: false)).removeAll(),
          want,
          reason: 'a string left open shows what a closed one shows',
        );
      });

      test('substring, input #$i', () {
        expect(Parser(Parser(input).substring(0)).removeAll(), want);
        expect(
          Parser(Parser(input).substring(0, close: false)).removeAll(),
          want,
        );
      });

      test('the printers, input #$i', () {
        expect(
          Parser(Printer(output: (_) {}).prepare(input)).removeAll(),
          want,
        );

        final sink = StringBuffer();
        SinkPrinter(sink)
          ..write(input)
          ..writeln();
        expect(
          Parser(sink.toString()).removeAll(),
          '$want\n',
          reason: 'a sink shows what a line printer shows, once the line is '
              'ended — a write that has not ended one holds back the sequence '
              'it could not finish, for the write that finishes it',
        );
      });

      test('the stacked pair, input #$i', () {
        expect(Parser(StackedParser(input).optimize()).removeAll(), want);
        expect(Parser(StackedParser(input).substring(0)).removeAll(), want);
        expect(
          Parser(StackedPrinter(output: (_) {}).prepare(input)).removeAll(),
          want,
        );
      });

      test('and writing it again changes nothing, input #$i', () {
        // A guard against a repair that only holds the first time: an output
        // fed back in is an input like any other, and the second pass must
        // find nothing left to do.
        final once = Parser(input).optimize();
        expect(Parser(once).optimize(), once);
      });
    }
  });

  group('an unfinished code keeps its hold on what follows:', () {
    test('a bare ESC is given an ST where text would be eaten', () {
      // The SGR is a reset from the default, so its transition is empty and
      // `optimize` writes nothing for it — which is what used to leave the
      // bare ESC standing against the text.
      expect(Parser('\x1B\x1B[0m31]').optimize(close: false), '\x1B\x1B\\31]');
    });

    test('and keeps its bytes where an ESC follows anyway', () {
      // Nothing is supplied here: the transition is not empty, so what
      // follows begins with an ESC of its own and the input goes out as it
      // came.
      expect(
        Parser('\x1B\x1B[31mabc').optimize(close: false),
        '\x1B\x1B[31mabc',
      );
    });

    test('a truncated CSI is held the same way', () {
      expect(
        Parser('\x1B[3\x1B[0m1m!').optimize(close: false),
        '\x1B[\x1B\\31m!',
      );
    });

    test('an ESC on an intermediate byte too', () {
      expect(Parser('\x1B(\x1B[0mB!').optimize(close: false), '\x1B(\x1B\\B!');
    });

    test('a control string is still given its own terminator', () {
      // The one shape that was guarded before, unchanged by the widening.
      expect(
        Parser('\x1B]0;t\x1B[0mabc').optimize(close: false),
        '\x1B]0;t\x1B\\abc',
      );
    });
  });
}
