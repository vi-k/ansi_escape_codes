import '../../csi.dart';
import '../../escape_codes.dart';
import 'assert.dart';
import 'indexes.dart';

//
// ANSI escape codes for background from 256-color table.
//

/// Opening tag for background with 256-color table.
///
/// Template: `${bg256Open}${colorIndex}${bg256Close}`
///
/// Predefined constants:
/// `$bg256Open$black$bg256Close` = `bg256Black`
///
/// Compatibility:
/// - +vscode
/// - +as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
///
/// See color indexes in the
/// [colors_8bit/indexes.dart](https://github.com/vi-k/ansi_escape_codes/blob/main/lib/src/values/sgr/colors_8bit/indexes.dart).
///
/// See also [bg256].
const String bg256Open = '${csi}48;5;';

/// Closing tag for background with 256-color table.
///
/// See [bg256Open] and [bg256Close].
const String bg256Close = sgr;

/// Set color to background from 256-color table.
///
/// See also [bg256Open] and [bg256Close].
String bg256(int colorIndex) {
  assert(colorIndex >= 0 && colorIndex <= 255, colorIndexAssert);

  return '$bg256Open$colorIndex$bg256Close';
}

//
// Predefined standard colors.
//

/// Background black from 256-color table.
const String bg256Black = '$bg256Open$black$bg256Close';

/// Background red from 256-color table.
const String bg256Red = '$bg256Open$red$bg256Close';

/// Background green from 256-color table.
const String bg256Green = '$bg256Open$green$bg256Close';

/// Background yellow from 256-color table.
const String bg256Yellow = '$bg256Open$yellow$bg256Close';

/// Background blue from 256-color table.
const String bg256Blue = '$bg256Open$blue$bg256Close';

/// Background magenta from 256-color table.
const String bg256Magenta = '$bg256Open$magenta$bg256Close';

/// Background cyan from 256-color table.
const String bg256Cyan = '$bg256Open$cyan$bg256Close';

/// Background white from 256-color table.
const String bg256White = '$bg256Open$white$bg256Close';

//
// Predefined high intensity colors.
//

/// Background high intensity black from 256-color table.
const String bg256HighBlack = '$bg256Open$highBlack$bg256Close';

/// Background high intensity red from 256-color table.
const String bg256HighRed = '$bg256Open$highRed$bg256Close';

/// Background high intensity green from 256-color table.
const String bg256HighGreen = '$bg256Open$highGreen$bg256Close';

/// Background high intensity yellow from 256-color table.
const String bg256HighYellow = '$bg256Open$highYellow$bg256Close';

/// Background high intensity blue from 256-color table.
const String bg256HighBlue = '$bg256Open$highBlue$bg256Close';

/// Background high intensity magenta from 256-color table.
const String bg256HighMagenta = '$bg256Open$highMagenta$bg256Close';

/// Background high intensity cyan from 256-color table.
const String bg256HighCyan = '$bg256Open$highCyan$bg256Close';

/// Background high intensity white from 256-color table.
const String bg256HighWhite = '$bg256Open$highWhite$bg256Close';

//
// Predefined RGB colors.
//
// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).
//

/// Background RGB 000 from 256-color table.
const String bg256Rgb000 = '$bg256Open$rgb000$bg256Close';

/// Background RGB 001 from 256-color table.
const String bg256Rgb001 = '$bg256Open$rgb001$bg256Close';

/// Background RGB 002 from 256-color table.
const String bg256Rgb002 = '$bg256Open$rgb002$bg256Close';

/// Background RGB 003 from 256-color table.
const String bg256Rgb003 = '$bg256Open$rgb003$bg256Close';

/// Background RGB 004 from 256-color table.
const String bg256Rgb004 = '$bg256Open$rgb004$bg256Close';

/// Background RGB 005 from 256-color table.
const String bg256Rgb005 = '$bg256Open$rgb005$bg256Close';

/// Background RGB 010 from 256-color table.
const String bg256Rgb010 = '$bg256Open$rgb010$bg256Close';

/// Background RGB 011 from 256-color table.
const String bg256Rgb011 = '$bg256Open$rgb011$bg256Close';

