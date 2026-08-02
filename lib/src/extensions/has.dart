import '../internal/sgr_functions.dart';
import '../parsing/patterns/patterns.dart';

/// Asking a string whether it carries escape codes, and of what kind.
extension StringHasEscapeCodesExtension on String {
  /// Whether there any escape codes in the text.
  bool get ansiHasEscapeCodes => escapeCodesRe.hasMatch(this);

  /// Whether there control sequences (CSI) in the text.
  bool get ansiHasCsi => csiRe.hasMatch(this);

  /// Whether there SGR (Select Graphic Rendition) codes in the text.
  bool get ansiHasSgr => sgrRe.hasMatch(this);

  /// Whether the foreground color in the text changes.
  bool get ansiHasForeground => hasSgrFunction(this, isForegroundFunction);

  /// Whether the background color in the text changes.
  bool get ansiHasBackground => hasSgrFunction(this, isBackgroundFunction);

  /// Whether the color of the underline in the text changes.
  bool get ansiHasUnderlineColor =>
      hasSgrFunction(this, isUnderlineColorFunction);

  /// Whether there are control codes in the text: the C0 bytes, `ESC` and
  /// `DEL`, escape sequences or not.
  bool get ansiHasControlCodes => controlCodesRe.hasMatch(this);
}
