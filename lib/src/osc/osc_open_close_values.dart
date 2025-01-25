import 'osc.dart' as ansi;

/// Predefined open/close OSC values.
enum OscOpenCloseValues {
  /// Link.
  link(ansi.linkOpen, ansi.linkTextOpen);

  const OscOpenCloseValues(this.open, this.close);

  final String open;
  final String close;

  static (OscOpenCloseValues, String)? byCode(String code) {
    for (final v in values) {
      if (code.startsWith(v.open) && code.endsWith(v.close)) {
        return (v, code.substring(v.open.length, code.length - v.close.length));
      }
    }

    return null;
  }
}
