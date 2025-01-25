import 'csi.dart' as ansi;
import 'sgr/sgr.dart' as ansi;
import 'sgr/sgr_256_colors/background_colors.dart' as ansi;
import 'sgr/sgr_256_colors/foreground_colors.dart' as ansi;
import 'sgr/sgr_256_colors/underline_colors.dart' as ansi;
import 'sgr/sgr_standart_colors.dart' as ansi;

/// Predefined CSI values.
enum CsiPredefinedValues {
  /// Moves the cursor up `1` line.
  cursorUp(ansi.cursorUp),

  /// Moves the cursor down `1` line.
  cursorDown(ansi.cursorDown),

  /// Moves the cursor forward `1` cell.
  cursorForward(ansi.cursorForward),

  /// Moves the cursor back `1` cell.
  cursorBack(ansi.cursorBack),

  /// Moves cursor to beginning of the line `1` line down.
  cursorNextLine(ansi.cursorNextLine),

  /// Moves cursor to beginning of the line `1` line up.
  cursorPrevLine(ansi.cursorPrevLine),

  /// Moves the cursor to column `1`.
  cursorHPos(ansi.cursorHPos),

  /// Moves the cursor to top left corner.
  cursorPosToTopLeft(ansi.cursorPosToTopLeft),

  /// Moves the cursor to top left corner.
  cursorHVPosToTopLeft(ansi.cursorHVPosToTopLeft),

  /// Clears from cursor to end of screen.
  clearScreenToEnd(ansi.clearScreenToEnd),

  /// Clears from cursor to beginning of the screen.
  clearScreenToBegin(ansi.clearScreenToBegin),

  /// Clears entire screen and moves cursor to upper left.
  clearScreen(ansi.clearScreen),

  /// Clears entire screen and delete all lines saved in the scrollback buffer.
  clearScreenWithBuf(ansi.clearScreenWithBuf),

  /// Clears from cursor to the end of the line.
  eraseLineToEnd(ansi.eraseLineToEnd),

  /// Clears from cursor to beginning of the line.
  eraseLineToBegin(ansi.eraseLineToBegin),

  /// Clears entire line.
  eraseLine(ansi.eraseLine),

  /// Scroll whole page up by `1` line.
  scrollUp(ansi.scrollUp),

  /// Scroll whole page down by `1` line.
  scrollDown(ansi.scrollDown),

  /// Shows the cursor.
  showCursor(ansi.showCursor),

  /// Hides the cursor.
  hideCursor(ansi.hideCursor),

  /// Reset.
  reset(ansi.reset),

  /// Bold.
  bold(ansi.bold),

  /// Faint.
  faint(ansi.faint),

  /// Italic.
  italic(ansi.italic),

  /// Underline.
  underline(ansi.underline),

  /// Slow blink.
  blink(ansi.blink),

  /// Rapid blink.
  rapidBlink(ansi.rapidBlink),

  /// Invert video.
  invert(ansi.invert),

  /// Hide.
  hide(ansi.hide),

  /// Strike.
  strike(ansi.strike),

  /// Doubly underlined.
  doublyUnderlined(ansi.doublyUnderlined),

  /// Normal intensity.
  notBoldNotFaint(ansi.notBoldNotFaint),

  /// Not italic.
  notItalic(ansi.notItalic),

  /// Not underlined.
  notUnderlined(ansi.notUnderlined),

  /// Not blinking.
  notBlinking(ansi.notBlinking),

  /// Not inverted.
  notInverted(ansi.notInverted),

  /// Not hidden.
  notHidden(ansi.notHidden),

  /// Not striked.
  notStriked(ansi.notStriked),

  /// Framed.
  framed(ansi.framed),

  /// Encircled.
  encircled(ansi.encircled),

  /// Overlined.
  overlined(ansi.overlined),

  /// Neither framed nor encircled.
  notFramedNotEncircled(ansi.notFramedNotEncircled),

  /// Not overlined.
  notOverlined(ansi.notOverlined),

  /// Superscript.
  superscript(ansi.superscript),

  /// Subscript.
  subscript(ansi.subscript),

  /// Neither superscript nor subscript.
  notSuperscriptedNotSubscripted(ansi.notSuperscriptedNotSubscripted),

  /// Foreground black.
  fgBlack(ansi.fgBlack),

  /// Foreground red.
  fgRed(ansi.fgRed),

  /// Foreground green.
  fgGreen(ansi.fgGreen),

  /// Foreground yellow.
  fgYellow(ansi.fgYellow),

  /// Foreground blue.
  fgBlue(ansi.fgBlue),

  /// Foreground magenta.
  fgMagenta(ansi.fgMagenta),

  /// Foreground cyan.
  fgCyan(ansi.fgCyan),

  /// Foreground white.
  fgWhite(ansi.fgWhite),

  /// Background black.
  bgBlack(ansi.bgBlack),

  /// Background red.
  bgRed(ansi.bgRed),

  /// Background green.
  bgGreen(ansi.bgGreen),

  /// Background yellow.
  bgYellow(ansi.bgYellow),

  /// Background blue.
  bgBlue(ansi.bgBlue),

  /// Background magenta.
  bgMagenta(ansi.bgMagenta),

  /// Background cyan.
  bgCyan(ansi.bgCyan),

  /// Background white.
  bgWhite(ansi.bgWhite),

  /// Foreground bright black.
  fgBrightBlack(ansi.fgBrightBlack),

  /// Foreground bright red.
  fgBrightRed(ansi.fgBrightRed),

  /// Foreground bright green.
  fgBrightGreen(ansi.fgBrightGreen),

  /// Foreground bright yellow.
  fgBrightYellow(ansi.fgBrightYellow),

  /// Foreground bright blue.
  fgBrightBlue(ansi.fgBrightBlue),

  /// Foreground bright magenta.
  fgBrightMagenta(ansi.fgBrightMagenta),

  /// Foreground bright cyan.
  fgBrightCyan(ansi.fgBrightCyan),

  /// Foreground bright white.
  fgBrightWhite(ansi.fgBrightWhite),

  /// Background bright black.
  bgBrightBlack(ansi.bgBrightBlack),

  /// Background bright red.
  bgBrightRed(ansi.bgBrightRed),

  /// Background bright green.
  bgBrightGreen(ansi.bgBrightGreen),

  /// Background bright yellow.
  bgBrightYellow(ansi.bgBrightYellow),

  /// Background bright blue.
  bgBrightBlue(ansi.bgBrightBlue),

  /// Background bright magenta.
  bgBrightMagenta(ansi.bgBrightMagenta),

  /// Background bright cyan.
  bgBrightCyan(ansi.bgBrightCyan),

  /// Background bright white.
  bgBrightWhite(ansi.bgBrightWhite),

  /// Default foreground color.
  fgDefault(ansi.fgDefault),

  /// Default background color.
  bgDefault(ansi.bgDefault),

  /// Default underline color.
  underlineDefault(ansi.underlineDefault),

  /// Background black from 256-color table.
  bg256Black(ansi.bg256Black),

  /// Background red from 256-color table.
  bg256Red(ansi.bg256Red),

  /// Background green from 256-color table.
  bg256Green(ansi.bg256Green),

  /// Background yellow from 256-color table.
  bg256Yellow(ansi.bg256Yellow),

  /// Background blue from 256-color table.
  bg256Blue(ansi.bg256Blue),

  /// Background magenta from 256-color table.
  bg256Magenta(ansi.bg256Magenta),

  /// Background cyan from 256-color table.
  bg256Cyan(ansi.bg256Cyan),

  /// Background white from 256-color table.
  bg256White(ansi.bg256White),

  /// Background high intensity black from 256-color table.
  bg256HighBlack(ansi.bg256HighBlack),

  /// Background high intensity red from 256-color table.
  bg256HighRed(ansi.bg256HighRed),

  /// Background high intensity green from 256-color table.
  bg256HighGreen(ansi.bg256HighGreen),

  /// Background high intensity yellow from 256-color table.
  bg256HighYellow(ansi.bg256HighYellow),

  /// Background high intensity blue from 256-color table.
  bg256HighBlue(ansi.bg256HighBlue),

  /// Background high intensity magenta from 256-color table.
  bg256HighMagenta(ansi.bg256HighMagenta),

  /// Background high intensity cyan from 256-color table.
  bg256HighCyan(ansi.bg256HighCyan),

  /// Background high intensity white from 256-color table.
  bg256HighWhite(ansi.bg256HighWhite),

  /// Background RGB 000 from 256-color table.
  bg256Rgb000(ansi.bg256Rgb000),

  /// Background RGB 001 from 256-color table.
  bg256Rgb001(ansi.bg256Rgb001),

  /// Background RGB 002 from 256-color table.
  bg256Rgb002(ansi.bg256Rgb002),

  /// Background RGB 003 from 256-color table.
  bg256Rgb003(ansi.bg256Rgb003),

  /// Background RGB 004 from 256-color table.
  bg256Rgb004(ansi.bg256Rgb004),

  /// Background RGB 005 from 256-color table.
  bg256Rgb005(ansi.bg256Rgb005),

  /// Background RGB 010 from 256-color table.
  bg256Rgb010(ansi.bg256Rgb010),

  /// Background RGB 011 from 256-color table.
  bg256Rgb011(ansi.bg256Rgb011),

  /// Background RGB 012 from 256-color table.
  bg256Rgb012(ansi.bg256Rgb012),

  /// Background RGB 013 from 256-color table.
  bg256Rgb013(ansi.bg256Rgb013),

  /// Background RGB 014 from 256-color table.
  bg256Rgb014(ansi.bg256Rgb014),

  /// Background RGB 015 from 256-color table.
  bg256Rgb015(ansi.bg256Rgb015),

  /// Background RGB 020 from 256-color table.
  bg256Rgb020(ansi.bg256Rgb020),

  /// Background RGB 021 from 256-color table.
  bg256Rgb021(ansi.bg256Rgb021),

  /// Background RGB 022 from 256-color table.
  bg256Rgb022(ansi.bg256Rgb022),

  /// Background RGB 023 from 256-color table.
  bg256Rgb023(ansi.bg256Rgb023),

  /// Background RGB 024 from 256-color table.
  bg256Rgb024(ansi.bg256Rgb024),

  /// Background RGB 025 from 256-color table.
  bg256Rgb025(ansi.bg256Rgb025),

  /// Background RGB 030 from 256-color table.
  bg256Rgb030(ansi.bg256Rgb030),

  /// Background RGB 031 from 256-color table.
  bg256Rgb031(ansi.bg256Rgb031),

  /// Background RGB 032 from 256-color table.
  bg256Rgb032(ansi.bg256Rgb032),

  /// Background RGB 033 from 256-color table.
  bg256Rgb033(ansi.bg256Rgb033),

  /// Background RGB 034 from 256-color table.
  bg256Rgb034(ansi.bg256Rgb034),

  /// Background RGB 035 from 256-color table.
  bg256Rgb035(ansi.bg256Rgb035),

  /// Background RGB 040 from 256-color table.
  bg256Rgb040(ansi.bg256Rgb040),

  /// Background RGB 041 from 256-color table.
  bg256Rgb041(ansi.bg256Rgb041),

