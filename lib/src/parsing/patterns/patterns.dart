import '../../ansi/c0.dart';

/// Pattern for escape codes.
final escapeCodesRe = RegExp(
  '(?<all>($csiPattern|$oscPattern|$escPattern))',
);

/// Pattern for CSI.
const String csiPattern = '(?<csi>$ESC\\[)'
    '(?<csi_params>[\x30-\x3F]*)'
    '(?<csi_final>[\x20-\x2F]*[\x40-\x7E])';

/// Pattern for CSI.
final RegExp csiRe = RegExp(csiPattern);

/// Pattern for SGR.
const String sgrPattern = '(?<csi>$ESC\\[)'
    '(?<params>[0-9:;<=>?]*)'
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

/// Pattern for control codes.
final controlCodesRe = RegExp('[\x00-\x1F\x7F]');
