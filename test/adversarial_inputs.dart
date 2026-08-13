/// Inputs the parser would break on if it cut any corners: truncated
/// sequences, surrogate pairs, eight-bit C1, control bytes.
///
/// Kept apart from any one test so that more than one can read it. What a
/// corpus like this is worth depends on how many properties are run over it,
/// and for a long time it was run over three: see
/// `round_trip_invariant_test.dart` for the parse, and
/// `reemission_invariant_test.dart` for what the four outputs make of it.
const adversarialInputs = <String>[
  '',
  'plain text, no codes at all',
  '\x1B',
  'ends with a lone escape\x1B',
  '\x1B[',
  'a\x1B[31',
  'a\x1B[31;',
  '\x1B[31mred\x1B[0m',
  '\x1B[999999999999999999999m',
  '\x1B]8;;http://example.com\x1B\\link\x1B]8;;\x1B\\',
  '\x1B]0;title without terminator',
  '\x1B]0;title\x07',
  '\x1B[38:2::255:0:0mcolon rgb\x1B[m',
  '\x1B[38;5mtruncated 256\x1B[m',
  '\x1B[38;2;1;2mtruncated rgb\x1B[m',
  '\x9B31mnot a CSI in a Dart string',
  // The one above carries no ESC, so `ansiRemoveEscapeCodes` answers it by
  // the `contains(ESC)` shortcut and never reaches the pattern. This one
  // does carry an ESC, which is the only way the eight-bit byte is ever put
  // to the regex — and `ansiRemoveEscapeCodes` promises to read by the same
  // pattern the parser does. Widen the pattern to take 0x9B and the two
  // stop agreeing here, where the shortcut cannot hide it.
  '\x1B[31m\x9B31m eight-bit behind a real CSI\x1B[m',
  'emoji \u{1F600} around \x1B[1m codes \u{1D11E}\x1B[m',
  'combining á\x1B[4mb́\x1B[24m',
  '\x00\x07\x7F control bytes\t\r\n',
  'crlf\r\n\x1B[31mline\x1B[m\r\n',
  '\x1B7saved\x1B8restored',
  '\x1B(Bcharset',
  // An unfinished code that is not a control string, a redundant SGR behind
  // it, and text behind that. The shape the four outputs used to swallow: the
  // SGR is what `optimize` exists to drop, and dropping it took away the
  // `ESC` that was holding the sequence off the text. Every entry above
  // carries a truncated sequence at the end of the string, where nothing
  // follows for it to eat, so none of them showed it.
  '\x1B\x1B[0m31]',
  '\x1B[3\x1B[0m1m!',
  '\x1B(\x1B[0mB!',
  '\x1B\x1B[0m0123456789Zrest',
  '\x1B[\x1B[m\x1B[3\x1B[0mtail',
  'text \x1B\x1B[22m more text',
];