  /// Background RGB 042 from 256-color table.
  bg256Rgb042(ansi.bg256Rgb042),

  /// Background RGB 043 from 256-color table.
  bg256Rgb043(ansi.bg256Rgb043),

  /// Background RGB 044 from 256-color table.
  bg256Rgb044(ansi.bg256Rgb044),

  /// Background RGB 045 from 256-color table.
  bg256Rgb045(ansi.bg256Rgb045),

  /// Background RGB 050 from 256-color table.
  bg256Rgb050(ansi.bg256Rgb050),

  /// Background RGB 051 from 256-color table.
  bg256Rgb051(ansi.bg256Rgb051),

  /// Background RGB 052 from 256-color table.
  bg256Rgb052(ansi.bg256Rgb052),

  /// Background RGB 053 from 256-color table.
  bg256Rgb053(ansi.bg256Rgb053),

  /// Background RGB 054 from 256-color table.
  bg256Rgb054(ansi.bg256Rgb054),

  /// Background RGB 055 from 256-color table.
  bg256Rgb055(ansi.bg256Rgb055),

  /// Background RGB 100 from 256-color table.
  bg256Rgb100(ansi.bg256Rgb100),

  /// Background RGB 101 from 256-color table.
  bg256Rgb101(ansi.bg256Rgb101),

  /// Background RGB 102 from 256-color table.
  bg256Rgb102(ansi.bg256Rgb102),

  /// Background RGB 103 from 256-color table.
  bg256Rgb103(ansi.bg256Rgb103),

  /// Background RGB 104 from 256-color table.
  bg256Rgb104(ansi.bg256Rgb104),

  /// Background RGB 105 from 256-color table.
  bg256Rgb105(ansi.bg256Rgb105),

  /// Background RGB 110 from 256-color table.
  bg256Rgb110(ansi.bg256Rgb110),

  /// Background RGB 111 from 256-color table.
  bg256Rgb111(ansi.bg256Rgb111),

  /// Background RGB 112 from 256-color table.
  bg256Rgb112(ansi.bg256Rgb112),

  /// Background RGB 113 from 256-color table.
  bg256Rgb113(ansi.bg256Rgb113),

  /// Background RGB 114 from 256-color table.
  bg256Rgb114(ansi.bg256Rgb114),

  /// Background RGB 115 from 256-color table.
  bg256Rgb115(ansi.bg256Rgb115),

  /// Background RGB 120 from 256-color table.
  bg256Rgb120(ansi.bg256Rgb120),

  /// Background RGB 121 from 256-color table.
  bg256Rgb121(ansi.bg256Rgb121),

  /// Background RGB 122 from 256-color table.
  bg256Rgb122(ansi.bg256Rgb122),

  /// Background RGB 123 from 256-color table.
  bg256Rgb123(ansi.bg256Rgb123),

  /// Background RGB 124 from 256-color table.
  bg256Rgb124(ansi.bg256Rgb124),

  /// Background RGB 125 from 256-color table.
  bg256Rgb125(ansi.bg256Rgb125),

  /// Background RGB 130 from 256-color table.
  bg256Rgb130(ansi.bg256Rgb130),

  /// Background RGB 131 from 256-color table.
  bg256Rgb131(ansi.bg256Rgb131),

  /// Background RGB 132 from 256-color table.
  bg256Rgb132(ansi.bg256Rgb132),

  /// Background RGB 133 from 256-color table.
  bg256Rgb133(ansi.bg256Rgb133),

  /// Background RGB 134 from 256-color table.
  bg256Rgb134(ansi.bg256Rgb134),

  /// Background RGB 135 from 256-color table.
  bg256Rgb135(ansi.bg256Rgb135),

  /// Background RGB 140 from 256-color table.
  bg256Rgb140(ansi.bg256Rgb140),

  /// Background RGB 141 from 256-color table.
  bg256Rgb141(ansi.bg256Rgb141),

  /// Background RGB 142 from 256-color table.
  bg256Rgb142(ansi.bg256Rgb142),

  /// Background RGB 143 from 256-color table.
  bg256Rgb143(ansi.bg256Rgb143),

  /// Background RGB 144 from 256-color table.
  bg256Rgb144(ansi.bg256Rgb144),

  /// Background RGB 145 from 256-color table.
  bg256Rgb145(ansi.bg256Rgb145),

  /// Background RGB 150 from 256-color table.
  bg256Rgb150(ansi.bg256Rgb150),

  /// Background RGB 151 from 256-color table.
  bg256Rgb151(ansi.bg256Rgb151),

  /// Background RGB 152 from 256-color table.
  bg256Rgb152(ansi.bg256Rgb152),

  /// Background RGB 153 from 256-color table.
  bg256Rgb153(ansi.bg256Rgb153),

  /// Background RGB 154 from 256-color table.
  bg256Rgb154(ansi.bg256Rgb154),

  /// Background RGB 155 from 256-color table.
  bg256Rgb155(ansi.bg256Rgb155),

  /// Background RGB 200 from 256-color table.
  bg256Rgb200(ansi.bg256Rgb200),

  /// Background RGB 201 from 256-color table.
  bg256Rgb201(ansi.bg256Rgb201),

  /// Background RGB 202 from 256-color table.
  bg256Rgb202(ansi.bg256Rgb202),

  /// Background RGB 203 from 256-color table.
  bg256Rgb203(ansi.bg256Rgb203),

  /// Background RGB 204 from 256-color table.
  bg256Rgb204(ansi.bg256Rgb204),

  /// Background RGB 205 from 256-color table.
  bg256Rgb205(ansi.bg256Rgb205),

  /// Background RGB 210 from 256-color table.
  bg256Rgb210(ansi.bg256Rgb210),

  /// Background RGB 211 from 256-color table.
  bg256Rgb211(ansi.bg256Rgb211),

  /// Background RGB 212 from 256-color table.
  bg256Rgb212(ansi.bg256Rgb212),

  /// Background RGB 213 from 256-color table.
  bg256Rgb213(ansi.bg256Rgb213),

  /// Background RGB 214 from 256-color table.
  bg256Rgb214(ansi.bg256Rgb214),

  /// Background RGB 215 from 256-color table.
  bg256Rgb215(ansi.bg256Rgb215),

  /// Background RGB 220 from 256-color table.
  bg256Rgb220(ansi.bg256Rgb220),

  /// Background RGB 221 from 256-color table.
  bg256Rgb221(ansi.bg256Rgb221),

  /// Background RGB 222 from 256-color table.
  bg256Rgb222(ansi.bg256Rgb222),

  /// Background RGB 223 from 256-color table.
  bg256Rgb223(ansi.bg256Rgb223),

  /// Background RGB 224 from 256-color table.
  bg256Rgb224(ansi.bg256Rgb224),

  /// Background RGB 225 from 256-color table.
  bg256Rgb225(ansi.bg256Rgb225),

  /// Background RGB 230 from 256-color table.
  bg256Rgb230(ansi.bg256Rgb230),

  /// Background RGB 231 from 256-color table.
  bg256Rgb231(ansi.bg256Rgb231),

  /// Background RGB 232 from 256-color table.
  bg256Rgb232(ansi.bg256Rgb232),

  /// Background RGB 233 from 256-color table.
  bg256Rgb233(ansi.bg256Rgb233),

  /// Background RGB 234 from 256-color table.
  bg256Rgb234(ansi.bg256Rgb234),

  /// Background RGB 235 from 256-color table.
  bg256Rgb235(ansi.bg256Rgb235),

  /// Background RGB 240 from 256-color table.
  bg256Rgb240(ansi.bg256Rgb240),

  /// Background RGB 241 from 256-color table.
  bg256Rgb241(ansi.bg256Rgb241),

  /// Background RGB 242 from 256-color table.
  bg256Rgb242(ansi.bg256Rgb242),

  /// Background RGB 243 from 256-color table.
  bg256Rgb243(ansi.bg256Rgb243),

  /// Background RGB 244 from 256-color table.
  bg256Rgb244(ansi.bg256Rgb244),

  /// Background RGB 245 from 256-color table.
  bg256Rgb245(ansi.bg256Rgb245),

  /// Background RGB 250 from 256-color table.
  bg256Rgb250(ansi.bg256Rgb250),

  /// Background RGB 251 from 256-color table.
  bg256Rgb251(ansi.bg256Rgb251),

  /// Background RGB 252 from 256-color table.
  bg256Rgb252(ansi.bg256Rgb252),

  /// Background RGB 253 from 256-color table.
  bg256Rgb253(ansi.bg256Rgb253),

  /// Background RGB 254 from 256-color table.
  bg256Rgb254(ansi.bg256Rgb254),

  /// Background RGB 255 from 256-color table.
  bg256Rgb255(ansi.bg256Rgb255),

  /// Background RGB 300 from 256-color table.
  bg256Rgb300(ansi.bg256Rgb300),

  /// Background RGB 301 from 256-color table.
  bg256Rgb301(ansi.bg256Rgb301),

  /// Background RGB 302 from 256-color table.
  bg256Rgb302(ansi.bg256Rgb302),

  /// Background RGB 303 from 256-color table.
  bg256Rgb303(ansi.bg256Rgb303),

  /// Background RGB 304 from 256-color table.
  bg256Rgb304(ansi.bg256Rgb304),

  /// Background RGB 305 from 256-color table.
  bg256Rgb305(ansi.bg256Rgb305),

  /// Background RGB 310 from 256-color table.
  bg256Rgb310(ansi.bg256Rgb310),

  /// Background RGB 311 from 256-color table.
  bg256Rgb311(ansi.bg256Rgb311),

  /// Background RGB 312 from 256-color table.
  bg256Rgb312(ansi.bg256Rgb312),

  /// Background RGB 313 from 256-color table.
  bg256Rgb313(ansi.bg256Rgb313),

  /// Background RGB 314 from 256-color table.
  bg256Rgb314(ansi.bg256Rgb314),

  /// Background RGB 315 from 256-color table.
  bg256Rgb315(ansi.bg256Rgb315),

  /// Background RGB 320 from 256-color table.
  bg256Rgb320(ansi.bg256Rgb320),

  /// Background RGB 321 from 256-color table.
  bg256Rgb321(ansi.bg256Rgb321),

  /// Background RGB 322 from 256-color table.
  bg256Rgb322(ansi.bg256Rgb322),

  /// Background RGB 323 from 256-color table.
  bg256Rgb323(ansi.bg256Rgb323),

  /// Background RGB 324 from 256-color table.
  bg256Rgb324(ansi.bg256Rgb324),

  /// Background RGB 325 from 256-color table.
  bg256Rgb325(ansi.bg256Rgb325),

  /// Background RGB 330 from 256-color table.
  bg256Rgb330(ansi.bg256Rgb330),

  /// Background RGB 331 from 256-color table.
  bg256Rgb331(ansi.bg256Rgb331),

  /// Background RGB 332 from 256-color table.
  bg256Rgb332(ansi.bg256Rgb332),

  /// Background RGB 333 from 256-color table.
  bg256Rgb333(ansi.bg256Rgb333),

  /// Background RGB 334 from 256-color table.
  bg256Rgb334(ansi.bg256Rgb334),

  /// Background RGB 335 from 256-color table.
  bg256Rgb335(ansi.bg256Rgb335),

