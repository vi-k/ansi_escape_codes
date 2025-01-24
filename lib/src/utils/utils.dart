import '../common.dart';

final _sgrRe = RegExp('$esc\\[\\d+(;\\d+)*m');

final _foregroundRe =
    RegExp('$esc\\[(3[0-79]|9[0-7]|38;5;\\d+|38;2;\\d+;\\d+;\\d+)m');

final _backgroundRe =
    RegExp('$esc\\[(4[0-79]|10[0-7]|48;5;\\d+|48;2;\\d+;\\d+;\\d+)m');

/// Show escape command symbol.
String showEsc(String text) => text.replaceAll(esc, 'ESC');

/// Has sgr?
bool hasSgr(String text) => _sgrRe.hasMatch(text);

/// Has foreground color?
bool hasForegroundColor(String text) => _foregroundRe.hasMatch(text);

/// Has background color?
bool hasBackgroundColor(String text) => _backgroundRe.hasMatch(text);

/// Returns all sgr in [text].
List<String> allSgr(String text) =>
    _sgrRe.allMatches(text).map((m) => m[0]!).toList();

/// Returns all foreground colors in [text].
List<String> foregroundColors(String text) =>
    _foregroundRe.allMatches(text).map((m) => m[0]!).toList();

/// Returns all background colors in [text].
List<String> backgroundColors(String text) =>
    _backgroundRe.allMatches(text).map((m) => m[0]!).toList();
