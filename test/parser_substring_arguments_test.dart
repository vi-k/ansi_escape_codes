import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The arguments [Parser.substring] refuses, and the one it used to.
///
/// `insertBefore`, `insertAfter`, `stateAt` and `linkAt` have had their
/// refusals held here since they were written; this one's were checked by
/// nothing, so a mutation to any of them would have lived. A caller catching
/// a `RangeError` is the reason it matters which one comes out.
void main() {
  group('substring refuses:', () {
    test('a negative start', () {
      expect(
        () => Parser('abc').substring(-1),
        throwsA(isA<RangeError>()),
      );
    });

    test('a negative maxLength', () {
      expect(
        () => Parser('abc').substring(0, maxLength: -1),
        throwsA(isA<RangeError>()),
      );
    });

    test('a start past the end of the plain text', () {
      expect(
        () => Parser('abc').substring(4),
        throwsA(isA<RangeError>()),
        reason: 'three characters, and the position after the last of them '
            'is the furthest a slice can begin',
      );
      expect(
        Parser('abc').substring(3),
        isEmpty,
        reason: 'that position itself is a slice of nothing, not a refusal',
      );
    });

    test('and counts the codes out of the length it measures against', () {
      expect(
        () => Parser('${fgRed}abc$reset').substring(4),
        throwsA(isA<RangeError>()),
        reason: 'the codes are not characters to begin a slice at',
      );
    });
  });

  group('substring takes the rest of the string:', () {
    // The largest int there is, spelt out rather than written down:
    // `avoid_js_rounded_ints` is on, and this is the value the sum of the
    // two arguments has to survive.
    final beyond = int.parse('9223372036854775807');

    test('for a maxLength larger than what is left', () {
      expect(Parser('abc').substring(0, maxLength: 100), 'abc');
      expect(Parser('abc').substring(1, maxLength: 100), 'bc');
    });

    test('for a maxLength no sum can hold', () {
      expect(
        Parser('abc').substring(0, maxLength: beyond),
        'abc',
        reason: 'from zero the sum does not overflow, and never did',
      );
      expect(
        Parser('abc').substring(1, maxLength: beyond),
        'bc',
        reason: 'from anywhere else it wraps round into the negatives, and a '
            'slice asking for everything was refused for asking too little',
      );
      expect(
        Parser('${fgRed}abc$reset').substring(1, maxLength: beyond),
        '${fgRed}bc$reset',
      );
    });
  });
}