  /// Background RGB 340 from 256-color table.
  bg256Rgb340(ansi.bg256Rgb340),

  /// Background RGB 341 from 256-color table.
  bg256Rgb341(ansi.bg256Rgb341),

  /// Background RGB 342 from 256-color table.
  bg256Rgb342(ansi.bg256Rgb342),

  /// Background RGB 343 from 256-color table.
  bg256Rgb343(ansi.bg256Rgb343),

  /// Background RGB 344 from 256-color table.
  bg256Rgb344(ansi.bg256Rgb344),

  /// Background RGB 345 from 256-color table.
  bg256Rgb345(ansi.bg256Rgb345),

  /// Background RGB 350 from 256-color table.
  bg256Rgb350(ansi.bg256Rgb350),

  /// Background RGB 351 from 256-color table.
  bg256Rgb351(ansi.bg256Rgb351),

  /// Background RGB 352 from 256-color table.
  bg256Rgb352(ansi.bg256Rgb352),

  /// Background RGB 353 from 256-color table.
  bg256Rgb353(ansi.bg256Rgb353),

  /// Background RGB 354 from 256-color table.
  bg256Rgb354(ansi.bg256Rgb354),

  /// Background RGB 355 from 256-color table.
  bg256Rgb355(ansi.bg256Rgb355),

  /// Background RGB 400 from 256-color table.
  bg256Rgb400(ansi.bg256Rgb400),

  /// Background RGB 401 from 256-color table.
  bg256Rgb401(ansi.bg256Rgb401),

  /// Background RGB 402 from 256-color table.
  bg256Rgb402(ansi.bg256Rgb402),

  /// Background RGB 403 from 256-color table.
  bg256Rgb403(ansi.bg256Rgb403),

  /// Background RGB 404 from 256-color table.
  bg256Rgb404(ansi.bg256Rgb404),

  /// Background RGB 405 from 256-color table.
  bg256Rgb405(ansi.bg256Rgb405),

  /// Background RGB 410 from 256-color table.
  bg256Rgb410(ansi.bg256Rgb410),

  /// Background RGB 411 from 256-color table.
  bg256Rgb411(ansi.bg256Rgb411),

  /// Background RGB 412 from 256-color table.
  bg256Rgb412(ansi.bg256Rgb412),

  /// Background RGB 413 from 256-color table.
  bg256Rgb413(ansi.bg256Rgb413),

  /// Background RGB 414 from 256-color table.
  bg256Rgb414(ansi.bg256Rgb414),

  /// Background RGB 415 from 256-color table.
  bg256Rgb415(ansi.bg256Rgb415),

  /// Background RGB 420 from 256-color table.
  bg256Rgb420(ansi.bg256Rgb420),

  /// Background RGB 421 from 256-color table.
  bg256Rgb421(ansi.bg256Rgb421),

  /// Background RGB 422 from 256-color table.
  bg256Rgb422(ansi.bg256Rgb422),

  /// Background RGB 423 from 256-color table.
  bg256Rgb423(ansi.bg256Rgb423),

  /// Background RGB 424 from 256-color table.
  bg256Rgb424(ansi.bg256Rgb424),

  /// Background RGB 425 from 256-color table.
  bg256Rgb425(ansi.bg256Rgb425),

  /// Background RGB 430 from 256-color table.
  bg256Rgb430(ansi.bg256Rgb430),

  /// Background RGB 431 from 256-color table.
  bg256Rgb431(ansi.bg256Rgb431),

  /// Background RGB 432 from 256-color table.
  bg256Rgb432(ansi.bg256Rgb432),

  /// Background RGB 433 from 256-color table.
  bg256Rgb433(ansi.bg256Rgb433),

  /// Background RGB 434 from 256-color table.
  bg256Rgb434(ansi.bg256Rgb434),

  /// Background RGB 435 from 256-color table.
  bg256Rgb435(ansi.bg256Rgb435),

  /// Background RGB 440 from 256-color table.
  bg256Rgb440(ansi.bg256Rgb440),

  /// Background RGB 441 from 256-color table.
  bg256Rgb441(ansi.bg256Rgb441),

  /// Background RGB 442 from 256-color table.
  bg256Rgb442(ansi.bg256Rgb442),

  /// Background RGB 443 from 256-color table.
  bg256Rgb443(ansi.bg256Rgb443),

  /// Background RGB 444 from 256-color table.
  bg256Rgb444(ansi.bg256Rgb444),

  /// Background RGB 445 from 256-color table.
  bg256Rgb445(ansi.bg256Rgb445),

  /// Background RGB 450 from 256-color table.
  bg256Rgb450(ansi.bg256Rgb450),

  /// Background RGB 451 from 256-color table.
  bg256Rgb451(ansi.bg256Rgb451),

  /// Background RGB 452 from 256-color table.
  bg256Rgb452(ansi.bg256Rgb452),

  /// Background RGB 453 from 256-color table.
  bg256Rgb453(ansi.bg256Rgb453),

  /// Background RGB 454 from 256-color table.
  bg256Rgb454(ansi.bg256Rgb454),

  /// Background RGB 455 from 256-color table.
  bg256Rgb455(ansi.bg256Rgb455),

  /// Background RGB 500 from 256-color table.
  bg256Rgb500(ansi.bg256Rgb500),

  /// Background RGB 501 from 256-color table.
  bg256Rgb501(ansi.bg256Rgb501),

  /// Background RGB 502 from 256-color table.
  bg256Rgb502(ansi.bg256Rgb502),

  /// Background RGB 503 from 256-color table.
  bg256Rgb503(ansi.bg256Rgb503),

  /// Background RGB 504 from 256-color table.
  bg256Rgb504(ansi.bg256Rgb504),

  /// Background RGB 505 from 256-color table.
  bg256Rgb505(ansi.bg256Rgb505),

  /// Background RGB 510 from 256-color table.
  bg256Rgb510(ansi.bg256Rgb510),

  /// Background RGB 511 from 256-color table.
  bg256Rgb511(ansi.bg256Rgb511),

  /// Background RGB 512 from 256-color table.
  bg256Rgb512(ansi.bg256Rgb512),

  /// Background RGB 513 from 256-color table.
  bg256Rgb513(ansi.bg256Rgb513),

  /// Background RGB 514 from 256-color table.
  bg256Rgb514(ansi.bg256Rgb514),

  /// Background RGB 515 from 256-color table.
  bg256Rgb515(ansi.bg256Rgb515),

  /// Background RGB 520 from 256-color table.
  bg256Rgb520(ansi.bg256Rgb520),

  /// Background RGB 521 from 256-color table.
  bg256Rgb521(ansi.bg256Rgb521),

  /// Background RGB 522 from 256-color table.
  bg256Rgb522(ansi.bg256Rgb522),

  /// Background RGB 523 from 256-color table.
  bg256Rgb523(ansi.bg256Rgb523),

  /// Background RGB 524 from 256-color table.
  bg256Rgb524(ansi.bg256Rgb524),

  /// Background RGB 525 from 256-color table.
  bg256Rgb525(ansi.bg256Rgb525),

  /// Background RGB 530 from 256-color table.
  bg256Rgb530(ansi.bg256Rgb530),

  /// Background RGB 531 from 256-color table.
  bg256Rgb531(ansi.bg256Rgb531),

  /// Background RGB 532 from 256-color table.
  bg256Rgb532(ansi.bg256Rgb532),

  /// Background RGB 533 from 256-color table.
  bg256Rgb533(ansi.bg256Rgb533),

  /// Background RGB 534 from 256-color table.
  bg256Rgb534(ansi.bg256Rgb534),

  /// Background RGB 535 from 256-color table.
  bg256Rgb535(ansi.bg256Rgb535),

  /// Background RGB 540 from 256-color table.
  bg256Rgb540(ansi.bg256Rgb540),

  /// Background RGB 541 from 256-color table.
  bg256Rgb541(ansi.bg256Rgb541),

  /// Background RGB 542 from 256-color table.
  bg256Rgb542(ansi.bg256Rgb542),

  /// Background RGB 543 from 256-color table.
  bg256Rgb543(ansi.bg256Rgb543),

  /// Background RGB 544 from 256-color table.
  bg256Rgb544(ansi.bg256Rgb544),

  /// Background RGB 545 from 256-color table.
  bg256Rgb545(ansi.bg256Rgb545),

  /// Background RGB 550 from 256-color table.
  bg256Rgb550(ansi.bg256Rgb550),

  /// Background RGB 551 from 256-color table.
  bg256Rgb551(ansi.bg256Rgb551),

  /// Background RGB 552 from 256-color table.
  bg256Rgb552(ansi.bg256Rgb552),

  /// Background RGB 553 from 256-color table.
  bg256Rgb553(ansi.bg256Rgb553),

  /// Background RGB 554 from 256-color table.
  bg256Rgb554(ansi.bg256Rgb554),

  /// Background RGB 555 from 256-color table.
  bg256Rgb555(ansi.bg256Rgb555),

  /// Background gray color 0 from 256-color table.
  bg256Gray0(ansi.bg256Gray0),

  /// Background gray color 1 from 256-color table.
  bg256Gray1(ansi.bg256Gray1),

  /// Background gray color 2 from 256-color table.
  bg256Gray2(ansi.bg256Gray2),

  /// Background gray color 3 from 256-color table.
  bg256Gray3(ansi.bg256Gray3),

  /// Background gray color 4 from 256-color table.
  bg256Gray4(ansi.bg256Gray4),

  /// Background gray color 5 from 256-color table.
  bg256Gray5(ansi.bg256Gray5),

  /// Background gray color 6 from 256-color table.
  bg256Gray6(ansi.bg256Gray6),

  /// Background gray color 7 from 256-color table.
  bg256Gray7(ansi.bg256Gray7),

  /// Background gray color 8 from 256-color table.
  bg256Gray8(ansi.bg256Gray8),

  /// Background gray color 9 from 256-color table.
  bg256Gray9(ansi.bg256Gray9),

  /// Background gray color 10 from 256-color table.
  bg256Gray10(ansi.bg256Gray10),

  /// Background gray color 11 from 256-color table.
  bg256Gray11(ansi.bg256Gray11),

  /// Background gray color 12 from 256-color table.
  bg256Gray12(ansi.bg256Gray12),

  /// Background gray color 13 from 256-color table.
  bg256Gray13(ansi.bg256Gray13),

  /// Background gray color 14 from 256-color table.
  bg256Gray14(ansi.bg256Gray14),

  /// Background gray color 15 from 256-color table.
  bg256Gray15(ansi.bg256Gray15),

  /// Background gray color 16 from 256-color table.
  bg256Gray16(ansi.bg256Gray16),

  /// Background gray color 17 from 256-color table.
  bg256Gray17(ansi.bg256Gray17),

  /// Background gray color 18 from 256-color table.
  bg256Gray18(ansi.bg256Gray18),

  /// Background gray color 19 from 256-color table.
  bg256Gray19(ansi.bg256Gray19),

  /// Background gray color 20 from 256-color table.
  bg256Gray20(ansi.bg256Gray20),

  /// Background gray color 21 from 256-color table.
  bg256Gray21(ansi.bg256Gray21),

  /// Background gray color 22 from 256-color table.
  bg256Gray22(ansi.bg256Gray22),

