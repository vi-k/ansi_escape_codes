import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

import 'adversarial_inputs.dart';

/// What each adversarial input shows, written out by hand.
///
/// The differential tests over this corpus --- `round_trip_invariant_test`,
/// `remove_agrees_with_parser_test`, `has_agrees_with_parser_test` --- compare
/// the parser with the extensions, and both read the same `escapeCodesRe`. A
/// defect in the pattern itself is therefore agreed upon by both sides and
/// invisible to all of them: the wrong class of bytes, an alternative lost,
/// the wrong greed in `oscPattern`. This list is the outside opinion they
/// lack.
///
/// Derived from the rules rather than from a run of the code, which is the
/// only thing that makes it worth having:
///
/// * a sequence the parser can finish is taken out whole;
/// * `ESC [` with no final byte is taken out and its parameter bytes stay,
///   as text --- the parser's documented reading, and not what a terminal
///   would do with them;
/// * a control string with no terminator runs to the next `ESC` or to the end
///   of the text, and all of it goes;
/// * the eight-bit `C1` are not codes here, so `0x9B` stays as it stands.
const _plainText = <String>[
  '',
  'plain text, no codes at all',
  '',
  'ends with a lone escape',
  '',
  'a31',
  'a31;',
  'red',
  '',
  'link',
  '',
  '',
  'colon rgb',
  'truncated 256',
  'truncated rgb',
  '\x9B31mnot a CSI in a Dart string',
  '\x9B31m eight-bit behind a real CSI',
  'emoji \u{1F600} around  codes \u{1D11E}',
  // The corpus carries a precomposed U+00E1 and then a `b` with a combining
  // U+0301 behind it; only the two SGRs between them come out.
  'combining \u00E1b\u0301',
  '\x00\x07\x7F control bytes\t\r\n',
  'crlf\r\nline\r\n',
  'savedrestored',
  'charset',
  '31]',
  '31m!',
  'B!',
  '0123456789Zrest',
  '3tail',
  'text  more text',
];

void main() {
  test('the corpus and the answers to it stay the same length', () {
    expect(
      _plainText,
      hasLength(adversarialInputs.length),
      reason: 'an input added without an answer would be checked by the '
          'differential tests alone, which is the gap this file is for',
    );
  });

  group('what each adversarial input shows:', () {
    for (final (i, input) in adversarialInputs.indexed) {
      test('input #$i', () {
        final want = _plainText[i];

        expect(
          Parser(input).removeAll(),
          want,
          reason: 'the parser, against an answer written by hand: '
              '${input.ansiShowEscapeSequences()}',
        );
        expect(
          input.ansiRemoveEscapeCodes(),
          want,
          reason: 'and the extension, which reads the same pattern and so '
              'could only ever agree with the parser',
        );
        expect(
          Parser(input).length,
          want.length,
          reason: 'the length is the same answer counted rather than built',
        );
      });
    }
  });
}
