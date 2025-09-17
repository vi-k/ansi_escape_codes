/// Standard colors.
///
/// Compatibility:
/// - +vscode
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
library;

import '../../../controls/c1.dart';
import '../../../controls/csi.dart';
import '../../../controls/sgr.dart';

/// Black display.
const String fgBlack = '$CSI$FG_BLACK$SGR';

/// Red display.
const String fgRed = '$CSI$FG_RED$SGR';

/// Green display.
const String fgGreen = '$CSI$FG_GREEN$SGR';

/// Yellow display.
const String fgYellow = '$CSI$FG_YELLOW$SGR';

/// Blue display.
const String fgBlue = '$CSI$FG_BLUE$SGR';

/// Magenta display.
const String fgMagenta = '$CSI$FG_MAGENTA$SGR';

/// Cyan display.
const String fgCyan = '$CSI$FG_CYAN$SGR';

/// White display.
const String fgWhite = '$CSI$FG_WHITE$SGR';

/// Black background.
const String bgBlack = '$CSI$BG_BLACK$SGR';

/// Red background.
const String bgRed = '$CSI$BG_RED$SGR';

/// Green background.
const String bgGreen = '$CSI$BG_GREEN$SGR';

/// Yellow background.
const String bgYellow = '$CSI$BG_YELLOW$SGR';

/// Blue background.
const String bgBlue = '$CSI$BG_BLUE$SGR';

/// Magenta background.
const String bgMagenta = '$CSI$BG_MAGENTA$SGR';

/// Cyan background.
const String bgCyan = '$CSI$BG_CYAN$SGR';

/// White background.
const String bgWhite = '$CSI$BG_WHITE$SGR';

/// High black display.
const String fgHighBlack = '$CSI$FG_HIGH_BLACK$SGR';

/// High red display.
const String fgHighRed = '$CSI$FG_HIGH_RED$SGR';

/// High green display.
const String fgHighGreen = '$CSI$FG_HIGH_GREEN$SGR';

/// High yellow display.
const String fgHighYellow = '$CSI$FG_HIGH_YELLOW$SGR';

/// High blue display.
const String fgHighBlue = '$CSI$FG_HIGH_BLUE$SGR';

/// High magenta display.
const String fgHighMagenta = '$CSI$FG_HIGH_MAGENTA$SGR';

/// High cyan display.
const String fgHighCyan = '$CSI$FG_HIGH_CYAN$SGR';

/// High white display.
const String fgHighWhite = '$CSI$FG_HIGH_WHITE$SGR';

/// High black background.
const String bgHighBlack = '$CSI$BG_HIGH_BLACK$SGR';

/// High red background.
const String bgHighRed = '$CSI$BG_HIGH_RED$SGR';

/// High green background.
const String bgHighGreen = '$CSI$BG_HIGH_GREEN$SGR';

/// High yellow background.
const String bgHighYellow = '$CSI$BG_HIGH_YELLOW$SGR';

/// High blue background.
const String bgHighBlue = '$CSI$BG_HIGH_BLUE$SGR';

/// High magenta background.
const String bgHighMagenta = '$CSI$BG_HIGH_MAGENTA$SGR';

/// High cyan background.
const String bgHighCyan = '$CSI$BG_HIGH_CYAN$SGR';

/// High white background.
const String bgHighWhite = '$CSI$BG_HIGH_WHITE$SGR';

/// Default display color (implementation-defined).
const String resetFg = '$CSI$FG_DEFAULT$SGR';

/// Default background color (implementation-defined).
const String resetBg = '$CSI$BG_DEFAULT$SGR';

/// Default underline color.
const String resetUnderlineColor = '$CSI$UNDERLINE_COLOR_DEFAULT$SGR';
