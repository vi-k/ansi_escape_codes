import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

import 'adversarial_inputs.dart';

void main() {
  group('the pieces of a parsed string give the string back', () {
    for (final (i, input) in adversarialInputs.indexed) {
      test('input #$i', () {
        final buf = StringBuffer();
        for (final m in Parser(input).matches) {
          buf.write(m.entity.string);
        }

        expect(
          buf.toString(),
          input,
          reason: 'concatenated entities must equal the input byte for byte',
        );
      });

      test('input #$i, stacked', () {
        final buf = StringBuffer();
        for (final m in StackedParser(input).matches) {
          buf.write(m.entity.string);
        }

        expect(buf.toString(), input);
      });

      test('input #$i, removeAll agrees with the extension', () {
        expect(
          Parser(input).removeAll(),
          input.ansiRemoveEscapeCodes(),
          reason: 'the parser and the regex must drop the same bytes',
        );
      });
    }
  });
}
