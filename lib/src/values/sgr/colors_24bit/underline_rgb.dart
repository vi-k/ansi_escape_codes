import '../../csi.dart';
import '../../escape_codes.dart';
import 'assert.dart';

//
// ANSI escape codes for underline color by RGB.
//

/// Opening tag for underline by RGB.
///
/// Not in standard!
///
/// Template: `${underlineRgbOpen}${r};${g};${b}${underlineRgbClose}`
///
/// Compatibility:
/// - +vscode
/// - +mac iTerm2
///
/// The following terminals mistakenly take each parameter as a command:
/// - CSI 58;5;3 SGR (underline256Yellow) -> blink, italic
/// - CSI 58;2;3;4;7 SGR (underlineRgb(3,4,7)) -> faint, italic, underline,
///   reverse
///
/// - -as
/// - -mac Terminal
/// - -mac Warp
const String underlineRgbOpen = '${csi}58;2;';

/// Closing tag for underline by RGB.
///
/// See [underlineRgbOpen].
const String underlineRgbClose = sgr;

/// Set color to underline by RGB.
///
/// See also [underlineRgbOpen] and [underlineRgbClose].
String underlineRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, colorComponentAssert);
  assert(g >= 0 && g <= 255, colorComponentAssert);
  assert(b >= 0 && b <= 255, colorComponentAssert);

  return '$underlineRgbOpen$r;$g;$b$underlineRgbClose';
}
