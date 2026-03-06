import '../parsing/patterns/patterns.dart';

extension StringRemoveEscapeCodesExtension on String {
  /// Removes any escape codes in the text.
  String ansiRemoveEscapeCodes() => replaceAll(escapeCodesRe, '');

  @Deprecated('Use ansiRemoveEscapeCodes instead')
  String removeEscapeCodes() => ansiRemoveEscapeCodes();

  /// Removes control sequences (CSI) in the text.
  String ansiRemoveCsi() => replaceAll(csiRe, '');

  @Deprecated('Use ansiRemoveCsi instead')
  String removeCsi() => ansiRemoveCsi();

  /// Removes SGR (Select Graphic Rendition) codes in the text.
  String ansiRemoveSgr() => replaceAll(sgrRe, '');

  @Deprecated('Use ansiRemoveSgr instead')
  String removeSgr() => ansiRemoveSgr();

  /// Removes foreground colors in the text.
  String ansiRemoveForeground() => replaceAll(foregroundRe, '');

  @Deprecated('Use ansiRemoveForeground instead')
  String removeForeground() => ansiRemoveForeground();

  /// Removes background colors in the text.
  String ansiRemoveBackground() => replaceAll(backgroundRe, '');

  @Deprecated('Use ansiRemoveBackground instead')
  String removeBackground() => ansiRemoveBackground();
}