  /// Background gray color 23 from 256-color table.
  bg256Gray23(ansi.bg256Gray23),

  /// Foreground black from 256-color table.
  fg256Black(ansi.fg256Black),

  /// Foreground red from 256-color table.
  fg256Red(ansi.fg256Red),

  /// Foreground green from 256-color table.
  fg256Green(ansi.fg256Green),

  /// Foreground yellow from 256-color table.
  fg256Yellow(ansi.fg256Yellow),

  /// Foreground blue from 256-color table.
  fg256Blue(ansi.fg256Blue),

  /// Foreground magenta from 256-color table.
  fg256Magenta(ansi.fg256Magenta),

  /// Foreground cyan from 256-color table.
  fg256Cyan(ansi.fg256Cyan),

  /// Foreground white from 256-color table.
  fg256White(ansi.fg256White),

  /// Foreground high intensity black from 256-color table.
  fg256HighBlack(ansi.fg256HighBlack),

  /// Foreground high intensity red from 256-color table.
  fg256HighRed(ansi.fg256HighRed),

  /// Foreground high intensity green from 256-color table.
  fg256HighGreen(ansi.fg256HighGreen),

  /// Foreground high intensity yellow from 256-color table.
  fg256HighYellow(ansi.fg256HighYellow),

  /// Foreground high intensity blue from 256-color table.
  fg256HighBlue(ansi.fg256HighBlue),

  /// Foreground high intensity magenta from 256-color table.
  fg256HighMagenta(ansi.fg256HighMagenta),

  /// Foreground high intensity cyan from 256-color table.
  fg256HighCyan(ansi.fg256HighCyan),

  /// Foreground high intensity white from 256-color table.
  fg256HighWhite(ansi.fg256HighWhite),

  /// Foreground RGB 000 from 256-color table.
  fg256Rgb000(ansi.fg256Rgb000),

  /// Foreground RGB 001 from 256-color table.
  fg256Rgb001(ansi.fg256Rgb001),

  /// Foreground RGB 002 from 256-color table.
  fg256Rgb002(ansi.fg256Rgb002),

  /// Foreground RGB 003 from 256-color table.
  fg256Rgb003(ansi.fg256Rgb003),

  /// Foreground RGB 004 from 256-color table.
  fg256Rgb004(ansi.fg256Rgb004),

  /// Foreground RGB 005 from 256-color table.
  fg256Rgb005(ansi.fg256Rgb005),

  /// Foreground RGB 010 from 256-color table.
  fg256Rgb010(ansi.fg256Rgb010),

  /// Foreground RGB 011 from 256-color table.
  fg256Rgb011(ansi.fg256Rgb011),

  /// Foreground RGB 012 from 256-color table.
  fg256Rgb012(ansi.fg256Rgb012),

  /// Foreground RGB 013 from 256-color table.
  fg256Rgb013(ansi.fg256Rgb013),

  /// Foreground RGB 014 from 256-color table.
  fg256Rgb014(ansi.fg256Rgb014),

  /// Foreground RGB 015 from 256-color table.
  fg256Rgb015(ansi.fg256Rgb015),

  /// Foreground RGB 020 from 256-color table.
  fg256Rgb020(ansi.fg256Rgb020),

  /// Foreground RGB 021 from 256-color table.
  fg256Rgb021(ansi.fg256Rgb021),

  /// Foreground RGB 022 from 256-color table.
  fg256Rgb022(ansi.fg256Rgb022),

  /// Foreground RGB 023 from 256-color table.
  fg256Rgb023(ansi.fg256Rgb023),

  /// Foreground RGB 024 from 256-color table.
  fg256Rgb024(ansi.fg256Rgb024),

  /// Foreground RGB 025 from 256-color table.
  fg256Rgb025(ansi.fg256Rgb025),

  /// Foreground RGB 030 from 256-color table.
  fg256Rgb030(ansi.fg256Rgb030),

  /// Foreground RGB 031 from 256-color table.
  fg256Rgb031(ansi.fg256Rgb031),

  /// Foreground RGB 032 from 256-color table.
  fg256Rgb032(ansi.fg256Rgb032),

  /// Foreground RGB 033 from 256-color table.
  fg256Rgb033(ansi.fg256Rgb033),

  /// Foreground RGB 034 from 256-color table.
  fg256Rgb034(ansi.fg256Rgb034),

  /// Foreground RGB 035 from 256-color table.
  fg256Rgb035(ansi.fg256Rgb035),

  /// Foreground RGB 040 from 256-color table.
  fg256Rgb040(ansi.fg256Rgb040),

  /// Foreground RGB 041 from 256-color table.
  fg256Rgb041(ansi.fg256Rgb041),

  /// Foreground RGB 042 from 256-color table.
  fg256Rgb042(ansi.fg256Rgb042),

  /// Foreground RGB 043 from 256-color table.
  fg256Rgb043(ansi.fg256Rgb043),

  /// Foreground RGB 044 from 256-color table.
  fg256Rgb044(ansi.fg256Rgb044),

  /// Foreground RGB 045 from 256-color table.
  fg256Rgb045(ansi.fg256Rgb045),

  /// Foreground RGB 050 from 256-color table.
  fg256Rgb050(ansi.fg256Rgb050),

  /// Foreground RGB 051 from 256-color table.
  fg256Rgb051(ansi.fg256Rgb051),

  /// Foreground RGB 052 from 256-color table.
  fg256Rgb052(ansi.fg256Rgb052),

  /// Foreground RGB 053 from 256-color table.
  fg256Rgb053(ansi.fg256Rgb053),

  /// Foreground RGB 054 from 256-color table.
  fg256Rgb054(ansi.fg256Rgb054),

  /// Foreground RGB 055 from 256-color table.
  fg256Rgb055(ansi.fg256Rgb055),

  /// Foreground RGB 100 from 256-color table.
  fg256Rgb100(ansi.fg256Rgb100),

  /// Foreground RGB 101 from 256-color table.
  fg256Rgb101(ansi.fg256Rgb101),

  /// Foreground RGB 102 from 256-color table.
  fg256Rgb102(ansi.fg256Rgb102),

  /// Foreground RGB 103 from 256-color table.
  fg256Rgb103(ansi.fg256Rgb103),

  /// Foreground RGB 104 from 256-color table.
  fg256Rgb104(ansi.fg256Rgb104),

  /// Foreground RGB 105 from 256-color table.
  fg256Rgb105(ansi.fg256Rgb105),

  /// Foreground RGB 110 from 256-color table.
  fg256Rgb110(ansi.fg256Rgb110),

  /// Foreground RGB 111 from 256-color table.
  fg256Rgb111(ansi.fg256Rgb111),

  /// Foreground RGB 112 from 256-color table.
  fg256Rgb112(ansi.fg256Rgb112),

  /// Foreground RGB 113 from 256-color table.
  fg256Rgb113(ansi.fg256Rgb113),

  /// Foreground RGB 114 from 256-color table.
  fg256Rgb114(ansi.fg256Rgb114),

  /// Foreground RGB 115 from 256-color table.
  fg256Rgb115(ansi.fg256Rgb115),

  /// Foreground RGB 120 from 256-color table.
  fg256Rgb120(ansi.fg256Rgb120),

  /// Foreground RGB 121 from 256-color table.
  fg256Rgb121(ansi.fg256Rgb121),

  /// Foreground RGB 122 from 256-color table.
  fg256Rgb122(ansi.fg256Rgb122),

  /// Foreground RGB 123 from 256-color table.
  fg256Rgb123(ansi.fg256Rgb123),

  /// Foreground RGB 124 from 256-color table.
  fg256Rgb124(ansi.fg256Rgb124),

  /// Foreground RGB 125 from 256-color table.
  fg256Rgb125(ansi.fg256Rgb125),

  /// Foreground RGB 130 from 256-color table.
  fg256Rgb130(ansi.fg256Rgb130),

  /// Foreground RGB 131 from 256-color table.
  fg256Rgb131(ansi.fg256Rgb131),

  /// Foreground RGB 132 from 256-color table.
  fg256Rgb132(ansi.fg256Rgb132),

  /// Foreground RGB 133 from 256-color table.
  fg256Rgb133(ansi.fg256Rgb133),

  /// Foreground RGB 134 from 256-color table.
  fg256Rgb134(ansi.fg256Rgb134),

  /// Foreground RGB 135 from 256-color table.
  fg256Rgb135(ansi.fg256Rgb135),

  /// Foreground RGB 140 from 256-color table.
  fg256Rgb140(ansi.fg256Rgb140),

  /// Foreground RGB 141 from 256-color table.
  fg256Rgb141(ansi.fg256Rgb141),

  /// Foreground RGB 142 from 256-color table.
  fg256Rgb142(ansi.fg256Rgb142),

  /// Foreground RGB 143 from 256-color table.
  fg256Rgb143(ansi.fg256Rgb143),

  /// Foreground RGB 144 from 256-color table.
  fg256Rgb144(ansi.fg256Rgb144),

  /// Foreground RGB 145 from 256-color table.
  fg256Rgb145(ansi.fg256Rgb145),

  /// Foreground RGB 150 from 256-color table.
  fg256Rgb150(ansi.fg256Rgb150),

  /// Foreground RGB 151 from 256-color table.
  fg256Rgb151(ansi.fg256Rgb151),

  /// Foreground RGB 152 from 256-color table.
  fg256Rgb152(ansi.fg256Rgb152),

  /// Foreground RGB 153 from 256-color table.
  fg256Rgb153(ansi.fg256Rgb153),

  /// Foreground RGB 154 from 256-color table.
  fg256Rgb154(ansi.fg256Rgb154),

  /// Foreground RGB 155 from 256-color table.
  fg256Rgb155(ansi.fg256Rgb155),

  /// Foreground RGB 200 from 256-color table.
  fg256Rgb200(ansi.fg256Rgb200),

  /// Foreground RGB 201 from 256-color table.
  fg256Rgb201(ansi.fg256Rgb201),

  /// Foreground RGB 202 from 256-color table.
  fg256Rgb202(ansi.fg256Rgb202),

  /// Foreground RGB 203 from 256-color table.
  fg256Rgb203(ansi.fg256Rgb203),

  /// Foreground RGB 204 from 256-color table.
  fg256Rgb204(ansi.fg256Rgb204),

  /// Foreground RGB 205 from 256-color table.
  fg256Rgb205(ansi.fg256Rgb205),

  /// Foreground RGB 210 from 256-color table.
  fg256Rgb210(ansi.fg256Rgb210),

  /// Foreground RGB 211 from 256-color table.
  fg256Rgb211(ansi.fg256Rgb211),

  /// Foreground RGB 212 from 256-color table.
  fg256Rgb212(ansi.fg256Rgb212),

  /// Foreground RGB 213 from 256-color table.
  fg256Rgb213(ansi.fg256Rgb213),

  /// Foreground RGB 214 from 256-color table.
  fg256Rgb214(ansi.fg256Rgb214),

  /// Foreground RGB 215 from 256-color table.
  fg256Rgb215(ansi.fg256Rgb215),

  /// Foreground RGB 220 from 256-color table.
  fg256Rgb220(ansi.fg256Rgb220),

