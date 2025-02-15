import '../../controls/sgr.dart' as sgr;
import '../../predefined_values/sgr/colors256/bg256.dart' as sgr;
import '../../predefined_values/sgr/colors256/fg256.dart' as sgr;
import '../../predefined_values/sgr/colors256/underline256.dart' as sgr;
import '../../predefined_values/sgr/sgr.dart' as sgr;
import '../../predefined_values/sgr/standart_colors/standart_colors.dart'
    as sgr;

/// SGR control functions.
enum ControlFunctionsSGR {
  /// See [sgr.reset] and [sgr.RESET].
  reset, // 0

  /// See [sgr.bold] and [sgr.BOLD].
  bold, // 1

  /// See [sgr.faint] and [sgr.FAINT].
  faint, // 2

  /// See [sgr.italicized] and [sgr.ITALICIZED].
  italicized, // 3

  /// See [sgr.underlined] and [sgr.UNDERLINED].
  underlined, // 4

  /// See [sgr.slowlyBlinking] and [sgr.SLOWLY_BLINKING].
  slowlyBlinking, // 5

  /// See [sgr.rapidlyBlinking] and [sgr.RAPIDLY_BLINKING].
  rapidlyBlinking, // 6

  /// See [sgr.negative] and [sgr.NEGATIVE].
  negative, // 7

  /// See [sgr.concealed] and [sgr.CONCEALED].
  concealed, // 8

  /// See [sgr.crossedOut] and [sgr.CROSSEDOUT].
  crossedOut, // 9

  /// See [sgr.PRIMARY_FONT].
  primaryFont(isUnused: true), // 10

  /// See [sgr.ALT_FONT_1].
  alternativeFont1(isUnused: true), // 11

  /// See [sgr.ALT_FONT_2].
  alternativeFont2(isUnused: true), // 12

  /// See [sgr.ALT_FONT_3].
  alternativeFont3(isUnused: true), // 13

  /// See [sgr.ALT_FONT_4].
  alternativeFont4(isUnused: true), // 14

  /// See [sgr.ALT_FONT_5].
  alternativeFont5(isUnused: true), // 15

  /// See [sgr.ALT_FONT_6].
  alternativeFont6(isUnused: true), // 16

  /// See [sgr.ALT_FONT_7].
  alternativeFont7(isUnused: true), // 17

  /// See [sgr.ALT_FONT_8].
  alternativeFont8(isUnused: true), // 18

  /// See [sgr.ALT_FONT_9].
  alternativeFont9(isUnused: true), // 19

  /// See [sgr.FRAKTUR].
  fraktur(isUnused: true), // 20

  /// See [sgr.doublyUnderlined] and [sgr.DOUBLY_UNDERLINED].
  doublyUnderlined, // 21

  /// See [sgr.resetBoldAndFaint] and [sgr.NOT_BOLD_NOT_FAINT].
  resetBoldAndFaint, // 22

  /// See [sgr.resetItalicized] and [sgr.NOT_ITALICIZED].
  resetItalicized, // 23

  /// See [sgr.resetUnderlined] and [sgr.NOT_UNDERLINED].
  resetUnderlined, // 24

  /// See [sgr.resetBlinking] and [sgr.NOT_BLINKING].
  resetBlinking, // 25

  /// Reserved for proportional spacing as specified in CCITT Recommendation
  /// T.61.
  reserved_26(isUnused: true), // 26

  /// See [sgr.resetNegative] and [sgr.NOT_NEGATIVE].
  resetNegative, // 27

  /// See [sgr.resetConcealed] and [sgr.NOT_CONCEALED].
  resetConcealed, // 28

  /// See [sgr.resetCrossedOut] and [sgr.NOT_CROSSEDOUT].
  resetCrossedOut, // 29

  /// See [sgr.fgBlack] and [sgr.FG_BLACK].
  fgBlack, // 30

  /// See [sgr.fgRed] and [sgr.FG_RED].
  fgRed, // 31

  /// See [sgr.fgGreen] and [sgr.FG_GREEN].
  fgGreen, // 32

