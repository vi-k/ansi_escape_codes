import '../control_codes/control_codes.dart';
import '../control_codes/control_codes_table.dart';
import '../csi/csi_open_close_values.dart';
import '../csi/csi_predefined_values.dart';
import '../csi/csi_table.dart';
import '../esc/esc_predefined_values.dart';
import '../escape_sequences/escape_sequences_table.dart';
import '../osc/osc_open_close_values.dart';
import '../osc/osc_predefined_values.dart';
import 'patterns.dart';

/// Show escape sequences.
String showEscapeSequences(
  String text, {
  String open = '[',
  String codeOpen = '',
  String codeClose = '',
  String parametersOpen = ' ',
  String parametersClose = '',
  String finalOpen = ' ',
  String finalClose = '',
  String close = ']',
  String Function(String text)? handlePlainText,
  bool recognizeSequences = false,
}) {
  final matches = escRe.allMatches(text);
  var pos = 0;
  final buf = StringBuffer();

  for (final m in matches) {
    // For debuging!!!
    // print(
    //   m.groupNames
    //       .map((e) => '$e: ${showControlCodes(m.namedGroup(e) ?? '')}')
    //       .toList(),
    // );

    /// Handle plain text.
    if (pos < m.start) {
      final part = text.substring(pos, m.start);
      buf.write(handlePlainText?.call(part) ?? part);
    }

    pos = m.end;

    final all = m.namedGroup('all')!;

    final csi = m.namedGroup('csi');
    if (csi != null) {
      if (recognizeSequences) {
        final predefinedValue = CsiPredefinedValues.byCode(all);
        if (predefinedValue != null) {
          buf
            ..write(open)
            ..write(codeOpen)
            ..write(predefinedValue.name)
            ..write(codeClose)
            ..write(close);

          continue;
        }

        final openCloseValue = CsiOpenCloseValues.byCode(all);
        if (openCloseValue != null) {
          final predefinedValue = openCloseValue.$1;
          final parameters = openCloseValue.$2;

          buf
            ..write(open)
            ..write(codeOpen)
            ..write(predefinedValue.name)
            ..write(parametersOpen)
            ..write(parameters)
            ..write(parametersClose)
            ..write(codeClose)
            ..write(close);

          continue;
        }
      }

      final parameters = m.namedGroup('csi_parameters')!;
      final intermediate = m.namedGroup('csi_intermediate')!;
      final code = m.namedGroup('csi_final')!;
      final abbr = CsiCodes.byCode(code)?.abbr ?? code;

      buf
        ..write(open)
        ..write(codeOpen)
        ..write(EscapeSequences.csi.abbr)
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
      if (recognizeSequences) {
        final predefinedValue = OscPredefinedValues.byCode(all);
        if (predefinedValue != null) {
          buf
            ..write(open)
            ..write(codeOpen)
            ..write(predefinedValue.name)
            ..write(codeClose)
            ..write(close);

          continue;
        }

        final openCloseValue = OscOpenCloseValues.byCode(all);
        if (openCloseValue != null) {
          final predefinedValue = openCloseValue.$1;
          final parameters = openCloseValue.$2;

          buf
            ..write(open)
            ..write(codeOpen)
            ..write(predefinedValue.name)
            ..write(parametersOpen)
            ..write(parameters)
            ..write(parametersClose)
            ..write(codeClose)
            ..write(close);

          continue;
        }
      }

      final parameters = m.namedGroup('osc_parameters')!;
      final terminator = m.namedGroup('osc_terminator')!;

      buf
        ..write(open)
        ..write(codeOpen)
        ..write(EscapeSequences.osc.abbr)
        ..write(codeClose)
        ..write(parametersOpen)
        ..write(parameters)
        ..write(parametersClose)
        ..write(finalOpen)
        ..write(
          terminator == bel ? ControlCodes.bel.abbr : EscapeSequences.st.abbr,
        )
        ..write(finalClose)
        ..write(close);

      continue;
    }

    final esc = m.namedGroup('esc');
    if (esc != null) {
      if (recognizeSequences) {
        final predefinedValue = EscPredefinedValues.byCode(all);
        if (predefinedValue != null) {
          buf
            ..write(open)
            ..write(codeOpen)
            ..write(predefinedValue.name)
            ..write(codeClose)
            ..write(close);

          continue;
        }
      }

      final code = m.namedGroup('esc_final')!;

      buf
        ..write(open)
        ..write(codeOpen)
        ..write(ControlCodes.esc.abbr)
        ..write(codeClose)
        ..write(finalOpen)
        ..write(code)
        ..write(finalClose)
        ..write(close);

      continue;
    }

    buf.write(m[0]);
  }

  /// Handle plain text.
  if (pos < text.length) {
    final part = text.substring(pos, text.length);
    buf.write(handlePlainText?.call(part) ?? part);
  }

  return buf.toString();
}
