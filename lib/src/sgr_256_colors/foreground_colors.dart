import '../csi.dart';
import '../sgr.dart';
import 'assert.dart';
import 'sgr_256_color_table.dart';

//
// ANSI escape codes for foreground from 256-color table.
//

/// Opening tag for foreground with 256-color table.
///
/// Template: `${fg256Open}{colorIndex}${fg256Close}`
///
/// Predefined constants:
/// `$fg256Open$black$fg256Close` = `fg256Black`
///
/// Compatibility:
/// - +vscode
/// - +mac Terminal
/// - +mac iTerm2
/// - +as
///
/// See color indexes in the
/// [sgr_256_color_table.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/sgr_256_color_table.dart).
///
/// See also [fg256].
const String fg256Open = '${csi}38;5;';

/// Closing tag for foreground with 256-color table.
///
/// See [fg256Open].
const String fg256Close = sgr;

/// Set color to foreground from 256-color table.
///
/// See also [fg256Open] and [fg256Close].
String fg256(int colorIndex) {
  assert(colorIndex >= 0 && colorIndex <= 255, colorIndexAssert);

  return '$fg256Open$colorIndex$fg256Close';
}

//
// Predefined standard colors.
//

/// Foreground black from 256-color table.
const String fg256Black = '$fg256Open$black$fg256Close';

/// Foreground red from 256-color table.
const String fg256Red = '$fg256Open$red$fg256Close';

/// Foreground green from 256-color table.
const String fg256Green = '$fg256Open$green$fg256Close';

/// Foreground yellow from 256-color table.
const String fg256Yellow = '$fg256Open$yellow$fg256Close';

/// Foreground blue from 256-color table.
const String fg256Blue = '$fg256Open$blue$fg256Close';

/// Foreground magenta from 256-color table.
const String fg256Magenta = '$fg256Open$magenta$fg256Close';

/// Foreground cyan from 256-color table.
const String fg256Cyan = '$fg256Open$cyan$fg256Close';

/// Foreground white from 256-color table.
const String fg256White = '$fg256Open$white$fg256Close';

//
// Predefined high intensity colors.
//

/// Foreground high intensity black from 256-color table.
const String fg256HighBlack = '$fg256Open$highBlack$fg256Close';

/// Foreground high intensity red from 256-color table.
const String fg256HighRed = '$fg256Open$highRed$fg256Close';

/// Foreground high intensity green from 256-color table.
const String fg256HighGreen = '$fg256Open$highGreen$fg256Close';

/// Foreground high intensity yellow from 256-color table.
const String fg256HighYellow = '$fg256Open$highYellow$fg256Close';

/// Foreground high intensity blue from 256-color table.
const String fg256HighBlue = '$fg256Open$highBlue$fg256Close';

/// Foreground high intensity magenta from 256-color table.
const String fg256HighMagenta = '$fg256Open$highMagenta$fg256Close';

/// Foreground high intensity cyan from 256-color table.
const String fg256HighCyan = '$fg256Open$highCyan$fg256Close';

/// Foreground high intensity white from 256-color table.
const String fg256HighWhite = '$fg256Open$highWhite$fg256Close';

//
// Predefined RGB colors.
//
// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).
//

/// Foreground RGB 000 from 256-color table.
const String fg256Rgb000 = '$fg256Open$rgb000$fg256Close';

/// Foreground RGB 001 from 256-color table.
const String fg256Rgb001 = '$fg256Open$rgb001$fg256Close';

/// Foreground RGB 002 from 256-color table.
const String fg256Rgb002 = '$fg256Open$rgb002$fg256Close';

/// Foreground RGB 003 from 256-color table.
const String fg256Rgb003 = '$fg256Open$rgb003$fg256Close';

/// Foreground RGB 004 from 256-color table.
const String fg256Rgb004 = '$fg256Open$rgb004$fg256Close';

/// Foreground RGB 005 from 256-color table.
const String fg256Rgb005 = '$fg256Open$rgb005$fg256Close';

/// Foreground RGB 010 from 256-color table.
const String fg256Rgb010 = '$fg256Open$rgb010$fg256Close';

/// Foreground RGB 011 from 256-color table.
const String fg256Rgb011 = '$fg256Open$rgb011$fg256Close';

/// Foreground RGB 012 from 256-color table.
const String fg256Rgb012 = '$fg256Open$rgb012$fg256Close';

