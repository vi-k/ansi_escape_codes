import 'csi.dart';
import 'sgr.dart';

const _colorNumberAssert = 'The color number must be in the range 0..255';
const _colorComponentAssert =
    'The rgb color component must be in the range 0..255';

// Standard colors
//
// Compatibility:
// - +vscode
// - +mac Terminal
// - +mac iTerm2
// - +as

const String fgBlack = '${csi}30$sgr';
const String fgRed = '${csi}31$sgr';
const String fgGreen = '${csi}32$sgr';
const String fgYellow = '${csi}33$sgr';
const String fgBlue = '${csi}34$sgr';
const String fgMagenta = '${csi}35$sgr';
const String fgCyan = '${csi}36$sgr';
const String fgWhite = '${csi}37$sgr';
const String bgBlack = '${csi}40$sgr';
const String bgRed = '${csi}41$sgr';
const String bgGreen = '${csi}42$sgr';
const String bgYellow = '${csi}43$sgr';
const String bgBlue = '${csi}44$sgr';
const String bgMagenta = '${csi}45$sgr';
const String bgCyan = '${csi}46$sgr';
const String bgWhite = '${csi}47$sgr';
const String fgBrightBlack = '${csi}90$sgr';
const String fgBrightRed = '${csi}91$sgr';
const String fgBrightGreen = '${csi}92$sgr';
const String fgBrightYellow = '${csi}93$sgr';
const String fgBrightBlue = '${csi}94$sgr';
const String fgBrightMagenta = '${csi}95$sgr';
const String fgBrightCyan = '${csi}96$sgr';
const String fgBrightWhite = '${csi}97$sgr';
const String bgBrightBlack = '${csi}100$sgr';
const String bgBrightRed = '${csi}101$sgr';
const String bgBrightGreen = '${csi}102$sgr';
const String bgBrightYellow = '${csi}103$sgr';
const String bgBrightBlue = '${csi}104$sgr';
const String bgBrightMagenta = '${csi}105$sgr';
const String bgBrightCyan = '${csi}106$sgr';
const String bgBrightWhite = '${csi}107$sgr';

/// Opening tag for foreground with 256-color table.
///
/// Template: `{fg256Open}{color}{fg256Close}`
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See [colors256.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256.dart)
/// for colors. See predefined constants starting with `fg256*` in the
/// [colors256_foreground.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256_foreground.dart).
///
/// See also [fg256].
const String fg256Open = '${csi}38;5;';

/// Closing tag for foreground with 256-color table.
///
/// Template: `{fg256Open}{color}{fg256Close}`
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See [colors256.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256.dart)
/// for colors. See predefined constants starting with `fg256*` in the
/// [colors256_foreground.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256_foreground.dart).
///
/// See also [fg256].
const String fg256Close = sgr;

/// Set color to foreground from 256-color table.
///
/// See also [fg256Open].
String fg256(int color) {
  assert(color >= 0 && color <= 255, _colorNumberAssert);
  return '$fg256Open$color$fg256Close';
}

/// Opening tag for background with 256-color table.
///
/// Template: `{bg256Open}{color}{bg256Close}`
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// 256-color table see in the [colors256.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256.dart).
/// See also predefined constants starting with `bg256*` in the
/// [colors256_background.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256_background.dart).
///
/// See also [fg256].
const String bg256Open = '${csi}48;5;';

/// Closing tag for background with 256-color table.
///
/// Template: `{bg256Open}{color}{bg256Close}`
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// 256-color table see in the [colors256.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256.dart).
/// See also predefined constants starting with `bg256*` in the
/// [colors256_background.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256_background.dart).
///
/// See also [fg256].
const String bg256Close = sgr;

/// Set color to background from 256-color table.
///
/// See also [bg256Open].
String bg256(int color) {
  assert(color >= 0 && color <= 255, _colorNumberAssert);
  return '$bg256Open$color$bg256Close';
}

/// Opening tag for underline with 256-color table.
///
/// Template: `{underline256Open}{color}{underline256Close}`
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// 256-color table see in the [colors256.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256.dart).
/// See also predefined constants starting with `underline256*` in the
/// [colors256_underline.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256_underline.dart).
///
/// See also [underline256].
const String underline256Open = '${csi}58;5;';

/// Closing tag for underline with 256-color table.
///
/// Template: `{underline256Open}{color}{underline256Close}`
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// 256-color table see in the [colors256.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256.dart).
/// See also predefined constants starting with `underline256*` in the
/// [colors256_underline.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/colors256_underline.dart).
///
/// See also [underline256].
const String underline256Close = sgr;

/// Set color to underline from 256-color table.
///
/// See also [underline256Open].
String underline256(int color) {
  assert(color >= 0 && color <= 255, _colorNumberAssert);
  return '$underline256Open$color$underline256Close';
}

/// Opening tag for foreground by RGB.
///
/// Template: `{fgRgbOpen}{r};{g};{b}{fgRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [fgRgb].
const String fgRgbOpen = '${csi}38;2;';

/// Closing tag for foreground by RGB.
///
/// Template: `{fgRgbOpen}{r};{g};{b}{fgRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
const String fgRgbClose = sgr;

/// Set color to foreground by RGB.
///
/// See also [fgRgbOpen].
String fgRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);
  return '$fgRgbOpen$r;$g;$b$fgRgbClose';
}

/// Opening tag for background by RGB.
///
/// Template: `{bgRgbOpen}{r};{g};{b}{bgRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
const String bgRgbOpen = '${csi}48;2;';

/// Closing tag for background by RGB.
///
/// Template: `{bgRgbOpen}{r};{g};{b}{bgRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
const String bgRgbClose = sgr;

/// Set color to background by RGB.
///
/// See also [bgRgbOpen].
String bgRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);
  return '$bgRgbOpen$r;$g;$b$bgRgbClose';
}

/// Opening tag for underline by RGB.
///
/// Template: `{underlineRgbOpen}{r};{g};{b}{underlineRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
const String underlineRgbOpen = '${csi}58;2;';

/// Closing tag for underline by RGB.
///
/// Template: `{underlineRgbOpen}{r};{g};{b}{underlineRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
const String underlineRgbClose = sgr;

/// Set color to underline by RGB.
///
/// See also [underlineRgbOpen].
String underlineRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);
  return '$underlineRgbOpen$r;$g;$b$underlineRgbClose';
}

/// Default foreground color.
const String fgDefault = '${csi}39$sgr';

/// Default background color.
const String bgDefault = '${csi}49$sgr';

/// Default underline color.
const String underlineDefault = '${csi}59$sgr';
