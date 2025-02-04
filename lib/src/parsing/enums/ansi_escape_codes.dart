import '../../values/control_codes.dart';

/// Table of escape codes.
enum AnsiEscapeCodes {
  csi('$esc[', 'CSI'),
  st('$esc\\', 'ST'),
  osc('$esc]', 'OSC');

  const AnsiEscapeCodes(
    this.code,
    this.abbr,
  );

  final String code;
  final String abbr;

  static AnsiEscapeCodes? byCode(String code) {
    for (final v in values) {
      if (v.code == code) {
        return v;
      }
    }

    return null;
  }
}