  /// Foreground RGB 221 from 256-color table.
  fg256Rgb221(ansi.fg256Rgb221),

  /// Foreground RGB 222 from 256-color table.
  fg256Rgb222(ansi.fg256Rgb222),

  /// Foreground RGB 223 from 256-color table.
  fg256Rgb223(ansi.fg256Rgb223),

  /// Foreground RGB 224 from 256-color table.
  fg256Rgb224(ansi.fg256Rgb224),

  /// Foreground RGB 225 from 256-color table.
  fg256Rgb225(ansi.fg256Rgb225),

  /// Foreground RGB 230 from 256-color table.
  fg256Rgb230(ansi.fg256Rgb230),

  /// Foreground RGB 231 from 256-color table.
  fg256Rgb231(ansi.fg256Rgb231),

  /// Foreground RGB 232 from 256-color table.
  fg256Rgb232(ansi.fg256Rgb232),

  /// Foreground RGB 233 from 256-color table.
  fg256Rgb233(ansi.fg256Rgb233),

  /// Foreground RGB 234 from 256-color table.
  fg256Rgb234(ansi.fg256Rgb234),

  /// Foreground RGB 235 from 256-color table.
  fg256Rgb235(ansi.fg256Rgb235),

  /// Foreground RGB 240 from 256-color table.
  fg256Rgb240(ansi.fg256Rgb240),

  /// Foreground RGB 241 from 256-color table.
  fg256Rgb241(ansi.fg256Rgb241),

  /// Foreground RGB 242 from 256-color table.
  fg256Rgb242(ansi.fg256Rgb242),

  /// Foreground RGB 243 from 256-color table.
  fg256Rgb243(ansi.fg256Rgb243),

  /// Foreground RGB 244 from 256-color table.
  fg256Rgb244(ansi.fg256Rgb244),

  /// Foreground RGB 245 from 256-color table.
  fg256Rgb245(ansi.fg256Rgb245),

  /// Foreground RGB 250 from 256-color table.
  fg256Rgb250(ansi.fg256Rgb250),

  /// Foreground RGB 251 from 256-color table.
  fg256Rgb251(ansi.fg256Rgb251),

  /// Foreground RGB 252 from 256-color table.
  fg256Rgb252(ansi.fg256Rgb252),

  /// Foreground RGB 253 from 256-color table.
  fg256Rgb253(ansi.fg256Rgb253),

  /// Foreground RGB 254 from 256-color table.
  fg256Rgb254(ansi.fg256Rgb254),

  /// Foreground RGB 255 from 256-color table.
  fg256Rgb255(ansi.fg256Rgb255),

  /// Foreground RGB 300 from 256-color table.
  fg256Rgb300(ansi.fg256Rgb300),

  /// Foreground RGB 301 from 256-color table.
  fg256Rgb301(ansi.fg256Rgb301),

  /// Foreground RGB 302 from 256-color table.
  fg256Rgb302(ansi.fg256Rgb302),

  /// Foreground RGB 303 from 256-color table.
  fg256Rgb303(ansi.fg256Rgb303),

  /// Foreground RGB 304 from 256-color table.
  fg256Rgb304(ansi.fg256Rgb304),

  /// Foreground RGB 305 from 256-color table.
  fg256Rgb305(ansi.fg256Rgb305),

  /// Foreground RGB 310 from 256-color table.
  fg256Rgb310(ansi.fg256Rgb310),

  /// Foreground RGB 311 from 256-color table.
  fg256Rgb311(ansi.fg256Rgb311),

  /// Foreground RGB 312 from 256-color table.
  fg256Rgb312(ansi.fg256Rgb312),

  /// Foreground RGB 313 from 256-color table.
  fg256Rgb313(ansi.fg256Rgb313),

  /// Foreground RGB 314 from 256-color table.
  fg256Rgb314(ansi.fg256Rgb314),

  /// Foreground RGB 315 from 256-color table.
  fg256Rgb315(ansi.fg256Rgb315),

  /// Foreground RGB 320 from 256-color table.
  fg256Rgb320(ansi.fg256Rgb320),

  /// Foreground RGB 321 from 256-color table.
  fg256Rgb321(ansi.fg256Rgb321),

  /// Foreground RGB 322 from 256-color table.
  fg256Rgb322(ansi.fg256Rgb322),

  /// Foreground RGB 323 from 256-color table.
  fg256Rgb323(ansi.fg256Rgb323),

  /// Foreground RGB 324 from 256-color table.
  fg256Rgb324(ansi.fg256Rgb324),

  /// Foreground RGB 325 from 256-color table.
  fg256Rgb325(ansi.fg256Rgb325),

  /// Foreground RGB 330 from 256-color table.
  fg256Rgb330(ansi.fg256Rgb330),

  /// Foreground RGB 331 from 256-color table.
  fg256Rgb331(ansi.fg256Rgb331),

  /// Foreground RGB 332 from 256-color table.
  fg256Rgb332(ansi.fg256Rgb332),

  /// Foreground RGB 333 from 256-color table.
  fg256Rgb333(ansi.fg256Rgb333),

  /// Foreground RGB 334 from 256-color table.
  fg256Rgb334(ansi.fg256Rgb334),

  /// Foreground RGB 335 from 256-color table.
  fg256Rgb335(ansi.fg256Rgb335),

  /// Foreground RGB 340 from 256-color table.
  fg256Rgb340(ansi.fg256Rgb340),

  /// Foreground RGB 341 from 256-color table.
  fg256Rgb341(ansi.fg256Rgb341),

  /// Foreground RGB 342 from 256-color table.
  fg256Rgb342(ansi.fg256Rgb342),

  /// Foreground RGB 343 from 256-color table.
  fg256Rgb343(ansi.fg256Rgb343),

  /// Foreground RGB 344 from 256-color table.
  fg256Rgb344(ansi.fg256Rgb344),

  /// Foreground RGB 345 from 256-color table.
  fg256Rgb345(ansi.fg256Rgb345),

  /// Foreground RGB 350 from 256-color table.
  fg256Rgb350(ansi.fg256Rgb350),

  /// Foreground RGB 351 from 256-color table.
  fg256Rgb351(ansi.fg256Rgb351),

  /// Foreground RGB 352 from 256-color table.
  fg256Rgb352(ansi.fg256Rgb352),

  /// Foreground RGB 353 from 256-color table.
  fg256Rgb353(ansi.fg256Rgb353),

  /// Foreground RGB 354 from 256-color table.
  fg256Rgb354(ansi.fg256Rgb354),

  /// Foreground RGB 355 from 256-color table.
  fg256Rgb355(ansi.fg256Rgb355),

  /// Foreground RGB 400 from 256-color table.
  fg256Rgb400(ansi.fg256Rgb400),

  /// Foreground RGB 401 from 256-color table.
  fg256Rgb401(ansi.fg256Rgb401),

  /// Foreground RGB 402 from 256-color table.
  fg256Rgb402(ansi.fg256Rgb402),

  /// Foreground RGB 403 from 256-color table.
  fg256Rgb403(ansi.fg256Rgb403),

  /// Foreground RGB 404 from 256-color table.
  fg256Rgb404(ansi.fg256Rgb404),

  /// Foreground RGB 405 from 256-color table.
  fg256Rgb405(ansi.fg256Rgb405),

  /// Foreground RGB 410 from 256-color table.
  fg256Rgb410(ansi.fg256Rgb410),

  /// Foreground RGB 411 from 256-color table.
  fg256Rgb411(ansi.fg256Rgb411),

  /// Foreground RGB 412 from 256-color table.
  fg256Rgb412(ansi.fg256Rgb412),

  /// Foreground RGB 413 from 256-color table.
  fg256Rgb413(ansi.fg256Rgb413),

  /// Foreground RGB 414 from 256-color table.
  fg256Rgb414(ansi.fg256Rgb414),

  /// Foreground RGB 415 from 256-color table.
  fg256Rgb415(ansi.fg256Rgb415),

  /// Foreground RGB 420 from 256-color table.
  fg256Rgb420(ansi.fg256Rgb420),

  /// Foreground RGB 421 from 256-color table.
  fg256Rgb421(ansi.fg256Rgb421),

  /// Foreground RGB 422 from 256-color table.
  fg256Rgb422(ansi.fg256Rgb422),

  /// Foreground RGB 423 from 256-color table.
  fg256Rgb423(ansi.fg256Rgb423),

  /// Foreground RGB 424 from 256-color table.
  fg256Rgb424(ansi.fg256Rgb424),

  /// Foreground RGB 425 from 256-color table.
  fg256Rgb425(ansi.fg256Rgb425),

  /// Foreground RGB 430 from 256-color table.
  fg256Rgb430(ansi.fg256Rgb430),

  /// Foreground RGB 431 from 256-color table.
  fg256Rgb431(ansi.fg256Rgb431),

  /// Foreground RGB 432 from 256-color table.
  fg256Rgb432(ansi.fg256Rgb432),

  /// Foreground RGB 433 from 256-color table.
  fg256Rgb433(ansi.fg256Rgb433),

  /// Foreground RGB 434 from 256-color table.
  fg256Rgb434(ansi.fg256Rgb434),

  /// Foreground RGB 435 from 256-color table.
  fg256Rgb435(ansi.fg256Rgb435),

  /// Foreground RGB 440 from 256-color table.
  fg256Rgb440(ansi.fg256Rgb440),

  /// Foreground RGB 441 from 256-color table.
  fg256Rgb441(ansi.fg256Rgb441),

  /// Foreground RGB 442 from 256-color table.
  fg256Rgb442(ansi.fg256Rgb442),

  /// Foreground RGB 443 from 256-color table.
  fg256Rgb443(ansi.fg256Rgb443),

  /// Foreground RGB 444 from 256-color table.
  fg256Rgb444(ansi.fg256Rgb444),

  /// Foreground RGB 445 from 256-color table.
  fg256Rgb445(ansi.fg256Rgb445),

  /// Foreground RGB 450 from 256-color table.
  fg256Rgb450(ansi.fg256Rgb450),

  /// Foreground RGB 451 from 256-color table.
  fg256Rgb451(ansi.fg256Rgb451),

  /// Foreground RGB 452 from 256-color table.
  fg256Rgb452(ansi.fg256Rgb452),

  /// Foreground RGB 453 from 256-color table.
  fg256Rgb453(ansi.fg256Rgb453),

  /// Foreground RGB 454 from 256-color table.
  fg256Rgb454(ansi.fg256Rgb454),

  /// Foreground RGB 455 from 256-color table.
  fg256Rgb455(ansi.fg256Rgb455),

  /// Foreground RGB 500 from 256-color table.
  fg256Rgb500(ansi.fg256Rgb500),

  /// Foreground RGB 501 from 256-color table.
  fg256Rgb501(ansi.fg256Rgb501),

  /// Foreground RGB 502 from 256-color table.
  fg256Rgb502(ansi.fg256Rgb502),

  /// Foreground RGB 503 from 256-color table.
  fg256Rgb503(ansi.fg256Rgb503),

  /// Foreground RGB 504 from 256-color table.
  fg256Rgb504(ansi.fg256Rgb504),

  /// Foreground RGB 505 from 256-color table.
  fg256Rgb505(ansi.fg256Rgb505),

