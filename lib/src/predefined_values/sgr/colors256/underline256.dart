/// Underline color.
library;

import '../../../controls/c1.dart';
import '../../../controls/colors.dart';
import '../../../controls/csi.dart';
import '../../../controls/sgr.dart';

//
// ANSI escape codes for underline from 256-color table.
//

/// Opening tag for underline with 256-color table.
///
/// Not in standard!
///
/// Template: `${underline256Open}{color}${underline256Close}`
///
/// Predefined constants:
/// `$underline256Open$black$underline256Close` = `underline256Black`
///
/// Compatibility:
/// - -vscode
/// - +mac iTerm2
///
/// The following terminals mistakenly take each parameter as a command:
/// - CSI 58;5;3 SGR (underline256Yellow) -> blink, italicized
/// - CSI 58;2;3;4;7 SGR (underlineRgb(3,4,7)) -> faint, italicized, underlined,
///   negative
///
/// - -as
/// - -mac Terminal
/// - -mac Warp
///
/// See color indexes in the
/// [colors_8bit/indexes.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/values/sgr/colors_8bit/indexes.dart).
///
/// See also [underline256Close] and [underline256].
const String underline256Open = '$CSI$UNDERLINE_COLOR;$COLOR_256;';

/// Closing tag for underline with 256-color table.
///
/// See [underline256Open].
const String underline256Close = SGR;

/// Set color to underline from 256-color table.
///
/// See also [underline256Open].
String underline256(int colorIndex) {
  IndexError.check(colorIndex, 256, name: 'colorIndex');

  return '$underline256Open$colorIndex$underline256Close';
}

/// Underline black from 256-color table.
const String underline256Black = '$underline256Open$BLACK$underline256Close';

/// Underline red from 256-color table.
const String underline256Red = '$underline256Open$RED$underline256Close';

/// Underline green from 256-color table.
const String underline256Green = '$underline256Open$GREEN$underline256Close';

/// Underline yellow from 256-color table.
const String underline256Yellow = '$underline256Open$YELLOW$underline256Close';

/// Underline blue from 256-color table.
const String underline256Blue = '$underline256Open$BLUE$underline256Close';

/// Underline magenta from 256-color table.
const String underline256Magenta =
    '$underline256Open$MAGENTA$underline256Close';

/// Underline cyan from 256-color table.
const String underline256Cyan = '$underline256Open$CYAN$underline256Close';

/// Underline white from 256-color table.
const String underline256White = '$underline256Open$WHITE$underline256Close';

//
// Predefined high intensity colors.
//

/// Underline high intensity black from 256-color table.
const String underline256HighBlack =
    '$underline256Open$HIGH_BLACK$underline256Close';

/// Underline high intensity red from 256-color table.
const String underline256HighRed =
    '$underline256Open$HIGH_RED$underline256Close';

/// Underline high intensity green from 256-color table.
const String underline256HighGreen =
    '$underline256Open$HIGH_GREEN$underline256Close';

/// Underline high intensity yellow from 256-color table.
const String underline256HighYellow =
    '$underline256Open$HIGH_YELLOW$underline256Close';

/// Underline high intensity blue from 256-color table.
const String underline256HighBlue =
    '$underline256Open$HIGH_BLUE$underline256Close';

/// Underline high intensity magenta from 256-color table.
const String underline256HighMagenta =
    '$underline256Open$HIGH_MAGENTA$underline256Close';

/// Underline high intensity cyan from 256-color table.
const String underline256HighCyan =
    '$underline256Open$HIGH_CYAN$underline256Close';

/// Underline high intensity white from 256-color table.
const String underline256HighWhite =
    '$underline256Open$HIGH_WHITE$underline256Close';

//
// Predefined RGB colors.
//
// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).
//

/// Underline RGB 000 from 256-color table.
const String underline256Rgb000 = '$underline256Open$RGB_000$underline256Close';

/// Underline RGB 001 from 256-color table.
const String underline256Rgb001 = '$underline256Open$RGB_001$underline256Close';

/// Underline RGB 002 from 256-color table.
const String underline256Rgb002 = '$underline256Open$RGB_002$underline256Close';

/// Underline RGB 003 from 256-color table.
const String underline256Rgb003 = '$underline256Open$RGB_003$underline256Close';

/// Underline RGB 004 from 256-color table.
const String underline256Rgb004 = '$underline256Open$RGB_004$underline256Close';

