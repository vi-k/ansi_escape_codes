import '../../csi.dart';
import '../../escape_codes.dart';
import 'assert.dart';

//
// ANSI escape codes for background color by RGB.
//

/// Opening tag for background by RGB.
///
/// Template: `${bgRgbOpen}${r};${g};${b}${bgRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - +as
/// - -mac Terminal
/// - +mac iTerm2
/// - +mac Warp
const String bgRgbOpen = '${csi}48;2;';

/// Closing tag for background by RGB.
///
/// See [bgRgbOpen].
const String bgRgbClose = sgr;

/// Set color to background by RGB.
///
/// See also [bgRgbOpen] and [bgRgbClose].
String bgRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, colorComponentAssert);
  assert(g >= 0 && g <= 255, colorComponentAssert);
  assert(b >= 0 && b <= 255, colorComponentAssert);

  return '$bgRgbOpen$r;$g;$b$bgRgbClose';
}
