import '../parsing/patterns/patterns.dart';

extension StringRemoveEscapeCodesExtension on String {
  /// Removes any escape codes in the text.
  String ansiRemoveEscapeCodes() => replaceAll(escapeCodesRe, '');

  /// Removes control sequences (CSI) in the text.
  String ansiRemoveCsi() => replaceAll(csiRe, '');

  /// Removes SGR (Select Graphic Rendition) codes in the text.
  String ansiRemoveSgr() => replaceAll(sgrRe, '');

  /// Removes foreground colors in the text.
  String ansiRemoveForeground() => replaceAll(foregroundRe, '');

  /// Removes background colors in the text.
  String ansiRemoveBackground() => replaceAll(backgroundRe, '');
}
