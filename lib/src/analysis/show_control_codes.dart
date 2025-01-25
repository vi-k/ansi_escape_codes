import '../control_codes/control_codes_table.dart';

/// Style for [showControlCodes].
enum ControlCodeStyle {
  abbr,
  emoji,
  escape,
  charCode,
}

/// Show control codes in [text].
String showControlCodes(
  String text, {
  String open = '',
  String close = '',
  String abbrOpen = '[',
  String abbrClose = ']',
  ControlCodeStyle preferStyle = ControlCodeStyle.escape,
}) {
  final buf = StringBuffer();

  for (final charCode in text.codeUnits) {
    final controlCode = ControlCodes.byCharCode(charCode);

    if (controlCode == null) {
      buf.writeCharCode(charCode);
      continue;
    }

    if (preferStyle == ControlCodeStyle.abbr) {
      buf
        ..write(open)
        ..write(abbrOpen)
        ..write(controlCode.abbr)
        ..write(abbrClose)
        ..write(close);
      continue;
    }

    if (preferStyle == ControlCodeStyle.emoji) {
      final emoji = controlCode.emoji;
      if (emoji != null) {
        buf
          ..write(open)
          ..write(emoji)
          ..write(close);
        continue;
      }

      preferStyle = ControlCodeStyle.escape;
    }

    if (preferStyle == ControlCodeStyle.escape) {
      final escape = controlCode.escape;
      if (escape != null) {
        buf
          ..write(open)
          ..write(escape)
          ..write(close);

        continue;
      }

      preferStyle = ControlCodeStyle.charCode;
    }

    buf
      ..write(open)
      ..write(r'\x')
      ..write(charCode.toRadixString(16).toUpperCase().padLeft(2, '0'))
      ..write(close);
  }

  return buf.toString();
}
