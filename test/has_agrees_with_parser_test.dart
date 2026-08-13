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
  '\x1B[58;5;',
  '\x1B[31',
  '\x1B',
  '\x1B]0;unterminated',
];

/// The fragments a removal's neighbour can be absorbed into: a sequence
/// still waiting for its end. A control sequence with no final byte takes
/// the next character for one — `\x1B[31` and a `t` after it are a whole
/// CSI — and an OSC string whose terminator never came runs on to the next
/// `ESC` or to the end of the text, swallowing whatever the sequence that
/// stood between them used to keep it off. Removing a complete sequence
/// next to either changes how it reads on, so the assertions about what
/// removal left behind skip compositions carrying them.
const _truncated = <String>{
  '\x1B',
  '\x1B[31',
  '\x1B[38;5;',
  '\x1B[58;5;',
  '\x1B]0;unterminated',
};

/// Whether one function the parser read touches one colour slot: a colour
/// function on it, or a simple code from its rows of the SGR table.
bool _touches(
  SgrFunction function,
  ControlFunctionsSGR target,
  bool Function(int code) simple,
) =>
    function is SgrFunctionWithCode &&
    (function.code == target || simple(function.code.index));

/// The SGR sequences the parser read, each with its own functions in the
/// order they were written.
///
/// Kept apart rather than run together: a comparison over one flat list
/// cannot tell `CSI 1 SGR CSI 2 SGR` from `CSI 1;2 SGR`, and a function
/// that moved from one sequence into the next would read as no change at
/// all.
List<List<SgrFunction>> _parserSequences(String text) => [
      for (final m in Parser(text).pieces)
        if (m.entity case Sgr(:final functions)) functions,
    ];

/// A function as a comparison of two readings can hold it: what kind the
/// parser made of it and what it carries. The functions are not values that
/// compare equal, and the two together are enough — a colour that moved
/// slots, a code that changed, a colour given up on where one was read
/// before all read as a different string.
String _shape(SgrFunction function) => '${function.runtimeType}: $function';

/// What the parser read as touching one colour slot.
bool _parserHas(
  String text,
  ControlFunctionsSGR target,
  bool Function(int code) simple,
) =>
    _parserSequences(text)
        .any((s) => s.any((f) => _touches(f, target, simple)));

/// Whether the parser made an SGR sequence of anything in the text — the
/// question `ansiHasSgr` answers by its pattern.
bool _parserHasSgr(String text) =>
    Parser(text).pieces.any((m) => m.entity is Sgr);

/// The text with every SGR sequence the parser found taken out of it: what
/// is left written out piece by piece, which is what `ansiRemoveSgr` leaves
/// if the two readings agree on which pieces are SGR.
String _parserRemoveSgr(String text) => [
      for (final m in Parser(text).pieces)
        if (m.entity is! Sgr) m.entity.string,
    ].join();

bool _fgSimple(int n) => n >= 30 && n <= 37 || n == 39 || n >= 90 && n <= 97;
bool _bgSimple(int n) => n >= 40 && n <= 47 || n == 49 || n >= 100 && n <= 107;
bool _underlineSimple(int n) => n == 59;

void main() {
  // Not only the colour surfaces any more: `ansiHasSgr` and `ansiRemoveSgr`
  // are read by the same pattern and answered for here too.
  group('the pattern and the parser agree:', () {
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
        expect(text.ansiHasSgr, _parserHasSgr(text), reason: reason);
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
        // Whole sequences, and the two readings on which pieces are ones:
        // what the pattern takes out is what the parser calls SGR, so what
        // is left is the rest of the parse written back out. Both sides are
        // read off the same string, so nothing here turns on how a
        // neighbour reads once a sequence between them is gone.
        expect(text.ansiRemoveSgr(), _parserRemoveSgr(text), reason: reason);
        // On the stripped string, not the original: removing a complete
        // sequence can let a neighbour still waiting for its end absorb
        // what follows — a truncated CSI takes the next character for its
        // final byte (`\x1B[31` + `t` is a complete CSI), an unterminated
        // OSC swallows the text the vanished `ESC` had stopped it at — so
        // the plain text of the original is not preserved on malformed
        // input: pre-existing behaviour, not a classifier question. What
        // must hold is that both readings agree on what removal left
        // behind.
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

    test(
        'a removal takes its own kind and leaves every other function '
        'where it was', () {
      final random = Random(20260807);

      for (var i = 0; i < 2000; i++) {
        final parts = [
          for (var j = 0; j < random.nextInt(6) + 1; j++)
            _fragments[random.nextInt(_fragments.length)],
        ];
        // Nothing is stepped around here, `_truncated` included. A piece
        // still waiting for its end absorbs a character of the text beside
        // it once the sequence between them is removed, and text is what
        // the assertions above have to make an exception for. Functions are
        // not: every SGR sequence begins with an `ESC`, which is where any
        // absorption stops, so none can be swallowed — and none can be
        // conjured either, since that would take an `m` for the absorbed
        // final byte, and none of the pieces that can be absorbed here
        // begins with one. What removal did to the functions is the same
        // question on a malformed string as on a clean one.
        final text = parts.join();
        final reason = 'on ${text.codeUnits}';
        final before = _parserSequences(text);

        for (final (removed, target, simple) in [
          (text.ansiRemoveForeground(), ControlFunctionsSGR.fg, _fgSimple),
          (text.ansiRemoveBackground(), ControlFunctionsSGR.bg, _bgSimple),
          (
            text.ansiRemoveUnderlineColor(),
            ControlFunctionsSGR.underlineColor,
            _underlineSimple,
          ),
        ]) {
          final kept = [
            for (final sequence in before)
              [
                for (final function in sequence)
                  if (!_touches(function, target, simple)) _shape(function),
              ],
          ];

          expect(
            [
              for (final sequence in _parserSequences(removed))
                [for (final function in sequence) _shape(function)],
            ],
            // A sequence left with nothing to say is not written back out.
            [
              for (final sequence in kept)
                if (sequence.isNotEmpty) sequence,
            ],
            reason: reason,
          );
        }
      }
    });
  });
}
