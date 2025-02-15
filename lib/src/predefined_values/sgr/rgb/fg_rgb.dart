import '../../../controls/c1.dart';
import '../../../controls/csi.dart';
import '../../../controls/sgr.dart';

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
const String fgRgbOpen = '$CSI$FOREGROUND;$COLOR_RGB;';

/// Closing tag for foreground by RGB.
///
/// See [fgRgbOpen].
const String fgRgbClose = SGR;

/// Set color to foreground by RGB.
///
/// See also [fgRgbOpen] and [fgRgbClose].
String fgRgb(int r, int g, int b) {
  IndexError.check(r, 256, name: 'r');
  IndexError.check(g, 256, name: 'g');
  IndexError.check(b, 256, name: 'b');

  return '$CSI$FOREGROUND;$COLOR_RGB;$r;$g;$b$SGR';
}
