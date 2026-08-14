import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

const _inputs = <({String bytes, String plain})>[
  (bytes: 'abcdef', plain: 'abcdef'),
  (bytes: '${fgRed}abc${reset}def', plain: 'abcdef'),
  (
    bytes: 'ab${linkOpen}https://a/$linkTextOpen'
        'cd${linkClose}ef',
    plain: 'abcdef',
  ),
];

const _insertions = <({String bytes, String plain})>[
  (bytes: '', plain: ''),
  (bytes: 'plain', plain: 'plain'),
  (bytes: '\x1B]0;t', plain: ''),
  (bytes: '\x1B', plain: ''),
  (bytes: '\x1B[31', plain: '31'),
  (bytes: '\x1B(', plain: ''),
  (bytes: '\x1B]0;t\x1B[31', plain: '31'),
  (bytes: '\x1B[31\x1B[0m', plain: '31'),
  (bytes: '\x1B]0;t\x1B[0mword', plain: 'word'),
];

void main() {
  test('insertion preserves the parser model of all three texts', () {
    for (final input in _inputs) {
      for (var pos = 0; pos <= input.plain.length; pos++) {
        for (final insertion in _insertions) {
          final expected = '${input.plain.substring(0, pos)}'
              '${insertion.plain}${input.plain.substring(pos)}';

          for (final after in [false, true]) {
            final parser = Parser(input.bytes);
            final result = after
                ? parser.insertAfter(pos, insertion.bytes)
                : parser.insertBefore(pos, insertion.bytes);

            expect(
              Parser(result).removeAll(),
              expected,
              reason: 'input ${input.bytes.ansiShowEscapeSequences()}, '
                  'insertion ${insertion.bytes.ansiShowEscapeSequences()}, '
                  'pos $pos, after: $after',
            );
          }
        }
      }
    }
  });
}