/// Background RGB 012 from 256-color table.
const String bg256Rgb012 = '$bg256Open$rgb012$bg256Close';

/// Background RGB 013 from 256-color table.
const String bg256Rgb013 = '$bg256Open$rgb013$bg256Close';

/// Background RGB 014 from 256-color table.
const String bg256Rgb014 = '$bg256Open$rgb014$bg256Close';

/// Background RGB 015 from 256-color table.
const String bg256Rgb015 = '$bg256Open$rgb015$bg256Close';

/// Background RGB 020 from 256-color table.
const String bg256Rgb020 = '$bg256Open$rgb020$bg256Close';

/// Background RGB 021 from 256-color table.
const String bg256Rgb021 = '$bg256Open$rgb021$bg256Close';

/// Background RGB 022 from 256-color table.
const String bg256Rgb022 = '$bg256Open$rgb022$bg256Close';

/// Background RGB 023 from 256-color table.
const String bg256Rgb023 = '$bg256Open$rgb023$bg256Close';

/// Background RGB 024 from 256-color table.
const String bg256Rgb024 = '$bg256Open$rgb024$bg256Close';

/// Background RGB 025 from 256-color table.
const String bg256Rgb025 = '$bg256Open$rgb025$bg256Close';

/// Background RGB 030 from 256-color table.
const String bg256Rgb030 = '$bg256Open$rgb030$bg256Close';

/// Background RGB 031 from 256-color table.
const String bg256Rgb031 = '$bg256Open$rgb031$bg256Close';

/// Background RGB 032 from 256-color table.
const String bg256Rgb032 = '$bg256Open$rgb032$bg256Close';

/// Background RGB 033 from 256-color table.
const String bg256Rgb033 = '$bg256Open$rgb033$bg256Close';

/// Background RGB 034 from 256-color table.
const String bg256Rgb034 = '$bg256Open$rgb034$bg256Close';

/// Background RGB 035 from 256-color table.
const String bg256Rgb035 = '$bg256Open$rgb035$bg256Close';

/// Background RGB 040 from 256-color table.
const String bg256Rgb040 = '$bg256Open$rgb040$bg256Close';

/// Background RGB 041 from 256-color table.
const String bg256Rgb041 = '$bg256Open$rgb041$bg256Close';

/// Background RGB 042 from 256-color table.
const String bg256Rgb042 = '$bg256Open$rgb042$bg256Close';

/// Background RGB 043 from 256-color table.
const String bg256Rgb043 = '$bg256Open$rgb043$bg256Close';

/// Background RGB 044 from 256-color table.
const String bg256Rgb044 = '$bg256Open$rgb044$bg256Close';

/// Background RGB 045 from 256-color table.
const String bg256Rgb045 = '$bg256Open$rgb045$bg256Close';

/// Background RGB 050 from 256-color table.
const String bg256Rgb050 = '$bg256Open$rgb050$bg256Close';

/// Background RGB 051 from 256-color table.
const String bg256Rgb051 = '$bg256Open$rgb051$bg256Close';

/// Background RGB 052 from 256-color table.
const String bg256Rgb052 = '$bg256Open$rgb052$bg256Close';

/// Background RGB 053 from 256-color table.
const String bg256Rgb053 = '$bg256Open$rgb053$bg256Close';

/// Background RGB 054 from 256-color table.
const String bg256Rgb054 = '$bg256Open$rgb054$bg256Close';

/// Background RGB 055 from 256-color table.
const String bg256Rgb055 = '$bg256Open$rgb055$bg256Close';

/// Background RGB 100 from 256-color table.
const String bg256Rgb100 = '$bg256Open$rgb100$bg256Close';

/// Background RGB 101 from 256-color table.
const String bg256Rgb101 = '$bg256Open$rgb101$bg256Close';

/// Background RGB 102 from 256-color table.
const String bg256Rgb102 = '$bg256Open$rgb102$bg256Close';

/// Background RGB 103 from 256-color table.
const String bg256Rgb103 = '$bg256Open$rgb103$bg256Close';

/// Background RGB 104 from 256-color table.
const String bg256Rgb104 = '$bg256Open$rgb104$bg256Close';

