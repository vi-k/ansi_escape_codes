import '../parsing/control_functions/control_functions_c0.dart';

/// How a control code is to be shown where it must be seen rather than obeyed.
enum ControlCodeStyle {
  /// The number of the byte: `0x0A`.
  charCode,

  /// The name the standard gives it: `[LF]`.
  abbr,

  /// The picture Unicode gives it: `␊`.
  unicode,

  /// The way Dart writes it in a string where there is one, `\n`, and the
  /// number of the byte where there is not.
  escapeOrCharCode,

  /// The way Dart writes it where there is one, and the name otherwise.
  escapeOrAbbr,

  /// The way Dart writes it where there is one, and the picture otherwise.
  escapeOrUnicode,
}

/// Showing the control codes in a string instead of sending them.
extension StringShowControlCodesExtension on String {
  /// Show control codes.
  String ansiShowControlCodes({
    String open = '',
    String close = '',
    String abbrOpen = '[',
    String abbrClose = ']',
    ControlCodeStyle preferStyle = ControlCodeStyle.escapeOrCharCode,
  }) {
    final buf = StringBuffer();

    void abbrToBuf(String abbr) {
      buf
        ..write(open)
        ..write(abbrOpen)
        ..write(abbr)
        ..write(abbrClose)
        ..write(close);
    }

    void unicodeToBuf(String unicodeSymbol) {
      buf
        ..write(open)
        ..write(unicodeSymbol)
        ..write(close);
    }

    void escapeCodeToBuf(String escapeSymbol) {
      buf
        ..write(open)
        ..write(escapeSymbol)
        ..write(close);
    }

    void charCodeToBuf(int charCode) {
      buf
        ..write(open)
        ..write(r'\x')
        ..write(charCode.toRadixString(16).toUpperCase().padLeft(2, '0'))
        ..write(close);
    }

    for (final charCode in codeUnits) {
      final controlCode = ControlFunctionsC0.byIndex(charCode);

      if (controlCode == null) {
        buf.writeCharCode(charCode);
      } else {
        switch (preferStyle) {
          case ControlCodeStyle.charCode:
            charCodeToBuf(charCode);

          case ControlCodeStyle.abbr:
            abbrToBuf(controlCode.name);

          case ControlCodeStyle.unicode:
            unicodeToBuf(controlCode.unicodeSymbol);

          case ControlCodeStyle.escapeOrCharCode:
            if (controlCode.escapeSymbol case final escapeSymbol?) {
              escapeCodeToBuf(escapeSymbol);
            } else {
              charCodeToBuf(charCode);
            }

          case ControlCodeStyle.escapeOrAbbr:
            if (controlCode.escapeSymbol case final escapeSymbol?) {
              escapeCodeToBuf(escapeSymbol);
            } else {
              abbrToBuf(controlCode.name);
            }

          case ControlCodeStyle.escapeOrUnicode:
            if (controlCode.escapeSymbol case final escapeSymbol?) {
              escapeCodeToBuf(escapeSymbol);
            } else {
              unicodeToBuf(controlCode.unicodeSymbol);
            }
        }
      }
    }

    return buf.toString();
  }
}
