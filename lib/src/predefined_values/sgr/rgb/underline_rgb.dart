import '../../../controls/c1.dart';
import '../../../controls/csi.dart';
import '../../../controls/sgr.dart';

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
/// - CSI 58;5;3 SGR (underline256Yellow) -> blink, italicized
/// - CSI 58;2;3;4;7 SGR (underlineRgb(3,4,7)) -> faint, italicized, underlined,
///   negative
///
/// - -as
/// - -mac Terminal
/// - -mac Warp
const String underlineRgbOpen = '$CSI$UNDERLINE_COLOR;$COLOR_RGB;';

/// Closing tag for underline by RGB.
///
/// See [underlineRgbOpen].
const String underlineRgbClose = SGR;

/// Set color to underline by RGB.
///
/// See also [underlineRgbOpen] and [underlineRgbClose].
String underlineRgb(int r, int g, int b) {
  IndexError.check(r, 256, name: 'r');
  IndexError.check(g, 256, name: 'g');
  IndexError.check(b, 256, name: 'b');

  return '$CSI$UNDERLINE_COLOR;$COLOR_RGB;$r;$g;$b$SGR';
}
