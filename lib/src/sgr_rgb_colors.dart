import 'csi.dart';
import 'sgr.dart';

//
// Rgb colors.
//

const _colorComponentAssert =
    'The rgb color component must be in the range 0..255';

/// Opening tag for foreground by RGB.
///
/// Template: `${fgRgbOpen}${r};${g};${b}${fgRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [fgRgb].
/// Foreground rgbOpen.
const String fgRgbOpen = '${csi}38;2;';

/// Closing tag for foreground by RGB.
///
/// See [fgRgbOpen].
const String fgRgbClose = sgr;

/// Set color to foreground by RGB.
///
/// See also [fgRgbOpen] and [fgRgbClose].
String fgRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);

  return '$fgRgbOpen$r;$g;$b$fgRgbClose';
}

/// Opening tag for background by RGB.
///
/// Template: `${bgRgbOpen}${r};${g};${b}${bgRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
const String bgRgbOpen = '${csi}48;2;';

/// Closing tag for background by RGB.
///
/// See [bgRgbOpen].
const String bgRgbClose = sgr;

/// Set color to background by RGB.
///
/// See also [bgRgbOpen] and [bgRgbClose].
String bgRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);

  return '$bgRgbOpen$r;$g;$b$bgRgbClose';
}

/// Opening tag for underline by RGB.
///
/// Template: `${underlineRgbOpen}${r};${g};${b}${underlineRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
const String underlineRgbOpen = '${csi}58;2;';

/// Closing tag for underline by RGB.
///
/// See [underlineRgbOpen].
const String underlineRgbClose = sgr;

/// Set color to underline by RGB.
///
/// See also [underlineRgbOpen] and [underlineRgbClose].
String underlineRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);

  return '$underlineRgbOpen$r;$g;$b$underlineRgbClose';
}
