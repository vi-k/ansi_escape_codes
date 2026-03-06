import '../parsing/patterns/patterns.dart';

extension StringHasEscapeCodesExtension on String {
  @Deprecated('Use ansiHasEscapeCodes instead')
  bool get hasEscapeCodes => ansiHasEscapeCodes;

  /// Whether there any escape codes in the text.
  bool get ansiHasEscapeCodes => escapeCodesRe.hasMatch(this);

  @Deprecated('Use ansiHasCsi instead')
  bool get hasCsi => ansiHasCsi;

  /// Whether there control sequences (CSI) in the text.
  bool get ansiHasCsi => csiRe.hasMatch(this);

  @Deprecated('Use ansiHasSgr instead')
  bool get hasSgr => ansiHasSgr;

  /// Whether there SGR (Select Graphic Rendition) codes in the text.
  bool get ansiHasSgr => sgrRe.hasMatch(this);

  @Deprecated('Use ansiHasForeground instead')
  bool get hasForeground => ansiHasForeground;

  /// Whether the foreground color in the text changes.
  bool get ansiHasForeground => foregroundRe.hasMatch(this);

  @Deprecated('Use ansiHasBackground instead')
  bool get hasBackground => ansiHasBackground;

  /// Whether the background color in the text changes.
  bool get ansiHasBackground => backgroundRe.hasMatch(this);
}
