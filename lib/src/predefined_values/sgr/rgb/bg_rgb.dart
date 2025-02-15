import '../../../controls/c1.dart';
import '../../../controls/csi.dart';
import '../../../controls/sgr.dart';

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
const String bgRgbOpen = '$CSI$BACKGROUND;$COLOR_RGB;';

/// Closing tag for background by RGB.
///
/// See [bgRgbOpen].
const String bgRgbClose = SGR;

/// Set color to background by RGB.
///
/// See also [bgRgbOpen] and [bgRgbClose].
String bgRgb(int r, int g, int b) {
  IndexError.check(r, 256, name: 'r');
  IndexError.check(g, 256, name: 'g');
  IndexError.check(b, 256, name: 'b');

  return '$CSI$BACKGROUND;$COLOR_RGB;$r;$g;$b$SGR';
}
