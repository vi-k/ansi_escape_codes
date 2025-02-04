import '../enums/ansi_control_codes.dart';

enum AnsiControlCodeStyle { abbr, emoji, escape, charCode }

extension StringShowControlCodesExtension on String {
  /// Show control codes.
  String showControlCodes({
    String open = '',
    String close = '',
    String abbrOpen = '[',
    String abbrClose = ']',
    AnsiControlCodeStyle preferStyle = AnsiControlCodeStyle.escape,
  }) {
    final buf = StringBuffer();

    for (final charCode in codeUnits) {
      final controlCode = AnsiControlCodes.byCharCode(charCode);

      if (controlCode == null) {
        buf.writeCharCode(charCode);
      } else if (preferStyle == AnsiControlCodeStyle.abbr) {
        buf
          ..write(open)
          ..write(abbrOpen)
          ..write(controlCode.abbr)
          ..write(abbrClose)
          ..write(close);
      } else {
        if (preferStyle == AnsiControlCodeStyle.emoji) {
          final emoji = controlCode.emoji;
          if (emoji != null) {
            buf
              ..write(open)
              ..write(emoji)
              ..write(close);
            continue;
          }

          preferStyle = AnsiControlCodeStyle.escape;
        }

        if (preferStyle == AnsiControlCodeStyle.escape) {
          final escape = controlCode.escape;
          if (escape != null) {
            buf
              ..write(open)
              ..write(escape)
              ..write(close);

            continue;
          }

          preferStyle = AnsiControlCodeStyle.charCode;
        }

        buf
          ..write(open)
          ..write(r'\x')
          ..write(charCode.toRadixString(16).toUpperCase().padLeft(2, '0'))
          ..write(close);
      }
    }

    return buf.toString();
  }
}
