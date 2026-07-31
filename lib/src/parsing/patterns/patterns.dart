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
const String oscPattern = '(?<osc>$ESC\\])'
    '(?<osc_params>.*?)(?<osc_terminator>$BEL|$ESC\\\\)';

/// Pattern for OSC.
final oscRe = RegExp(oscPattern);

/// Pattern for ESC.
const String escPattern = '(?<esc>$ESC)(?<esc_final>.)';

/// Pattern for control codes.
final controlCodesRe = RegExp('[\x00-\x1F\x7F]');
