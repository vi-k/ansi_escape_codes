import '../../escape_sequences/escape_sequences.dart';
import '../csi.dart';

//
// Standard colors.
//

// Compatibility:
// - +vscode
// - +mac Terminal
// - +mac iTerm2
// - +as

/// Foreground black.
const String fgBlack = '${csi}30$sgr';

/// Foreground red.
const String fgRed = '${csi}31$sgr';

/// Foreground green.
const String fgGreen = '${csi}32$sgr';

/// Foreground yellow.
const String fgYellow = '${csi}33$sgr';

/// Foreground blue.
const String fgBlue = '${csi}34$sgr';

/// Foreground magenta.
const String fgMagenta = '${csi}35$sgr';

/// Foreground cyan.
const String fgCyan = '${csi}36$sgr';

/// Foreground white.
const String fgWhite = '${csi}37$sgr';

/// Background black.
const String bgBlack = '${csi}40$sgr';

/// Background red.
const String bgRed = '${csi}41$sgr';

/// Background green.
const String bgGreen = '${csi}42$sgr';

/// Background yellow.
const String bgYellow = '${csi}43$sgr';

/// Background blue.
const String bgBlue = '${csi}44$sgr';

/// Background magenta.
const String bgMagenta = '${csi}45$sgr';

/// Background cyan.
const String bgCyan = '${csi}46$sgr';

/// Background white.
const String bgWhite = '${csi}47$sgr';

/// Foreground bright black.
const String fgBrightBlack = '${csi}90$sgr';

/// Foreground bright red.
const String fgBrightRed = '${csi}91$sgr';

/// Foreground bright green.
const String fgBrightGreen = '${csi}92$sgr';

/// Foreground bright yellow.
const String fgBrightYellow = '${csi}93$sgr';

/// Foreground bright blue.
const String fgBrightBlue = '${csi}94$sgr';

/// Foreground bright magenta.
const String fgBrightMagenta = '${csi}95$sgr';

/// Foreground bright cyan.
const String fgBrightCyan = '${csi}96$sgr';

/// Foreground bright white.
const String fgBrightWhite = '${csi}97$sgr';

/// Background bright black.
const String bgBrightBlack = '${csi}100$sgr';

/// Background bright red.
const String bgBrightRed = '${csi}101$sgr';

/// Background bright green.
const String bgBrightGreen = '${csi}102$sgr';

/// Background bright yellow.
const String bgBrightYellow = '${csi}103$sgr';

/// Background bright blue.
const String bgBrightBlue = '${csi}104$sgr';

/// Background bright magenta.
const String bgBrightMagenta = '${csi}105$sgr';

/// Background bright cyan.
const String bgBrightCyan = '${csi}106$sgr';

/// Background bright white.
const String bgBrightWhite = '${csi}107$sgr';

/// Default foreground color.
const String fgDefault = '${csi}39$sgr';

/// Default background color.
const String bgDefault = '${csi}49$sgr';

/// Default underline color.
const String underlineDefault = '${csi}59$sgr';
