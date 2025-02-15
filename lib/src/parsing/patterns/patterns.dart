import '../../controls/c0.dart';

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

/// Pattern for background color.
const String backgroundPattern = '(?<csi>$ESC\\[)'
    r'(?<params>4[0-79]|10[0-7]|48;5;\d+|48;2;\d+;\d+;\d+)'
    '(?<sgr>m)';

/// Pattern for background color.
final backgroundRe = RegExp(backgroundPattern);

/// Pattern for foreground color.
const String foregroundPattern = '(?<csi>$ESC\\[)'
    r'(?<params>3[0-79]|9[0-7]|38;5;\d+|38;2;\d+;\d+;\d+)'
    '(?<sgr>m)';

/// Pattern for foreground color.
final foregroundRe = RegExp(foregroundPattern);

/// Pattern for OSC.
const String oscPattern = '(?<osc>$ESC\\])'
    '(?<osc_params>.*?)(?<osc_terminator>$BEL|$ESC\\\\)';

/// Pattern for OSC.
final oscRe = RegExp(oscPattern);

/// Pattern for ESC.
const String escPattern = '(?<esc>$ESC)(?<esc_final>.)';