/// Foreground RGB 013 from 256-color table.
const String fg256Rgb013 = '$fg256Open$rgb013$fg256Close';

/// Foreground RGB 014 from 256-color table.
const String fg256Rgb014 = '$fg256Open$rgb014$fg256Close';

/// Foreground RGB 015 from 256-color table.
const String fg256Rgb015 = '$fg256Open$rgb015$fg256Close';

/// Foreground RGB 020 from 256-color table.
const String fg256Rgb020 = '$fg256Open$rgb020$fg256Close';

/// Foreground RGB 021 from 256-color table.
const String fg256Rgb021 = '$fg256Open$rgb021$fg256Close';

/// Foreground RGB 022 from 256-color table.
const String fg256Rgb022 = '$fg256Open$rgb022$fg256Close';

/// Foreground RGB 023 from 256-color table.
const String fg256Rgb023 = '$fg256Open$rgb023$fg256Close';

/// Foreground RGB 024 from 256-color table.
const String fg256Rgb024 = '$fg256Open$rgb024$fg256Close';

/// Foreground RGB 025 from 256-color table.
const String fg256Rgb025 = '$fg256Open$rgb025$fg256Close';

/// Foreground RGB 030 from 256-color table.
const String fg256Rgb030 = '$fg256Open$rgb030$fg256Close';

/// Foreground RGB 031 from 256-color table.
const String fg256Rgb031 = '$fg256Open$rgb031$fg256Close';

/// Foreground RGB 032 from 256-color table.
const String fg256Rgb032 = '$fg256Open$rgb032$fg256Close';

/// Foreground RGB 033 from 256-color table.
const String fg256Rgb033 = '$fg256Open$rgb033$fg256Close';

/// Foreground RGB 034 from 256-color table.
const String fg256Rgb034 = '$fg256Open$rgb034$fg256Close';

/// Foreground RGB 035 from 256-color table.
const String fg256Rgb035 = '$fg256Open$rgb035$fg256Close';

/// Foreground RGB 040 from 256-color table.
const String fg256Rgb040 = '$fg256Open$rgb040$fg256Close';

/// Foreground RGB 041 from 256-color table.
const String fg256Rgb041 = '$fg256Open$rgb041$fg256Close';

/// Foreground RGB 042 from 256-color table.
const String fg256Rgb042 = '$fg256Open$rgb042$fg256Close';

/// Foreground RGB 043 from 256-color table.
const String fg256Rgb043 = '$fg256Open$rgb043$fg256Close';

/// Foreground RGB 044 from 256-color table.
const String fg256Rgb044 = '$fg256Open$rgb044$fg256Close';

/// Foreground RGB 045 from 256-color table.
const String fg256Rgb045 = '$fg256Open$rgb045$fg256Close';

/// Foreground RGB 050 from 256-color table.
const String fg256Rgb050 = '$fg256Open$rgb050$fg256Close';

/// Foreground RGB 051 from 256-color table.
const String fg256Rgb051 = '$fg256Open$rgb051$fg256Close';

/// Foreground RGB 052 from 256-color table.
const String fg256Rgb052 = '$fg256Open$rgb052$fg256Close';

/// Foreground RGB 053 from 256-color table.
const String fg256Rgb053 = '$fg256Open$rgb053$fg256Close';

/// Foreground RGB 054 from 256-color table.
const String fg256Rgb054 = '$fg256Open$rgb054$fg256Close';

/// Foreground RGB 055 from 256-color table.
const String fg256Rgb055 = '$fg256Open$rgb055$fg256Close';

/// Foreground RGB 100 from 256-color table.
const String fg256Rgb100 = '$fg256Open$rgb100$fg256Close';

/// Foreground RGB 101 from 256-color table.
const String fg256Rgb101 = '$fg256Open$rgb101$fg256Close';

/// Foreground RGB 102 from 256-color table.
const String fg256Rgb102 = '$fg256Open$rgb102$fg256Close';

/// Foreground RGB 103 from 256-color table.
const String fg256Rgb103 = '$fg256Open$rgb103$fg256Close';

/// Foreground RGB 104 from 256-color table.
const String fg256Rgb104 = '$fg256Open$rgb104$fg256Close';

/// Foreground RGB 105 from 256-color table.
const String fg256Rgb105 = '$fg256Open$rgb105$fg256Close';