  /// Foreground RGB 510 from 256-color table.
  fg256Rgb510(ansi.fg256Rgb510),

  /// Foreground RGB 511 from 256-color table.
  fg256Rgb511(ansi.fg256Rgb511),

  /// Foreground RGB 512 from 256-color table.
  fg256Rgb512(ansi.fg256Rgb512),

  /// Foreground RGB 513 from 256-color table.
  fg256Rgb513(ansi.fg256Rgb513),

  /// Foreground RGB 514 from 256-color table.
  fg256Rgb514(ansi.fg256Rgb514),

  /// Foreground RGB 515 from 256-color table.
  fg256Rgb515(ansi.fg256Rgb515),

  /// Foreground RGB 520 from 256-color table.
  fg256Rgb520(ansi.fg256Rgb520),

  /// Foreground RGB 521 from 256-color table.
  fg256Rgb521(ansi.fg256Rgb521),

  /// Foreground RGB 522 from 256-color table.
  fg256Rgb522(ansi.fg256Rgb522),

  /// Foreground RGB 523 from 256-color table.
  fg256Rgb523(ansi.fg256Rgb523),

  /// Foreground RGB 524 from 256-color table.
  fg256Rgb524(ansi.fg256Rgb524),

  /// Foreground RGB 525 from 256-color table.
  fg256Rgb525(ansi.fg256Rgb525),

  /// Foreground RGB 530 from 256-color table.
  fg256Rgb530(ansi.fg256Rgb530),

  /// Foreground RGB 531 from 256-color table.
  fg256Rgb531(ansi.fg256Rgb531),

  /// Foreground RGB 532 from 256-color table.
  fg256Rgb532(ansi.fg256Rgb532),

  /// Foreground RGB 533 from 256-color table.
  fg256Rgb533(ansi.fg256Rgb533),

  /// Foreground RGB 534 from 256-color table.
  fg256Rgb534(ansi.fg256Rgb534),

  /// Foreground RGB 535 from 256-color table.
  fg256Rgb535(ansi.fg256Rgb535),

  /// Foreground RGB 540 from 256-color table.
  fg256Rgb540(ansi.fg256Rgb540),

  /// Foreground RGB 541 from 256-color table.
  fg256Rgb541(ansi.fg256Rgb541),

  /// Foreground RGB 542 from 256-color table.
  fg256Rgb542(ansi.fg256Rgb542),

  /// Foreground RGB 543 from 256-color table.
  fg256Rgb543(ansi.fg256Rgb543),

  /// Foreground RGB 544 from 256-color table.
  fg256Rgb544(ansi.fg256Rgb544),

  /// Foreground RGB 545 from 256-color table.
  fg256Rgb545(ansi.fg256Rgb545),

  /// Foreground RGB 550 from 256-color table.
  fg256Rgb550(ansi.fg256Rgb550),

  /// Foreground RGB 551 from 256-color table.
  fg256Rgb551(ansi.fg256Rgb551),

  /// Foreground RGB 552 from 256-color table.
  fg256Rgb552(ansi.fg256Rgb552),

  /// Foreground RGB 553 from 256-color table.
  fg256Rgb553(ansi.fg256Rgb553),

  /// Foreground RGB 554 from 256-color table.
  fg256Rgb554(ansi.fg256Rgb554),

  /// Foreground RGB 555 from 256-color table.
  fg256Rgb555(ansi.fg256Rgb555),

  /// Foreground gray color 0 from 256-color table.
  fg256Gray0(ansi.fg256Gray0),

  /// Foreground gray color 1 from 256-color table.
  fg256Gray1(ansi.fg256Gray1),

  /// Foreground gray color 2 from 256-color table.
  fg256Gray2(ansi.fg256Gray2),

  /// Foreground gray color 3 from 256-color table.
  fg256Gray3(ansi.fg256Gray3),

  /// Foreground gray color 4 from 256-color table.
  fg256Gray4(ansi.fg256Gray4),

  /// Foreground gray color 5 from 256-color table.
  fg256Gray5(ansi.fg256Gray5),

  /// Foreground gray color 6 from 256-color table.
  fg256Gray6(ansi.fg256Gray6),

  /// Foreground gray color 7 from 256-color table.
  fg256Gray7(ansi.fg256Gray7),

  /// Foreground gray color 8 from 256-color table.
  fg256Gray8(ansi.fg256Gray8),

  /// Foreground gray color 9 from 256-color table.
  fg256Gray9(ansi.fg256Gray9),

  /// Foreground gray color 10 from 256-color table.
  fg256Gray10(ansi.fg256Gray10),

  /// Foreground gray color 11 from 256-color table.
  fg256Gray11(ansi.fg256Gray11),

  /// Foreground gray color 12 from 256-color table.
  fg256Gray12(ansi.fg256Gray12),

  /// Foreground gray color 13 from 256-color table.
  fg256Gray13(ansi.fg256Gray13),

  /// Foreground gray color 14 from 256-color table.
  fg256Gray14(ansi.fg256Gray14),

  /// Foreground gray color 15 from 256-color table.
  fg256Gray15(ansi.fg256Gray15),

  /// Foreground gray color 16 from 256-color table.
  fg256Gray16(ansi.fg256Gray16),

  /// Foreground gray color 17 from 256-color table.
  fg256Gray17(ansi.fg256Gray17),

  /// Foreground gray color 18 from 256-color table.
  fg256Gray18(ansi.fg256Gray18),

  /// Foreground gray color 19 from 256-color table.
  fg256Gray19(ansi.fg256Gray19),

  /// Foreground gray color 20 from 256-color table.
  fg256Gray20(ansi.fg256Gray20),

  /// Foreground gray color 21 from 256-color table.
  fg256Gray21(ansi.fg256Gray21),

  /// Foreground gray color 22 from 256-color table.
  fg256Gray22(ansi.fg256Gray22),

  /// Foreground gray color 23 from 256-color table.
  fg256Gray23(ansi.fg256Gray23),

  /// Underline black from 256-color table.
  underline256Black(ansi.underline256Black),

  /// Underline red from 256-color table.
  underline256Red(ansi.underline256Red),

  /// Underline green from 256-color table.
  underline256Green(ansi.underline256Green),

  /// Underline yellow from 256-color table.
  underline256Yellow(ansi.underline256Yellow),

  /// Underline blue from 256-color table.
  underline256Blue(ansi.underline256Blue),

  /// Underline magenta from 256-color table.
  underline256Magenta(ansi.underline256Magenta),

  /// Underline cyan from 256-color table.
  underline256Cyan(ansi.underline256Cyan),

  /// Underline white from 256-color table.
  underline256White(ansi.underline256White),

  /// Underline high intensity black from 256-color table.
  underline256HighBlack(ansi.underline256HighBlack),

  /// Underline high intensity red from 256-color table.
  underline256HighRed(ansi.underline256HighRed),

  /// Underline high intensity green from 256-color table.
  underline256HighGreen(ansi.underline256HighGreen),

  /// Underline high intensity yellow from 256-color table.
  underline256HighYellow(ansi.underline256HighYellow),

  /// Underline high intensity blue from 256-color table.
  underline256HighBlue(ansi.underline256HighBlue),

  /// Underline high intensity magenta from 256-color table.
  underline256HighMagenta(ansi.underline256HighMagenta),

  /// Underline high intensity cyan from 256-color table.
  underline256HighCyan(ansi.underline256HighCyan),

  /// Underline high intensity white from 256-color table.
  underline256HighWhite(ansi.underline256HighWhite),

  /// Underline RGB 000 from 256-color table.
  underline256Rgb000(ansi.underline256Rgb000),

  /// Underline RGB 001 from 256-color table.
  underline256Rgb001(ansi.underline256Rgb001),

  /// Underline RGB 002 from 256-color table.
  underline256Rgb002(ansi.underline256Rgb002),

  /// Underline RGB 003 from 256-color table.
  underline256Rgb003(ansi.underline256Rgb003),

  /// Underline RGB 004 from 256-color table.
  underline256Rgb004(ansi.underline256Rgb004),

  /// Underline RGB 005 from 256-color table.
  underline256Rgb005(ansi.underline256Rgb005),

  /// Underline RGB 010 from 256-color table.
  underline256Rgb010(ansi.underline256Rgb010),

  /// Underline RGB 011 from 256-color table.
  underline256Rgb011(ansi.underline256Rgb011),

  /// Underline RGB 012 from 256-color table.
  underline256Rgb012(ansi.underline256Rgb012),

  /// Underline RGB 013 from 256-color table.
  underline256Rgb013(ansi.underline256Rgb013),

  /// Underline RGB 014 from 256-color table.
  underline256Rgb014(ansi.underline256Rgb014),

  /// Underline RGB 015 from 256-color table.
  underline256Rgb015(ansi.underline256Rgb015),

  /// Underline RGB 020 from 256-color table.
  underline256Rgb020(ansi.underline256Rgb020),

  /// Underline RGB 021 from 256-color table.
  underline256Rgb021(ansi.underline256Rgb021),

  /// Underline RGB 022 from 256-color table.
  underline256Rgb022(ansi.underline256Rgb022),

  /// Underline RGB 023 from 256-color table.
  underline256Rgb023(ansi.underline256Rgb023),

  /// Underline RGB 024 from 256-color table.
  underline256Rgb024(ansi.underline256Rgb024),

  /// Underline RGB 025 from 256-color table.
  underline256Rgb025(ansi.underline256Rgb025),

  /// Underline RGB 030 from 256-color table.
  underline256Rgb030(ansi.underline256Rgb030),

  /// Underline RGB 031 from 256-color table.
  underline256Rgb031(ansi.underline256Rgb031),

  /// Underline RGB 032 from 256-color table.
  underline256Rgb032(ansi.underline256Rgb032),

  /// Underline RGB 033 from 256-color table.
  underline256Rgb033(ansi.underline256Rgb033),

  /// Underline RGB 034 from 256-color table.
  underline256Rgb034(ansi.underline256Rgb034),

  /// Underline RGB 035 from 256-color table.
  underline256Rgb035(ansi.underline256Rgb035),

  /// Underline RGB 040 from 256-color table.
  underline256Rgb040(ansi.underline256Rgb040),

  /// Underline RGB 041 from 256-color table.
  underline256Rgb041(ansi.underline256Rgb041),

  /// Underline RGB 042 from 256-color table.
  underline256Rgb042(ansi.underline256Rgb042),

  /// Underline RGB 043 from 256-color table.
  underline256Rgb043(ansi.underline256Rgb043),

  /// Underline RGB 044 from 256-color table.
  underline256Rgb044(ansi.underline256Rgb044),

  /// Underline RGB 045 from 256-color table.
  underline256Rgb045(ansi.underline256Rgb045),

  /// Underline RGB 050 from 256-color table.
  underline256Rgb050(ansi.underline256Rgb050),

  /// Underline RGB 051 from 256-color table.
  underline256Rgb051(ansi.underline256Rgb051),

  /// Underline RGB 052 from 256-color table.
  underline256Rgb052(ansi.underline256Rgb052),

  /// Underline RGB 053 from 256-color table.
  underline256Rgb053(ansi.underline256Rgb053),

  /// Underline RGB 054 from 256-color table.
  underline256Rgb054(ansi.underline256Rgb054),

