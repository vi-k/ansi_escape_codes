import '../parsing/patterns/patterns.dart';

extension StringRemoveEscapeCodesExtension on String {
  /// Removes any escape codes in the text.
  String removeEscapeCodes() => replaceAll(escapeCodesRe, '');

  /// Removes control sequences (CSI) in the text.
  String removeCsi() => replaceAll(csiRe, '');

  /// Removes SGR (Select Graphic Rendition) codes in the text.
  String removeSgr() => replaceAll(sgrRe, '');

  /// Removes foreground colors in the text.
  String removeForeground() => replaceAll(foregroundRe, '');

  /// Removes background colors in the text.
  String removeBackground() => replaceAll(backgroundRe, '');
}
