import 'patterns.dart';

/// Has escape sequences?
bool hasEscapeSequences(String text) => escRe.hasMatch(text);

/// Has CSI?
bool hasCsi(String text) => csiRe.hasMatch(text);

/// Has SGR?
bool hasSgr(String text) => sgrRe.hasMatch(text);

/// Has foreground color?
bool hasForegroundColor(String text) => foregroundRe.hasMatch(text);

/// Has background color?
bool hasBackgroundColor(String text) => backgroundRe.hasMatch(text);
