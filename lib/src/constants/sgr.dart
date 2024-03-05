import 'csi.dart';

/// SGR (Select Graphic Rendition): CSI {n} m

const String sgr = 'm';

/// All attributes become turned off.
///
/// +vscode
/// +mac Terminal
/// +mac iTerm2
/// +as
const String reset = '${csi}0$sgr';
const String normal = reset;

/// -vscode
/// +mac Terminal
/// +mac iTerm2
/// +as
const String bold = '${csi}1$sgr';
const String increasedIntensity = bold;

/// +vscode
/// +mac Terminal
/// +mac iTerm2
/// -as
const String faint = '${csi}2$sgr';
const String decreasedIntensity = faint;
const String dim = faint;

/// +vscode
/// -mac Terminal
/// +mac iTerm2
/// +as
const String italic = '${csi}3$sgr';

/// +vscode
/// +mac Terminal
/// +mac iTerm2
/// +as
const String underline = '${csi}4$sgr';

/// +vscode
/// +mac Terminal
/// -mac iTerm2
/// -as
const String blink = '${csi}5$sgr';

/// +vscode
/// -mac Terminal
/// -mac iTerm2
/// -as
const String rapidBlink = '${csi}6$sgr';

/// +-vscode (does not invert the default colors)
/// +mac Terminal
/// +mac iTerm2
/// +as
const String reverse = '${csi}7$sgr';
const String invert = reverse;

/// +vscode
/// +mac Terminal
/// -mac iTerm2
/// -as
const String conceal = '${csi}8$sgr';
const String hide = conceal;

/// +vscode
/// -mac Terminal
/// +mac iTerm2
/// +as
const String crossedOut = '${csi}9$sgr';
const String strike = crossedOut;

/// +vscode
/// -mac Terminal
/// -mac iTerm2
/// +as (one thick line)
const String doublyUnderlined = '${csi}21$sgr';

/// +vscode
/// +mac Terminal
/// +mac iTerm2
/// +as
const String normalIntensity = '${csi}22$sgr';

/// +vscode
/// -mac Terminal
/// +mac iTerm2
/// +as
const String notItalic = '${csi}23$sgr';

/// +vscode
/// +mac Terminal
/// +mac iTerm2
/// +as
const String notUnderlined = '${csi}24$sgr';

/// +vscode
/// +mac Terminal
/// -mac iTerm2
/// -as
const String notBlinking = '${csi}25$sgr';

/// +vscode
/// +mac Terminal
/// +mac iTerm2
/// +as
const String notReversed = '${csi}27$sgr';
const String notInverted = notReversed;

/// ?vscode
/// ?mac Terminal
/// ?mac iTerm2
/// ?as
const String reveal = '${csi}28$sgr';
const String notHide = reveal;

/// +vscode
/// -mac Terminal
/// +mac iTerm2
/// ?as
const String notCrossedOut = '${csi}29$sgr';
const String notStrike = notCrossedOut;

/// -vscode
/// -mac Terminal
/// -mac iTerm2
/// +as
const String framed = '${csi}51$sgr';

/// -vscode
/// -mac Terminal
/// -mac iTerm2
/// +as (same as framed)
const String encircled = '${csi}52$sgr';

/// +vscode
/// -mac Terminal
/// -mac iTerm2
/// -as
const String overlined = '${csi}53$sgr';

/// -vscode
/// -mac Terminal
/// -mac iTerm2
/// +as
const String notFramedNotEncircled = '${csi}54$sgr';

/// +vscode
/// -mac Terminal
/// -mac iTerm2
/// -as
const String notOverlined = '${csi}55$sgr';

/// +vscode
/// -mac Terminal
/// -mac iTerm2
/// -as
const String superscript = '${csi}73$sgr';

/// +vscode
/// -mac Terminal
/// -mac iTerm2
/// -as
const String subscript = '${csi}74$sgr';

/// +vscode
/// -mac Terminal
/// -mac iTerm2
/// -as
const String notSuperscriptNotSubscript = '${csi}75$sgr';

//
// Standard colors
//
// +vscode
// +mac Terminal
// +mac iTerm2
// +as

const String fgBlack = '${csi}30$sgr';
const String fgRed = '${csi}31$sgr';
const String fgGreen = '${csi}32$sgr';
const String fgYellow = '${csi}33$sgr';
const String fgBlue = '${csi}34$sgr';
const String fgMagenta = '${csi}35$sgr';
const String fgCyan = '${csi}36$sgr';
const String fgWhite = '${csi}37$sgr';
const String fgDefault = '${csi}39$sgr';
const String bgBlack = '${csi}40$sgr';
const String bgRed = '${csi}41$sgr';
const String bgGreen = '${csi}42$sgr';
const String bgYellow = '${csi}43$sgr';
const String bgBlue = '${csi}44$sgr';
const String bgMagenta = '${csi}45$sgr';
const String bgCyan = '${csi}46$sgr';
const String bgWhite = '${csi}47$sgr';
const String bgDefault = '${csi}49$sgr';
const String underlineColorDefault = '${csi}59$sgr';
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

//
// 256 colors table
//
// +vscode
// +mac Terminal
// +mac iTerm2
// +as

const String fg256Open = '${csi}38;5;';
const String fg256Close = sgr;
const String bg256Open = '${csi}48;5;';
const String bg256Close = sgr;

// +vscode (not reset by the reset)
// -mac Terminal (blinks)
// -mac iTerm2
// -as (italic and underline)
const String underline256Open = '${csi}58;5;';
const String underline256Close = sgr;

//
// RGB colors
//
// +vscode
// -mac Terminal
// +mac iTerm2
// +as

const String fgRgbOpen = '${csi}38;2;';
const String fgRgbClose = sgr;
const String bgRgbOpen = '${csi}48;2;';
const String bgRgbClose = sgr;

// +vscode
// -mac Terminal
// -mac iTerm2
// -as
const String underlineRgbOpen = '${csi}58;2;';
const String underlineRgbClose = sgr;