  /// Underline RGB 055 from 256-color table.
  underline256Rgb055(ansi.underline256Rgb055),

  /// Underline RGB 100 from 256-color table.
  underline256Rgb100(ansi.underline256Rgb100),

  /// Underline RGB 101 from 256-color table.
  underline256Rgb101(ansi.underline256Rgb101),

  /// Underline RGB 102 from 256-color table.
  underline256Rgb102(ansi.underline256Rgb102),

  /// Underline RGB 103 from 256-color table.
  underline256Rgb103(ansi.underline256Rgb103),

  /// Underline RGB 104 from 256-color table.
  underline256Rgb104(ansi.underline256Rgb104),

  /// Underline RGB 105 from 256-color table.
  underline256Rgb105(ansi.underline256Rgb105),

  /// Underline RGB 110 from 256-color table.
  underline256Rgb110(ansi.underline256Rgb110),

  /// Underline RGB 111 from 256-color table.
  underline256Rgb111(ansi.underline256Rgb111),

  /// Underline RGB 112 from 256-color table.
  underline256Rgb112(ansi.underline256Rgb112),

  /// Underline RGB 113 from 256-color table.
  underline256Rgb113(ansi.underline256Rgb113),

  /// Underline RGB 114 from 256-color table.
  underline256Rgb114(ansi.underline256Rgb114),

  /// Underline RGB 115 from 256-color table.
  underline256Rgb115(ansi.underline256Rgb115),

  /// Underline RGB 120 from 256-color table.
  underline256Rgb120(ansi.underline256Rgb120),

  /// Underline RGB 121 from 256-color table.
  underline256Rgb121(ansi.underline256Rgb121),

  /// Underline RGB 122 from 256-color table.
  underline256Rgb122(ansi.underline256Rgb122),

  /// Underline RGB 123 from 256-color table.
  underline256Rgb123(ansi.underline256Rgb123),

  /// Underline RGB 124 from 256-color table.
  underline256Rgb124(ansi.underline256Rgb124),

  /// Underline RGB 125 from 256-color table.
  underline256Rgb125(ansi.underline256Rgb125),

  /// Underline RGB 130 from 256-color table.
  underline256Rgb130(ansi.underline256Rgb130),

  /// Underline RGB 131 from 256-color table.
  underline256Rgb131(ansi.underline256Rgb131),

  /// Underline RGB 132 from 256-color table.
  underline256Rgb132(ansi.underline256Rgb132),

  /// Underline RGB 133 from 256-color table.
  underline256Rgb133(ansi.underline256Rgb133),

  /// Underline RGB 134 from 256-color table.
  underline256Rgb134(ansi.underline256Rgb134),

  /// Underline RGB 135 from 256-color table.
  underline256Rgb135(ansi.underline256Rgb135),

  /// Underline RGB 140 from 256-color table.
  underline256Rgb140(ansi.underline256Rgb140),

  /// Underline RGB 141 from 256-color table.
  underline256Rgb141(ansi.underline256Rgb141),

  /// Underline RGB 142 from 256-color table.
  underline256Rgb142(ansi.underline256Rgb142),

  /// Underline RGB 143 from 256-color table.
  underline256Rgb143(ansi.underline256Rgb143),

  /// Underline RGB 144 from 256-color table.
  underline256Rgb144(ansi.underline256Rgb144),

  /// Underline RGB 145 from 256-color table.
  underline256Rgb145(ansi.underline256Rgb145),

  /// Underline RGB 150 from 256-color table.
  underline256Rgb150(ansi.underline256Rgb150),

  /// Underline RGB 151 from 256-color table.
  underline256Rgb151(ansi.underline256Rgb151),

  /// Underline RGB 152 from 256-color table.
  underline256Rgb152(ansi.underline256Rgb152),

  /// Underline RGB 153 from 256-color table.
  underline256Rgb153(ansi.underline256Rgb153),

  /// Underline RGB 154 from 256-color table.
  underline256Rgb154(ansi.underline256Rgb154),

  /// Underline RGB 155 from 256-color table.
  underline256Rgb155(ansi.underline256Rgb155),

  /// Underline RGB 200 from 256-color table.
  underline256Rgb200(ansi.underline256Rgb200),

  /// Underline RGB 201 from 256-color table.
  underline256Rgb201(ansi.underline256Rgb201),

  /// Underline RGB 202 from 256-color table.
  underline256Rgb202(ansi.underline256Rgb202),

  /// Underline RGB 203 from 256-color table.
  underline256Rgb203(ansi.underline256Rgb203),

  /// Underline RGB 204 from 256-color table.
  underline256Rgb204(ansi.underline256Rgb204),

  /// Underline RGB 205 from 256-color table.
  underline256Rgb205(ansi.underline256Rgb205),

  /// Underline RGB 210 from 256-color table.
  underline256Rgb210(ansi.underline256Rgb210),

  /// Underline RGB 211 from 256-color table.
  underline256Rgb211(ansi.underline256Rgb211),

  /// Underline RGB 212 from 256-color table.
  underline256Rgb212(ansi.underline256Rgb212),

  /// Underline RGB 213 from 256-color table.
  underline256Rgb213(ansi.underline256Rgb213),

  /// Underline RGB 214 from 256-color table.
  underline256Rgb214(ansi.underline256Rgb214),

  /// Underline RGB 215 from 256-color table.
  underline256Rgb215(ansi.underline256Rgb215),

  /// Underline RGB 220 from 256-color table.
  underline256Rgb220(ansi.underline256Rgb220),

  /// Underline RGB 221 from 256-color table.
  underline256Rgb221(ansi.underline256Rgb221),

  /// Underline RGB 222 from 256-color table.
  underline256Rgb222(ansi.underline256Rgb222),

  /// Underline RGB 223 from 256-color table.
  underline256Rgb223(ansi.underline256Rgb223),

  /// Underline RGB 224 from 256-color table.
  underline256Rgb224(ansi.underline256Rgb224),

  /// Underline RGB 225 from 256-color table.
  underline256Rgb225(ansi.underline256Rgb225),

  /// Underline RGB 230 from 256-color table.
  underline256Rgb230(ansi.underline256Rgb230),

  /// Underline RGB 231 from 256-color table.
  underline256Rgb231(ansi.underline256Rgb231),

  /// Underline RGB 232 from 256-color table.
  underline256Rgb232(ansi.underline256Rgb232),

  /// Underline RGB 233 from 256-color table.
  underline256Rgb233(ansi.underline256Rgb233),

  /// Underline RGB 234 from 256-color table.
  underline256Rgb234(ansi.underline256Rgb234),

  /// Underline RGB 235 from 256-color table.
  underline256Rgb235(ansi.underline256Rgb235),

  /// Underline RGB 240 from 256-color table.
  underline256Rgb240(ansi.underline256Rgb240),

  /// Underline RGB 241 from 256-color table.
  underline256Rgb241(ansi.underline256Rgb241),

  /// Underline RGB 242 from 256-color table.
  underline256Rgb242(ansi.underline256Rgb242),

  /// Underline RGB 243 from 256-color table.
  underline256Rgb243(ansi.underline256Rgb243),

  /// Underline RGB 244 from 256-color table.
  underline256Rgb244(ansi.underline256Rgb244),

  /// Underline RGB 245 from 256-color table.
  underline256Rgb245(ansi.underline256Rgb245),

  /// Underline RGB 250 from 256-color table.
  underline256Rgb250(ansi.underline256Rgb250),

  /// Underline RGB 251 from 256-color table.
  underline256Rgb251(ansi.underline256Rgb251),

  /// Underline RGB 252 from 256-color table.
  underline256Rgb252(ansi.underline256Rgb252),

  /// Underline RGB 253 from 256-color table.
  underline256Rgb253(ansi.underline256Rgb253),

  /// Underline RGB 254 from 256-color table.
  underline256Rgb254(ansi.underline256Rgb254),

  /// Underline RGB 255 from 256-color table.
  underline256Rgb255(ansi.underline256Rgb255),

  /// Underline RGB 300 from 256-color table.
  underline256Rgb300(ansi.underline256Rgb300),

  /// Underline RGB 301 from 256-color table.
  underline256Rgb301(ansi.underline256Rgb301),

  /// Underline RGB 302 from 256-color table.
  underline256Rgb302(ansi.underline256Rgb302),

  /// Underline RGB 303 from 256-color table.
  underline256Rgb303(ansi.underline256Rgb303),

  /// Underline RGB 304 from 256-color table.
  underline256Rgb304(ansi.underline256Rgb304),

  /// Underline RGB 305 from 256-color table.
  underline256Rgb305(ansi.underline256Rgb305),

  /// Underline RGB 310 from 256-color table.
  underline256Rgb310(ansi.underline256Rgb310),

  /// Underline RGB 311 from 256-color table.
  underline256Rgb311(ansi.underline256Rgb311),

  /// Underline RGB 312 from 256-color table.
  underline256Rgb312(ansi.underline256Rgb312),

  /// Underline RGB 313 from 256-color table.
  underline256Rgb313(ansi.underline256Rgb313),

  /// Underline RGB 314 from 256-color table.
  underline256Rgb314(ansi.underline256Rgb314),

  /// Underline RGB 315 from 256-color table.
  underline256Rgb315(ansi.underline256Rgb315),

  /// Underline RGB 320 from 256-color table.
  underline256Rgb320(ansi.underline256Rgb320),

  /// Underline RGB 321 from 256-color table.
  underline256Rgb321(ansi.underline256Rgb321),

  /// Underline RGB 322 from 256-color table.
  underline256Rgb322(ansi.underline256Rgb322),

  /// Underline RGB 323 from 256-color table.
  underline256Rgb323(ansi.underline256Rgb323),

  /// Underline RGB 324 from 256-color table.
  underline256Rgb324(ansi.underline256Rgb324),

  /// Underline RGB 325 from 256-color table.
  underline256Rgb325(ansi.underline256Rgb325),

  /// Underline RGB 330 from 256-color table.
  underline256Rgb330(ansi.underline256Rgb330),

  /// Underline RGB 331 from 256-color table.
  underline256Rgb331(ansi.underline256Rgb331),

  /// Underline RGB 332 from 256-color table.
  underline256Rgb332(ansi.underline256Rgb332),

  /// Underline RGB 333 from 256-color table.
  underline256Rgb333(ansi.underline256Rgb333),

  /// Underline RGB 334 from 256-color table.
  underline256Rgb334(ansi.underline256Rgb334),

  /// Underline RGB 335 from 256-color table.
  underline256Rgb335(ansi.underline256Rgb335),

  /// Underline RGB 340 from 256-color table.
  underline256Rgb340(ansi.underline256Rgb340),

  /// Underline RGB 341 from 256-color table.
  underline256Rgb341(ansi.underline256Rgb341),

  /// Underline RGB 342 from 256-color table.
  underline256Rgb342(ansi.underline256Rgb342),

  /// Underline RGB 343 from 256-color table.
  underline256Rgb343(ansi.underline256Rgb343),

  /// Underline RGB 344 from 256-color table.
  underline256Rgb344(ansi.underline256Rgb344),

  /// Underline RGB 345 from 256-color table.
  underline256Rgb345(ansi.underline256Rgb345),