  /// See [sgr.fgYellow] and [sgr.FG_YELLOW].
  fgYellow, // 33

  /// See [sgr.fgBlue] and [sgr.FG_BLUE].
  fgBlue, // 34

  /// See [sgr.fgMagenta] and [sgr.FG_MAGENTA].
  fgMagenta, // 35

  /// See [sgr.fgCyan] and [sgr.FG_CYAN].
  fgCyan, // 36

  /// See [sgr.fgWhite] and [sgr.FG_WHITE].
  fgWhite, // 37

  /// See [sgr.fg256Open], [sgr.fg256Close], [sgr.fg256] and [sgr.FOREGROUND].
  fg, // 38

  /// See [sgr.resetFg] and [sgr.FG_DEFAULT].
  resetFg, // 39

  /// See [sgr.bgBlack] and [sgr.BG_BLACK].
  bgBlack, // 30

  /// See [sgr.bgRed] and [sgr.BG_RED].
  bgRed, // 31

  /// See [sgr.bgGreen] and [sgr.BG_GREEN].
  bgGreen, // 32

  /// See [sgr.bgYellow] and [sgr.BG_YELLOW].
  bgYellow, // 33

  /// See [sgr.bgBlue] and [sgr.BG_BLUE].
  bgBlue, // 34

  /// See [sgr.bgMagenta] and [sgr.BG_MAGENTA].
  bgMagenta, // 35

  /// See [sgr.bgCyan] and [sgr.BG_CYAN].
  bgCyan, // 36

  /// See [sgr.bgWhite] and [sgr.BG_WHITE].
  bgWhite, // 37

  /// See [sgr.bg256Open], [sgr.bg256Close], [sgr.bg256] and [sgr.BACKGROUND].
  bg, // 48

  /// See [sgr.resetBg] and [sgr.BG_DEFAULT].
  resetBg, // 49

  /// Reserved for cancelling the effect of the rendering aspect established
  /// by parameter value 26.
  reserved_50(isUnused: true), // 50

  /// See [sgr.framed] and [sgr.FRAMED].
  framed, // 51

  /// See [sgr.encircled] and [sgr.ENCIRCLED].
  encircled, // 52

  /// See [sgr.overlined] and [sgr.OVERLINED].
  overlined, // 53

  /// See [sgr.resetFramedAndEncircled] and [sgr.NOT_FRAMED_NOT_ENCIRCLED].
  resetFramedAndEncircled, // 54

  /// See [sgr.resetOverlined] and [sgr.NOT_OVERLINED].
  resetOverlined, // 55

  /// Reserved for future standardization.
  reserved_56(isUnused: true), // 56

  /// Reserved for future standardization.
  reserved_57(isUnused: true), // 57

  /// See [sgr.underline256Open], [sgr.underline256Close], [sgr.underline256]
  /// and [sgr.UNDERLINE_COLOR].
  underlineColor(id: 'underline'), // 58

  /// See [sgr.resetUnderlineColor] and [sgr.UNDERLINE_COLOR_DEFAULT].
  resetUnderlineColor, // 59

  /// Ideogram underline or right side line.
  reserved_60(isUnused: true), // 60

  /// Ideogram double underline or double line on the right side.
  reserved_61(isUnused: true), // 61

  /// Ideogram overline or left side line.
  reserved_62(isUnused: true), // 62

  /// Ideogram double overline or double line on the left side.
  reserved_63(isUnused: true), // 63

  /// Ideogram stress marking.
  reserved_64(isUnused: true), // 64

  /// Cancels the effect of the rendition aspects established by parameter
  /// values 60 to 64.
  reserved_65(isUnused: true), // 65

  /// Reserved.
  reserved_66(isUnused: true), // 66

  /// Reserved.
  reserved_67(isUnused: true), // 67

  /// Reserved.
  reserved_68(isUnused: true), // 68

  /// Reserved.
  reserved_69(isUnused: true), // 69

  /// Reserved.
  reserved_70(isUnused: true), // 70

