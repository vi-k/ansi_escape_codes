import 'package:meta/meta.dart';

import 'patterns.dart';

/// Handle escape sequences.
@experimental
String handleEscapeSequences(
  String text,
  String Function(String escapeSequence) handleEscapeSequence, {
  String Function(String text)? handlePlainText,
}) {
  final matches = escRe.allMatches(text);
  var pos = 0;
  final buf = StringBuffer();

  for (final m in matches) {
    /// Handle plain text.
    if (pos < m.start) {
      final part = text.substring(pos, m.start);
      buf.write(handlePlainText?.call(part) ?? part);
    }

    pos = m.end;

    final sequence = m.namedGroup('all')!;
    buf.write(handleEscapeSequence(sequence));
  }

  /// Handle plain text.
  if (pos < text.length) {
    final part = text.substring(pos, text.length);
    buf.write(handlePlainText?.call(part) ?? part);
  }

  return buf.toString();
}

/// Handle plain text.
@experimental
String handlePlainText(
  String text,
  String Function(String text) handlePlainText,
) =>
    handleEscapeSequences(
      text,
      (seq) => seq,
      handlePlainText: handlePlainText,
    );
