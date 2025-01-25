import 'osc.dart' as ansi;

/// Predefined OSC values.
enum OscPredefinedValues {
  /// Link.
  linkEnd(ansi.linkClose);

  const OscPredefinedValues(this.code);

  final String code;

  static OscPredefinedValues? byCode(String code) {
    for (final v in values) {
      if (v.code == code) {
        return v;
      }
    }

    return null;
  }
}