/// Underline RGB 005 from 256-color table.
const String underline256Rgb005 = '$underline256Open$RGB_005$underline256Close';

/// Underline RGB 010 from 256-color table.
const String underline256Rgb010 = '$underline256Open$RGB_010$underline256Close';

/// Underline RGB 011 from 256-color table.
const String underline256Rgb011 = '$underline256Open$RGB_011$underline256Close';

/// Underline RGB 012 from 256-color table.
const String underline256Rgb012 = '$underline256Open$RGB_012$underline256Close';

/// Underline RGB 013 from 256-color table.
const String underline256Rgb013 = '$underline256Open$RGB_013$underline256Close';

/// Underline RGB 014 from 256-color table.
const String underline256Rgb014 = '$underline256Open$RGB_014$underline256Close';

/// Underline RGB 015 from 256-color table.
const String underline256Rgb015 = '$underline256Open$RGB_015$underline256Close';

/// Underline RGB 020 from 256-color table.
const String underline256Rgb020 = '$underline256Open$RGB_020$underline256Close';

/// Underline RGB 021 from 256-color table.
const String underline256Rgb021 = '$underline256Open$RGB_021$underline256Close';

/// Underline RGB 022 from 256-color table.
const String underline256Rgb022 = '$underline256Open$RGB_022$underline256Close';

/// Underline RGB 023 from 256-color table.
const String underline256Rgb023 = '$underline256Open$RGB_023$underline256Close';

/// Underline RGB 024 from 256-color table.
const String underline256Rgb024 = '$underline256Open$RGB_024$underline256Close';

/// Underline RGB 025 from 256-color table.
const String underline256Rgb025 = '$underline256Open$RGB_025$underline256Close';

/// Underline RGB 030 from 256-color table.
const String underline256Rgb030 = '$underline256Open$RGB_030$underline256Close';

/// Underline RGB 031 from 256-color table.
const String underline256Rgb031 = '$underline256Open$RGB_031$underline256Close';

/// Underline RGB 032 from 256-color table.
const String underline256Rgb032 = '$underline256Open$RGB_032$underline256Close';

/// Underline RGB 033 from 256-color table.
const String underline256Rgb033 = '$underline256Open$RGB_033$underline256Close';

/// Underline RGB 034 from 256-color table.
const String underline256Rgb034 = '$underline256Open$RGB_034$underline256Close';

/// Underline RGB 035 from 256-color table.
const String underline256Rgb035 = '$underline256Open$RGB_035$underline256Close';

/// Underline RGB 040 from 256-color table.
const String underline256Rgb040 = '$underline256Open$RGB_040$underline256Close';

/// Underline RGB 041 from 256-color table.
const String underline256Rgb041 = '$underline256Open$RGB_041$underline256Close';

/// Underline RGB 042 from 256-color table.
const String underline256Rgb042 = '$underline256Open$RGB_042$underline256Close';

/// Underline RGB 043 from 256-color table.
const String underline256Rgb043 = '$underline256Open$RGB_043$underline256Close';

/// Underline RGB 044 from 256-color table.
const String underline256Rgb044 = '$underline256Open$RGB_044$underline256Close';

/// Underline RGB 045 from 256-color table.
const String underline256Rgb045 = '$underline256Open$RGB_045$underline256Close';

/// Underline RGB 050 from 256-color table.
const String underline256Rgb050 = '$underline256Open$RGB_050$underline256Close';

/// Underline RGB 051 from 256-color table.
const String underline256Rgb051 = '$underline256Open$RGB_051$underline256Close';

/// Underline RGB 052 from 256-color table.
const String underline256Rgb052 = '$underline256Open$RGB_052$underline256Close';

/// Underline RGB 053 from 256-color table.
const String underline256Rgb053 = '$underline256Open$RGB_053$underline256Close';

/// Underline RGB 054 from 256-color table.
const String underline256Rgb054 = '$underline256Open$RGB_054$underline256Close';

/// Underline RGB 055 from 256-color table.
const String underline256Rgb055 = '$underline256Open$RGB_055$underline256Close';

/// Underline RGB 100 from 256-color table.
const String underline256Rgb100 = '$underline256Open$RGB_100$underline256Close';

/// Underline RGB 101 from 256-color table.
const String underline256Rgb101 = '$underline256Open$RGB_101$underline256Close';

/// Underline RGB 102 from 256-color table.
const String underline256Rgb102 = '$underline256Open$RGB_102$underline256Close';

