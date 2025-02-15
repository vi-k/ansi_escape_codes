import '../parsing/patterns/patterns.dart';

extension StringHasEscapeCodesExtension on String {
  /// Whether there any escape codes in the text.
  bool get hasEscapeCodes => escapeCodesRe.hasMatch(this);

  /// Whether there control sequences (CSI) in the text.
  bool get hasCsi => csiRe.hasMatch(this);

  /// Whether there SGR (Select Graphic Rendition) codes in the text.
  bool get hasSgr => sgrRe.hasMatch(this);

  /// Whether the foreground color in the text changes.
  bool get hasForeground => foregroundRe.hasMatch(this);

  /// Whether the background color in the text changes.
  bool get hasBackground => backgroundRe.hasMatch(this);
}
