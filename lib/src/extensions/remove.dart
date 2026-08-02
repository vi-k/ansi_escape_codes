import '../internal/sgr_functions.dart';
import '../parsing/patterns/patterns.dart';

/// Taking escape codes back out of a string, all of them or by kind.
extension StringRemoveEscapeCodesExtension on String {
  /// Removes any escape codes in the text.
  String ansiRemoveEscapeCodes() => replaceAll(escapeCodesRe, '');

  /// Removes control sequences (CSI) in the text.
  String ansiRemoveCsi() => replaceAll(csiRe, '');

  /// Removes SGR (Select Graphic Rendition) codes in the text.
  String ansiRemoveSgr() => replaceAll(sgrRe, '');

  /// Removes foreground colors in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 1;31 SGR` becomes
  /// `CSI 1 SGR`.
  String ansiRemoveForeground() =>
      removeSgrFunction(this, isForegroundFunction);

  /// Removes background colors in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 1;41 SGR` becomes
  /// `CSI 1 SGR`.
  String ansiRemoveBackground() =>
      removeSgrFunction(this, isBackgroundFunction);

  /// Removes the colors of the underline in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 4;58;5;1 SGR` becomes
  /// `CSI 4 SGR`, leaving the underline itself.
  String ansiRemoveUnderlineColor() =>
      removeSgrFunction(this, isUnderlineColorFunction);

  /// Returns the length of the string without escape codes.
  int get lengthWithoutEscapeCodes => ansiRemoveEscapeCodes().length;
}
