import '../../values/control_codes.dart';

/// Pattern for escape codes.
final escapeCodesRe = RegExp(
  '(?<all>($csiPattern|$oscPattern|$escPattern))',
);

/// Pattern for CSI.
const String csiPattern = '(?<csi>$esc\\[)'
    '(?<csi_parameters>[0-9:;<=>?]*)'
    r'(?<csi_intermediate>[!"#$ '
    "%&'()*+,-./]*)"
    r'(?<csi_final>[@A-Z[\\\]^_`a-z{|}~])';

/// Pattern for CSI.
final RegExp csiRe = RegExp(csiPattern);

/// Pattern for SGR.
const String sgrPattern = '(?<csi>$esc\\[)'
    '(?<parameters>[0-9:;<=>?]*)'
    '(?<sgr>m)';

/// Pattern for SGR.
final RegExp sgrRe = RegExp(sgrPattern);

/// Pattern for background color.
const String backgroundPattern = '(?<csi>$esc\\[)'
    r'(?<parameters>4[0-79]|10[0-7]|48;5;\d+|48;2;\d+;\d+;\d+)'
    '(?<sgr>m)';

/// Pattern for background color.
final backgroundRe = RegExp(backgroundPattern);

/// Pattern for foreground color.
const String foregroundPattern = '(?<csi>$esc\\[)'
    r'(?<parameters>3[0-79]|9[0-7]|38;5;\d+|38;2;\d+;\d+;\d+)'
    '(?<sgr>m)';

/// Pattern for foreground color.
final foregroundRe = RegExp(foregroundPattern);

/// Pattern for OSC.
const String oscPattern = '(?<osc>$esc\\])'
    '(?<osc_parameters>.*?)(?<osc_terminator>$bel|$esc\\\\)';

/// Pattern for OSC.
final oscRe = RegExp(oscPattern);

/// Pattern for ESC.
const String escPattern = '(?<esc>$esc)(?<esc_final>.)';

/// Pattern for parameter spiltter.
final splitterRe = RegExp(';');
