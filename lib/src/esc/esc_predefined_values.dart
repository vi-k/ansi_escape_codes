import 'esc.dart' as ansi;

/// Predefined ESC values.
enum EscPredefinedValues {
  /// Saves the cursor.
  saveCursor(ansi.saveCursor),

  /// Resores the cursor.
  restoreCursor(ansi.restoreCursor);

  const EscPredefinedValues(this.code);

  final String code;

  static EscPredefinedValues? byCode(String code) {
    for (final v in values) {
      if (v.code == code) {
        return v;
      }
    }

    return null;
  }
}
