import '../../values/control_codes.dart';
import '../enums/ansi_control_codes.dart';
import '../enums/ansi_csi_codes.dart';
import '../enums/ansi_escape_codes.dart';
import '../patterns/patterns.dart';

extension StringShowEscapeCodesExtension on String {
  /// Show escape codes.
  String showEscapeCodes({
    String open = '[',
    String codeOpen = '',
    String codeClose = '',
    String parametersOpen = ' ',
    String parametersClose = '',
    String finalOpen = ' ',
    String finalClose = '',
    String close = ']',
  }) {
    final buf = StringBuffer();
    var pos = 0;

    for (final m in escapeCodesRe.allMatches(this)) {
      final all = m.namedGroup('all');

      /// Handle plain text.
      if (pos < m.start) {
        final text = substring(pos, m.start);
        buf.write(text);
      }

      pos = m.end;

      final csi = m.namedGroup('csi');
      if (csi != null) {
        final parameters = m.namedGroup('csi_parameters')!;
        final intermediate = m.namedGroup('csi_intermediate')!;
        final code = m.namedGroup('csi_final')!;
        final abbr = AnsiCsiCodes.byCode(code)?.abbr ?? code;

        buf
          ..write(open)
          ..write(codeOpen)
          ..write(AnsiEscapeCodes.csi.abbr)
          ..write(codeClose);

        if (parameters.isNotEmpty) {
          buf
            ..write(parametersOpen)
            ..write(parameters)
            ..write(intermediate)
            ..write(parametersClose);
        }

        buf
          ..write(finalOpen)
          ..write(abbr)
          ..write(finalClose)
          ..write(close);

        continue;
      }

      final osc = m.namedGroup('osc');
      if (osc != null) {
        final parameters = m.namedGroup('osc_parameters')!;
        final terminator = m.namedGroup('osc_terminator')!;

        buf
          ..write(open)
          ..write(codeOpen)
          ..write(AnsiEscapeCodes.osc.abbr)
          ..write(codeClose)
          ..write(parametersOpen)
          ..write(parameters)
          ..write(parametersClose)
          ..write(finalOpen)
          ..write(
            terminator == bel
                ? AnsiControlCodes.bel.abbr
                : AnsiEscapeCodes.st.abbr,
          )
          ..write(finalClose)
          ..write(close);

        continue;
      }

      final esc = m.namedGroup('esc');
      if (esc != null) {
        final code = m.namedGroup('esc_final')!;

        buf
          ..write(open)
          ..write(codeOpen)
          ..write(AnsiControlCodes.esc.abbr)
          ..write(codeClose)
          ..write(finalOpen)
          ..write(code)
          ..write(finalClose)
          ..write(close);

        continue;
      }

      buf.write(all);
    }

    /// Handle plain text.
    if (pos < length) {
      final text = substring(pos, length);
      buf.write(text);
    }

    return buf.toString();
  }
}