/// Background RGB 105 from 256-color table.
const String bg256Rgb105 = '$bg256Open$rgb105$bg256Close';

/// Background RGB 110 from 256-color table.
const String bg256Rgb110 = '$bg256Open$rgb110$bg256Close';

/// Background RGB 111 from 256-color table.
const String bg256Rgb111 = '$bg256Open$rgb111$bg256Close';

/// Background RGB 112 from 256-color table.
const String bg256Rgb112 = '$bg256Open$rgb112$bg256Close';

/// Background RGB 113 from 256-color table.
const String bg256Rgb113 = '$bg256Open$rgb113$bg256Close';

/// Background RGB 114 from 256-color table.
const String bg256Rgb114 = '$bg256Open$rgb114$bg256Close';

/// Background RGB 115 from 256-color table.
const String bg256Rgb115 = '$bg256Open$rgb115$bg256Close';

/// Background RGB 120 from 256-color table.
const String bg256Rgb120 = '$bg256Open$rgb120$bg256Close';

/// Background RGB 121 from 256-color table.
const String bg256Rgb121 = '$bg256Open$rgb121$bg256Close';

/// Background RGB 122 from 256-color table.
const String bg256Rgb122 = '$bg256Open$rgb122$bg256Close';

/// Background RGB 123 from 256-color table.
const String bg256Rgb123 = '$bg256Open$rgb123$bg256Close';

/// Background RGB 124 from 256-color table.
const String bg256Rgb124 = '$bg256Open$rgb124$bg256Close';

/// Background RGB 125 from 256-color table.
const String bg256Rgb125 = '$bg256Open$rgb125$bg256Close';

/// Background RGB 130 from 256-color table.
const String bg256Rgb130 = '$bg256Open$rgb130$bg256Close';

/// Background RGB 131 from 256-color table.
const String bg256Rgb131 = '$bg256Open$rgb131$bg256Close';

/// Background RGB 132 from 256-color table.
const String bg256Rgb132 = '$bg256Open$rgb132$bg256Close';

/// Background RGB 133 from 256-color table.
const String bg256Rgb133 = '$bg256Open$rgb133$bg256Close';

/// Background RGB 134 from 256-color table.
const String bg256Rgb134 = '$bg256Open$rgb134$bg256Close';

/// Background RGB 135 from 256-color table.
const String bg256Rgb135 = '$bg256Open$rgb135$bg256Close';

/// Background RGB 140 from 256-color table.
const String bg256Rgb140 = '$bg256Open$rgb140$bg256Close';

/// Background RGB 141 from 256-color table.
const String bg256Rgb141 = '$bg256Open$rgb141$bg256Close';

/// Background RGB 142 from 256-color table.
const String bg256Rgb142 = '$bg256Open$rgb142$bg256Close';

/// Background RGB 143 from 256-color table.
const String bg256Rgb143 = '$bg256Open$rgb143$bg256Close';

/// Background RGB 144 from 256-color table.
const String bg256Rgb144 = '$bg256Open$rgb144$bg256Close';

/// Background RGB 145 from 256-color table.
const String bg256Rgb145 = '$bg256Open$rgb145$bg256Close';

/// Background RGB 150 from 256-color table.
const String bg256Rgb150 = '$bg256Open$rgb150$bg256Close';

/// Background RGB 151 from 256-color table.
const String bg256Rgb151 = '$bg256Open$rgb151$bg256Close';

/// Background RGB 152 from 256-color table.
const String bg256Rgb152 = '$bg256Open$rgb152$bg256Close';

/// Background RGB 153 from 256-color table.
const String bg256Rgb153 = '$bg256Open$rgb153$bg256Close';

/// Background RGB 154 from 256-color table.
const String bg256Rgb154 = '$bg256Open$rgb154$bg256Close';

/// Background RGB 155 from 256-color table.
const String bg256Rgb155 = '$bg256Open$rgb155$bg256Close';

/// Background RGB 200 from 256-color table.
const String bg256Rgb200 = '$bg256Open$rgb200$bg256Close';

/// Background RGB 201 from 256-color table.
const String bg256Rgb201 = '$bg256Open$rgb201$bg256Close';