/// Foreground RGB 110 from 256-color table.
const String fg256Rgb110 = '$fg256Open$rgb110$fg256Close';

/// Foreground RGB 111 from 256-color table.
const String fg256Rgb111 = '$fg256Open$rgb111$fg256Close';

/// Foreground RGB 112 from 256-color table.
const String fg256Rgb112 = '$fg256Open$rgb112$fg256Close';

/// Foreground RGB 113 from 256-color table.
const String fg256Rgb113 = '$fg256Open$rgb113$fg256Close';

/// Foreground RGB 114 from 256-color table.
const String fg256Rgb114 = '$fg256Open$rgb114$fg256Close';

/// Foreground RGB 115 from 256-color table.
const String fg256Rgb115 = '$fg256Open$rgb115$fg256Close';

/// Foreground RGB 120 from 256-color table.
const String fg256Rgb120 = '$fg256Open$rgb120$fg256Close';

/// Foreground RGB 121 from 256-color table.
const String fg256Rgb121 = '$fg256Open$rgb121$fg256Close';

/// Foreground RGB 122 from 256-color table.
const String fg256Rgb122 = '$fg256Open$rgb122$fg256Close';

/// Foreground RGB 123 from 256-color table.
const String fg256Rgb123 = '$fg256Open$rgb123$fg256Close';

/// Foreground RGB 124 from 256-color table.
const String fg256Rgb124 = '$fg256Open$rgb124$fg256Close';

/// Foreground RGB 125 from 256-color table.
const String fg256Rgb125 = '$fg256Open$rgb125$fg256Close';

/// Foreground RGB 130 from 256-color table.
const String fg256Rgb130 = '$fg256Open$rgb130$fg256Close';

/// Foreground RGB 131 from 256-color table.
const String fg256Rgb131 = '$fg256Open$rgb131$fg256Close';

/// Foreground RGB 132 from 256-color table.
const String fg256Rgb132 = '$fg256Open$rgb132$fg256Close';

/// Foreground RGB 133 from 256-color table.
const String fg256Rgb133 = '$fg256Open$rgb133$fg256Close';

/// Foreground RGB 134 from 256-color table.
const String fg256Rgb134 = '$fg256Open$rgb134$fg256Close';

/// Foreground RGB 135 from 256-color table.
const String fg256Rgb135 = '$fg256Open$rgb135$fg256Close';

/// Foreground RGB 140 from 256-color table.
const String fg256Rgb140 = '$fg256Open$rgb140$fg256Close';

/// Foreground RGB 141 from 256-color table.
const String fg256Rgb141 = '$fg256Open$rgb141$fg256Close';

/// Foreground RGB 142 from 256-color table.
const String fg256Rgb142 = '$fg256Open$rgb142$fg256Close';

/// Foreground RGB 143 from 256-color table.
const String fg256Rgb143 = '$fg256Open$rgb143$fg256Close';

/// Foreground RGB 144 from 256-color table.
const String fg256Rgb144 = '$fg256Open$rgb144$fg256Close';

/// Foreground RGB 145 from 256-color table.
const String fg256Rgb145 = '$fg256Open$rgb145$fg256Close';

/// Foreground RGB 150 from 256-color table.
const String fg256Rgb150 = '$fg256Open$rgb150$fg256Close';

/// Foreground RGB 151 from 256-color table.
const String fg256Rgb151 = '$fg256Open$rgb151$fg256Close';

/// Foreground RGB 152 from 256-color table.
const String fg256Rgb152 = '$fg256Open$rgb152$fg256Close';

/// Foreground RGB 153 from 256-color table.
const String fg256Rgb153 = '$fg256Open$rgb153$fg256Close';

/// Foreground RGB 154 from 256-color table.
const String fg256Rgb154 = '$fg256Open$rgb154$fg256Close';

/// Foreground RGB 155 from 256-color table.
const String fg256Rgb155 = '$fg256Open$rgb155$fg256Close';

/// Foreground RGB 200 from 256-color table.
const String fg256Rgb200 = '$fg256Open$rgb200$fg256Close';

/// Foreground RGB 201 from 256-color table.
const String fg256Rgb201 = '$fg256Open$rgb201$fg256Close';

/// Foreground RGB 202 from 256-color table.
const String fg256Rgb202 = '$fg256Open$rgb202$fg256Close';

