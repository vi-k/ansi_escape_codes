import '../../ansi/c1.dart';
import '../../ansi/csi.dart';
import '../../ansi/sgr.dart';

/// Default rendition (implementation-defined), cancels the effect of any
/// preceding occurrence of SGR in the data stream regardless of the setting
/// of the GRAPHIC RENDITION COMBINATION MODE (GRCM).
///
/// See [RESET].
///
/// Compatibility:
/// - +vscode
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
/// - +mac WezTerm
/// - +mac Kitty
/// - +mac Alacritty
const String reset = '$CSI$RESET$SGR';

/// Bold or increased intensity.
///
/// See [BOLD].
///
/// Compatibility:
/// - -vscode
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
/// - +mac WezTerm
/// - +mac Kitty
/// - +mac Alacritty
///
/// Bold+dim:
/// - -vscode (same as dim, not support bold)
/// - -as (same as bold, not support dim)
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp (on the default colors only)
/// - -mac WezTerm (only one)
/// - +mac Kitty
/// - +mac Alacritty
///
/// See also [dim] and [resetBoldAndDim].
const String bold = '$CSI$BOLD$SGR';

/// Dim, decreased intensity or second color.
///
/// See [DIM].
///
/// Compatibility:
/// - +vscode (decreased intensity, also of the background color)
/// - -as
/// - +mac Terminal (decreased intensity)
/// - +mac iTerm2 (decreased intensity)
/// - +mac Warp (decreased intensity)
/// - +mac WezTerm (thin symbols)
/// - +mac Kitty (decreased intensity)
/// - +mac Alacritty (decreased intensity)
///
/// Bold+dim:
/// - -vscode (same as dim, not support bold)
/// - -as (same as bold, not support dim)
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp (on the default colors only)
/// - -mac WezTerm (only one)
/// - +mac Kitty
/// - +mac Alacritty
///
/// See also [bold] and [resetBoldAndDim].
const String dim = '$CSI$DIM$SGR';

/// Normal colour or normal intensity (neither bold nor dim).
///
/// See [NOT_BOLD_NOT_DIM].
///
/// See also [bold] and [dim].
const String resetBoldAndDim = '$CSI$NOT_BOLD_NOT_DIM$SGR';

/// Italic.
///
/// See [ITALIC].
///
/// Compatibility:
/// - +vscode
/// - +as
/// - -mac Terminal
/// - +mac iTerm2
/// - +mac Warp
/// - +mac WezTerm
/// - +mac Kitty
/// - +mac Alacritty
///
/// See also [resetItalic].
const String italic = '$CSI$ITALIC$SGR';

/// Not italic, not fraktur.
///
/// See [NOT_ITALIC].
///
/// See also [italic].
const String resetItalic = '$CSI$NOT_ITALIC$SGR';

/// Underline.
///
/// See [UNDERLINE].
///
/// Compatibility:
/// - +vscode
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
/// - +mac WezTerm
/// - +mac Kitty
/// - +mac Alacritty
///
/// Colors:
/// - +-vscode (only rgb colors)
///
/// See also [resetUnderline] and [doublyUnderline].
const String underline = '$CSI$UNDERLINE$SGR';

/// Doubly underline.
///
/// See [DOUBLY_UNDERLINE].
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
/// - +mac WezTerm
/// - +mac Kitty
/// - -mac Alacritty
///
/// Colors:
/// - +-vscode (only rgb colors)
///
/// See also [resetUnderline] and [underline].
const String doublyUnderline = '$CSI$DOUBLY_UNDERLINE$SGR';

/// Not underline (neither singly nor doubly).
///
/// See [NOT_UNDERLINE].
///
/// See also [underline] and [doublyUnderline].
const String resetUnderline = '$CSI$NOT_UNDERLINE$SGR';

/// Blink.
///
/// See [BLINK].
///
/// Compatibility:
/// - +vscode
/// - -as
/// - +mac Terminal
/// - -mac iTerm2
/// - -mac Warp
/// - +mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// See also [blinkRapid] and [resetBlink].
const String blink = '$CSI$BLINK$SGR';

/// Blink rapid.
///
/// See [BLINK_RAPID].
///
/// Compatibility:
/// - +vscode
/// - -as
/// - +-mac Terminal same as [blink])
/// - -mac iTerm2
/// - -mac Warp
/// - +mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// See also [blink] and [resetBlink].
const String blinkRapid = '$CSI$BLINK_RAPID$SGR';