  /// Reserved.
  reserved_71(isUnused: true), // 71

  /// Reserved.
  reserved_72(isUnused: true), // 72

  /// See [sgr.superscripted] and [sgr.SUPERSCRIPTED].
  superscripted, // 73

  /// See [sgr.subscripted] and [sgr.SUBSCRIPTED].
  subscripted, // 74

  /// See [sgr.resetSuperAndSubscripted] and [sgr.NOT_SUPER_NOT_SUBSCRIPTED].
  resetSuperAndSubscripted, // 75

  /// Reserved.
  reserved_76(isUnused: true), // 76

  /// Reserved.
  reserved_77(isUnused: true), // 77

  /// Reserved.
  reserved_78(isUnused: true), // 78

  /// Reserved.
  reserved_79(isUnused: true), // 79

  /// Reserved.
  reserved_80(isUnused: true), // 80

  /// Reserved.
  reserved_81(isUnused: true), // 81

  /// Reserved.
  reserved_82(isUnused: true), // 82

  /// Reserved.
  reserved_83(isUnused: true), // 83

  /// Reserved.
  reserved_84(isUnused: true), // 84

  /// Reserved.
  reserved_85(isUnused: true), // 85

  /// Reserved.
  reserved_86(isUnused: true), // 86

  /// Reserved.
  reserved_87(isUnused: true), // 87

  /// Reserved.
  reserved_88(isUnused: true), // 88

  /// Reserved.
  reserved_89(isUnused: true), // 89

  /// See [sgr.fgHighBlack] and [sgr.FG_HIGH_BLACK].
  fgHighBlack, // 90

  /// See [sgr.fgHighRed] and [sgr.FG_HIGH_RED].
  fgHighRed, // 91

  /// See [sgr.fgHighGreen] and [sgr.FG_HIGH_GREEN].
  fgHighGreen, // 92

  /// See [sgr.fgHighYellow] and [sgr.FG_HIGH_YELLOW].
  fgHighYellow, // 93

  /// See [sgr.fgHighBlue] and [sgr.FG_HIGH_BLUE].
  fgHighBlue, // 94

  /// See [sgr.fgHighMagenta] and [sgr.FG_HIGH_MAGENTA].
  fgHighMagenta, // 95

  /// See [sgr.fgHighCyan] and [sgr.FG_HIGH_CYAN].
  fgHighCyan, // 96

  /// See [sgr.fgHighWhite] and [sgr.FG_HIGH_WHITE].
  fgHighWhite, // 97

  /// Reserved.
  reserved_98(isUnused: true), // 98

  /// Reserved.
  reserved_99(isUnused: true), // 99

  /// See [sgr.bgHighBlack] and [sgr.BG_HIGH_BLACK].
  bgHighBlack, // 100

  /// See [sgr.bgHighRed] and [sgr.BG_HIGH_RED].
  bgHighRed, // 101

  /// See [sgr.bgHighGreen] and [sgr.BG_HIGH_GREEN].
  bgHighGreen, // 102

  /// See [sgr.bgHighYellow] and [sgr.BG_HIGH_YELLOW].
  bgHighYellow, // 103

  /// See [sgr.bgHighBlue] and [sgr.BG_HIGH_BLUE].
  bgHighBlue, // 1010

  /// See [sgr.bgHighMagenta] and [sgr.BG_HIGH_MAGENTA].
  bgHighMagenta, // 105

  /// See [sgr.bgHighCyan] and [sgr.BG_HIGH_CYAN].
  bgHighCyan, // 106

  /// See [sgr.bgHighWhite] and [sgr.BG_HIGH_WHITE].
  bgHighWhite; // 107

  final bool isUnused;
  final String? _id;

  const ControlFunctionsSGR({
    this.isUnused = false,
    String? id,
  }) : _id = id;

  String get id => _id ?? name;

  static ControlFunctionsSGR? byIndex(int index) {
    if (index >= 0 && index < values.length) {
      final value = values[index];
      if (!value.isUnused) {
        return value;
      }
    }

    return null;
  }
}
