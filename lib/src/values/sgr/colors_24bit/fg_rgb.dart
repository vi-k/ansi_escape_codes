import '../../csi.dart';
import '../../escape_codes.dart';
import 'assert.dart';

//
// ANSI escape codes for foreground color by RGB.
//

/// Opening tag for foreground by RGB.
///
/// Template: `${fgRgbOpen}${r};${g};${b}${fgRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - +as
/// - -mac Terminal
/// - +mac iTerm2
/// - +mac Warp
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
  assert(r >= 0 && r <= 255, colorComponentAssert);
  assert(g >= 0 && g <= 255, colorComponentAssert);
  assert(b >= 0 && b <= 255, colorComponentAssert);

  return '$fgRgbOpen$r;$g;$b$fgRgbClose';
}
