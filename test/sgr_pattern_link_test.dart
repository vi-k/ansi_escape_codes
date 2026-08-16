import 'package:ansi_escape_codes/ansi_escape_codes.dart';
// The pattern the SGR shortcuts read. Not exported by any entry point — it
// is an implementation detail — but a test that ties it to the parser has to
// read the real one, or it would only be a third copy.
import 'package:ansi_escape_codes/src/parsing/patterns/patterns.dart';
import 'package:test/test.dart';

void main() {
  test('sgrPattern and the parser agree on what an SGR is', () {
    // `sgrPattern` writes the two opening bytes itself, apart from
    // `csiPattern`, and `ansiHasSgr`, `ansiRemoveSgr` and
    // `sgr_functions.dart` read it. A copy that drifts answers where the
    // parser sees nothing: loosen the `[` to optional and
    // `ansiHasSgr('aa\x1B31mbb')` turns true with the whole suite green.
    const openers = ['\x1B[', '\x1B', '[', '\x9B', '\x1B[['];
    const bodies = [
      '31m',
      '0m',
      'm',
      ';m',
      '1;31m',
      '38;5;9m',
      '38;2;1;2;3m',
      '4:3m',
      '31',
      '31x',
      '?5m',
      '>4;1m',
      '<35;10;2m',
    ];

    for (final opener in openers) {
      for (final body in bodies) {
        final input = 'aa$opener${body}bb';

        expect(
          RegExp(sgrPattern).allMatches(input).isNotEmpty,
          Parser(input).pieces.any((m) => m.entity is Sgr),
          reason: 'on ${input.codeUnits}',
        );
      }
    }
  });

  test('a private byte makes a sequence private in the first place only', () {
    // A parameter string beginning `<`, `=`, `>` or `?` is private use, and
    // the whole sequence with it. One of those bytes anywhere else is a
    // parameter byte the standard leaves undefined — the sequence is still
    // an ordinary `CSI ... m`, and the parser reads it as one, putting it in
    // the rendition branch with the numbers it cannot read.
    //
    // The pattern used to disagree, and the extensions read the pattern: the
    // same sequence was an SGR to the parser and not one to `ansiHasSgr`.
    const privateFirst = ['\x1B[?5m', '\x1B[>4;1m', '\x1B[<35;10;2m'];
    const ordinary = ['\x1B[1<m', '\x1B[99;<m', '\x1B[31;>m', '\x1B[1=m'];

    for (final code in privateFirst) {
      expect('${code}A'.ansiHasSgr, isFalse, reason: code);
      expect('${code}A'.ansiRemoveSgr(), '${code}A', reason: code);
      expect(
        Parser('${code}AB').substring(1),
        'B',
        reason: '$code is a code to copy, not a rendition to replay',
      );
    }

    for (final code in ordinary) {
      expect('${code}A'.ansiHasSgr, isTrue, reason: code);
      expect('${code}A'.ansiRemoveSgr(), 'A', reason: code);
      expect(
        Parser('${code}AB').substring(1),
        '${code}B$reset',
        reason: '$code travels in the rendition branch, so a slice that '
            'begins past it opens it again',
      );
    }
  });
}