/// Underline RGB 103 from 256-color table.
const String underline256Rgb103 = '$underline256Open$RGB_103$underline256Close';

/// Underline RGB 104 from 256-color table.
const String underline256Rgb104 = '$underline256Open$RGB_104$underline256Close';

/// Underline RGB 105 from 256-color table.
const String underline256Rgb105 = '$underline256Open$RGB_105$underline256Close';

/// Underline RGB 110 from 256-color table.
const String underline256Rgb110 = '$underline256Open$RGB_110$underline256Close';

/// Underline RGB 111 from 256-color table.
const String underline256Rgb111 = '$underline256Open$RGB_111$underline256Close';

/// Underline RGB 112 from 256-color table.
const String underline256Rgb112 = '$underline256Open$RGB_112$underline256Close';

/// Underline RGB 113 from 256-color table.
const String underline256Rgb113 = '$underline256Open$RGB_113$underline256Close';

/// Underline RGB 114 from 256-color table.
const String underline256Rgb114 = '$underline256Open$RGB_114$underline256Close';

/// Underline RGB 115 from 256-color table.
const String underline256Rgb115 = '$underline256Open$RGB_115$underline256Close';

/// Underline RGB 120 from 256-color table.
const String underline256Rgb120 = '$underline256Open$RGB_120$underline256Close';

/// Underline RGB 121 from 256-color table.
const String underline256Rgb121 = '$underline256Open$RGB_121$underline256Close';

/// Underline RGB 122 from 256-color table.
const String underline256Rgb122 = '$underline256Open$RGB_122$underline256Close';

/// Underline RGB 123 from 256-color table.
const String underline256Rgb123 = '$underline256Open$RGB_123$underline256Close';

/// Underline RGB 124 from 256-color table.
const String underline256Rgb124 = '$underline256Open$RGB_124$underline256Close';

/// Underline RGB 125 from 256-color table.
const String underline256Rgb125 = '$underline256Open$RGB_125$underline256Close';

/// Underline RGB 130 from 256-color table.
const String underline256Rgb130 = '$underline256Open$RGB_130$underline256Close';

/// Underline RGB 131 from 256-color table.
const String underline256Rgb131 = '$underline256Open$RGB_131$underline256Close';

/// Underline RGB 132 from 256-color table.
const String underline256Rgb132 = '$underline256Open$RGB_132$underline256Close';

/// Underline RGB 133 from 256-color table.
const String underline256Rgb133 = '$underline256Open$RGB_133$underline256Close';

/// Underline RGB 134 from 256-color table.
const String underline256Rgb134 = '$underline256Open$RGB_134$underline256Close';

/// Underline RGB 135 from 256-color table.
const String underline256Rgb135 = '$underline256Open$RGB_135$underline256Close';

/// Underline RGB 140 from 256-color table.
const String underline256Rgb140 = '$underline256Open$RGB_140$underline256Close';

/// Underline RGB 141 from 256-color table.
const String underline256Rgb141 = '$underline256Open$RGB_141$underline256Close';

/// Underline RGB 142 from 256-color table.
const String underline256Rgb142 = '$underline256Open$RGB_142$underline256Close';

/// Underline RGB 143 from 256-color table.
const String underline256Rgb143 = '$underline256Open$RGB_143$underline256Close';

/// Underline RGB 144 from 256-color table.
const String underline256Rgb144 = '$underline256Open$RGB_144$underline256Close';

/// Underline RGB 145 from 256-color table.
const String underline256Rgb145 = '$underline256Open$RGB_145$underline256Close';

/// Underline RGB 150 from 256-color table.
const String underline256Rgb150 = '$underline256Open$RGB_150$underline256Close';

/// Underline RGB 151 from 256-color table.
const String underline256Rgb151 = '$underline256Open$RGB_151$underline256Close';

/// Underline RGB 152 from 256-color table.
const String underline256Rgb152 = '$underline256Open$RGB_152$underline256Close';

/// Underline RGB 153 from 256-color table.
const String underline256Rgb153 = '$underline256Open$RGB_153$underline256Close';

/// Underline RGB 154 from 256-color table.
const String underline256Rgb154 = '$underline256Open$RGB_154$underline256Close';

/// Underline RGB 155 from 256-color table.
const String underline256Rgb155 = '$underline256Open$RGB_155$underline256Close';

