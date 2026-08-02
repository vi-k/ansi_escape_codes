import '../ansi/c0.dart';
import '../parsing/control_functions/control_functions_c0.dart';
import '../parsing/control_functions/control_functions_c1.dart';
import '../parsing/control_functions/control_sequences.dart';
import '../parsing/patterns/patterns.dart';

/// Showing the escape sequences in a string instead of sending them.
extension StringShowEscapeCodesExtension on String {
  /// Show escape sequences.
  String ansiShowEscapeSequences({
    String open = '[',
    String codeOpen = '',
    String codeClose = '',
    String paramsOpen = ' ',
    String paramsClose = '',
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
        final params = m.namedGroup('csi_params')!;
        final code = m.namedGroup('csi_final')!;
        final name = ControlSequencesFunctions.byCode(code)?.name ??
            code.replaceAll(' ', '␠');

        buf
          ..write(open)
          ..write(codeOpen)
          ..write(ControlFunctionsC1.CSI.name)
          ..write(codeClose);

        if (params.isNotEmpty) {
          buf
            ..write(paramsOpen)
            ..write(params)
            ..write(paramsClose);
        }

        buf
          ..write(finalOpen)
          ..write(name)
          ..write(finalClose)
          ..write(close);

        continue;
      }

      final osc = m.namedGroup('osc');
      if (osc != null) {
        final params = m.namedGroup('osc_params')!;
        final terminator = m.namedGroup('osc_terminator');

        buf
          ..write(open)
          ..write(codeOpen)
          ..write(ControlFunctionsC1.OSC.name)
          ..write(codeClose)
          ..write(paramsOpen)
          ..write(params)
          ..write(paramsClose)
          ..write(finalOpen)
          ..write(
            switch (terminator) {
              BEL => ControlFunctionsC0.BEL.name,
              // The string was never terminated.
              null => '',
              _ => ControlFunctionsC1.ST.name,
            },
          )
          ..write(finalClose)
          ..write(close);

        continue;
      }

      final esc = m.namedGroup('esc');
      if (esc != null) {
        // The intermediate bytes belong to the code: `ESC ( B` and `ESC ) B`
        // designate different character sets, and `ESC SP 7` is not the `ESC 7`
        // that saves the cursor. A broken sequence has no final byte at all.
        final code = '${m.namedGroup('esc_inter') ?? ''}'
                '${m.namedGroup('esc_final') ?? ''}'
            .replaceAll(' ', '␠');

        buf
          ..write(open)
          ..write(codeOpen)
          ..write(ControlFunctionsC0.ESC.name)
          ..write(codeClose);

        if (code.isNotEmpty) {
          buf
            ..write(finalOpen)
            ..write(code)
            ..write(finalClose);
        }

        buf.write(close);

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
