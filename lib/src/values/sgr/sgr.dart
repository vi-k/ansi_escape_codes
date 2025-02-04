import '../csi.dart';
import '../escape_codes.dart';

/// Reset or normal.
///
/// All attributes become turned off.
///
/// Compatibility:
/// - +vscode
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
const String reset = '${csi}0$sgr';

/// Bold or increased intensity.
///
/// Compatibility:
/// - -vscode
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
///
/// See also [faint] and [neitherBoldNorFaint].
const String bold = '${csi}1$sgr';

/// Faint, decreased intensity, or dim.
///
/// Compatibility:
/// - +vscode
/// - -as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
///
/// See also [bold] and [neitherBoldNorFaint].
const String faint = '${csi}2$sgr';

/// Italic.
///
/// Not widely supported. Sometimes treated as inverse or blink.
///
/// Compatibility:
/// - +vscode
/// - +as
/// - -mac Terminal
/// - +mac iTerm2
/// - +mac Warp
///
/// See also [notItalic].
const String italic = '${csi}3$sgr';

/// Underline.
///
/// Compatibility:
/// - +vscode
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
///
/// Colors:
/// - +-vscode (only rgb colors)
///
/// See also [notUnderlined] and [doublyUnderlined].
const String underline = '${csi}4$sgr';

/// Slow blink.
///
/// Sets blinking to less than 150 times per minute.
///
/// Compatibility:
/// - +vscode
/// - -as
/// - +mac Terminal
/// - -mac iTerm2
/// - -mac Warp
///
/// See also [rapidBlink] and [notBlinking].
const String blink = '${csi}5$sgr';

/// Rapid blink.
///
/// 150+ per minute. Not widely supported.
///
/// Compatibility:
/// - +vscode
/// - -as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
///
/// See also [blink] and [notBlinking].
const String rapidBlink = '${csi}6$sgr';

/// Reverse video or invert.
///
/// Swap foreground and background colors. Inconsistent emulation.
///
/// Compatibility:
/// - +-vscode (does not reverse the default colors)
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
///
/// See also [notReversed].
const String reverse = '${csi}7$sgr';

/// Conceal or hide.
///
/// Not widely supported.
///
/// Compatibility:
/// - +vscode
/// - -as
/// - +mac Terminal
/// - +mac iTerm2
/// - -mac Warp
///
/// See also [reveal].
const String conceal = '${csi}8$sgr';

/// Crossed-out, or strike.
///
/// Characters legible but marked as if for deletion.
///
/// Compatibility:
/// - +vscode
/// - +as
/// - -mac Terminal
/// - +mac iTerm2
/// - +mac Warp
///
/// Crossed out + underline:
/// - +vscode
/// - +mac iTerm2
/// - -mac Warp (underline has priority)
/// - +as
///
/// See also [notCrossedOut].
const String crossedOut = '${csi}9$sgr';

/// Doubly underlined.
///
/// Double-underline per ECMA-48, but instead disables bold intensity on
/// several terminals, including in the Linux kernel's console before version
/// 4.17.
///
/// Compatibility:
/// - +vscode
/// - +as (one thick line)
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
///
/// Colors:
/// - +-vscode (only rgb colors)
///
/// See also [notUnderlined] and [underline].
const String doublyUnderlined = '${csi}21$sgr';

/// Normal intensity. Neither bold nor faint.
///
/// See also [bold] and [faint].
const String neitherBoldNorFaint = '${csi}22$sgr';

/// Not italic.
///
/// See also [italic].
const String notItalic = '${csi}23$sgr';

/// Not underlined.
///
/// Neither singly nor doubly underlined.
///
/// See also [underline] and [doublyUnderlined].
const String notUnderlined = '${csi}24$sgr';

/// Not blinking.
///
/// Turn blinking off.
///
/// See also [blink] and [rapidBlink].
const String notBlinking = '${csi}25$sgr';

/// Not reversed.
///
/// See also [reverse].
const String notReversed = '${csi}27$sgr';

/// Reveal.
///
/// See also [conceal].
const String reveal = '${csi}28$sgr';

/// Not crossed out.
///
/// See also [crossedOut].
const String notCrossedOut = '${csi}29$sgr';

/// Framed.
///
/// Compatibility:
/// - -vscode
/// - +as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
///
/// See also [neitherFramedNorEncircled].
const String framed = '${csi}51$sgr';

/// Encircled.
///
/// Compatibility:
/// - -vscode
/// - +as (same as [framed])
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
///
/// See also [neitherFramedNorEncircled].
const String encircled = '${csi}52$sgr';

/// Overlined.
///
/// Compatibility:
/// - +vscode
/// - -as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
///
/// Overlined + underline:
/// - +vscode
///
/// Overlined + crossed out:
/// - +vscode
///
/// Colors:
/// - +-vscode (only rgb colors)
///
/// See also [notOverlined].
const String overlined = '${csi}53$sgr';

/// Neither framed nor encircled.
///
/// See [framed] and [encircled].
const String neitherFramedNorEncircled = '${csi}54$sgr';

/// Not overlined.
///
/// See also [overlined].
const String notOverlined = '${csi}55$sgr';

/// Superscript.
///
/// Compatibility:
/// - +vscode
/// - -as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
///
/// See also [subscript] and [netherSuperscriptedNorSubscripted].
const String superscript = '${csi}73$sgr';

/// Subscript.
///
/// Compatibility:
/// - +vscode
/// - -as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
///
/// See also [superscript] and [netherSuperscriptedNorSubscripted].
const String subscript = '${csi}74$sgr';

/// Neither superscript nor subscript.
///
/// See also [superscript] and [subscript].
const String netherSuperscriptedNorSubscripted = '${csi}75$sgr';
