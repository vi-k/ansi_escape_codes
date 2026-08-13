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
          Parser(input).matches.any((m) => m.entity is Sgr),
          reason: 'on ${input.codeUnits}',
        );
      }
    }
  });
}
