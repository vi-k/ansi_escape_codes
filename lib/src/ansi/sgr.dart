// ignore_for_file: constant_identifier_names

/// Select Graphic Rendition.
///
/// Codes for use in SGR.
library;

/// Default rendition (implementation-defined), cancels the effect of any
/// preceding occurrence of SGR in the data stream regardless of the setting
/// of the GRAPHIC RENDITION COMBINATION MODE (GRCM).
const int RESET = 0;

/// Bold or increased intensity.
///
/// See also [DIM] and [NOT_BOLD_NOT_DIM].
const int BOLD = 1;

/// Dim, decreased intensity or second color.
///
/// See also [BOLD] and [NOT_BOLD_NOT_DIM].
const int DIM = 2;

/// Italic.
///
/// See also [NOT_ITALIC].
const int ITALIC = 3;

/// Underline.
///
/// See also [NOT_UNDERLINE] and [DOUBLY_UNDERLINE].
const int UNDERLINE = 4;

/// Blink.
///
/// See also [BLINK_RAPID] and [NOT_BLINK].
const int BLINK = 5;

/// Blink rapid.
///
/// See also [BLINK] and [NOT_BLINK].
const int BLINK_RAPID = 6;

/// Inverse.
///
/// Swap foreground and background colors.
///
/// See also [NOT_INVERSE].
const int INVERSE = 7;

/// Invisible.
///
/// See also [NOT_INVISIBLE].
const int INVISIBLE = 8;

/// Strikethrough (characters still legible but marked as to be deleted).
///
/// See also [NOT_STRIKETHROUGH].
const int STRIKETHROUGH = 9;

/// Primary (default) font.
const int PRIMARY_FONT = 10;

/// First alternative font.
const int ALT_FONT_1 = 11;

/// Second alternative font.
const int ALT_FONT_2 = 12;

/// Third alternative font.
const int ALT_FONT_3 = 13;

/// Fourth alternative font.
const int ALT_FONT_4 = 14;

/// Fifth alternative font.
const int ALT_FONT_5 = 15;

/// Sixth alternative font.
const int ALT_FONT_6 = 16;

/// Seventh alternative font.
const int ALT_FONT_7 = 17;

/// Eighth alternative font.
const int ALT_FONT_8 = 18;

/// Ninth alternative font.
const int ALT_FONT_9 = 19;

/// Fraktur (Gothic).
const int FRAKTUR = 20;

/// Doubly underline.
///
/// Double-underline per ECMA-48, but instead disables bold intensity on
/// several terminals, including in the Linux kernel's console before version
/// 4.17.
///
/// See also [NOT_UNDERLINE] and [UNDERLINE].
const int DOUBLY_UNDERLINE = 21;

/// Normal colour or normal intensity (neither bold nor dim).
///
/// See also [BOLD] and [DIM].
const int NOT_BOLD_NOT_DIM = 22;

/// Not italic, not fraktur.
///
/// See also [ITALIC].
const int NOT_ITALIC = 23;

/// Not underline (neither singly nor doubly).
///
/// See also [UNDERLINE] and [DOUBLY_UNDERLINE].
const int NOT_UNDERLINE = 24;

/// Steady (not blink).
///
/// See also [BLINK] and [BLINK_RAPID].
const int NOT_BLINK = 25;

/// Positive (not inverse).
///
/// See also [INVERSE].
const int NOT_INVERSE = 27;

/// Revealed (not invisible).
///
/// See also [INVISIBLE].
const int NOT_INVISIBLE = 28;

/// Not strikethrough.
///
/// See also [STRIKETHROUGH].
const int NOT_STRIKETHROUGH = 29;

/// Black display.
const int FG_BLACK = 30;

/// Red display.
const int FG_RED = 31;

/// Green display.
const int FG_GREEN = 32;

/// Yellow display.
const int FG_YELLOW = 33;

/// Blue display.
const int FG_BLUE = 34;

/// Magenta display.
const int FG_MAGENTA = 35;

/// Cyan display.
const int FG_CYAN = 36;

/// White display.
const int FG_WHITE = 37;

/// Display color as specified in ITU-T Rec. T.416 (03/93).
const int FOREGROUND = 38;

/// Default display color (implementation-defined).
const int FG_DEFAULT = 39;

/// Black background.
const int BG_BLACK = 40;

/// Red background.
const int BG_RED = 41;

/// Green background.
const int BG_GREEN = 42;

/// Yellow background.
const int BG_YELLOW = 43;

/// Blue background.
const int BG_BLUE = 44;

/// Magenta background.
const int BG_MAGENTA = 45;

/// Cyan background.
const int BG_CYAN = 46;

/// White background.
const int BG_WHITE = 47;

/// Background color as specified in ITU-T Rec. T.416 (03/93).
const int BACKGROUND = 48;

/// Default background color (implementation-defined).
const int BG_DEFAULT = 49;

/// Framed.
///
/// See also [NOT_FRAME_NOT_ENCIRCLE].
const int FRAME = 51;

/// Encircled.
///
/// See also [NOT_FRAME_NOT_ENCIRCLE].
const int ENCIRCLE = 52;

/// Overlined.
///
/// See also [NOT_OVERLINE].
const int OVERLINE = 53;

/// Not framed, not encircled.
///
/// See [FRAME] and [ENCIRCLE].
const int NOT_FRAME_NOT_ENCIRCLE = 54;

/// Not overlined.
///
/// See also [OVERLINE].
const int NOT_OVERLINE = 55;

/// Underline color.
const int UNDERLINE_COLOR = 58;

/// Default underline color.
const int UNDERLINE_COLOR_DEFAULT = 59;

/// Superscripted.
///
/// See also [SUBSCRIPT] and [NOT_SUPER_NOT_SUBSCRIPT].
const int SUPERSCRIPT = 73;

/// Subscripted.
///
/// See also [SUPERSCRIPT] and [NOT_SUPER_NOT_SUBSCRIPT].
const int SUBSCRIPT = 74;

/// Not superscripted, not subscipted.
///
/// See also [SUPERSCRIPT] and [SUBSCRIPT].
const int NOT_SUPER_NOT_SUBSCRIPT = 75;

/// High black display.
const int FG_HIGH_BLACK = 90;

/// High red display.
const int FG_HIGH_RED = 91;

/// High green display.
const int FG_HIGH_GREEN = 92;

/// High yellow display.
const int FG_HIGH_YELLOW = 93;

/// High blue display.
const int FG_HIGH_BLUE = 94;

/// High magenta display.
const int FG_HIGH_MAGENTA = 95;

/// High cyan display.
const int FG_HIGH_CYAN = 96;

/// High white display.
const int FG_HIGH_WHITE = 97;

/// High black background.
const int BG_HIGH_BLACK = 100;

/// High red background.
const int BG_HIGH_RED = 101;

/// High green background.
const int BG_HIGH_GREEN = 102;

/// High yellow background.
const int BG_HIGH_YELLOW = 103;

/// High blue background.
const int BG_HIGH_BLUE = 104;

/// High magenta background.
const int BG_HIGH_MAGENTA = 105;

/// High cyan background.
const int BG_HIGH_CYAN = 106;

/// High white background.
const int BG_HIGH_WHITE = 107;

/// A constant to define the color from a 256-color table for [FOREGROUND],
/// [BACKGROUND] and [UNDERLINE_COLOR].
const int COLOR_256 = 5;

/// A constant to define the color by RGB for [FOREGROUND], [BACKGROUND] and
/// [UNDERLINE_COLOR].
const int COLOR_RGB = 2;