/// Foreground RGB 203 from 256-color table.
const String fg256Rgb203 = '$fg256Open$rgb203$fg256Close';

/// Foreground RGB 204 from 256-color table.
const String fg256Rgb204 = '$fg256Open$rgb204$fg256Close';

/// Foreground RGB 205 from 256-color table.
const String fg256Rgb205 = '$fg256Open$rgb205$fg256Close';

/// Foreground RGB 210 from 256-color table.
const String fg256Rgb210 = '$fg256Open$rgb210$fg256Close';

/// Foreground RGB 211 from 256-color table.
const String fg256Rgb211 = '$fg256Open$rgb211$fg256Close';

/// Foreground RGB 212 from 256-color table.
const String fg256Rgb212 = '$fg256Open$rgb212$fg256Close';

/// Foreground RGB 213 from 256-color table.
const String fg256Rgb213 = '$fg256Open$rgb213$fg256Close';

/// Foreground RGB 214 from 256-color table.
const String fg256Rgb214 = '$fg256Open$rgb214$fg256Close';

/// Foreground RGB 215 from 256-color table.
const String fg256Rgb215 = '$fg256Open$rgb215$fg256Close';

/// Foreground RGB 220 from 256-color table.
const String fg256Rgb220 = '$fg256Open$rgb220$fg256Close';

/// Foreground RGB 221 from 256-color table.
const String fg256Rgb221 = '$fg256Open$rgb221$fg256Close';

/// Foreground RGB 222 from 256-color table.
const String fg256Rgb222 = '$fg256Open$rgb222$fg256Close';

/// Foreground RGB 223 from 256-color table.
const String fg256Rgb223 = '$fg256Open$rgb223$fg256Close';

/// Foreground RGB 224 from 256-color table.
const String fg256Rgb224 = '$fg256Open$rgb224$fg256Close';

/// Foreground RGB 225 from 256-color table.
const String fg256Rgb225 = '$fg256Open$rgb225$fg256Close';

/// Foreground RGB 230 from 256-color table.
const String fg256Rgb230 = '$fg256Open$rgb230$fg256Close';

/// Foreground RGB 231 from 256-color table.
const String fg256Rgb231 = '$fg256Open$rgb231$fg256Close';

/// Foreground RGB 232 from 256-color table.
const String fg256Rgb232 = '$fg256Open$rgb232$fg256Close';

/// Foreground RGB 233 from 256-color table.
const String fg256Rgb233 = '$fg256Open$rgb233$fg256Close';

/// Foreground RGB 234 from 256-color table.
const String fg256Rgb234 = '$fg256Open$rgb234$fg256Close';

/// Foreground RGB 235 from 256-color table.
const String fg256Rgb235 = '$fg256Open$rgb235$fg256Close';

/// Foreground RGB 240 from 256-color table.
const String fg256Rgb240 = '$fg256Open$rgb240$fg256Close';

/// Foreground RGB 241 from 256-color table.
const String fg256Rgb241 = '$fg256Open$rgb241$fg256Close';

/// Foreground RGB 242 from 256-color table.
const String fg256Rgb242 = '$fg256Open$rgb242$fg256Close';

/// Foreground RGB 243 from 256-color table.
const String fg256Rgb243 = '$fg256Open$rgb243$fg256Close';

/// Foreground RGB 244 from 256-color table.
const String fg256Rgb244 = '$fg256Open$rgb244$fg256Close';

/// Foreground RGB 245 from 256-color table.
const String fg256Rgb245 = '$fg256Open$rgb245$fg256Close';

/// Foreground RGB 250 from 256-color table.
const String fg256Rgb250 = '$fg256Open$rgb250$fg256Close';

/// Foreground RGB 251 from 256-color table.
const String fg256Rgb251 = '$fg256Open$rgb251$fg256Close';

/// Foreground RGB 252 from 256-color table.
const String fg256Rgb252 = '$fg256Open$rgb252$fg256Close';

/// Foreground RGB 253 from 256-color table.
const String fg256Rgb253 = '$fg256Open$rgb253$fg256Close';

/// Foreground RGB 254 from 256-color table.
const String fg256Rgb254 = '$fg256Open$rgb254$fg256Close';

/// Foreground RGB 255 from 256-color table.
const String fg256Rgb255 = '$fg256Open$rgb255$fg256Close';