/// Underline RGB 200 from 256-color table.
const String underline256Rgb200 = '$underline256Open$RGB_200$underline256Close';

/// Underline RGB 201 from 256-color table.
const String underline256Rgb201 = '$underline256Open$RGB_201$underline256Close';

/// Underline RGB 202 from 256-color table.
const String underline256Rgb202 = '$underline256Open$RGB_202$underline256Close';

/// Underline RGB 203 from 256-color table.
const String underline256Rgb203 = '$underline256Open$RGB_203$underline256Close';

/// Underline RGB 204 from 256-color table.
const String underline256Rgb204 = '$underline256Open$RGB_204$underline256Close';

/// Underline RGB 205 from 256-color table.
const String underline256Rgb205 = '$underline256Open$RGB_205$underline256Close';

/// Underline RGB 210 from 256-color table.
const String underline256Rgb210 = '$underline256Open$RGB_210$underline256Close';

/// Underline RGB 211 from 256-color table.
const String underline256Rgb211 = '$underline256Open$RGB_211$underline256Close';

/// Underline RGB 212 from 256-color table.
const String underline256Rgb212 = '$underline256Open$RGB_212$underline256Close';

/// Underline RGB 213 from 256-color table.
const String underline256Rgb213 = '$underline256Open$RGB_213$underline256Close';

/// Underline RGB 214 from 256-color table.
const String underline256Rgb214 = '$underline256Open$RGB_214$underline256Close';

/// Underline RGB 215 from 256-color table.
const String underline256Rgb215 = '$underline256Open$RGB_215$underline256Close';

/// Underline RGB 220 from 256-color table.
const String underline256Rgb220 = '$underline256Open$RGB_220$underline256Close';

/// Underline RGB 221 from 256-color table.
const String underline256Rgb221 = '$underline256Open$RGB_221$underline256Close';

/// Underline RGB 222 from 256-color table.
const String underline256Rgb222 = '$underline256Open$RGB_222$underline256Close';

/// Underline RGB 223 from 256-color table.
const String underline256Rgb223 = '$underline256Open$RGB_223$underline256Close';

/// Underline RGB 224 from 256-color table.
const String underline256Rgb224 = '$underline256Open$RGB_224$underline256Close';

/// Underline RGB 225 from 256-color table.
const String underline256Rgb225 = '$underline256Open$RGB_225$underline256Close';

/// Underline RGB 230 from 256-color table.
const String underline256Rgb230 = '$underline256Open$RGB_230$underline256Close';

/// Underline RGB 231 from 256-color table.
const String underline256Rgb231 = '$underline256Open$RGB_231$underline256Close';

/// Underline RGB 232 from 256-color table.
const String underline256Rgb232 = '$underline256Open$RGB_232$underline256Close';

/// Underline RGB 233 from 256-color table.
const String underline256Rgb233 = '$underline256Open$RGB_233$underline256Close';

/// Underline RGB 234 from 256-color table.
const String underline256Rgb234 = '$underline256Open$RGB_234$underline256Close';

/// Underline RGB 235 from 256-color table.
const String underline256Rgb235 = '$underline256Open$RGB_235$underline256Close';

/// Underline RGB 240 from 256-color table.
const String underline256Rgb240 = '$underline256Open$RGB_240$underline256Close';

/// Underline RGB 241 from 256-color table.
const String underline256Rgb241 = '$underline256Open$RGB_241$underline256Close';

/// Underline RGB 242 from 256-color table.
const String underline256Rgb242 = '$underline256Open$RGB_242$underline256Close';

/// Underline RGB 243 from 256-color table.
const String underline256Rgb243 = '$underline256Open$RGB_243$underline256Close';

/// Underline RGB 244 from 256-color table.
const String underline256Rgb244 = '$underline256Open$RGB_244$underline256Close';

/// Underline RGB 245 from 256-color table.
const String underline256Rgb245 = '$underline256Open$RGB_245$underline256Close';

/// Underline RGB 250 from 256-color table.
const String underline256Rgb250 = '$underline256Open$RGB_250$underline256Close';

/// Underline RGB 251 from 256-color table.
const String underline256Rgb251 = '$underline256Open$RGB_251$underline256Close';

/// Underline RGB 252 from 256-color table.
const String underline256Rgb252 = '$underline256Open$RGB_252$underline256Close';

/// Underline RGB 253 from 256-color table.
const String underline256Rgb253 = '$underline256Open$RGB_253$underline256Close';

