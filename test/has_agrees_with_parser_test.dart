import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The pieces a terminal stream is made of, the SGR-shaped troublemakers
/// included: colours cut short, leading zeroes, kinds nobody knows,
/// private sequences ending in the SGR final.
const _fragments = <String>[
  'text',
  'a',
  '𝄞',
  '\x1B[31m',
  '\x1B[39m',
  '\x1B[41m',
  '\x1B[49m',
  '\x1B[97m',
  '\x1B[107m',
  '\x1B[0m',
  '\x1B[m',
  '\x1B[;m',
  '\x1B[1;31m',
  '\x1B[38;5;196m',
  '\x1B[48;5;21m',
  '\x1B[58;5;93m',
  '\x1B[38;2;1;2;3m',
  '\x1B[58;2;1;2;3m',
  '\x1B[38:2::1:2:3m',
  '\x1B[58:2::1:2:3m',
  '\x1B[4:3m',
  '\x1B[59m',
  '\x1B[38;2;1;2m',
  '\x1B[38;05;196m',
  '\x1B[038;5;196m',
  '\x1B[38;7;1m',
  '\x1B[58;5m',
  '\x1B[38m',
  '\x1B[?5m',
  '\x1B[>4;1m',
  '\x1B[<35;10;2m',
  '\x1B[38;5;',
  '\x1B[31',
  '\x1B',
];

/// The fragments a removal's neighbour can be absorbed into: a sequence
/// with no final byte yet. Removing a complete sequence next to one
/// changes how it reads on, so the text-preservation assertions skip
/// compositions carrying them.
const _truncated = <String>{'\x1B', '\x1B[31', '\x1B[38;5;'};

/// What the parser read as touching one colour slot: a colour function on
/// it, or a simple code from its rows of the SGR table.
bool _parserHas(
  String text,
  ControlFunctionsSGR target,
  bool Function(int code) simple,
) {
  for (final m in Parser(text).matches) {
    if (m.entity case Sgr(:final functions)) {
      for (final f in functions) {
        if (f is SgrFunctionWithCode &&
            (f.code == target || simple(f.code.index))) {
          return true;
        }
      }
    }
  }

  return false;
}

bool _fgSimple(int n) => n >= 30 && n <= 37 || n == 39 || n >= 90 && n <= 97;
bool _bgSimple(int n) => n >= 40 && n <= 47 || n == 49 || n >= 100 && n <= 107;
bool _underlineSimple(int n) => n == 59;

void main() {
  group('the colour surfaces and the parser agree:', () {
    test('has answers as the parser reads, whatever is thrown at it', () {
      // The seed is fixed so that a failure can be looked at again.
      final random = Random(20260805);

      for (var i = 0; i < 5000; i++) {
        final parts = [
          for (var j = 0; j < random.nextInt(6) + 1; j++)
            _fragments[random.nextInt(_fragments.length)],
        ];
        final text = parts.join();
        final reason = 'on ${text.codeUnits}';

        expect(
          text.ansiHasForeground,
          _parserHas(text, ControlFunctionsSGR.fg, _fgSimple),
          reason: reason,
        );
        expect(
          text.ansiHasBackground,
          _parserHas(text, ControlFunctionsSGR.bg, _bgSimple),
          reason: reason,
        );
        expect(
          text.ansiHasUnderlineColor,
          _parserHas(
            text,
            ControlFunctionsSGR.underlineColor,
            _underlineSimple,
          ),
          reason: reason,
        );
      }
    });

    test(
        'what remove took out, has no longer sees — '
        'and what is left reads one way', () {
      final random = Random(20260806);

      for (var i = 0; i < 2000; i++) {
        final parts = [
          for (var j = 0; j < random.nextInt(6) + 1; j++)
            _fragments[random.nextInt(_fragments.length)],
        ];
        final text = parts.join();
        final reason = 'on ${text.codeUnits}';
        final hasTruncated = parts.any(_truncated.contains);

        expect(
          text.ansiRemoveForeground().ansiHasForeground,
          isFalse,
          reason: reason,
        );
        expect(
          text.ansiRemoveBackground().ansiHasBackground,
          isFalse,
          reason: reason,
        );
        expect(
          text.ansiRemoveUnderlineColor().ansiHasUnderlineColor,
          isFalse,
          reason: reason,
        );
        // On the stripped string, not the original: removing a complete
        // sequence can let a truncated neighbour absorb the following
        // character (`\x1B[31` + `t` is a complete CSI), so the plain
        // text of the original is not preserved on malformed input —
        // pre-existing behaviour, not a classifier question. What must
        // hold is that both readings agree on what removal left behind.
        final stripped = text.ansiRemoveForeground();
        expect(
          stripped.ansiRemoveEscapeCodes(),
          Parser(stripped).removeAll(),
          reason: reason,
        );
        if (!hasTruncated) {
          expect(
            stripped.ansiRemoveEscapeCodes(),
            Parser(text).removeAll(),
            reason: reason,
          );
          expect(
            stripped.ansiHasBackground,
            text.ansiHasBackground,
            reason: reason,
          );
          expect(
            text.ansiRemoveBackground().ansiHasForeground,
            text.ansiHasForeground,
            reason: reason,
          );
          expect(
            text.ansiRemoveUnderlineColor().ansiHasBackground,
            text.ansiHasBackground,
            reason: reason,
          );
        }
      }
    });
  });
}
