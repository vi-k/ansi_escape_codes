import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Inputs whose tails a terminal reads differently from the way the parser
/// hands them back, and ordinary ones beside them for company.
const _inputs = <String>[
  'aa\x1B]0;title',
  'aa\x1B]8;;http://a/',
  'aa\x1B',
  'aa\x1B[',
  'aa\x1B[31',
  'aa\x1B(',
  'aa\x1B#',
  'aa\x1B[31\x1B[0m',
  'aa\x1B[31\x1B[0mcc',
  'aa\x1B]0;t\x1B\\',
  'aa\x1B]0;t\x1B7bb',
  'aa\x1B[31bb',
  'aa\x1B[31m bb \x1B[0m',
  // Two unfinished sequences in a row: the seam belongs in front of both of
  // them rather than in the gap between them.
  'aa\x1B]0;t\x1B[31',
  'aa\x1BPpay\x1B[31',
  'aa\x1BPpay\x1B',
  'aa\x1B\x1B[31',
  'aa\x1B(\x1B[31',
  // A run longer than two.
  'aa\x1BPpay\x1B(\x1B[31',
  // A finished code breaks the run, and the insertion behind it is right
  // already and has to stay where it is.
  'aa\x1BPpay\x1B(B\x1B[31',
  // Two runs with a piece of text between them: a CSI with no final byte
  // hands its parameters back as text, which is the one way a piece of text
  // can stand behind a code that never finished. The run behind the text is
  // its own, and an insertion aimed at the end of the text goes in front of
  // the finished code that follows it and no further back.
  'aa\x1B[31\x1B(B\x1BPpay\x1B',
  // And the same two runs with nothing finished between them. There the run
  // behind the text begins inside the CSI in front of it — the text is that
  // CSI's parameters, and the place before the run is the final byte it is
  // waiting for — so every position at the end of the parameters is owed a
  // refusal rather than an answer, from both insertions.
  'aa\x1B[31\x1BPpay\x1B',
  'aa\x1B[31\x1B[31',
  'aa\x1B[31\x1B]8;;http://u',
  'aa\x1B(B\x1B[31\x1B',
  // And the text behind a code that never finished is not always parameters:
  // a byte no sequence can be built from — a LF, a letter outside ASCII —
  // leaves the code waiting and comes back as text all the same.
  'aa\x1B\n\x1BPpay\x1B',
  'aa\x1B(я\x1B[31',
  // More than one sequence waiting in the same stretch.
  'aa\x1B[31\x1B[32\x1BPpay\x1B',
  'aa\x1B]0;t\x1B[31\x1B',
  'aa',
  '',
];

/// The text these tests insert.
///
/// Both of them read the marker back out of the answer — one out of the plain
/// text, the other by taking it out of the string again — so it may not be a
/// character the inputs are built from. `X` is the byte that opens an `SOS`,
/// and behind an `ESC` it stops being a marker and becomes part of a control
/// string that swallows the rest; `@` opens nothing.
const _marker = '@';

void main() {
  test('an insertion either lands where it was asked or is refused', () {
    for (final input in _inputs) {
      final plain = Parser(input).removeAll();
      for (var pos = 0; pos <= plain.length; pos++) {
        for (final after in [true, false]) {
          final parser = Parser(input);
          final String result;
          try {
            result = after
                ? parser.insertAfter(pos, _marker)
                : parser.insertBefore(pos, _marker);
          } on UnfinishedSequenceException {
            continue;
          }

          expect(
            Parser(result).removeAll(),
            '${plain.substring(0, pos)}$_marker${plain.substring(pos)}',
            reason: 'input ${input.ansiShowEscapeSequences()}, pos $pos, '
                'after: $after',
          );
        }
      }
    }
  });

  test('and what it hands back is the input with the text put in', () {
    for (final input in _inputs) {
      final plain = Parser(input).removeAll();
      for (var pos = 0; pos <= plain.length; pos++) {
        for (final after in [true, false]) {
          final parser = Parser(input);
          final String result;
          try {
            result = after
                ? parser.insertAfter(pos, _marker)
                : parser.insertBefore(pos, _marker);
          } on UnfinishedSequenceException {
            continue;
          }

          expect(
            result.replaceFirst(_marker, ''),
            input,
            reason: 'no byte of the input is invented or dropped: '
                '${input.ansiShowEscapeSequences()}, pos $pos, after: $after',
          );
        }
      }
    }
  });

  test('a position outside the plain text is still a RangeError', () {
    expect(
      () => Parser('aa\x1B[31').insertAfter(5, _marker),
      throwsRangeError,
      reason: 'the plain text is four characters long, and asking past it is '
          "the caller's mistake rather than the input's",
    );
    expect(
      () => Parser('aa\x1B[31').insertBefore(-1, _marker),
      throwsRangeError,
    );
  });
}