/// Steady (not blink).
///
/// See [NOT_BLINK].
///
/// See also [blink] and [blinkRapid].
const String resetBlink = '$CSI$NOT_BLINK$SGR';

/// Inverse.
///
/// See [INVERSE].
///
/// Swap foreground and background colors.
///
/// Compatibility:
/// - -vscode (does not work on default colors)
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
/// - +mac WezTerm
/// - +mac Kitty
/// - +mac Alacritty
///
/// See also [resetInverse].
const String inverse = '$CSI$INVERSE$SGR';

/// Positive (not inverse).
///
/// See [NOT_INVERSE].
///
/// See also [inverse].
const String resetInverse = '$CSI$NOT_INVERSE$SGR';

/// Invisible.
///
/// See [INVISIBLE].
///
/// Compatibility:
/// - +vscode
/// - -as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
/// - +mac WezTerm
/// - -mac Kitty
/// - +mac Alacritty
///
/// See also [resetInvisible].
const String invisible = '$CSI$INVISIBLE$SGR';

/// Revealed characters (not concealed).
///
/// See [NOT_INVISIBLE].
///
/// See also [invisible].
const String resetInvisible = '$CSI$NOT_INVISIBLE$SGR';

/// Strikethrough (characters still legible but marked as to be deleted).
///
/// See [STRIKETHROUGH].
///
/// Compatibility:
/// - +vscode
/// - +as
/// - -mac Terminal
/// - +mac iTerm2
/// - +mac Warp
/// - +mac WezTerm
/// - +mac Kitty
/// - +mac Alacritty
///
/// Strikethrough + underline:
/// - +vscode
/// - +as
/// - +mac iTerm2
/// - -mac Warp (underline has priority)
///
/// See also [resetStrikethrough].
const String strikethrough = '$CSI$STRIKETHROUGH$SGR';

/// Not strikethrough.
///
/// See [NOT_STRIKETHROUGH].
///
/// See also [strikethrough].
const String resetStrikethrough = '$CSI$NOT_STRIKETHROUGH$SGR';

/// Frame.
///
/// See [FRAME].
///
/// Compatibility:
/// - -vscode
/// - +as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
/// - -mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// See also [resetFrameAndEncircle].
const String frame = '$CSI$FRAME$SGR';

/// Encircle.
///
/// See [ENCIRCLE].
///
/// Compatibility:
/// - -vscode
/// - +as (same as [frame])
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
/// - -mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// See also [resetFrameAndEncircle].
const String encircle = '$CSI$ENCIRCLE$SGR';

/// Not frame, not encircle.
///
/// See [NOT_FRAME_NOT_ENCIRCLE].
///
/// See [frame] and [encircle].
const String resetFrameAndEncircle = '$CSI$NOT_FRAME_NOT_ENCIRCLE$SGR';

/// Overlined.
///
/// See [OVERLINE].
///
/// Compatibility:
/// - +vscode
/// - -as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
/// - +mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// Overlined + underline:
/// - +vscode
/// - +mac WezTerm
///
/// Overlined + strikethrough:
/// - +vscode
/// - +mac WezTerm
///
/// Colors:
/// - +-vscode (only rgb colors)
/// - +mac WezTerm
///
/// See also [resetOverline].
const String overline = '$CSI$OVERLINE$SGR';

/// Not overlined.
///
/// See [NOT_OVERLINE].
///
/// See also [overline].
const String resetOverline = '$CSI$NOT_OVERLINE$SGR';

/// Superscripted.
///
/// See [SUPERSCRIPT].
///
/// Compatibility:
/// - +vscode
/// - -as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
/// - +mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// See also [subscript] and [resetSuperAndSubscript].
const String superscript = '$CSI$SUPERSCRIPT$SGR';

/// Subscripted.
///
/// See [SUBSCRIPT].
///
/// Compatibility:
/// - +vscode
/// - -as
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
/// - +mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// See also [superscript] and [resetSuperAndSubscript].
const String subscript = '$CSI$SUBSCRIPT$SGR';

/// Not superscripted, not subscripted.
///
/// See [NOT_SUPER_NOT_SUBSCRIPT].
///
/// See also [superscript] and [subscript].
const String resetSuperAndSubscript = '$CSI$NOT_SUPER_NOT_SUBSCRIPT$SGR';