/// Underline RGB 254 from 256-color table.
const String underline256Rgb254 = '$underline256Open$RGB_254$underline256Close';

/// Underline RGB 255 from 256-color table.
const String underline256Rgb255 = '$underline256Open$RGB_255$underline256Close';

/// Underline RGB 300 from 256-color table.
const String underline256Rgb300 = '$underline256Open$RGB_300$underline256Close';

/// Underline RGB 301 from 256-color table.
const String underline256Rgb301 = '$underline256Open$RGB_301$underline256Close';

/// Underline RGB 302 from 256-color table.
const String underline256Rgb302 = '$underline256Open$RGB_302$underline256Close';

/// Underline RGB 303 from 256-color table.
const String underline256Rgb303 = '$underline256Open$RGB_303$underline256Close';

/// Underline RGB 304 from 256-color table.
const String underline256Rgb304 = '$underline256Open$RGB_304$underline256Close';

/// Underline RGB 305 from 256-color table.
const String underline256Rgb305 = '$underline256Open$RGB_305$underline256Close';

/// Underline RGB 310 from 256-color table.
const String underline256Rgb310 = '$underline256Open$RGB_310$underline256Close';

/// Underline RGB 311 from 256-color table.
const String underline256Rgb311 = '$underline256Open$RGB_311$underline256Close';

/// Underline RGB 312 from 256-color table.
const String underline256Rgb312 = '$underline256Open$RGB_312$underline256Close';

/// Underline RGB 313 from 256-color table.
const String underline256Rgb313 = '$underline256Open$RGB_313$underline256Close';

/// Underline RGB 314 from 256-color table.
const String underline256Rgb314 = '$underline256Open$RGB_314$underline256Close';

/// Underline RGB 315 from 256-color table.
const String underline256Rgb315 = '$underline256Open$RGB_315$underline256Close';

/// Underline RGB 320 from 256-color table.
const String underline256Rgb320 = '$underline256Open$RGB_320$underline256Close';

/// Underline RGB 321 from 256-color table.
const String underline256Rgb321 = '$underline256Open$RGB_321$underline256Close';

/// Underline RGB 322 from 256-color table.
const String underline256Rgb322 = '$underline256Open$RGB_322$underline256Close';

/// Underline RGB 323 from 256-color table.
const String underline256Rgb323 = '$underline256Open$RGB_323$underline256Close';

/// Underline RGB 324 from 256-color table.
const String underline256Rgb324 = '$underline256Open$RGB_324$underline256Close';

/// Underline RGB 325 from 256-color table.
const String underline256Rgb325 = '$underline256Open$RGB_325$underline256Close';

/// Underline RGB 330 from 256-color table.
const String underline256Rgb330 = '$underline256Open$RGB_330$underline256Close';

/// Underline RGB 331 from 256-color table.
const String underline256Rgb331 = '$underline256Open$RGB_331$underline256Close';

/// Underline RGB 332 from 256-color table.
const String underline256Rgb332 = '$underline256Open$RGB_332$underline256Close';

/// Underline RGB 333 from 256-color table.
const String underline256Rgb333 = '$underline256Open$RGB_333$underline256Close';

/// Underline RGB 334 from 256-color table.
const String underline256Rgb334 = '$underline256Open$RGB_334$underline256Close';

/// Underline RGB 335 from 256-color table.
const String underline256Rgb335 = '$underline256Open$RGB_335$underline256Close';

/// Underline RGB 340 from 256-color table.
const String underline256Rgb340 = '$underline256Open$RGB_340$underline256Close';

/// Underline RGB 341 from 256-color table.
const String underline256Rgb341 = '$underline256Open$RGB_341$underline256Close';

/// Underline RGB 342 from 256-color table.
const String underline256Rgb342 = '$underline256Open$RGB_342$underline256Close';

/// Underline RGB 343 from 256-color table.
const String underline256Rgb343 = '$underline256Open$RGB_343$underline256Close';

/// Underline RGB 344 from 256-color table.
const String underline256Rgb344 = '$underline256Open$RGB_344$underline256Close';

/// Underline RGB 345 from 256-color table.
const String underline256Rgb345 = '$underline256Open$RGB_345$underline256Close';

/// Underline RGB 350 from 256-color table.
const String underline256Rgb350 = '$underline256Open$RGB_350$underline256Close';