/// Background RGB 202 from 256-color table.
const String bg256Rgb202 = '$bg256Open$rgb202$bg256Close';

/// Background RGB 203 from 256-color table.
const String bg256Rgb203 = '$bg256Open$rgb203$bg256Close';

/// Background RGB 204 from 256-color table.
const String bg256Rgb204 = '$bg256Open$rgb204$bg256Close';

/// Background RGB 205 from 256-color table.
const String bg256Rgb205 = '$bg256Open$rgb205$bg256Close';

/// Background RGB 210 from 256-color table.
const String bg256Rgb210 = '$bg256Open$rgb210$bg256Close';

/// Background RGB 211 from 256-color table.
const String bg256Rgb211 = '$bg256Open$rgb211$bg256Close';

/// Background RGB 212 from 256-color table.
const String bg256Rgb212 = '$bg256Open$rgb212$bg256Close';

/// Background RGB 213 from 256-color table.
const String bg256Rgb213 = '$bg256Open$rgb213$bg256Close';

/// Background RGB 214 from 256-color table.
const String bg256Rgb214 = '$bg256Open$rgb214$bg256Close';

/// Background RGB 215 from 256-color table.
const String bg256Rgb215 = '$bg256Open$rgb215$bg256Close';

/// Background RGB 220 from 256-color table.
const String bg256Rgb220 = '$bg256Open$rgb220$bg256Close';

/// Background RGB 221 from 256-color table.
const String bg256Rgb221 = '$bg256Open$rgb221$bg256Close';

/// Background RGB 222 from 256-color table.
const String bg256Rgb222 = '$bg256Open$rgb222$bg256Close';

/// Background RGB 223 from 256-color table.
const String bg256Rgb223 = '$bg256Open$rgb223$bg256Close';

/// Background RGB 224 from 256-color table.
const String bg256Rgb224 = '$bg256Open$rgb224$bg256Close';

/// Background RGB 225 from 256-color table.
const String bg256Rgb225 = '$bg256Open$rgb225$bg256Close';

/// Background RGB 230 from 256-color table.
const String bg256Rgb230 = '$bg256Open$rgb230$bg256Close';

/// Background RGB 231 from 256-color table.
const String bg256Rgb231 = '$bg256Open$rgb231$bg256Close';

/// Background RGB 232 from 256-color table.
const String bg256Rgb232 = '$bg256Open$rgb232$bg256Close';

/// Background RGB 233 from 256-color table.
const String bg256Rgb233 = '$bg256Open$rgb233$bg256Close';

/// Background RGB 234 from 256-color table.
const String bg256Rgb234 = '$bg256Open$rgb234$bg256Close';

/// Background RGB 235 from 256-color table.
const String bg256Rgb235 = '$bg256Open$rgb235$bg256Close';

/// Background RGB 240 from 256-color table.
const String bg256Rgb240 = '$bg256Open$rgb240$bg256Close';

/// Background RGB 241 from 256-color table.
const String bg256Rgb241 = '$bg256Open$rgb241$bg256Close';

/// Background RGB 242 from 256-color table.
const String bg256Rgb242 = '$bg256Open$rgb242$bg256Close';

/// Background RGB 243 from 256-color table.
const String bg256Rgb243 = '$bg256Open$rgb243$bg256Close';

/// Background RGB 244 from 256-color table.
const String bg256Rgb244 = '$bg256Open$rgb244$bg256Close';

/// Background RGB 245 from 256-color table.
const String bg256Rgb245 = '$bg256Open$rgb245$bg256Close';

/// Background RGB 250 from 256-color table.
const String bg256Rgb250 = '$bg256Open$rgb250$bg256Close';

/// Background RGB 251 from 256-color table.
const String bg256Rgb251 = '$bg256Open$rgb251$bg256Close';

/// Background RGB 252 from 256-color table.
const String bg256Rgb252 = '$bg256Open$rgb252$bg256Close';

/// Background RGB 253 from 256-color table.
const String bg256Rgb253 = '$bg256Open$rgb253$bg256Close';

/// Background RGB 254 from 256-color table.
const String bg256Rgb254 = '$bg256Open$rgb254$bg256Close';

