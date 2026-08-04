import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

bool _isHigh(int u) => (u & 0xFC00) == 0xD800;
bool _isLow(int u) => (u & 0xFC00) == 0xDC00;

/// Whether every surrogate in [s] is half of a whole pair.
bool _isValidUtf16(String s) {
  for (var i = 0; i < s.length; i++) {
    final u = s.codeUnitAt(i);
    if (_isHigh(u)) {
      if (i + 1 == s.length || !_isLow(s.codeUnitAt(i + 1))) {
        return false;
      }
      i++;
    } else if (_isLow(u)) {
      return false;
    }
  }

  return true;
}

/// Where the insertion is expected to land in the plain text: at [pos], or
/// shifted off the middle of a pair towards its edge.
int _landing(String plain, int pos, {required bool after}) {
  if (pos > 0 &&
      pos < plain.length &&
      _isHigh(plain.codeUnitAt(pos - 1)) &&
      _isLow(plain.codeUnitAt(pos))) {
    return after ? pos + 1 : pos - 1;
  }

  return pos;
}

void main() {
  group('an insertion aimed inside a surrogate pair:', () {
    test('insertBefore shifts to the front of the pair', () {
      expect(Parser('𝄞abc').insertBefore(1, 'X'), 'X𝄞abc');
    });

    test('insertAfter shifts past the pair', () {
      expect(Parser('𝄞abc').insertAfter(1, 'X'), '𝄞Xabc');
    });

    test('a styled string shifts the same way', () {
      expect(
        Parser('$fgRed𝄞$reset').insertBefore(1, 'X'),
        'X$fgRed𝄞$reset',
      );
    });

    test('StackedParser shifts the same way', () {
      expect(StackedParser('𝄞abc').insertBefore(1, 'X'), 'X𝄞abc');
    });

    test('a lone half next to a pair does not pull the shift further', () {
      // D834, then the pair D834 DD1E: position 2 is mid-pair, position 1
      // is between two highs — one step is always enough.
      expect(Parser('\uD834𝄞').insertBefore(2, 'X'), '\uD834X𝄞');
      expect(Parser('\uD834𝄞').insertAfter(2, 'X'), '\uD834𝄞X');
    });

    test('a pair the input broke with a code is left as it lies', () {
      // The halves are lone surrogates of the input itself: the library
      // does not mend invalid input, and the seam between them stays open.
      expect(
        Parser('\uD834$fgRed\uDD1E').insertBefore(1, 'X'),
        '\uD834X$fgRed\uDD1E',
      );
      expect(
        Parser('\uD834$fgRed\uDD1E').insertAfter(1, 'X'),
        '\uD834${fgRed}X\uDD1E',
      );
    });

    test('never breaks a pair anywhere in a mixed corpus', () {
      final corpus = [
        '𝄞abc',
        'a𝄞b😀c',
        '$fgRed😀$reset😀',
        'né😀$bg256Red日本語𝄞$reset',
        '${link('https://e.com/', text: '😀𝄞')} tail',
      ];

      for (final text in corpus) {
        final parser = Parser(text);
        final plain = parser.removeAll();

        for (var pos = 0; pos <= parser.length; pos++) {
          for (final after in [false, true]) {
            final result = after
                ? parser.insertAfter(pos, 'X')
                : parser.insertBefore(pos, 'X');
            final reason = '"$text" @ $pos, after: $after';

            expect(_isValidUtf16(result), isTrue, reason: reason);

            final landing = _landing(plain, pos, after: after);
            expect(
              Parser(result).removeAll(),
              '${plain.substring(0, landing)}X${plain.substring(landing)}',
              reason: reason,
            );
          }
        }
      }
    });
  });
}