/// Foreground RGB 300 from 256-color table.
const String fg256Rgb300 = '$fg256Open$rgb300$fg256Close';

/// Foreground RGB 301 from 256-color table.
const String fg256Rgb301 = '$fg256Open$rgb301$fg256Close';

/// Foreground RGB 302 from 256-color table.
const String fg256Rgb302 = '$fg256Open$rgb302$fg256Close';

/// Foreground RGB 303 from 256-color table.
const String fg256Rgb303 = '$fg256Open$rgb303$fg256Close';

/// Foreground RGB 304 from 256-color table.
const String fg256Rgb304 = '$fg256Open$rgb304$fg256Close';

/// Foreground RGB 305 from 256-color table.
const String fg256Rgb305 = '$fg256Open$rgb305$fg256Close';

/// Foreground RGB 310 from 256-color table.
const String fg256Rgb310 = '$fg256Open$rgb310$fg256Close';

/// Foreground RGB 311 from 256-color table.
const String fg256Rgb311 = '$fg256Open$rgb311$fg256Close';

/// Foreground RGB 312 from 256-color table.
const String fg256Rgb312 = '$fg256Open$rgb312$fg256Close';

/// Foreground RGB 313 from 256-color table.
const String fg256Rgb313 = '$fg256Open$rgb313$fg256Close';

/// Foreground RGB 314 from 256-color table.
const String fg256Rgb314 = '$fg256Open$rgb314$fg256Close';

/// Foreground RGB 315 from 256-color table.
const String fg256Rgb315 = '$fg256Open$rgb315$fg256Close';

/// Foreground RGB 320 from 256-color table.
const String fg256Rgb320 = '$fg256Open$rgb320$fg256Close';

/// Foreground RGB 321 from 256-color table.
const String fg256Rgb321 = '$fg256Open$rgb321$fg256Close';

/// Foreground RGB 322 from 256-color table.
const String fg256Rgb322 = '$fg256Open$rgb322$fg256Close';

/// Foreground RGB 323 from 256-color table.
const String fg256Rgb323 = '$fg256Open$rgb323$fg256Close';

/// Foreground RGB 324 from 256-color table.
const String fg256Rgb324 = '$fg256Open$rgb324$fg256Close';

/// Foreground RGB 325 from 256-color table.
const String fg256Rgb325 = '$fg256Open$rgb325$fg256Close';

/// Foreground RGB 330 from 256-color table.
const String fg256Rgb330 = '$fg256Open$rgb330$fg256Close';

/// Foreground RGB 331 from 256-color table.
const String fg256Rgb331 = '$fg256Open$rgb331$fg256Close';

/// Foreground RGB 332 from 256-color table.
const String fg256Rgb332 = '$fg256Open$rgb332$fg256Close';

/// Foreground RGB 333 from 256-color table.
const String fg256Rgb333 = '$fg256Open$rgb333$fg256Close';

/// Foreground RGB 334 from 256-color table.
const String fg256Rgb334 = '$fg256Open$rgb334$fg256Close';

/// Foreground RGB 335 from 256-color table.
const String fg256Rgb335 = '$fg256Open$rgb335$fg256Close';

/// Foreground RGB 340 from 256-color table.
const String fg256Rgb340 = '$fg256Open$rgb340$fg256Close';

/// Foreground RGB 341 from 256-color table.
const String fg256Rgb341 = '$fg256Open$rgb341$fg256Close';

/// Foreground RGB 342 from 256-color table.
const String fg256Rgb342 = '$fg256Open$rgb342$fg256Close';

/// Foreground RGB 343 from 256-color table.
const String fg256Rgb343 = '$fg256Open$rgb343$fg256Close';

/// Foreground RGB 344 from 256-color table.
const String fg256Rgb344 = '$fg256Open$rgb344$fg256Close';

/// Foreground RGB 345 from 256-color table.
const String fg256Rgb345 = '$fg256Open$rgb345$fg256Close';

/// Foreground RGB 350 from 256-color table.
const String fg256Rgb350 = '$fg256Open$rgb350$fg256Close';

/// Foreground RGB 351 from 256-color table.
const String fg256Rgb351 = '$fg256Open$rgb351$fg256Close';

/// Foreground RGB 352 from 256-color table.
const String fg256Rgb352 = '$fg256Open$rgb352$fg256Close';

