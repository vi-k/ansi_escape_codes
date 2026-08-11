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
  'aa',
  '',
];

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
                ? parser.insertAfter(pos, 'X')
                : parser.insertBefore(pos, 'X');
          } on UnfinishedSequenceException {
            continue;
          }

          expect(
            Parser(result).removeAll(),
            '${plain.substring(0, pos)}X${plain.substring(pos)}',
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
                ? parser.insertAfter(pos, 'X')
                : parser.insertBefore(pos, 'X');
          } on UnfinishedSequenceException {
            continue;
          }

          expect(
            result.replaceFirst('X', ''),
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
      () => Parser('aa\x1B[31').insertAfter(5, 'X'),
      throwsRangeError,
      reason: 'the plain text is four characters long, and asking past it is '
          "the caller's mistake rather than the input's",
    );
    expect(() => Parser('aa\x1B[31').insertBefore(-1, 'X'), throwsRangeError);
  });
}