/// Background RGB 255 from 256-color table.
const String bg256Rgb255 = '$bg256Open$rgb255$bg256Close';

/// Background RGB 300 from 256-color table.
const String bg256Rgb300 = '$bg256Open$rgb300$bg256Close';

/// Background RGB 301 from 256-color table.
const String bg256Rgb301 = '$bg256Open$rgb301$bg256Close';

/// Background RGB 302 from 256-color table.
const String bg256Rgb302 = '$bg256Open$rgb302$bg256Close';

/// Background RGB 303 from 256-color table.
const String bg256Rgb303 = '$bg256Open$rgb303$bg256Close';

/// Background RGB 304 from 256-color table.
const String bg256Rgb304 = '$bg256Open$rgb304$bg256Close';

/// Background RGB 305 from 256-color table.
const String bg256Rgb305 = '$bg256Open$rgb305$bg256Close';

/// Background RGB 310 from 256-color table.
const String bg256Rgb310 = '$bg256Open$rgb310$bg256Close';

/// Background RGB 311 from 256-color table.
const String bg256Rgb311 = '$bg256Open$rgb311$bg256Close';

/// Background RGB 312 from 256-color table.
const String bg256Rgb312 = '$bg256Open$rgb312$bg256Close';

/// Background RGB 313 from 256-color table.
const String bg256Rgb313 = '$bg256Open$rgb313$bg256Close';

/// Background RGB 314 from 256-color table.
const String bg256Rgb314 = '$bg256Open$rgb314$bg256Close';

/// Background RGB 315 from 256-color table.
const String bg256Rgb315 = '$bg256Open$rgb315$bg256Close';

/// Background RGB 320 from 256-color table.
const String bg256Rgb320 = '$bg256Open$rgb320$bg256Close';

/// Background RGB 321 from 256-color table.
const String bg256Rgb321 = '$bg256Open$rgb321$bg256Close';

/// Background RGB 322 from 256-color table.
const String bg256Rgb322 = '$bg256Open$rgb322$bg256Close';

/// Background RGB 323 from 256-color table.
const String bg256Rgb323 = '$bg256Open$rgb323$bg256Close';

/// Background RGB 324 from 256-color table.
const String bg256Rgb324 = '$bg256Open$rgb324$bg256Close';

/// Background RGB 325 from 256-color table.
const String bg256Rgb325 = '$bg256Open$rgb325$bg256Close';

/// Background RGB 330 from 256-color table.
const String bg256Rgb330 = '$bg256Open$rgb330$bg256Close';

/// Background RGB 331 from 256-color table.
const String bg256Rgb331 = '$bg256Open$rgb331$bg256Close';

/// Background RGB 332 from 256-color table.
const String bg256Rgb332 = '$bg256Open$rgb332$bg256Close';

/// Background RGB 333 from 256-color table.
const String bg256Rgb333 = '$bg256Open$rgb333$bg256Close';

/// Background RGB 334 from 256-color table.
const String bg256Rgb334 = '$bg256Open$rgb334$bg256Close';

/// Background RGB 335 from 256-color table.
const String bg256Rgb335 = '$bg256Open$rgb335$bg256Close';

/// Background RGB 340 from 256-color table.
const String bg256Rgb340 = '$bg256Open$rgb340$bg256Close';

/// Background RGB 341 from 256-color table.
const String bg256Rgb341 = '$bg256Open$rgb341$bg256Close';

/// Background RGB 342 from 256-color table.
const String bg256Rgb342 = '$bg256Open$rgb342$bg256Close';

/// Background RGB 343 from 256-color table.
const String bg256Rgb343 = '$bg256Open$rgb343$bg256Close';

/// Background RGB 344 from 256-color table.
const String bg256Rgb344 = '$bg256Open$rgb344$bg256Close';

/// Background RGB 345 from 256-color table.
const String bg256Rgb345 = '$bg256Open$rgb345$bg256Close';

/// Background RGB 350 from 256-color table.
const String bg256Rgb350 = '$bg256Open$rgb350$bg256Close';

/// Background RGB 351 from 256-color table.
const String bg256Rgb351 = '$bg256Open$rgb351$bg256Close';

/// Background RGB 352 from 256-color table.
const String bg256Rgb352 = '$bg256Open$rgb352$bg256Close';