/// Foreground RGB 353 from 256-color table.
const String fg256Rgb353 = '$fg256Open$rgb353$fg256Close';

/// Foreground RGB 354 from 256-color table.
const String fg256Rgb354 = '$fg256Open$rgb354$fg256Close';

/// Foreground RGB 355 from 256-color table.
const String fg256Rgb355 = '$fg256Open$rgb355$fg256Close';

/// Foreground RGB 400 from 256-color table.
const String fg256Rgb400 = '$fg256Open$rgb400$fg256Close';

/// Foreground RGB 401 from 256-color table.
const String fg256Rgb401 = '$fg256Open$rgb401$fg256Close';

/// Foreground RGB 402 from 256-color table.
const String fg256Rgb402 = '$fg256Open$rgb402$fg256Close';

/// Foreground RGB 403 from 256-color table.
const String fg256Rgb403 = '$fg256Open$rgb403$fg256Close';

/// Foreground RGB 404 from 256-color table.
const String fg256Rgb404 = '$fg256Open$rgb404$fg256Close';

/// Foreground RGB 405 from 256-color table.
const String fg256Rgb405 = '$fg256Open$rgb405$fg256Close';

/// Foreground RGB 410 from 256-color table.
const String fg256Rgb410 = '$fg256Open$rgb410$fg256Close';

/// Foreground RGB 411 from 256-color table.
const String fg256Rgb411 = '$fg256Open$rgb411$fg256Close';

/// Foreground RGB 412 from 256-color table.
const String fg256Rgb412 = '$fg256Open$rgb412$fg256Close';

/// Foreground RGB 413 from 256-color table.
const String fg256Rgb413 = '$fg256Open$rgb413$fg256Close';

/// Foreground RGB 414 from 256-color table.
const String fg256Rgb414 = '$fg256Open$rgb414$fg256Close';

/// Foreground RGB 415 from 256-color table.
const String fg256Rgb415 = '$fg256Open$rgb415$fg256Close';

/// Foreground RGB 420 from 256-color table.
const String fg256Rgb420 = '$fg256Open$rgb420$fg256Close';

/// Foreground RGB 421 from 256-color table.
const String fg256Rgb421 = '$fg256Open$rgb421$fg256Close';

/// Foreground RGB 422 from 256-color table.
const String fg256Rgb422 = '$fg256Open$rgb422$fg256Close';

/// Foreground RGB 423 from 256-color table.
const String fg256Rgb423 = '$fg256Open$rgb423$fg256Close';

/// Foreground RGB 424 from 256-color table.
const String fg256Rgb424 = '$fg256Open$rgb424$fg256Close';

/// Foreground RGB 425 from 256-color table.
const String fg256Rgb425 = '$fg256Open$rgb425$fg256Close';

/// Foreground RGB 430 from 256-color table.
const String fg256Rgb430 = '$fg256Open$rgb430$fg256Close';

/// Foreground RGB 431 from 256-color table.
const String fg256Rgb431 = '$fg256Open$rgb431$fg256Close';

/// Foreground RGB 432 from 256-color table.
const String fg256Rgb432 = '$fg256Open$rgb432$fg256Close';

/// Foreground RGB 433 from 256-color table.
const String fg256Rgb433 = '$fg256Open$rgb433$fg256Close';

/// Foreground RGB 434 from 256-color table.
const String fg256Rgb434 = '$fg256Open$rgb434$fg256Close';

/// Foreground RGB 435 from 256-color table.
const String fg256Rgb435 = '$fg256Open$rgb435$fg256Close';

/// Foreground RGB 440 from 256-color table.
const String fg256Rgb440 = '$fg256Open$rgb440$fg256Close';

/// Foreground RGB 441 from 256-color table.
const String fg256Rgb441 = '$fg256Open$rgb441$fg256Close';

/// Foreground RGB 442 from 256-color table.
const String fg256Rgb442 = '$fg256Open$rgb442$fg256Close';

/// Foreground RGB 443 from 256-color table.
const String fg256Rgb443 = '$fg256Open$rgb443$fg256Close';

/// Foreground RGB 444 from 256-color table.
const String fg256Rgb444 = '$fg256Open$rgb444$fg256Close';

/// Foreground RGB 445 from 256-color table.
const String fg256Rgb445 = '$fg256Open$rgb445$fg256Close';

