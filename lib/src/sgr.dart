import 'csi.dart';

/// SGR (Select Graphic Rendition): CSI {n} m
const String sgr = 'm';

/// Reset or normal.
///
/// All attributes become turned off.
///
/// Same as [normal].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
const String reset = '${csi}0$sgr';

/// Reset or normal.
///
/// All attributes become turned off.
///
/// Same as [reset].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
const String normal = reset;

/// Bold or increased intensity.
///
/// Same as [increasedIntensity].
///
/// Compatibility:
/// - -vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [faint], [dim], [notBoldNotFaint], [notBoldNotDim].
const String bold = '${csi}1$sgr';

/// Bold or increased intensity.
///
/// Same as [bold].
///
/// Compatibility:
/// - -vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [decreasedIntensity], [normalIntensity].
const String increasedIntensity = bold;

/// Faint, decreased intensity, or dim.
///
/// Same as [decreasedIntensity] and [dim].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - -as
///
/// See also [bold], [notBoldNotFaint].
const String faint = '${csi}2$sgr';

/// Faint, decreased intensity, or dim.
///
/// Same as [faint] and [dim].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - -as
///
/// See also [increasedIntensity], [normalIntensity].
const String decreasedIntensity = faint;

/// Faint, decreased intensity, or dim.
///
/// Same as [faint] and [decreasedIntensity].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - -as
///
/// See also [bold], [notBoldNotDim].
const String dim = faint;

/// Italic.
///
/// Not widely supported. Sometimes treated as inverse or blink.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [notItalic].
const String italic = '${csi}3$sgr';

/// Underline.
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [notUnderlined] and [doublyUnderlined].
const String underline = '${csi}4$sgr';

/// Slow blink.
///
/// Sets blinking to less than 150 times per minute.
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [notBlinking].
const String blink = '${csi}5$sgr';

/// Rapid blink.
///
/// 150+ per minute. Not widely supported.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [notBlinking].
const String rapidBlink = '${csi}6$sgr';

/// Reverse video or invert.
///
/// Swap foreground and background colors. Inconsistent emulation.
///
/// Same as [invert].
///
/// Compatibility:
/// +- -vscode (does not invert the default colors)
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [notReversed].
const String reverse = '${csi}7$sgr';

/// Reverse video or invert.
///
/// Swap foreground and background colors. Inconsistent emulation.
///
/// Same as [reverse].
///
/// Compatibility:
/// +- -vscode (does not invert the default colors)
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [notInverted].
const String invert = reverse;

/// Conceal or hide.
///
/// Not widely supported.
///
/// Same as [hide].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [reveal].
const String conceal = '${csi}8$sgr';

/// Conceal or hide.
///
/// Not widely supported.
///
/// Same as [conceal].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [notHidden].
const String hide = conceal;

/// Crossed-out, or strike.
///
/// Characters legible but marked as if for deletion.
///
/// Same as [strike].
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [notCrossedOut].
const String crossedOut = '${csi}9$sgr';

/// Crossed-out, or strike.
///
/// Characters legible but marked as if for deletion.
///
/// Same as [crossedOut].
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [notStriked].
const String strike = crossedOut;

/// Doubly underlined.
///
/// Double-underline per ECMA-48, but instead disables bold intensity on
/// several terminals, including in the Linux kernel's console before version
/// 4.17.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - +as (one thick line)
///
/// See also [notUnderlined] and [underline].
const String doublyUnderlined = '${csi}21$sgr';

/// Normal intensity.
///
/// Neither bold nor faint.
///
/// Same as [notBoldNotFaint] and [notBoldNotDim].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [increasedIntensity] and [decreasedIntensity].
const String normalIntensity = '${csi}22$sgr';

/// Normal intensity.
///
/// Neither bold nor faint.
///
/// Same as [normalIntensity] and [notBoldNotDim].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [bold] and [faint].
const String notBoldNotFaint = normalIntensity;

/// Normal intensity.
///
/// Neither bold nor faint.
///
/// Same as [normalIntensity] and [notBoldNotFaint].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [bold] and [dim].
const String notBoldNotDim = normalIntensity;

/// Not italic.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [italic].
const String notItalic = '${csi}23$sgr';

/// Not underlined.
///
/// Neither singly nor doubly underlined.
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [underline] and [doublyUnderlined].
const String notUnderlined = '${csi}24$sgr';

/// Not blinking.
///
/// Turn blinking off.
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [blink] and [rapidBlink].
const String notBlinking = '${csi}25$sgr';

/// Not reversed.
///
/// Same as [notInverted].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [reverse].
const String notReversed = '${csi}27$sgr';

/// Not inverted.
///
/// Same as [notReversed].
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See also [invert].
const String notInverted = notReversed;

/// Reveal.
///
/// Same as [notHidden].
///
/// Compatibility:
/// - ?vscode
/// - ?mac Terminal
/// - ?mac iTerm2
/// - ?as
///
/// See also [conceal].
const String reveal = '${csi}28$sgr';

/// Not hidden.
///
/// Same as [reveal].
///
/// Compatibility:
/// - ?vscode
/// - ?mac Terminal
/// - ?mac iTerm2
/// - ?as
///
/// See also [hide].
const String notHidden = reveal;

/// Not crossed out.
///
/// Same as [notStriked].
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - ?as
///
/// See also [crossedOut].
const String notCrossedOut = '${csi}29$sgr';

/// Not striked.
///
/// Same as [notCrossedOut].
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - +mac iTerm2
/// - ?as
///
/// See also [strike].
const String notStriked = notCrossedOut;

/// Framed.
///
/// Compatibility:
/// - -vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - +as
///
/// See also [notFramedNotEncircled].
const String framed = '${csi}51$sgr';

/// Encircled.
///
/// Compatibility:
/// - -vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - +as (same as [framed])
///
/// See also [notFramedNotEncircled].
const String encircled = '${csi}52$sgr';

/// Overlined.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [notOverlined]
const String overlined = '${csi}53$sgr';

/// Neither framed nor encircled.
///
/// Compatibility:
/// - -vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - +as
///
/// See [framed] and [encircled].
const String notFramedNotEncircled = '${csi}54$sgr';

/// Not overlined.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [overlined].
const String notOverlined = '${csi}55$sgr';

/// Superscript.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [subscript] and [notSuperscriptNotSubscript].
const String superscript = '${csi}73$sgr';

/// Subscript.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
///
/// See also [superscript] and [notSuperscriptNotSubscript].
const String subscript = '${csi}74$sgr';

/// Neither superscript nor subscript.
///
/// Compatibility:
/// - +vscode
/// - -mac Terminal
/// - -mac iTerm2
/// - -as
const String notSuperscriptNotSubscript = '${csi}75$sgr';