/// Background RGB 353 from 256-color table.
const String bg256Rgb353 = '$bg256Open$rgb353$bg256Close';

/// Background RGB 354 from 256-color table.
const String bg256Rgb354 = '$bg256Open$rgb354$bg256Close';

/// Background RGB 355 from 256-color table.
const String bg256Rgb355 = '$bg256Open$rgb355$bg256Close';

/// Background RGB 400 from 256-color table.
const String bg256Rgb400 = '$bg256Open$rgb400$bg256Close';

/// Background RGB 401 from 256-color table.
const String bg256Rgb401 = '$bg256Open$rgb401$bg256Close';

/// Background RGB 402 from 256-color table.
const String bg256Rgb402 = '$bg256Open$rgb402$bg256Close';

/// Background RGB 403 from 256-color table.
const String bg256Rgb403 = '$bg256Open$rgb403$bg256Close';

/// Background RGB 404 from 256-color table.
const String bg256Rgb404 = '$bg256Open$rgb404$bg256Close';

/// Background RGB 405 from 256-color table.
const String bg256Rgb405 = '$bg256Open$rgb405$bg256Close';

/// Background RGB 410 from 256-color table.
const String bg256Rgb410 = '$bg256Open$rgb410$bg256Close';

/// Background RGB 411 from 256-color table.
const String bg256Rgb411 = '$bg256Open$rgb411$bg256Close';

/// Background RGB 412 from 256-color table.
const String bg256Rgb412 = '$bg256Open$rgb412$bg256Close';

/// Background RGB 413 from 256-color table.
const String bg256Rgb413 = '$bg256Open$rgb413$bg256Close';

/// Background RGB 414 from 256-color table.
const String bg256Rgb414 = '$bg256Open$rgb414$bg256Close';

/// Background RGB 415 from 256-color table.
const String bg256Rgb415 = '$bg256Open$rgb415$bg256Close';

/// Background RGB 420 from 256-color table.
const String bg256Rgb420 = '$bg256Open$rgb420$bg256Close';

/// Background RGB 421 from 256-color table.
const String bg256Rgb421 = '$bg256Open$rgb421$bg256Close';

/// Background RGB 422 from 256-color table.
const String bg256Rgb422 = '$bg256Open$rgb422$bg256Close';

/// Background RGB 423 from 256-color table.
const String bg256Rgb423 = '$bg256Open$rgb423$bg256Close';

/// Background RGB 424 from 256-color table.
const String bg256Rgb424 = '$bg256Open$rgb424$bg256Close';

/// Background RGB 425 from 256-color table.
const String bg256Rgb425 = '$bg256Open$rgb425$bg256Close';

/// Background RGB 430 from 256-color table.
const String bg256Rgb430 = '$bg256Open$rgb430$bg256Close';

/// Background RGB 431 from 256-color table.
const String bg256Rgb431 = '$bg256Open$rgb431$bg256Close';

/// Background RGB 432 from 256-color table.
const String bg256Rgb432 = '$bg256Open$rgb432$bg256Close';

/// Background RGB 433 from 256-color table.
const String bg256Rgb433 = '$bg256Open$rgb433$bg256Close';

/// Background RGB 434 from 256-color table.
const String bg256Rgb434 = '$bg256Open$rgb434$bg256Close';

/// Background RGB 435 from 256-color table.
const String bg256Rgb435 = '$bg256Open$rgb435$bg256Close';

/// Background RGB 440 from 256-color table.
const String bg256Rgb440 = '$bg256Open$rgb440$bg256Close';

/// Background RGB 441 from 256-color table.
const String bg256Rgb441 = '$bg256Open$rgb441$bg256Close';

/// Background RGB 442 from 256-color table.
const String bg256Rgb442 = '$bg256Open$rgb442$bg256Close';

/// Background RGB 443 from 256-color table.
const String bg256Rgb443 = '$bg256Open$rgb443$bg256Close';

/// Background RGB 444 from 256-color table.
const String bg256Rgb444 = '$bg256Open$rgb444$bg256Close';

/// Background RGB 445 from 256-color table.
const String bg256Rgb445 = '$bg256Open$rgb445$bg256Close';