/// Foreground RGB 450 from 256-color table.
const String fg256Rgb450 = '$fg256Open$rgb450$fg256Close';

/// Foreground RGB 451 from 256-color table.
const String fg256Rgb451 = '$fg256Open$rgb451$fg256Close';

/// Foreground RGB 452 from 256-color table.
const String fg256Rgb452 = '$fg256Open$rgb452$fg256Close';

/// Foreground RGB 453 from 256-color table.
const String fg256Rgb453 = '$fg256Open$rgb453$fg256Close';

/// Foreground RGB 454 from 256-color table.
const String fg256Rgb454 = '$fg256Open$rgb454$fg256Close';

/// Foreground RGB 455 from 256-color table.
const String fg256Rgb455 = '$fg256Open$rgb455$fg256Close';

/// Foreground RGB 500 from 256-color table.
const String fg256Rgb500 = '$fg256Open$rgb500$fg256Close';

/// Foreground RGB 501 from 256-color table.
const String fg256Rgb501 = '$fg256Open$rgb501$fg256Close';

/// Foreground RGB 502 from 256-color table.
const String fg256Rgb502 = '$fg256Open$rgb502$fg256Close';

/// Foreground RGB 503 from 256-color table.
const String fg256Rgb503 = '$fg256Open$rgb503$fg256Close';

/// Foreground RGB 504 from 256-color table.
const String fg256Rgb504 = '$fg256Open$rgb504$fg256Close';

/// Foreground RGB 505 from 256-color table.
const String fg256Rgb505 = '$fg256Open$rgb505$fg256Close';

/// Foreground RGB 510 from 256-color table.
const String fg256Rgb510 = '$fg256Open$rgb510$fg256Close';

/// Foreground RGB 511 from 256-color table.
const String fg256Rgb511 = '$fg256Open$rgb511$fg256Close';

/// Foreground RGB 512 from 256-color table.
const String fg256Rgb512 = '$fg256Open$rgb512$fg256Close';

/// Foreground RGB 513 from 256-color table.
const String fg256Rgb513 = '$fg256Open$rgb513$fg256Close';

/// Foreground RGB 514 from 256-color table.
const String fg256Rgb514 = '$fg256Open$rgb514$fg256Close';

/// Foreground RGB 515 from 256-color table.
const String fg256Rgb515 = '$fg256Open$rgb515$fg256Close';

/// Foreground RGB 520 from 256-color table.
const String fg256Rgb520 = '$fg256Open$rgb520$fg256Close';

/// Foreground RGB 521 from 256-color table.
const String fg256Rgb521 = '$fg256Open$rgb521$fg256Close';

/// Foreground RGB 522 from 256-color table.
const String fg256Rgb522 = '$fg256Open$rgb522$fg256Close';

/// Foreground RGB 523 from 256-color table.
const String fg256Rgb523 = '$fg256Open$rgb523$fg256Close';

/// Foreground RGB 524 from 256-color table.
const String fg256Rgb524 = '$fg256Open$rgb524$fg256Close';

/// Foreground RGB 525 from 256-color table.
const String fg256Rgb525 = '$fg256Open$rgb525$fg256Close';

/// Foreground RGB 530 from 256-color table.
const String fg256Rgb530 = '$fg256Open$rgb530$fg256Close';

/// Foreground RGB 531 from 256-color table.
const String fg256Rgb531 = '$fg256Open$rgb531$fg256Close';

/// Foreground RGB 532 from 256-color table.
const String fg256Rgb532 = '$fg256Open$rgb532$fg256Close';

/// Foreground RGB 533 from 256-color table.
const String fg256Rgb533 = '$fg256Open$rgb533$fg256Close';

/// Foreground RGB 534 from 256-color table.
const String fg256Rgb534 = '$fg256Open$rgb534$fg256Close';

/// Foreground RGB 535 from 256-color table.
const String fg256Rgb535 = '$fg256Open$rgb535$fg256Close';

/// Foreground RGB 540 from 256-color table.
const String fg256Rgb540 = '$fg256Open$rgb540$fg256Close';

/// Foreground RGB 541 from 256-color table.
const String fg256Rgb541 = '$fg256Open$rgb541$fg256Close';

/// Foreground RGB 542 from 256-color table.
const String fg256Rgb542 = '$fg256Open$rgb542$fg256Close';

