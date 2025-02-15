import '../parsing/control_functions/control_functions_c0.dart';

enum ControlCodeStyle { abbr, unicodeSymbol, escape, charCode }

extension StringShowControlCodesExtension on String {
  /// Show control codes.
  String showControlCodes({
    String open = '',
    String close = '',
    String abbrOpen = '[',
    String abbrClose = ']',
    ControlCodeStyle preferStyle = ControlCodeStyle.escape,
  }) {
    final buf = StringBuffer();

    for (final charCode in codeUnits) {
      final controlCode = ControlFunctionsC0.byIndex(charCode);

      if (controlCode == null) {
        buf.writeCharCode(charCode);
      } else {
        switch (preferStyle) {
          case ControlCodeStyle.abbr:
            buf
              ..write(open)
              ..write(abbrOpen)
              ..write(controlCode.name)
              ..write(abbrClose)
              ..write(close);

          case ControlCodeStyle.unicodeSymbol:
            final symbol = controlCode.unicodeSymbol;
            buf
              ..write(open)
              ..write(symbol)
              ..write(close);

          case ControlCodeStyle.escape when controlCode.escapeSymbol != null:
            buf
              ..write(open)
              ..write(controlCode.escapeSymbol)
              ..write(close);

          case ControlCodeStyle.escape:
          case ControlCodeStyle.charCode:
            buf
              ..write(open)
              ..write(r'\x')
              ..write(charCode.toRadixString(16).toUpperCase().padLeft(2, '0'))
              ..write(close);
        }
      }
    }

    return buf.toString();
  }
}
