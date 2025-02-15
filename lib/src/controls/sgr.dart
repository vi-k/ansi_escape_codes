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
/// See also [FAINT] and [NOT_BOLD_NOT_FAINT].
const int BOLD = 1;

/// Faint, decreased intensity or second color.
///
/// See also [BOLD] and [NOT_BOLD_NOT_FAINT].
const int FAINT = 2;

/// Italicized.
///
/// See also [NOT_ITALICIZED].
const int ITALICIZED = 3;

/// Singly underlined.
///
/// See also [NOT_UNDERLINED] and [DOUBLY_UNDERLINED].
const int UNDERLINED = 4;

/// Slowly blinking (less then 150 per minute).
///
/// See also [RAPIDLY_BLINKING] and [NOT_BLINKING].
const int SLOWLY_BLINKING = 5;

/// Rapidly blinking (150 per minute or more).
///
/// See also [SLOWLY_BLINKING] and [NOT_BLINKING].
const int RAPIDLY_BLINKING = 6;

/// Negative image.
///
/// Swap foreground and background colors.
///
/// See also [NOT_NEGATIVE].
const int NEGATIVE = 7;

/// Concealed characters.
///
/// See also [NOT_CONCEALED].
const int CONCEALED = 8;

/// Crossed-out (characters still legible but marked as to be deleted).
///
/// See also [NOT_CROSSEDOUT].
const int CROSSEDOUT = 9;

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

/// Doubly underlined.
///
/// Double-underline per ECMA-48, but instead disables bold intensity on
/// several terminals, including in the Linux kernel's console before version
/// 4.17.
///
/// See also [NOT_UNDERLINED] and [UNDERLINED].
const int DOUBLY_UNDERLINED = 21;

/// Normal colour or normal intensity (neither bold nor faint).
///
/// See also [BOLD] and [FAINT].
const int NOT_BOLD_NOT_FAINT = 22;

/// Not italicized, not fraktur.
///
/// See also [ITALICIZED].
const int NOT_ITALICIZED = 23;

/// Not underlined (neither singly nor doubly).
///
/// See also [UNDERLINED] and [DOUBLY_UNDERLINED].
const int NOT_UNDERLINED = 24;

/// Steady (not blinking).
///
/// See also [SLOWLY_BLINKING] and [RAPIDLY_BLINKING].
const int NOT_BLINKING = 25;

/// Positive image (not negative).
///
/// See also [NEGATIVE].
const int NOT_NEGATIVE = 27;

/// Revealed characters (not concealed).
///
/// See also [CONCEALED].
const int NOT_CONCEALED = 28;

/// Not crossed out.
///
/// See also [CROSSEDOUT].
const int NOT_CROSSEDOUT = 29;

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
/// See also [NOT_FRAMED_NOT_ENCIRCLED].
const int FRAMED = 51;

/// Encircled.
///
/// See also [NOT_FRAMED_NOT_ENCIRCLED].
const int ENCIRCLED = 52;

/// Overlined.
///
/// See also [NOT_OVERLINED].
const int OVERLINED = 53;

/// Not framed, not encircled.
///
/// See [FRAMED] and [ENCIRCLED].
const int NOT_FRAMED_NOT_ENCIRCLED = 54;

/// Not overlined.
///
/// See also [OVERLINED].
const int NOT_OVERLINED = 55;

/// Underline color.
const int UNDERLINE_COLOR = 58;

/// Default underline color.
const int UNDERLINE_COLOR_DEFAULT = 59;

/// Superscripted.
///
/// See also [SUBSCRIPTED] and [NOT_SUPER_NOT_SUBSCRIPTED].
const int SUPERSCRIPTED = 73;

/// Subscripted.
///
/// See also [SUPERSCRIPTED] and [NOT_SUPER_NOT_SUBSCRIPTED].
const int SUBSCRIPTED = 74;

/// Not superscripted, not subscipted.
///
/// See also [SUPERSCRIPTED] and [SUBSCRIPTED].
const int NOT_SUPER_NOT_SUBSCRIPTED = 75;

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