/// Foreground RGB 543 from 256-color table.
const String fg256Rgb543 = '$fg256Open$rgb543$fg256Close';

/// Foreground RGB 544 from 256-color table.
const String fg256Rgb544 = '$fg256Open$rgb544$fg256Close';

/// Foreground RGB 545 from 256-color table.
const String fg256Rgb545 = '$fg256Open$rgb545$fg256Close';

/// Foreground RGB 550 from 256-color table.
const String fg256Rgb550 = '$fg256Open$rgb550$fg256Close';

/// Foreground RGB 551 from 256-color table.
const String fg256Rgb551 = '$fg256Open$rgb551$fg256Close';

/// Foreground RGB 552 from 256-color table.
const String fg256Rgb552 = '$fg256Open$rgb552$fg256Close';

/// Foreground RGB 553 from 256-color table.
const String fg256Rgb553 = '$fg256Open$rgb553$fg256Close';

/// Foreground RGB 554 from 256-color table.
const String fg256Rgb554 = '$fg256Open$rgb554$fg256Close';

/// Foreground RGB 555 from 256-color table.
const String fg256Rgb555 = '$fg256Open$rgb555$fg256Close';

//
// Predefined grayscale.
//
// Gray colors from dark to light in 24 steps.
//

/// Foreground gray color 0 from 256-color table.
const String fg256Gray0 = '$fg256Open$gray0$fg256Close';

/// Foreground gray color 1 from 256-color table.
const String fg256Gray1 = '$fg256Open$gray1$fg256Close';

/// Foreground gray color 2 from 256-color table.
const String fg256Gray2 = '$fg256Open$gray2$fg256Close';

/// Foreground gray color 3 from 256-color table.
const String fg256Gray3 = '$fg256Open$gray3$fg256Close';

/// Foreground gray color 4 from 256-color table.
const String fg256Gray4 = '$fg256Open$gray4$fg256Close';

/// Foreground gray color 5 from 256-color table.
const String fg256Gray5 = '$fg256Open$gray5$fg256Close';

/// Foreground gray color 6 from 256-color table.
const String fg256Gray6 = '$fg256Open$gray6$fg256Close';

/// Foreground gray color 7 from 256-color table.
const String fg256Gray7 = '$fg256Open$gray7$fg256Close';

/// Foreground gray color 8 from 256-color table.
const String fg256Gray8 = '$fg256Open$gray8$fg256Close';

/// Foreground gray color 9 from 256-color table.
const String fg256Gray9 = '$fg256Open$gray9$fg256Close';

/// Foreground gray color 10 from 256-color table.
const String fg256Gray10 = '$fg256Open$gray10$fg256Close';

/// Foreground gray color 11 from 256-color table.
const String fg256Gray11 = '$fg256Open$gray11$fg256Close';

/// Foreground gray color 12 from 256-color table.
const String fg256Gray12 = '$fg256Open$gray12$fg256Close';

/// Foreground gray color 13 from 256-color table.
const String fg256Gray13 = '$fg256Open$gray13$fg256Close';

/// Foreground gray color 14 from 256-color table.
const String fg256Gray14 = '$fg256Open$gray14$fg256Close';

/// Foreground gray color 15 from 256-color table.
const String fg256Gray15 = '$fg256Open$gray15$fg256Close';

/// Foreground gray color 16 from 256-color table.
const String fg256Gray16 = '$fg256Open$gray16$fg256Close';

/// Foreground gray color 17 from 256-color table.
const String fg256Gray17 = '$fg256Open$gray17$fg256Close';

/// Foreground gray color 18 from 256-color table.
const String fg256Gray18 = '$fg256Open$gray18$fg256Close';

/// Foreground gray color 19 from 256-color table.
const String fg256Gray19 = '$fg256Open$gray19$fg256Close';

/// Foreground gray color 20 from 256-color table.
const String fg256Gray20 = '$fg256Open$gray20$fg256Close';

/// Foreground gray color 21 from 256-color table.
const String fg256Gray21 = '$fg256Open$gray21$fg256Close';

/// Foreground gray color 22 from 256-color table.
const String fg256Gray22 = '$fg256Open$gray22$fg256Close';

/// Foreground gray color 23 from 256-color table.
const String fg256Gray23 = '$fg256Open$gray23$fg256Close';
