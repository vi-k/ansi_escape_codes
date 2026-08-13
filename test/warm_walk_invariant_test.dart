import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Inputs with escape codes standing behind the last piece of text, which is
/// what takes a walk past the piece it stands in: a slice reads on to the end
/// of the pieces, and `stateAt` asked about the position behind the text
/// walks the rest of the string looking for one more piece. Ordinary strings
/// stand beside them for company.
const _inputs = <String>[
  'aa\x1B[31\x1B[31\x1BPpay\x1B',
  '\x1B[31\x1B]0;title',
  'aa\x1B[31\x1B]0;title',
  'aa\x1B]0;title',
  'aa\x1B',
  'aa\x1B[31',
  'aa\x1B[31mbb',
  'aa\x1B[31m\x1B[0mbb\x1B[',
  'aa\x1BPpay\x1B[31cc',
  'aa\x1B[31cc\x1BPpay',
  'aa\x1B[31\x1B(Bcc\x1B[',
  'aa\x1B]0;title\x1B(Bcc',
  'aa\x1B\n\x1BPpay\x1B',
  'aa\x1B(я\x1B[31',
  'aa\x1B[31m\x1B]8;;http://u/\x1B[',
  'aa\x1B]8;;http://o/\x1B\\\x1BPpay',
  'aa\x1B]8;;http://u/\x1B\\bb\x1B]8;;\x1B\\cc',
  '\x1BPpay\x1Baa\x1B[31',
  'aabb',
  '',
];

/// The text the insertions put in.
///
/// `X` opens an `SOS` where it lands behind an `ESC`, and would fuse with the
/// inputs instead of marking a place in them; `@` opens nothing. See
/// `insert_unfinished_invariant_test.dart`, which says the whole of it.
const _marker = '@';

/// The questions a parser is asked about a position.
const _questions = <String>[
  'substring',
  'substring maxLength: 1',
  'substring close: false',
  'stateAt',
  'linkAt',
  'insertBefore',
  'insertAfter',
];

/// The questions that leave a walk behind for the next one to pick up.
const _warmups = <String>[
  'substring',
  'substring maxLength: 1',
  'stateAt',
  'linkAt',
];

/// The answer [parser] gives to [question] at [pos], or the refusal it gives
/// instead, in a form two parsers can be compared and told apart by.
///
/// Strings are read out as code units on purpose: a raw C1 byte is one a
/// terminal does not draw, and a failure printing the strings as they are
/// would show two different answers looking the same. Links are read out by
/// their bytes for the same reason — two links on one url are told apart by
/// the parameters and the terminator they were written with, and by nothing
/// else.
///
/// Every question answers every position from zero to the length of the plain
/// text, so nothing here is caught but the refusal: probed over the corpus
/// below, 623 questions, not one [RangeError]. One thrown here would be news
/// worth the failure it makes.
String _ask(String question, Parser parser, int pos) {
  try {
    return switch (question) {
      'substring' => 'ok ${parser.substring(pos).codeUnits}',
      'substring maxLength: 1' =>
        'ok ${parser.substring(pos, maxLength: 1).codeUnits}',
      'substring close: false' =>
        'ok ${parser.substring(pos, close: false).codeUnits}',
      'stateAt' => 'ok ${parser.stateAt(pos)}',
      'linkAt' => 'ok ${parser.linkAt(pos)?.string.codeUnits}',
      'insertBefore' => 'ok ${parser.insertBefore(pos, _marker).codeUnits}',
      'insertAfter' => 'ok ${parser.insertAfter(pos, _marker).codeUnits}',
      _ => throw StateError('unknown question: $question'),
    };
  } on UnfinishedSequenceException catch (e) {
    return 'refused at ${e.offset}';
  }
}

void main() {
  test('a warmed parser answers as a fresh one would', () {
    for (final input in _inputs) {
      final plain = Parser(input).removeAll();

      for (final question in _questions) {
        for (var pos = 0; pos <= plain.length; pos++) {
          final fresh = _ask(question, Parser(input), pos);

          for (final warmup in _warmups) {
            for (var at = 0; at <= plain.length; at++) {
              final parser = Parser(input);
              _ask(warmup, parser, at);

              expect(
                _ask(question, parser, pos),
                fresh,
                reason: 'input ${input.ansiShowEscapeSequences()}: '
                    '$question at $pos, asked after $warmup at $at',
              );
            }
          }
        }
      }
    }
  });
}