/// Underline RGB 351 from 256-color table.
const String underline256Rgb351 = '$underline256Open$RGB_351$underline256Close';

/// Underline RGB 352 from 256-color table.
const String underline256Rgb352 = '$underline256Open$RGB_352$underline256Close';

/// Underline RGB 353 from 256-color table.
const String underline256Rgb353 = '$underline256Open$RGB_353$underline256Close';

/// Underline RGB 354 from 256-color table.
const String underline256Rgb354 = '$underline256Open$RGB_354$underline256Close';

/// Underline RGB 355 from 256-color table.
const String underline256Rgb355 = '$underline256Open$RGB_355$underline256Close';

/// Underline RGB 400 from 256-color table.
const String underline256Rgb400 = '$underline256Open$RGB_400$underline256Close';

/// Underline RGB 401 from 256-color table.
const String underline256Rgb401 = '$underline256Open$RGB_401$underline256Close';

/// Underline RGB 402 from 256-color table.
const String underline256Rgb402 = '$underline256Open$RGB_402$underline256Close';

/// Underline RGB 403 from 256-color table.
const String underline256Rgb403 = '$underline256Open$RGB_403$underline256Close';

/// Underline RGB 404 from 256-color table.
const String underline256Rgb404 = '$underline256Open$RGB_404$underline256Close';

/// Underline RGB 405 from 256-color table.
const String underline256Rgb405 = '$underline256Open$RGB_405$underline256Close';

/// Underline RGB 410 from 256-color table.
const String underline256Rgb410 = '$underline256Open$RGB_410$underline256Close';

/// Underline RGB 411 from 256-color table.
const String underline256Rgb411 = '$underline256Open$RGB_411$underline256Close';

/// Underline RGB 412 from 256-color table.
const String underline256Rgb412 = '$underline256Open$RGB_412$underline256Close';

/// Underline RGB 413 from 256-color table.
const String underline256Rgb413 = '$underline256Open$RGB_413$underline256Close';

/// Underline RGB 414 from 256-color table.
const String underline256Rgb414 = '$underline256Open$RGB_414$underline256Close';

/// Underline RGB 415 from 256-color table.
const String underline256Rgb415 = '$underline256Open$RGB_415$underline256Close';

/// Underline RGB 420 from 256-color table.
const String underline256Rgb420 = '$underline256Open$RGB_420$underline256Close';

/// Underline RGB 421 from 256-color table.
const String underline256Rgb421 = '$underline256Open$RGB_421$underline256Close';

/// Underline RGB 422 from 256-color table.
const String underline256Rgb422 = '$underline256Open$RGB_422$underline256Close';

/// Underline RGB 423 from 256-color table.
const String underline256Rgb423 = '$underline256Open$RGB_423$underline256Close';

/// Underline RGB 424 from 256-color table.
const String underline256Rgb424 = '$underline256Open$RGB_424$underline256Close';

/// Underline RGB 425 from 256-color table.
const String underline256Rgb425 = '$underline256Open$RGB_425$underline256Close';

/// Underline RGB 430 from 256-color table.
const String underline256Rgb430 = '$underline256Open$RGB_430$underline256Close';

/// Underline RGB 431 from 256-color table.
const String underline256Rgb431 = '$underline256Open$RGB_431$underline256Close';

/// Underline RGB 432 from 256-color table.
const String underline256Rgb432 = '$underline256Open$RGB_432$underline256Close';

/// Underline RGB 433 from 256-color table.
const String underline256Rgb433 = '$underline256Open$RGB_433$underline256Close';

/// Underline RGB 434 from 256-color table.
const String underline256Rgb434 = '$underline256Open$RGB_434$underline256Close';

/// Underline RGB 435 from 256-color table.
const String underline256Rgb435 = '$underline256Open$RGB_435$underline256Close';

/// Underline RGB 440 from 256-color table.
const String underline256Rgb440 = '$underline256Open$RGB_440$underline256Close';

/// Underline RGB 441 from 256-color table.
const String underline256Rgb441 = '$underline256Open$RGB_441$underline256Close';

/// Underline RGB 442 from 256-color table.
const String underline256Rgb442 = '$underline256Open$RGB_442$underline256Close';

/// Underline RGB 443 from 256-color table.
const String underline256Rgb443 = '$underline256Open$RGB_443$underline256Close';

/// Underline RGB 444 from 256-color table.
const String underline256Rgb444 = '$underline256Open$RGB_444$underline256Close';

