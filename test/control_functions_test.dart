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
      expect(Parser('\x1B[1 q').matches.first.entity, isA<CsiPrivate>());

      // Private through its parameters rather than its final bytes.
      expect(Parser('\x1B[?25h').matches.first.entity, isA<CsiPrivate>());

      // Final bytes that name nothing at all.
      expect(Parser('\x1B[1!p').matches.first.entity, isA<CsiUnknown>());
    });

    test('gives nothing for a code that names no function', () {
      expect(ControlSequencesFunctions.byCode(''), isNull);
      expect(ControlSequencesFunctions.byCode('AB'), isNull);
      expect(ControlSequencesFunctions.byCode('\x00'), isNull);
    });
  });
}