/// Background RGB 450 from 256-color table.
const String bg256Rgb450 = '$bg256Open$rgb450$bg256Close';

/// Background RGB 451 from 256-color table.
const String bg256Rgb451 = '$bg256Open$rgb451$bg256Close';

/// Background RGB 452 from 256-color table.
const String bg256Rgb452 = '$bg256Open$rgb452$bg256Close';

/// Background RGB 453 from 256-color table.
const String bg256Rgb453 = '$bg256Open$rgb453$bg256Close';

/// Background RGB 454 from 256-color table.
const String bg256Rgb454 = '$bg256Open$rgb454$bg256Close';

/// Background RGB 455 from 256-color table.
const String bg256Rgb455 = '$bg256Open$rgb455$bg256Close';

/// Background RGB 500 from 256-color table.
const String bg256Rgb500 = '$bg256Open$rgb500$bg256Close';

/// Background RGB 501 from 256-color table.
const String bg256Rgb501 = '$bg256Open$rgb501$bg256Close';

/// Background RGB 502 from 256-color table.
const String bg256Rgb502 = '$bg256Open$rgb502$bg256Close';

/// Background RGB 503 from 256-color table.
const String bg256Rgb503 = '$bg256Open$rgb503$bg256Close';

/// Background RGB 504 from 256-color table.
const String bg256Rgb504 = '$bg256Open$rgb504$bg256Close';

/// Background RGB 505 from 256-color table.
const String bg256Rgb505 = '$bg256Open$rgb505$bg256Close';

/// Background RGB 510 from 256-color table.
const String bg256Rgb510 = '$bg256Open$rgb510$bg256Close';

/// Background RGB 511 from 256-color table.
const String bg256Rgb511 = '$bg256Open$rgb511$bg256Close';

/// Background RGB 512 from 256-color table.
const String bg256Rgb512 = '$bg256Open$rgb512$bg256Close';

/// Background RGB 513 from 256-color table.
const String bg256Rgb513 = '$bg256Open$rgb513$bg256Close';

/// Background RGB 514 from 256-color table.
const String bg256Rgb514 = '$bg256Open$rgb514$bg256Close';

/// Background RGB 515 from 256-color table.
const String bg256Rgb515 = '$bg256Open$rgb515$bg256Close';

/// Background RGB 520 from 256-color table.
const String bg256Rgb520 = '$bg256Open$rgb520$bg256Close';

/// Background RGB 521 from 256-color table.
const String bg256Rgb521 = '$bg256Open$rgb521$bg256Close';

/// Background RGB 522 from 256-color table.
const String bg256Rgb522 = '$bg256Open$rgb522$bg256Close';

/// Background RGB 523 from 256-color table.
const String bg256Rgb523 = '$bg256Open$rgb523$bg256Close';

/// Background RGB 524 from 256-color table.
const String bg256Rgb524 = '$bg256Open$rgb524$bg256Close';

/// Background RGB 525 from 256-color table.
const String bg256Rgb525 = '$bg256Open$rgb525$bg256Close';

/// Background RGB 530 from 256-color table.
const String bg256Rgb530 = '$bg256Open$rgb530$bg256Close';

/// Background RGB 531 from 256-color table.
const String bg256Rgb531 = '$bg256Open$rgb531$bg256Close';

/// Background RGB 532 from 256-color table.
const String bg256Rgb532 = '$bg256Open$rgb532$bg256Close';

/// Background RGB 533 from 256-color table.
const String bg256Rgb533 = '$bg256Open$rgb533$bg256Close';

/// Background RGB 534 from 256-color table.
const String bg256Rgb534 = '$bg256Open$rgb534$bg256Close';

/// Background RGB 535 from 256-color table.
const String bg256Rgb535 = '$bg256Open$rgb535$bg256Close';

/// Background RGB 540 from 256-color table.
const String bg256Rgb540 = '$bg256Open$rgb540$bg256Close';

/// Background RGB 541 from 256-color table.
const String bg256Rgb541 = '$bg256Open$rgb541$bg256Close';

/// Background RGB 542 from 256-color table.
const String bg256Rgb542 = '$bg256Open$rgb542$bg256Close';