/// Underline RGB 445 from 256-color table.
const String underline256Rgb445 = '$underline256Open$RGB_445$underline256Close';

/// Underline RGB 450 from 256-color table.
const String underline256Rgb450 = '$underline256Open$RGB_450$underline256Close';

/// Underline RGB 451 from 256-color table.
const String underline256Rgb451 = '$underline256Open$RGB_451$underline256Close';

/// Underline RGB 452 from 256-color table.
const String underline256Rgb452 = '$underline256Open$RGB_452$underline256Close';

/// Underline RGB 453 from 256-color table.
const String underline256Rgb453 = '$underline256Open$RGB_453$underline256Close';

/// Underline RGB 454 from 256-color table.
const String underline256Rgb454 = '$underline256Open$RGB_454$underline256Close';

/// Underline RGB 455 from 256-color table.
const String underline256Rgb455 = '$underline256Open$RGB_455$underline256Close';

/// Underline RGB 500 from 256-color table.
const String underline256Rgb500 = '$underline256Open$RGB_500$underline256Close';

/// Underline RGB 501 from 256-color table.
const String underline256Rgb501 = '$underline256Open$RGB_501$underline256Close';

/// Underline RGB 502 from 256-color table.
const String underline256Rgb502 = '$underline256Open$RGB_502$underline256Close';

/// Underline RGB 503 from 256-color table.
const String underline256Rgb503 = '$underline256Open$RGB_503$underline256Close';

/// Underline RGB 504 from 256-color table.
const String underline256Rgb504 = '$underline256Open$RGB_504$underline256Close';

/// Underline RGB 505 from 256-color table.
const String underline256Rgb505 = '$underline256Open$RGB_505$underline256Close';

/// Underline RGB 510 from 256-color table.
const String underline256Rgb510 = '$underline256Open$RGB_510$underline256Close';

/// Underline RGB 511 from 256-color table.
const String underline256Rgb511 = '$underline256Open$RGB_511$underline256Close';

/// Underline RGB 512 from 256-color table.
const String underline256Rgb512 = '$underline256Open$RGB_512$underline256Close';

/// Underline RGB 513 from 256-color table.
const String underline256Rgb513 = '$underline256Open$RGB_513$underline256Close';

/// Underline RGB 514 from 256-color table.
const String underline256Rgb514 = '$underline256Open$RGB_514$underline256Close';

/// Underline RGB 515 from 256-color table.
const String underline256Rgb515 = '$underline256Open$RGB_515$underline256Close';

/// Underline RGB 520 from 256-color table.
const String underline256Rgb520 = '$underline256Open$RGB_520$underline256Close';

/// Underline RGB 521 from 256-color table.
const String underline256Rgb521 = '$underline256Open$RGB_521$underline256Close';

/// Underline RGB 522 from 256-color table.
const String underline256Rgb522 = '$underline256Open$RGB_522$underline256Close';

/// Underline RGB 523 from 256-color table.
const String underline256Rgb523 = '$underline256Open$RGB_523$underline256Close';

/// Underline RGB 524 from 256-color table.
const String underline256Rgb524 = '$underline256Open$RGB_524$underline256Close';

/// Underline RGB 525 from 256-color table.
const String underline256Rgb525 = '$underline256Open$RGB_525$underline256Close';

/// Underline RGB 530 from 256-color table.
const String underline256Rgb530 = '$underline256Open$RGB_530$underline256Close';

/// Underline RGB 531 from 256-color table.
const String underline256Rgb531 = '$underline256Open$RGB_531$underline256Close';

/// Underline RGB 532 from 256-color table.
const String underline256Rgb532 = '$underline256Open$RGB_532$underline256Close';

/// Underline RGB 533 from 256-color table.
const String underline256Rgb533 = '$underline256Open$RGB_533$underline256Close';

/// Underline RGB 534 from 256-color table.
const String underline256Rgb534 = '$underline256Open$RGB_534$underline256Close';

/// Underline RGB 535 from 256-color table.
const String underline256Rgb535 = '$underline256Open$RGB_535$underline256Close';

/// Underline RGB 540 from 256-color table.
const String underline256Rgb540 = '$underline256Open$RGB_540$underline256Close';

/// Underline RGB 541 from 256-color table.
const String underline256Rgb541 = '$underline256Open$RGB_541$underline256Close';

/// Underline RGB 542 from 256-color table.
const String underline256Rgb542 = '$underline256Open$RGB_542$underline256Close';

