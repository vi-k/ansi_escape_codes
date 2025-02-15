import '../../controls/c1.dart';
import '../../controls/csi.dart';
import '../../controls/sgr.dart';

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
/// Bold+faint:
/// - -vscode (same as faint, not support bold)
/// - -as (same as bold, not support faint)
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp (on the default colors only)
/// - -mac WezTerm (only one)
/// - +mac Kitty
/// - +mac Alacritty
///
/// See also [faint] and [resetBoldAndFaint].
const String bold = '$CSI$BOLD$SGR';

/// Faint, decreased intensity or second color.
///
/// See [FAINT].
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
/// Bold+faint:
/// - -vscode (same as faint, not support bold)
/// - -as (same as bold, not support faint)
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp (on the default colors only)
/// - -mac WezTerm (only one)
/// - +mac Kitty
/// - +mac Alacritty
///
/// See also [bold] and [resetBoldAndFaint].
const String faint = '$CSI$FAINT$SGR';

/// Normal colour or normal intensity (neither bold nor faint).
///
/// See [NOT_BOLD_NOT_FAINT].
///
/// See also [bold] and [faint].
const String resetBoldAndFaint = '$CSI$NOT_BOLD_NOT_FAINT$SGR';

/// Italicized.
///
/// See [ITALICIZED].
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
/// See also [resetItalicized].
const String italicized = '$CSI$ITALICIZED$SGR';

/// Not italicized, not fraktur.
///
/// See [NOT_ITALICIZED].
///
/// See also [italicized].
const String resetItalicized = '$CSI$NOT_ITALICIZED$SGR';

/// Singly underlined.
///
/// See [UNDERLINED].
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
/// See also [resetUnderlined] and [doublyUnderlined].
const String underlined = '$CSI$UNDERLINED$SGR';

/// Doubly underlined.
///
/// See [DOUBLY_UNDERLINED].
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
/// See also [resetUnderlined] and [underlined].
const String doublyUnderlined = '$CSI$DOUBLY_UNDERLINED$SGR';

/// Not underlined (neither singly nor doubly).
///
/// See [NOT_UNDERLINED].
///
/// See also [underlined] and [doublyUnderlined].
const String resetUnderlined = '$CSI$NOT_UNDERLINED$SGR';

/// Slowly blinking (less then 150 per minute).
///
/// See [SLOWLY_BLINKING].
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
/// See also [rapidlyBlinking] and [resetBlinking].
const String slowlyBlinking = '$CSI$SLOWLY_BLINKING$SGR';

/// Rapidly blinking (150 per minute or more).
///
/// See [RAPIDLY_BLINKING].
///
/// Compatibility:
/// - +vscode
/// - -as
/// - +-mac Terminal same as [slowlyBlinking])
/// - -mac iTerm2
/// - -mac Warp
/// - +mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// See also [slowlyBlinking] and [resetBlinking].
const String rapidlyBlinking = '$CSI$RAPIDLY_BLINKING$SGR';

/// Steady (not blinking).
///
/// See [NOT_BLINKING].
///
/// See also [slowlyBlinking] and [rapidlyBlinking].
const String resetBlinking = '$CSI$NOT_BLINKING$SGR';

/// Negative image.
///
/// See [NEGATIVE].
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
/// See also [resetNegative].
const String negative = '$CSI$NEGATIVE$SGR';

/// Positive image (not negative).
///
/// See [NOT_NEGATIVE].
///
/// See also [negative].
const String resetNegative = '$CSI$NOT_NEGATIVE$SGR';

/// Concealed characters.
///
/// See [CONCEALED].
///
/// Compatibility:
/// - +vscode
/// - -as
/// - +mac Terminal
/// - +mac iTerm2
/// - -mac Warp
/// - +mac WezTerm
/// - -mac Kitty
/// - +mac Alacritty
///
/// See also [resetConcealed].
const String concealed = '$CSI$CONCEALED$SGR';

/// Revealed characters (not concealed).
///
/// See [NOT_CONCEALED].
///
/// See also [concealed].
const String resetConcealed = '$CSI$NOT_CONCEALED$SGR';

/// Crossed-out (characters still legible but marked as to be deleted).
///
/// See [CROSSEDOUT].
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
/// Crossed out + underline:
/// - +vscode
/// - +as
/// - +mac iTerm2
/// - -mac Warp (underline has priority)
///
/// See also [resetCrossedOut].
const String crossedOut = '$CSI$CROSSEDOUT$SGR';

/// Not crossed out.
///
/// See [NOT_CROSSEDOUT].
///
/// See also [crossedOut].
const String resetCrossedOut = '$CSI$NOT_CROSSEDOUT$SGR';

/// Framed.
///
/// See [FRAMED].
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
/// See also [resetFramedAndEncircled].
const String framed = '$CSI$FRAMED$SGR';

/// Encircled.
///
/// See [ENCIRCLED].
///
/// Compatibility:
/// - -vscode
/// - +as (same as [framed])
/// - -mac Terminal
/// - -mac iTerm2
/// - -mac Warp
/// - -mac WezTerm
/// - -mac Kitty
/// - -mac Alacritty
///
/// See also [resetFramedAndEncircled].
const String encircled = '$CSI$ENCIRCLED$SGR';

/// Not framed, not encircled.
///
/// See [NOT_FRAMED_NOT_ENCIRCLED].
///
/// See [framed] and [encircled].
const String resetFramedAndEncircled = '$CSI$NOT_FRAMED_NOT_ENCIRCLED$SGR';

/// Overlined.
///
/// See [OVERLINED].
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
/// Overlined + crossed out:
/// - +vscode
/// - +mac WezTerm
///
/// Colors:
/// - +-vscode (only rgb colors)
/// - +mac WezTerm
///
/// See also [resetOverlined].
const String overlined = '$CSI$OVERLINED$SGR';

/// Not overlined.
///
/// See [NOT_OVERLINED].
///
/// See also [overlined].
const String resetOverlined = '$CSI$NOT_OVERLINED$SGR';

/// Superscripted.
///
/// See [SUPERSCRIPTED].
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
/// See also [subscripted] and [resetSuperAndSubscripted].
const String superscripted = '$CSI$SUPERSCRIPTED$SGR';

/// Subscripted.
///
/// See [SUBSCRIPTED].
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
/// See also [superscripted] and [resetSuperAndSubscripted].
const String subscripted = '$CSI$SUBSCRIPTED$SGR';

/// Not superscripted, not subscipted.
///
/// See [NOT_SUPER_NOT_SUBSCRIPTED].
///
/// See also [superscripted] and [subscripted].
const String resetSuperAndSubscripted = '$CSI$NOT_SUPER_NOT_SUBSCRIPTED$SGR';
