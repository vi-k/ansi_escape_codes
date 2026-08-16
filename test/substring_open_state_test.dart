import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// What a slice left open ends in.
///
/// `substring(close: false)` asks `transitTo` for the reset half only: it
/// unwinds what the string took off by the cut and does not put on what the
/// string put on there, since those codes belong to the character after the
/// cut and the slice does not carry it.
///
/// One thing was leaking out of that. `transitTo` writes a joint reset —
/// `CSI 22` takes bold and dim off together — wherever one of the pair goes
/// off, and leans on the half that puts things on to bring the survivor back.
/// The survivor is part of the reset, not a set of its own, and dropping it
/// with the rest left the slice in a state that was neither its own nor the
/// string's.
void main() {
  group('the survivor of a joint reset comes back:', () {
    test('transitTo keeps it even when the set half is skipped', () {
      // The unit of it, away from any slice: bold and dim both on, dim off.
      const from = Style(bold: true, dim: true);
      const to = Style(bold: true);

      expect(from.transitTo(to), '\x1B[22;1m');
      expect(
        from.transitToPart(to, skipSet: true),
        '\x1B[22;1m',
        reason: 'the 1 is the other half of the 22, not a set of its own',
      );
    });

    test('but not where the reset it survives was skipped', () {
      // With skipReset the CSI 22 is not written, so nothing took the
      // survivor off and nothing has to put it back. Where the property
      // was not on to begin with the set is still needed.
      const boldDim = Style(bold: true, dim: true);
      const boldOnly = Style(bold: true);
      const dimOnly = Style(dim: true);

      expect(
        boldDim.transitToPart(boldOnly, skipReset: true),
        isEmpty,
        reason: 'bold was on and stayed on',
      );
      expect(
        boldDim.transitToPart(dimOnly, skipReset: true),
        isEmpty,
        reason: 'dim was on and stayed on',
      );
      expect(
        boldOnly.transitToPart(dimOnly, skipReset: true),
        '\x1B[2m',
        reason: 'dim was not on, so it has to be set',
      );
      expect(
        dimOnly.transitToPart(boldOnly, skipReset: true),
        '\x1B[1m',
        reason: 'bold was not on, so it has to be set',
      );
    });

    test('a slice left open stands where the string stands', () {
      const input = '\x1B[1;2mAB\x1B[22;1m';
      final parser = Parser(input);
      final slice = parser.substring(0, close: false);

      expect(slice, '\x1B[1;2mAB\x1B[22;1m');
      expect(Parser(slice).finalState, parser.finalState);
      expect(Parser(slice).finalState, const Style(bold: true));
    });

    test('and a genuine set is still left out', () {
      // Nothing here is a joint reset: the dim was never on, so the 1 is a
      // set like any other and an open slice does not write it.
      const from = Style.terminalColors;
      const to = Style(bold: true);

      expect(from.transitTo(to), '\x1B[1m');
      expect(from.transitToPart(to, skipSet: true), '');
    });
  });

  group('a change of kind is a set, and an open slice leaves it out:', () {
    // The other four pairs never take the joint-reset road. `CSI 24` is
    // written only where the far end has no underline at all, so going from
    // one underline to the other is the bare `CSI 21` — a set, which
    // `close: false` does not write. The slice keeps the kind it showed, and
    // the string goes on to the other one without it.
    const cases = <(String, String, Style, Style)>[
      (
        'underline, then doubled',
        '\x1B[4mAB\x1B[24;21m',
        Style(underline: true),
        Style(doublyUnderline: true),
      ),
      (
        'blink, then rapid',
        '\x1B[5mAB\x1B[25;6m',
        Style(blink: true),
        Style(blinkRapid: true),
      ),
      (
        'framed, then encircled',
        '\x1B[51mAB\x1B[54;52m',
        Style(frame: true),
        Style(encircle: true),
      ),
      (
        'superscript, then subscript',
        '\x1B[73mAB\x1B[75;74m',
        Style(superscript: true),
        Style(subscript: true),
      ),
    ];

    for (final (name, input, sliceEnds, stringEnds) in cases) {
      test(name, () {
        final parser = Parser(input);
        final slice = parser.substring(0, close: false);

        expect(Parser(slice).finalState, sliceEnds);
        expect(parser.finalState, stringEnds);
      });
    }
  });

  test('a closed slice winds the style all the way back', () {
    for (final input in <String>[
      '\x1B[1;2mAB\x1B[22;1m',
      '\x1B[4mAB\x1B[24;21m',
      '\x1B[5mAB\x1B[25;6m',
      '\x1B[51mAB\x1B[54;52m',
      '\x1B[73mAB\x1B[75;74m',
    ]) {
      expect(
        Parser(Parser(input).substring(0)).finalState,
        Style.terminalColors,
        reason: 'close: true is unaffected by any of this — it short-circuits '
            'to a plain reset before skipSet is ever consulted',
      );
    }
  });
}
