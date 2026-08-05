import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Inputs the parser would break on if it cut any corners: truncated
/// sequences, surrogate pairs, eight-bit C1, control bytes.
const adversarialInputs = <String>[
  '',
  'plain text, no codes at all',
  '\x1B',
  'ends with a lone escape\x1B',
  '\x1B[',
  'a\x1B[31',
  'a\x1B[31;',
  '\x1B[31mred\x1B[0m',
  '\x1B[999999999999999999999m',
  '\x1B]8;;http://example.com\x1B\\link\x1B]8;;\x1B\\',
  '\x1B]0;title without terminator',
  '\x1B]0;title\x07',
  '\x1B[38:2::255:0:0mcolon rgb\x1B[m',
  '\x1B[38;5mtruncated 256\x1B[m',
  '\x1B[38;2;1;2mtruncated rgb\x1B[m',
  '\x9B31mnot a CSI in a Dart string',
  'emoji \u{1F600} around \x1B[1m codes \u{1D11E}\x1B[m',
  'combining á\x1B[4mb́\x1B[24m',
  '\x00\x07\x7F control bytes\t\r\n',
  'crlf\r\n\x1B[31mline\x1B[m\r\n',
  '\x1B7saved\x1B8restored',
  '\x1B(Bcharset',
];

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
