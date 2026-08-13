import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('looking a control sequence up by its code:', () {
    test('finds every named one, and only those', () {
      var found = 0;

      for (final function in ControlSequencesFunctions.values) {
        final byCode = ControlSequencesFunctions.byCode(function.code);

        if (function.isPrivate || function.isReserved) {
          // A code of this kind belongs to no named function, though another
          // function may well answer to the same one.
          expect(byCode, isNot(function), reason: function.name);
        } else if (byCode != null) {
          expect(byCode, function, reason: function.name);
          found++;
        }
      }

      expect(found, greaterThan(90));
    });

    test('a sequence kept for private use is not an unknown one', () {
      // DECSCUSR, the shape of the cursor: CSI Ps SP q.
      expect(Parser('\x1B[1 q').pieces.first.entity, isA<CsiPrivate>());

      // Private through its parameters rather than its final bytes. The four
      // modes this package writes itself have names of their own — see
      // ShowCursor and the three beside it — and this is not one of them.
      expect(Parser('\x1B[?7h').pieces.first.entity, isA<CsiPrivate>());

      // Final bytes that name nothing at all.
      expect(Parser('\x1B[1!p').pieces.first.entity, isA<CsiUnknown>());
    });

    test('finds a C0 control by the byte it is', () {
      expect(ControlFunctionsC0.byCode('\n'), ControlFunctionsC0.LF);
      expect(ControlFunctionsC0.byCode('\x1B'), ControlFunctionsC0.ESC);

      expect(ControlFunctionsC0.byCode(''), isNull);
      expect(ControlFunctionsC0.byCode('ab'), isNull, reason: 'one byte only');
      expect(
        ControlFunctionsC0.byCode('a'),
        isNull,
        reason: 'a printable character is no control',
      );
    });

    test('and says what kind a code is where it has no name of its own', () {
      expect(ControlSequencesFunctions.CUU.description, 'Cursor Up');
      expect(
        ControlSequencesFunctions.values
            .firstWhere((f) => f.isPrivate)
            .description,
        'Private',
      );
      expect(
        ControlSequencesFunctions.values
            .firstWhere((f) => f.isReserved)
            .description,
        'Reserved',
      );
    });

    test('finds a C1 function by the sequence it is written as', () {
      expect(ControlFunctionsC1.byCode('\x1B['), ControlFunctionsC1.CSI);
      expect(ControlFunctionsC1.byCode('\x1B]'), ControlFunctionsC1.OSC);
      expect(ControlFunctionsC1.byCode('\x1B\\'), ControlFunctionsC1.ST);
      expect(ControlFunctionsC1.byCode('\x1BN'), ControlFunctionsC1.SS2);
    });

    test('and gives nothing for a sequence that is no C1 function', () {
      expect(ControlFunctionsC1.byCode(''), isNull);
      expect(ControlFunctionsC1.byCode('\x1B'), isNull, reason: 'ESC alone');
      expect(
        ControlFunctionsC1.byCode('[['),
        isNull,
        reason: 'the first byte must be the ESC itself',
      );
      expect(
        ControlFunctionsC1.byCode('\x1B\x1B'),
        isNull,
        reason: '0x1B is below the 0x40 the C1 set starts at',
      );
      expect(
        ControlFunctionsC1.byCode('\x1Bz'),
        isNull,
        reason: 'and 0x7A is above the 0x5F it ends at',
      );
    });

    test('gives nothing for a code that names no function', () {
      expect(ControlSequencesFunctions.byCode(''), isNull);
      expect(ControlSequencesFunctions.byCode('AB'), isNull);
      expect(ControlSequencesFunctions.byCode('\x00'), isNull);
    });
  });
}