/// Underline RGB 543 from 256-color table.
const String underline256Rgb543 = '$underline256Open$RGB_543$underline256Close';

/// Underline RGB 544 from 256-color table.
const String underline256Rgb544 = '$underline256Open$RGB_544$underline256Close';

/// Underline RGB 545 from 256-color table.
const String underline256Rgb545 = '$underline256Open$RGB_545$underline256Close';

/// Underline RGB 550 from 256-color table.
const String underline256Rgb550 = '$underline256Open$RGB_550$underline256Close';

/// Underline RGB 551 from 256-color table.
const String underline256Rgb551 = '$underline256Open$RGB_551$underline256Close';

/// Underline RGB 552 from 256-color table.
const String underline256Rgb552 = '$underline256Open$RGB_552$underline256Close';

/// Underline RGB 553 from 256-color table.
const String underline256Rgb553 = '$underline256Open$RGB_553$underline256Close';

/// Underline RGB 554 from 256-color table.
const String underline256Rgb554 = '$underline256Open$RGB_554$underline256Close';

/// Underline RGB 555 from 256-color table.
const String underline256Rgb555 = '$underline256Open$RGB_555$underline256Close';

//
// Predefined grayscale.
//
// Gray colors from dark to light in 24 steps.
//

/// Underline gray color 0 from 256-color table.
const String underline256Gray0 = '$underline256Open$GRAY0$underline256Close';

/// Underline gray color 1 from 256-color table.
const String underline256Gray1 = '$underline256Open$GRAY1$underline256Close';

/// Underline gray color 2 from 256-color table.
const String underline256Gray2 = '$underline256Open$GRAY2$underline256Close';

/// Underline gray color 3 from 256-color table.
const String underline256Gray3 = '$underline256Open$GRAY3$underline256Close';

/// Underline gray color 4 from 256-color table.
const String underline256Gray4 = '$underline256Open$GRAY4$underline256Close';

/// Underline gray color 5 from 256-color table.
const String underline256Gray5 = '$underline256Open$GRAY5$underline256Close';

/// Underline gray color 6 from 256-color table.
const String underline256Gray6 = '$underline256Open$GRAY6$underline256Close';

/// Underline gray color 7 from 256-color table.
const String underline256Gray7 = '$underline256Open$GRAY7$underline256Close';

/// Underline gray color 8 from 256-color table.
const String underline256Gray8 = '$underline256Open$GRAY8$underline256Close';

/// Underline gray color 9 from 256-color table.
const String underline256Gray9 = '$underline256Open$GRAY9$underline256Close';

/// Underline gray color 10 from 256-color table.
const String underline256Gray10 = '$underline256Open$GRAY10$underline256Close';

/// Underline gray color 11 from 256-color table.
const String underline256Gray11 = '$underline256Open$GRAY11$underline256Close';

/// Underline gray color 12 from 256-color table.
const String underline256Gray12 = '$underline256Open$GRAY12$underline256Close';

/// Underline gray color 13 from 256-color table.
const String underline256Gray13 = '$underline256Open$GRAY13$underline256Close';

/// Underline gray color 14 from 256-color table.
const String underline256Gray14 = '$underline256Open$GRAY14$underline256Close';

/// Underline gray color 15 from 256-color table.
const String underline256Gray15 = '$underline256Open$GRAY15$underline256Close';

/// Underline gray color 16 from 256-color table.
const String underline256Gray16 = '$underline256Open$GRAY16$underline256Close';

/// Underline gray color 17 from 256-color table.
const String underline256Gray17 = '$underline256Open$GRAY17$underline256Close';

/// Underline gray color 18 from 256-color table.
const String underline256Gray18 = '$underline256Open$GRAY18$underline256Close';

/// Underline gray color 19 from 256-color table.
const String underline256Gray19 = '$underline256Open$GRAY19$underline256Close';

/// Underline gray color 20 from 256-color table.
const String underline256Gray20 = '$underline256Open$GRAY20$underline256Close';

/// Underline gray color 21 from 256-color table.
const String underline256Gray21 = '$underline256Open$GRAY21$underline256Close';

/// Underline gray color 22 from 256-color table.
const String underline256Gray22 = '$underline256Open$GRAY22$underline256Close';

/// Underline gray color 23 from 256-color table.
const String underline256Gray23 = '$underline256Open$GRAY23$underline256Close';