/// Background RGB 543 from 256-color table.
const String bg256Rgb543 = '$bg256Open$rgb543$bg256Close';

/// Background RGB 544 from 256-color table.
const String bg256Rgb544 = '$bg256Open$rgb544$bg256Close';

/// Background RGB 545 from 256-color table.
const String bg256Rgb545 = '$bg256Open$rgb545$bg256Close';

/// Background RGB 550 from 256-color table.
const String bg256Rgb550 = '$bg256Open$rgb550$bg256Close';

/// Background RGB 551 from 256-color table.
const String bg256Rgb551 = '$bg256Open$rgb551$bg256Close';

/// Background RGB 552 from 256-color table.
const String bg256Rgb552 = '$bg256Open$rgb552$bg256Close';

/// Background RGB 553 from 256-color table.
const String bg256Rgb553 = '$bg256Open$rgb553$bg256Close';

/// Background RGB 554 from 256-color table.
const String bg256Rgb554 = '$bg256Open$rgb554$bg256Close';

/// Background RGB 555 from 256-color table.
const String bg256Rgb555 = '$bg256Open$rgb555$bg256Close';

//
// Predefined grayscale.
//
// Gray colors from dark to light in 24 steps.
//

/// Background gray color 0 from 256-color table.
const String bg256Gray0 = '$bg256Open$gray0$bg256Close';

/// Background gray color 1 from 256-color table.
const String bg256Gray1 = '$bg256Open$gray1$bg256Close';

/// Background gray color 2 from 256-color table.
const String bg256Gray2 = '$bg256Open$gray2$bg256Close';

/// Background gray color 3 from 256-color table.
const String bg256Gray3 = '$bg256Open$gray3$bg256Close';

/// Background gray color 4 from 256-color table.
const String bg256Gray4 = '$bg256Open$gray4$bg256Close';

/// Background gray color 5 from 256-color table.
const String bg256Gray5 = '$bg256Open$gray5$bg256Close';

/// Background gray color 6 from 256-color table.
const String bg256Gray6 = '$bg256Open$gray6$bg256Close';

/// Background gray color 7 from 256-color table.
const String bg256Gray7 = '$bg256Open$gray7$bg256Close';

/// Background gray color 8 from 256-color table.
const String bg256Gray8 = '$bg256Open$gray8$bg256Close';

/// Background gray color 9 from 256-color table.
const String bg256Gray9 = '$bg256Open$gray9$bg256Close';

/// Background gray color 10 from 256-color table.
const String bg256Gray10 = '$bg256Open$gray10$bg256Close';

/// Background gray color 11 from 256-color table.
const String bg256Gray11 = '$bg256Open$gray11$bg256Close';

/// Background gray color 12 from 256-color table.
const String bg256Gray12 = '$bg256Open$gray12$bg256Close';

/// Background gray color 13 from 256-color table.
const String bg256Gray13 = '$bg256Open$gray13$bg256Close';

/// Background gray color 14 from 256-color table.
const String bg256Gray14 = '$bg256Open$gray14$bg256Close';

/// Background gray color 15 from 256-color table.
const String bg256Gray15 = '$bg256Open$gray15$bg256Close';

/// Background gray color 16 from 256-color table.
const String bg256Gray16 = '$bg256Open$gray16$bg256Close';

/// Background gray color 17 from 256-color table.
const String bg256Gray17 = '$bg256Open$gray17$bg256Close';

/// Background gray color 18 from 256-color table.
const String bg256Gray18 = '$bg256Open$gray18$bg256Close';

/// Background gray color 19 from 256-color table.
const String bg256Gray19 = '$bg256Open$gray19$bg256Close';

/// Background gray color 20 from 256-color table.
const String bg256Gray20 = '$bg256Open$gray20$bg256Close';

/// Background gray color 21 from 256-color table.
const String bg256Gray21 = '$bg256Open$gray21$bg256Close';

/// Background gray color 22 from 256-color table.
const String bg256Gray22 = '$bg256Open$gray22$bg256Close';

/// Background gray color 23 from 256-color table.
const String bg256Gray23 = '$bg256Open$gray23$bg256Close';
