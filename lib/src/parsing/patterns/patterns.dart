import '../../ansi/c0.dart';

/// Pattern for escape codes.
final escapeCodesRe = RegExp(
  '(?<all>($csiPattern|$oscPattern|$controlStringPattern|$escPattern))',
);

/// Pattern for CSI.
const String csiPattern = '(?<csi>$ESC\\[)'
    '(?<csi_params>[\x30-\x3F]*)'
    '(?<csi_final>[\x20-\x2F]*[\x40-\x7E])';

/// Pattern for CSI.
final RegExp csiRe = RegExp(csiPattern);

/// Pattern for SGR.
const String sgrPattern = '(?<csi>$ESC\\[)'
    // Digits, `;` and `:` only: a params field with a private byte —
    // `?5`, `>4;1`, the SGR-mouse `<35;10;2` — is a private sequence,
    // not SGR, exactly as the parser classifies it.
    '(?<params>[0-9;:]*)'
    '(?<sgr>m)';

/// Pattern for SGR.
final RegExp sgrRe = RegExp(sgrPattern);

/// Pattern for OSC.
///
/// The string runs until its terminator, and a terminator that never comes —
/// a truncated stream, or a sequence the writer forgot to close — ends it at
/// the next `ESC` or at the end of the text. Without that the string would be
/// read as a two-character escape code and its payload would surface as text.
const String oscPattern = '(?<osc>$ESC\\])'
    '(?<osc_params>[^$BEL$ESC]*)'
    '(?<osc_terminator>$BEL|$ESC\\\\)?';

/// Pattern for the C1 string openers other than `OSC`: `DCS`, `SOS`, `PM`
/// and `APC`.
///
/// Each opens a string that runs to its `ST`, and one that never got a
/// terminator ends at the next `ESC` or at the end of the text — the reading
/// `oscPattern` gives, and for the reason it gives it: read as a
/// two-character escape instead, the string would surface its body as text
/// and whatever was written after the opener would be swallowed by the
/// terminal.
///
/// A `BEL` ends none of these. It ends an `OSC`, which is xterm's and not the
/// standard's, and the standard gives all five `ST`.
const String controlStringPattern =
    // P, X, ^ and _: DCS, SOS, PM and APC.
    '(?<cstr>$ESC[\x50\x58\x5E\x5F])'
    '(?<cstr_params>[^$ESC]*)'
    '(?<cstr_terminator>$ESC\\\\)?';

/// Pattern for ESC.
///
/// An escape sequence is `ESC`, any number of intermediate bytes and a final
/// byte. The final byte is optional here so that a broken sequence — a lone
/// `ESC` at the end of the text, or one followed by a byte that cannot end a
/// sequence — is still recognized as an escape code rather than left in the
/// text.
const String escPattern =
    '(?<esc>$ESC)(?<esc_inter>$_intermediates*)(?<esc_final>[\x30-\x7E])?';

/// Bytes that may precede the final byte of a sequence.
const String _intermediates = '[\x20-\x2F]';

/// Pattern for control codes: the C0 set, `DEL`, and the eight-bit C1.
///
/// The eight-bit C1 are here and nowhere else. They are controls by
/// Unicode's own category and print as rubbish rather than as characters,
/// so what strips and shows controls must know them — but they open no
/// escape sequence in this package, and `escapeCodesRe` does not look for
/// them. The reasoning is in
/// `docs/records/2026-08-12[1]-eight-bit-c1-design.md`.
final controlCodesRe = RegExp('[\x00-\x1F\x7F-\x9F]');