  /// Underline RGB 350 from 256-color table.
  underline256Rgb350(ansi.underline256Rgb350),

  /// Underline RGB 351 from 256-color table.
  underline256Rgb351(ansi.underline256Rgb351),

  /// Underline RGB 352 from 256-color table.
  underline256Rgb352(ansi.underline256Rgb352),

  /// Underline RGB 353 from 256-color table.
  underline256Rgb353(ansi.underline256Rgb353),

  /// Underline RGB 354 from 256-color table.
  underline256Rgb354(ansi.underline256Rgb354),

  /// Underline RGB 355 from 256-color table.
  underline256Rgb355(ansi.underline256Rgb355),

  /// Underline RGB 400 from 256-color table.
  underline256Rgb400(ansi.underline256Rgb400),

  /// Underline RGB 401 from 256-color table.
  underline256Rgb401(ansi.underline256Rgb401),

  /// Underline RGB 402 from 256-color table.
  underline256Rgb402(ansi.underline256Rgb402),

  /// Underline RGB 403 from 256-color table.
  underline256Rgb403(ansi.underline256Rgb403),

  /// Underline RGB 404 from 256-color table.
  underline256Rgb404(ansi.underline256Rgb404),

  /// Underline RGB 405 from 256-color table.
  underline256Rgb405(ansi.underline256Rgb405),

  /// Underline RGB 410 from 256-color table.
  underline256Rgb410(ansi.underline256Rgb410),

  /// Underline RGB 411 from 256-color table.
  underline256Rgb411(ansi.underline256Rgb411),

  /// Underline RGB 412 from 256-color table.
  underline256Rgb412(ansi.underline256Rgb412),

  /// Underline RGB 413 from 256-color table.
  underline256Rgb413(ansi.underline256Rgb413),

  /// Underline RGB 414 from 256-color table.
  underline256Rgb414(ansi.underline256Rgb414),

  /// Underline RGB 415 from 256-color table.
  underline256Rgb415(ansi.underline256Rgb415),

  /// Underline RGB 420 from 256-color table.
  underline256Rgb420(ansi.underline256Rgb420),

  /// Underline RGB 421 from 256-color table.
  underline256Rgb421(ansi.underline256Rgb421),

  /// Underline RGB 422 from 256-color table.
  underline256Rgb422(ansi.underline256Rgb422),

  /// Underline RGB 423 from 256-color table.
  underline256Rgb423(ansi.underline256Rgb423),

  /// Underline RGB 424 from 256-color table.
  underline256Rgb424(ansi.underline256Rgb424),

  /// Underline RGB 425 from 256-color table.
  underline256Rgb425(ansi.underline256Rgb425),

  /// Underline RGB 430 from 256-color table.
  underline256Rgb430(ansi.underline256Rgb430),

  /// Underline RGB 431 from 256-color table.
  underline256Rgb431(ansi.underline256Rgb431),

  /// Underline RGB 432 from 256-color table.
  underline256Rgb432(ansi.underline256Rgb432),

  /// Underline RGB 433 from 256-color table.
  underline256Rgb433(ansi.underline256Rgb433),

  /// Underline RGB 434 from 256-color table.
  underline256Rgb434(ansi.underline256Rgb434),

  /// Underline RGB 435 from 256-color table.
  underline256Rgb435(ansi.underline256Rgb435),

  /// Underline RGB 440 from 256-color table.
  underline256Rgb440(ansi.underline256Rgb440),

  /// Underline RGB 441 from 256-color table.
  underline256Rgb441(ansi.underline256Rgb441),

  /// Underline RGB 442 from 256-color table.
  underline256Rgb442(ansi.underline256Rgb442),

  /// Underline RGB 443 from 256-color table.
  underline256Rgb443(ansi.underline256Rgb443),

  /// Underline RGB 444 from 256-color table.
  underline256Rgb444(ansi.underline256Rgb444),

  /// Underline RGB 445 from 256-color table.
  underline256Rgb445(ansi.underline256Rgb445),

  /// Underline RGB 450 from 256-color table.
  underline256Rgb450(ansi.underline256Rgb450),

  /// Underline RGB 451 from 256-color table.
  underline256Rgb451(ansi.underline256Rgb451),

  /// Underline RGB 452 from 256-color table.
  underline256Rgb452(ansi.underline256Rgb452),

  /// Underline RGB 453 from 256-color table.
  underline256Rgb453(ansi.underline256Rgb453),

  /// Underline RGB 454 from 256-color table.
  underline256Rgb454(ansi.underline256Rgb454),

  /// Underline RGB 455 from 256-color table.
  underline256Rgb455(ansi.underline256Rgb455),

  /// Underline RGB 500 from 256-color table.
  underline256Rgb500(ansi.underline256Rgb500),

  /// Underline RGB 501 from 256-color table.
  underline256Rgb501(ansi.underline256Rgb501),

  /// Underline RGB 502 from 256-color table.
  underline256Rgb502(ansi.underline256Rgb502),

  /// Underline RGB 503 from 256-color table.
  underline256Rgb503(ansi.underline256Rgb503),

  /// Underline RGB 504 from 256-color table.
  underline256Rgb504(ansi.underline256Rgb504),

  /// Underline RGB 505 from 256-color table.
  underline256Rgb505(ansi.underline256Rgb505),

  /// Underline RGB 510 from 256-color table.
  underline256Rgb510(ansi.underline256Rgb510),

  /// Underline RGB 511 from 256-color table.
  underline256Rgb511(ansi.underline256Rgb511),

  /// Underline RGB 512 from 256-color table.
  underline256Rgb512(ansi.underline256Rgb512),

  /// Underline RGB 513 from 256-color table.
  underline256Rgb513(ansi.underline256Rgb513),

  /// Underline RGB 514 from 256-color table.
  underline256Rgb514(ansi.underline256Rgb514),

  /// Underline RGB 515 from 256-color table.
  underline256Rgb515(ansi.underline256Rgb515),

  /// Underline RGB 520 from 256-color table.
  underline256Rgb520(ansi.underline256Rgb520),

  /// Underline RGB 521 from 256-color table.
  underline256Rgb521(ansi.underline256Rgb521),

  /// Underline RGB 522 from 256-color table.
  underline256Rgb522(ansi.underline256Rgb522),

  /// Underline RGB 523 from 256-color table.
  underline256Rgb523(ansi.underline256Rgb523),

  /// Underline RGB 524 from 256-color table.
  underline256Rgb524(ansi.underline256Rgb524),

  /// Underline RGB 525 from 256-color table.
  underline256Rgb525(ansi.underline256Rgb525),

  /// Underline RGB 530 from 256-color table.
  underline256Rgb530(ansi.underline256Rgb530),

  /// Underline RGB 531 from 256-color table.
  underline256Rgb531(ansi.underline256Rgb531),

  /// Underline RGB 532 from 256-color table.
  underline256Rgb532(ansi.underline256Rgb532),

  /// Underline RGB 533 from 256-color table.
  underline256Rgb533(ansi.underline256Rgb533),

  /// Underline RGB 534 from 256-color table.
  underline256Rgb534(ansi.underline256Rgb534),

  /// Underline RGB 535 from 256-color table.
  underline256Rgb535(ansi.underline256Rgb535),

  /// Underline RGB 540 from 256-color table.
  underline256Rgb540(ansi.underline256Rgb540),

  /// Underline RGB 541 from 256-color table.
  underline256Rgb541(ansi.underline256Rgb541),

  /// Underline RGB 542 from 256-color table.
  underline256Rgb542(ansi.underline256Rgb542),

  /// Underline RGB 543 from 256-color table.
  underline256Rgb543(ansi.underline256Rgb543),

  /// Underline RGB 544 from 256-color table.
  underline256Rgb544(ansi.underline256Rgb544),

  /// Underline RGB 545 from 256-color table.
  underline256Rgb545(ansi.underline256Rgb545),

  /// Underline RGB 550 from 256-color table.
  underline256Rgb550(ansi.underline256Rgb550),

  /// Underline RGB 551 from 256-color table.
  underline256Rgb551(ansi.underline256Rgb551),

  /// Underline RGB 552 from 256-color table.
  underline256Rgb552(ansi.underline256Rgb552),

  /// Underline RGB 553 from 256-color table.
  underline256Rgb553(ansi.underline256Rgb553),

  /// Underline RGB 554 from 256-color table.
  underline256Rgb554(ansi.underline256Rgb554),

  /// Underline RGB 555 from 256-color table.
  underline256Rgb555(ansi.underline256Rgb555),

  /// Underline gray color 0 from 256-color table.
  underline256Gray0(ansi.underline256Gray0),

  /// Underline gray color 1 from 256-color table.
  underline256Gray1(ansi.underline256Gray1),

  /// Underline gray color 2 from 256-color table.
  underline256Gray2(ansi.underline256Gray2),

  /// Underline gray color 3 from 256-color table.
  underline256Gray3(ansi.underline256Gray3),

  /// Underline gray color 4 from 256-color table.
  underline256Gray4(ansi.underline256Gray4),

  /// Underline gray color 5 from 256-color table.
  underline256Gray5(ansi.underline256Gray5),

  /// Underline gray color 6 from 256-color table.
  underline256Gray6(ansi.underline256Gray6),

  /// Underline gray color 7 from 256-color table.
  underline256Gray7(ansi.underline256Gray7),

  /// Underline gray color 8 from 256-color table.
  underline256Gray8(ansi.underline256Gray8),

  /// Underline gray color 9 from 256-color table.
  underline256Gray9(ansi.underline256Gray9),

  /// Underline gray color 10 from 256-color table.
  underline256Gray10(ansi.underline256Gray10),

  /// Underline gray color 11 from 256-color table.
  underline256Gray11(ansi.underline256Gray11),

  /// Underline gray color 12 from 256-color table.
  underline256Gray12(ansi.underline256Gray12),

  /// Underline gray color 13 from 256-color table.
  underline256Gray13(ansi.underline256Gray13),

  /// Underline gray color 14 from 256-color table.
  underline256Gray14(ansi.underline256Gray14),

  /// Underline gray color 15 from 256-color table.
  underline256Gray15(ansi.underline256Gray15),

  /// Underline gray color 16 from 256-color table.
  underline256Gray16(ansi.underline256Gray16),

  /// Underline gray color 17 from 256-color table.
  underline256Gray17(ansi.underline256Gray17),

  /// Underline gray color 18 from 256-color table.
  underline256Gray18(ansi.underline256Gray18),

  /// Underline gray color 19 from 256-color table.
  underline256Gray19(ansi.underline256Gray19),

  /// Underline gray color 20 from 256-color table.
  underline256Gray20(ansi.underline256Gray20),

  /// Underline gray color 21 from 256-color table.
  underline256Gray21(ansi.underline256Gray21),

  /// Underline gray color 22 from 256-color table.
  underline256Gray22(ansi.underline256Gray22),

  /// Underline gray color 23 from 256-color table.
  underline256Gray23(ansi.underline256Gray23);

  const CsiPredefinedValues(this.code);

  final String code;

  static CsiPredefinedValues? byCode(String code) {
    for (final v in values) {
      if (v.code == code) {
        return v;
      }
    }

    return null;
  }
}
