import 'patterns.dart';

/// Remove all escape sequences in [text].
String removeEscapeSequences(String text) => text.replaceAll(escRe, '');

/// Remove all CSI in [text].
String removeCsi(String text) => text.replaceAll(csiRe, '');

/// Remove all sgr in [text].
String removeSgr(String text) => text.replaceAll(sgrRe, '');

/// Remove all background colors in [text].
String removeBackgroundColors(String text) => text.replaceAll(backgroundRe, '');

/// Remove all foreground colors in [text].
String removeForegroundColors(String text) => text.replaceAll(foregroundRe, '');
