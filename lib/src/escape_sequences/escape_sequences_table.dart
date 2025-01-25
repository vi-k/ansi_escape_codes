import '../control_codes/control_codes.dart';

/// Table of escape sequences.
enum EscapeSequences {
  csi('$esc[', 'CSI'),
  st('$esc\\', 'ST'),
  osc('$esc]', 'OSC');

  const EscapeSequences(
    this.code,
    this.abbr,
  );

  final String code;
  final String abbr;

  static EscapeSequences? byCode(String code) {
    for (final v in values) {
      if (v.code == code) {
        return v;
      }
    }

    return null;
  }
}
