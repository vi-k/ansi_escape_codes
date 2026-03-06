part of 'state.dart';

const _bold = 0x0001;
const _dim = 0x0002;
const _italic = 0x0004;
const _underline = 0x0008;
const _doublyUnderline = 0x0010;
const _blink = 0x0020;
const _blinkRapid = 0x0040;
const _inverse = 0x0080;
const _invisible = 0x0100;
const _strikethrough = 0x0200;
const _frame = 0x0400;
const _encircle = 0x0800;
const _overline = 0x1000;
const _superscript = 0x2000;
const _subscript = 0x4000;

enum IntensityStyle { bold, dim }

enum UnderlineStyle { singly, doubly }

enum BlinkStyle { slow, rapid }

enum FrameStyle { frame, encircle }

enum ScriptStyle { superscript, subscript }

/// Represents the currently active text style.
///
/// [Style] contains the current state of ANSI graphic renditions (SGR) without
/// keeping any history. Modifications (e.g., calling [bold] or [foreground])
/// return a new [Style] with up-to-date properties.
///
/// A [Style] can be called as a function (e.g., `style('text')`) to apply
/// itself to the given string.
final class Style extends State<Style> {
  final int _flags;

  @override
  final Color? foregroundColor;

  @override
  final Color? backgroundColor;

  @override
  final ExtendedColor? underlineColorValue;

  const Style({
    bool bold = false,
    bool dim = false,
    bool italic = false,
    bool underline = false,
    bool doublyUnderline = false,
    bool blink = false,
    bool blinkRapid = false,
    bool inverse = false,
    bool invisible = false,
    bool strikethrough = false,
    bool frame = false,
    bool encircle = false,
    bool overline = false,
    bool superscript = false,
    bool subscript = false,
    Color? foreground,
    Color? background,
    ExtendedColor? underlineColor,
  })  : assert(
          !underline || !doublyUnderline,
          'Either underline or doublyUnderline can be set',
        ),
        assert(
          !blink || !blinkRapid,
          'Either blink or blinkRapid can be set',
        ),
        assert(
          !frame || !encircle,
          'Either frame or encircle can be set',
        ),
        assert(
          !superscript || !subscript,
          'Either superscript or subscript can be set',
        ),
        _flags = (bold ? _bold : 0) |
            (dim ? _dim : 0) |
            (italic ? _italic : 0) |
            (underline ? _underline : 0) |
            (doublyUnderline && !underline ? _doublyUnderline : 0) |
            (blink ? _blink : 0) |
            (blinkRapid && !blink ? _blinkRapid : 0) |
            (inverse ? _inverse : 0) |
            (invisible ? _invisible : 0) |
            (strikethrough ? _strikethrough : 0) |
            (frame ? _frame : 0) |
            (encircle && !frame ? _encircle : 0) |
            (overline ? _overline : 0) |
            (superscript && !subscript ? _superscript : 0) |
            (subscript ? _subscript : 0),
        foregroundColor = foreground,
        backgroundColor = background,
        underlineColorValue = underlineColor;

  const Style._(
    this._flags,
    this.foregroundColor,
    this.backgroundColor,
    this.underlineColorValue,
  );

  static const Style defaults = Style._(0, null, null, null);

  String call(String text) {
    final buf = StringBuffer();
    final printer = StackedPrinter(defaultStyle: this);

    for (final line in text.split('\n')) {
      final output = printer.prepare(line);
      buf.write(output);
    }

    return buf.toString();
  }

  @override
  bool get isBold => _flags & _bold != 0;

  @override
  bool get isDim => _flags & _dim != 0;

  @override
  bool get isItalic => _flags & _italic != 0;

  @override
  bool get isUnderline => _flags & _underline != 0;

  @override
  bool get isDoublyUnderline => _flags & _doublyUnderline != 0;

  @override
  UnderlineStyle? get underlineStyle => isUnderline
      ? UnderlineStyle.singly
      : isDoublyUnderline
          ? UnderlineStyle.doubly
          : null;

  @override
  bool get isBlink => _flags & _blink != 0;

  @override
  bool get isBlinkRapid => _flags & _blinkRapid != 0;

  @override
  BlinkStyle? get blinkStyle => isBlink
      ? BlinkStyle.slow
      : isBlinkRapid
          ? BlinkStyle.rapid
          : null;

  @override
  bool get isInverse => _flags & _inverse != 0;

  @override
  bool get isInvisible => _flags & _invisible != 0;

  @override
  bool get isStrikethrough => _flags & _strikethrough != 0;

  @override
  bool get isFrame => _flags & _frame != 0;

  @override
  bool get isEncircle => _flags & _encircle != 0;

  @override
  FrameStyle? get frameStyle => isFrame
      ? FrameStyle.frame
      : isEncircle
          ? FrameStyle.encircle
          : null;

  @override
  bool get isOverline => _flags & _overline != 0;

  @override
  bool get isSuperscript => _flags & _superscript != 0;

  @override
  bool get isSubscript => _flags & _subscript != 0;

  @override
  ScriptStyle? get scriptStyle => isSuperscript
      ? ScriptStyle.superscript
      : isSubscript
          ? ScriptStyle.subscript
          : null;

  @override
  Style get bold => _setFlags(_flags | _bold);

  @override
  Style get dim => _setFlags(_flags | _dim);

  @override
  Style get italic => _setFlags(_flags | _italic);

  @override
  Style get underline => _setFlags(_flags & ~_doublyUnderline | _underline);

  @override
  Style get doublyUnderline =>
      _setFlags(_flags & ~_underline | _doublyUnderline);

  @override
  Style get blink => _setFlags(_flags & ~_blinkRapid | _blink);

  @override
  Style get blinkRapid => _setFlags(_flags & ~_blink | _blinkRapid);

  @override
  Style get inverse => _setFlags(_flags | _inverse);

  @override
  Style get invisible => _setFlags(_flags | _invisible);

  @override
  Style get strikethrough => _setFlags(_flags | _strikethrough);

  @override
  Style get frame => _setFlags(_flags & ~_encircle | _frame);

  @override
  Style get encircle => _setFlags(_flags & ~_frame | _encircle);

  @override
  Style get overline => _setFlags(_flags | _overline);

  @override
  Style get superscript => _setFlags(_flags & ~_subscript | _superscript);

  @override
  Style get subscript => _setFlags(_flags & ~_superscript | _subscript);

  @override
  Style foreground(Color color) => Style._(
        _flags,
        color.withPrefix('fg'),
        backgroundColor,
        underlineColorValue,
      );

  @override
  Style background(Color color) => Style._(
        _flags,
        foregroundColor,
        color.withPrefix('bg'),
        underlineColorValue,
      );

  @override
  Style underlineColor(ExtendedColor color) => Style._(
        _flags,
        foregroundColor,
        backgroundColor,
        color.withPrefix('underlineColor'),
      );

  @override
  Style get reset => defaults;

  @override
  Style get resetBoldAndDim => _setFlags(_flags & ~(_bold | _dim));

  @override
  Style get resetItalic => _setFlags(_flags & ~_italic);

  @override
  Style get resetUnderline =>
      _setFlags(_flags & ~(_underline | _doublyUnderline));

  @override
  Style get resetBlink => _setFlags(_flags & ~(_blink | _blinkRapid));

  @override
  Style get resetInverse => _setFlags(_flags & ~_inverse);

  @override
  Style get resetInvisible => _setFlags(_flags & ~_invisible);

  @override
  Style get resetStrikethrough => _setFlags(_flags & ~_strikethrough);

  @override
  Style get resetFrameAndEncircle => _setFlags(_flags & ~(_frame | _encircle));

  @override
  Style get resetOverline => _setFlags(_flags & ~_overline);

  @override
  Style get resetSuperAndSubscript => _setFlags(
        _flags & ~(_superscript | _subscript),
      );
  @override
  Style get resetForeground =>
      Style._(_flags, null, backgroundColor, underlineColorValue);

  @override
  Style get resetBackground =>
      Style._(_flags, foregroundColor, null, underlineColorValue);

  @override
  Style get resetUnderlineColor =>
      Style._(_flags, foregroundColor, backgroundColor, null);

  Style _setFlags(int flags) => Style._(
        flags,
        foregroundColor,
        backgroundColor,
        underlineColorValue,
      );

  @override
  Style toStyle() => this;

  @override
  String get _objectTypeName => '$Style';

  Style get black => foreground(Color256.black);
  Style get red => foreground(Color256.red);
  Style get green => foreground(Color256.green);
  Style get yellow => foreground(Color256.yellow);
  Style get blue => foreground(Color256.blue);
  Style get magenta => foreground(Color256.magenta);
  Style get cyan => foreground(Color256.cyan);
  Style get white => foreground(Color256.white);
  Style get highBlack => foreground(Color256.highBlack);
  Style get highRed => foreground(Color256.highRed);
  Style get highGreen => foreground(Color256.highGreen);
  Style get highYellow => foreground(Color256.highYellow);
  Style get highBlue => foreground(Color256.highBlue);
  Style get highMagenta => foreground(Color256.highMagenta);
  Style get highCyan => foreground(Color256.highCyan);
  Style get highWhite => foreground(Color256.highWhite);
  Style get rgb000 => foreground(Color256.rgb000);
  Style get rgb001 => foreground(Color256.rgb001);
  Style get rgb002 => foreground(Color256.rgb002);
  Style get rgb003 => foreground(Color256.rgb003);
  Style get rgb004 => foreground(Color256.rgb004);
  Style get rgb005 => foreground(Color256.rgb005);
  Style get rgb010 => foreground(Color256.rgb010);
  Style get rgb011 => foreground(Color256.rgb011);
  Style get rgb012 => foreground(Color256.rgb012);
  Style get rgb013 => foreground(Color256.rgb013);
  Style get rgb014 => foreground(Color256.rgb014);
  Style get rgb015 => foreground(Color256.rgb015);
  Style get rgb020 => foreground(Color256.rgb020);
  Style get rgb021 => foreground(Color256.rgb021);
  Style get rgb022 => foreground(Color256.rgb022);
  Style get rgb023 => foreground(Color256.rgb023);
  Style get rgb024 => foreground(Color256.rgb024);
  Style get rgb025 => foreground(Color256.rgb025);
  Style get rgb030 => foreground(Color256.rgb030);
  Style get rgb031 => foreground(Color256.rgb031);
  Style get rgb032 => foreground(Color256.rgb032);
  Style get rgb033 => foreground(Color256.rgb033);
  Style get rgb034 => foreground(Color256.rgb034);
  Style get rgb035 => foreground(Color256.rgb035);
  Style get rgb040 => foreground(Color256.rgb040);
  Style get rgb041 => foreground(Color256.rgb041);
  Style get rgb042 => foreground(Color256.rgb042);
  Style get rgb043 => foreground(Color256.rgb043);
  Style get rgb044 => foreground(Color256.rgb044);
  Style get rgb045 => foreground(Color256.rgb045);
  Style get rgb050 => foreground(Color256.rgb050);
  Style get rgb051 => foreground(Color256.rgb051);
  Style get rgb052 => foreground(Color256.rgb052);
  Style get rgb053 => foreground(Color256.rgb053);
  Style get rgb054 => foreground(Color256.rgb054);
  Style get rgb055 => foreground(Color256.rgb055);
  Style get rgb100 => foreground(Color256.rgb100);
  Style get rgb101 => foreground(Color256.rgb101);
  Style get rgb102 => foreground(Color256.rgb102);
  Style get rgb103 => foreground(Color256.rgb103);
  Style get rgb104 => foreground(Color256.rgb104);
  Style get rgb105 => foreground(Color256.rgb105);
  Style get rgb110 => foreground(Color256.rgb110);
  Style get rgb111 => foreground(Color256.rgb111);
  Style get rgb112 => foreground(Color256.rgb112);
  Style get rgb113 => foreground(Color256.rgb113);
  Style get rgb114 => foreground(Color256.rgb114);
  Style get rgb115 => foreground(Color256.rgb115);
  Style get rgb120 => foreground(Color256.rgb120);
  Style get rgb121 => foreground(Color256.rgb121);
  Style get rgb122 => foreground(Color256.rgb122);
  Style get rgb123 => foreground(Color256.rgb123);
  Style get rgb124 => foreground(Color256.rgb124);
  Style get rgb125 => foreground(Color256.rgb125);
  Style get rgb130 => foreground(Color256.rgb130);
  Style get rgb131 => foreground(Color256.rgb131);
  Style get rgb132 => foreground(Color256.rgb132);
  Style get rgb133 => foreground(Color256.rgb133);
  Style get rgb134 => foreground(Color256.rgb134);
  Style get rgb135 => foreground(Color256.rgb135);
  Style get rgb140 => foreground(Color256.rgb140);
  Style get rgb141 => foreground(Color256.rgb141);
  Style get rgb142 => foreground(Color256.rgb142);
  Style get rgb143 => foreground(Color256.rgb143);
  Style get rgb144 => foreground(Color256.rgb144);
  Style get rgb145 => foreground(Color256.rgb145);
  Style get rgb150 => foreground(Color256.rgb150);
  Style get rgb151 => foreground(Color256.rgb151);
  Style get rgb152 => foreground(Color256.rgb152);
  Style get rgb153 => foreground(Color256.rgb153);
  Style get rgb154 => foreground(Color256.rgb154);
  Style get rgb155 => foreground(Color256.rgb155);
  Style get rgb200 => foreground(Color256.rgb200);
  Style get rgb201 => foreground(Color256.rgb201);
  Style get rgb202 => foreground(Color256.rgb202);
  Style get rgb203 => foreground(Color256.rgb203);
  Style get rgb204 => foreground(Color256.rgb204);
  Style get rgb205 => foreground(Color256.rgb205);
  Style get rgb210 => foreground(Color256.rgb210);
  Style get rgb211 => foreground(Color256.rgb211);
  Style get rgb212 => foreground(Color256.rgb212);
  Style get rgb213 => foreground(Color256.rgb213);
  Style get rgb214 => foreground(Color256.rgb214);
  Style get rgb215 => foreground(Color256.rgb215);
  Style get rgb220 => foreground(Color256.rgb220);
  Style get rgb221 => foreground(Color256.rgb221);
  Style get rgb222 => foreground(Color256.rgb222);
  Style get rgb223 => foreground(Color256.rgb223);
  Style get rgb224 => foreground(Color256.rgb224);
  Style get rgb225 => foreground(Color256.rgb225);
  Style get rgb230 => foreground(Color256.rgb230);
  Style get rgb231 => foreground(Color256.rgb231);
  Style get rgb232 => foreground(Color256.rgb232);
  Style get rgb233 => foreground(Color256.rgb233);
  Style get rgb234 => foreground(Color256.rgb234);
  Style get rgb235 => foreground(Color256.rgb235);
  Style get rgb240 => foreground(Color256.rgb240);
  Style get rgb241 => foreground(Color256.rgb241);
  Style get rgb242 => foreground(Color256.rgb242);
  Style get rgb243 => foreground(Color256.rgb243);
  Style get rgb244 => foreground(Color256.rgb244);
  Style get rgb245 => foreground(Color256.rgb245);
  Style get rgb250 => foreground(Color256.rgb250);
  Style get rgb251 => foreground(Color256.rgb251);
  Style get rgb252 => foreground(Color256.rgb252);
  Style get rgb253 => foreground(Color256.rgb253);
  Style get rgb254 => foreground(Color256.rgb254);
  Style get rgb255 => foreground(Color256.rgb255);
  Style get rgb300 => foreground(Color256.rgb300);
  Style get rgb301 => foreground(Color256.rgb301);
  Style get rgb302 => foreground(Color256.rgb302);
  Style get rgb303 => foreground(Color256.rgb303);
  Style get rgb304 => foreground(Color256.rgb304);
  Style get rgb305 => foreground(Color256.rgb305);
  Style get rgb310 => foreground(Color256.rgb310);
  Style get rgb311 => foreground(Color256.rgb311);
  Style get rgb312 => foreground(Color256.rgb312);
  Style get rgb313 => foreground(Color256.rgb313);
  Style get rgb314 => foreground(Color256.rgb314);
  Style get rgb315 => foreground(Color256.rgb315);
  Style get rgb320 => foreground(Color256.rgb320);
  Style get rgb321 => foreground(Color256.rgb321);
  Style get rgb322 => foreground(Color256.rgb322);
  Style get rgb323 => foreground(Color256.rgb323);
  Style get rgb324 => foreground(Color256.rgb324);
  Style get rgb325 => foreground(Color256.rgb325);
  Style get rgb330 => foreground(Color256.rgb330);
  Style get rgb331 => foreground(Color256.rgb331);
  Style get rgb332 => foreground(Color256.rgb332);
  Style get rgb333 => foreground(Color256.rgb333);
  Style get rgb334 => foreground(Color256.rgb334);
  Style get rgb335 => foreground(Color256.rgb335);
  Style get rgb340 => foreground(Color256.rgb340);
  Style get rgb341 => foreground(Color256.rgb341);
  Style get rgb342 => foreground(Color256.rgb342);
  Style get rgb343 => foreground(Color256.rgb343);
  Style get rgb344 => foreground(Color256.rgb344);
  Style get rgb345 => foreground(Color256.rgb345);
  Style get rgb350 => foreground(Color256.rgb350);
  Style get rgb351 => foreground(Color256.rgb351);
  Style get rgb352 => foreground(Color256.rgb352);
  Style get rgb353 => foreground(Color256.rgb353);
  Style get rgb354 => foreground(Color256.rgb354);
  Style get rgb355 => foreground(Color256.rgb355);
  Style get rgb400 => foreground(Color256.rgb400);
  Style get rgb401 => foreground(Color256.rgb401);
  Style get rgb402 => foreground(Color256.rgb402);
  Style get rgb403 => foreground(Color256.rgb403);
  Style get rgb404 => foreground(Color256.rgb404);
  Style get rgb405 => foreground(Color256.rgb405);
  Style get rgb410 => foreground(Color256.rgb410);
  Style get rgb411 => foreground(Color256.rgb411);
  Style get rgb412 => foreground(Color256.rgb412);
  Style get rgb413 => foreground(Color256.rgb413);
  Style get rgb414 => foreground(Color256.rgb414);
  Style get rgb415 => foreground(Color256.rgb415);
  Style get rgb420 => foreground(Color256.rgb420);
  Style get rgb421 => foreground(Color256.rgb421);
  Style get rgb422 => foreground(Color256.rgb422);
  Style get rgb423 => foreground(Color256.rgb423);
  Style get rgb424 => foreground(Color256.rgb424);
  Style get rgb425 => foreground(Color256.rgb425);
  Style get rgb430 => foreground(Color256.rgb430);
  Style get rgb431 => foreground(Color256.rgb431);
  Style get rgb432 => foreground(Color256.rgb432);
  Style get rgb433 => foreground(Color256.rgb433);
  Style get rgb434 => foreground(Color256.rgb434);
  Style get rgb435 => foreground(Color256.rgb435);
  Style get rgb440 => foreground(Color256.rgb440);
  Style get rgb441 => foreground(Color256.rgb441);
  Style get rgb442 => foreground(Color256.rgb442);
  Style get rgb443 => foreground(Color256.rgb443);
  Style get rgb444 => foreground(Color256.rgb444);
  Style get rgb445 => foreground(Color256.rgb445);
  Style get rgb450 => foreground(Color256.rgb450);
  Style get rgb451 => foreground(Color256.rgb451);
  Style get rgb452 => foreground(Color256.rgb452);
  Style get rgb453 => foreground(Color256.rgb453);
  Style get rgb454 => foreground(Color256.rgb454);
  Style get rgb455 => foreground(Color256.rgb455);
  Style get rgb500 => foreground(Color256.rgb500);
  Style get rgb501 => foreground(Color256.rgb501);
  Style get rgb502 => foreground(Color256.rgb502);
  Style get rgb503 => foreground(Color256.rgb503);
  Style get rgb504 => foreground(Color256.rgb504);
  Style get rgb505 => foreground(Color256.rgb505);
  Style get rgb510 => foreground(Color256.rgb510);
  Style get rgb511 => foreground(Color256.rgb511);
  Style get rgb512 => foreground(Color256.rgb512);
  Style get rgb513 => foreground(Color256.rgb513);
  Style get rgb514 => foreground(Color256.rgb514);
  Style get rgb515 => foreground(Color256.rgb515);
  Style get rgb520 => foreground(Color256.rgb520);
  Style get rgb521 => foreground(Color256.rgb521);
  Style get rgb522 => foreground(Color256.rgb522);
  Style get rgb523 => foreground(Color256.rgb523);
  Style get rgb524 => foreground(Color256.rgb524);
  Style get rgb525 => foreground(Color256.rgb525);
  Style get rgb530 => foreground(Color256.rgb530);
  Style get rgb531 => foreground(Color256.rgb531);
  Style get rgb532 => foreground(Color256.rgb532);
  Style get rgb533 => foreground(Color256.rgb533);
  Style get rgb534 => foreground(Color256.rgb534);
  Style get rgb535 => foreground(Color256.rgb535);
  Style get rgb540 => foreground(Color256.rgb540);
  Style get rgb541 => foreground(Color256.rgb541);
  Style get rgb542 => foreground(Color256.rgb542);
  Style get rgb543 => foreground(Color256.rgb543);
  Style get rgb544 => foreground(Color256.rgb544);
  Style get rgb545 => foreground(Color256.rgb545);
  Style get rgb550 => foreground(Color256.rgb550);
  Style get rgb551 => foreground(Color256.rgb551);
  Style get rgb552 => foreground(Color256.rgb552);
  Style get rgb553 => foreground(Color256.rgb553);
  Style get rgb554 => foreground(Color256.rgb554);
  Style get rgb555 => foreground(Color256.rgb555);
  Style get gray0 => foreground(Color256.gray0);
  Style get gray1 => foreground(Color256.gray1);
  Style get gray2 => foreground(Color256.gray2);
  Style get gray3 => foreground(Color256.gray3);
  Style get gray4 => foreground(Color256.gray4);
  Style get gray5 => foreground(Color256.gray5);
  Style get gray6 => foreground(Color256.gray6);
  Style get gray7 => foreground(Color256.gray7);
  Style get gray8 => foreground(Color256.gray8);
  Style get gray9 => foreground(Color256.gray9);
  Style get gray10 => foreground(Color256.gray10);
  Style get gray11 => foreground(Color256.gray11);
  Style get gray12 => foreground(Color256.gray12);
  Style get gray13 => foreground(Color256.gray13);
  Style get gray14 => foreground(Color256.gray14);
  Style get gray15 => foreground(Color256.gray15);
  Style get gray16 => foreground(Color256.gray16);
  Style get gray17 => foreground(Color256.gray17);
  Style get gray18 => foreground(Color256.gray18);
  Style get gray19 => foreground(Color256.gray19);
  Style get gray20 => foreground(Color256.gray20);
  Style get gray21 => foreground(Color256.gray21);
  Style get gray22 => foreground(Color256.gray22);
  Style get gray23 => foreground(Color256.gray23);

  Style get bgBlack => background(Color256.black);
  Style get bgRed => background(Color256.red);
  Style get bgGreen => background(Color256.green);
  Style get bgYellow => background(Color256.yellow);
  Style get bgBlue => background(Color256.blue);
  Style get bgMagenta => background(Color256.magenta);
  Style get bgCyan => background(Color256.cyan);
  Style get bgWhite => background(Color256.white);
  Style get bgHighBlack => background(Color256.highBlack);
  Style get bgHighRed => background(Color256.highRed);
  Style get bgHighGreen => background(Color256.highGreen);
  Style get bgHighYellow => background(Color256.highYellow);
  Style get bgHighBlue => background(Color256.highBlue);
  Style get bgHighMagenta => background(Color256.highMagenta);
  Style get bgHighCyan => background(Color256.highCyan);
  Style get bgHighWhite => background(Color256.highWhite);
  Style get bgRgb000 => background(Color256.rgb000);
  Style get bgRgb001 => background(Color256.rgb001);
  Style get bgRgb002 => background(Color256.rgb002);
  Style get bgRgb003 => background(Color256.rgb003);
  Style get bgRgb004 => background(Color256.rgb004);
  Style get bgRgb005 => background(Color256.rgb005);
  Style get bgRgb010 => background(Color256.rgb010);
  Style get bgRgb011 => background(Color256.rgb011);
  Style get bgRgb012 => background(Color256.rgb012);
  Style get bgRgb013 => background(Color256.rgb013);
  Style get bgRgb014 => background(Color256.rgb014);
  Style get bgRgb015 => background(Color256.rgb015);
  Style get bgRgb020 => background(Color256.rgb020);
  Style get bgRgb021 => background(Color256.rgb021);
  Style get bgRgb022 => background(Color256.rgb022);
  Style get bgRgb023 => background(Color256.rgb023);
  Style get bgRgb024 => background(Color256.rgb024);
  Style get bgRgb025 => background(Color256.rgb025);
  Style get bgRgb030 => background(Color256.rgb030);
  Style get bgRgb031 => background(Color256.rgb031);
  Style get bgRgb032 => background(Color256.rgb032);
  Style get bgRgb033 => background(Color256.rgb033);
  Style get bgRgb034 => background(Color256.rgb034);
  Style get bgRgb035 => background(Color256.rgb035);
  Style get bgRgb040 => background(Color256.rgb040);
  Style get bgRgb041 => background(Color256.rgb041);
  Style get bgRgb042 => background(Color256.rgb042);
  Style get bgRgb043 => background(Color256.rgb043);
  Style get bgRgb044 => background(Color256.rgb044);
  Style get bgRgb045 => background(Color256.rgb045);
  Style get bgRgb050 => background(Color256.rgb050);
  Style get bgRgb051 => background(Color256.rgb051);
  Style get bgRgb052 => background(Color256.rgb052);
  Style get bgRgb053 => background(Color256.rgb053);
  Style get bgRgb054 => background(Color256.rgb054);
  Style get bgRgb055 => background(Color256.rgb055);
  Style get bgRgb100 => background(Color256.rgb100);
  Style get bgRgb101 => background(Color256.rgb101);
  Style get bgRgb102 => background(Color256.rgb102);
  Style get bgRgb103 => background(Color256.rgb103);
  Style get bgRgb104 => background(Color256.rgb104);
  Style get bgRgb105 => background(Color256.rgb105);
  Style get bgRgb110 => background(Color256.rgb110);
  Style get bgRgb111 => background(Color256.rgb111);
  Style get bgRgb112 => background(Color256.rgb112);
  Style get bgRgb113 => background(Color256.rgb113);
  Style get bgRgb114 => background(Color256.rgb114);
  Style get bgRgb115 => background(Color256.rgb115);
  Style get bgRgb120 => background(Color256.rgb120);
  Style get bgRgb121 => background(Color256.rgb121);
  Style get bgRgb122 => background(Color256.rgb122);
  Style get bgRgb123 => background(Color256.rgb123);
  Style get bgRgb124 => background(Color256.rgb124);
  Style get bgRgb125 => background(Color256.rgb125);
  Style get bgRgb130 => background(Color256.rgb130);
  Style get bgRgb131 => background(Color256.rgb131);
  Style get bgRgb132 => background(Color256.rgb132);
  Style get bgRgb133 => background(Color256.rgb133);
  Style get bgRgb134 => background(Color256.rgb134);
  Style get bgRgb135 => background(Color256.rgb135);
  Style get bgRgb140 => background(Color256.rgb140);
  Style get bgRgb141 => background(Color256.rgb141);
  Style get bgRgb142 => background(Color256.rgb142);
  Style get bgRgb143 => background(Color256.rgb143);
  Style get bgRgb144 => background(Color256.rgb144);
  Style get bgRgb145 => background(Color256.rgb145);
  Style get bgRgb150 => background(Color256.rgb150);
  Style get bgRgb151 => background(Color256.rgb151);
  Style get bgRgb152 => background(Color256.rgb152);
  Style get bgRgb153 => background(Color256.rgb153);
  Style get bgRgb154 => background(Color256.rgb154);
  Style get bgRgb155 => background(Color256.rgb155);
  Style get bgRgb200 => background(Color256.rgb200);
  Style get bgRgb201 => background(Color256.rgb201);
  Style get bgRgb202 => background(Color256.rgb202);
  Style get bgRgb203 => background(Color256.rgb203);
  Style get bgRgb204 => background(Color256.rgb204);
  Style get bgRgb205 => background(Color256.rgb205);
  Style get bgRgb210 => background(Color256.rgb210);
  Style get bgRgb211 => background(Color256.rgb211);
  Style get bgRgb212 => background(Color256.rgb212);
  Style get bgRgb213 => background(Color256.rgb213);
  Style get bgRgb214 => background(Color256.rgb214);
  Style get bgRgb215 => background(Color256.rgb215);
  Style get bgRgb220 => background(Color256.rgb220);
  Style get bgRgb221 => background(Color256.rgb221);
  Style get bgRgb222 => background(Color256.rgb222);
  Style get bgRgb223 => background(Color256.rgb223);
  Style get bgRgb224 => background(Color256.rgb224);
  Style get bgRgb225 => background(Color256.rgb225);
  Style get bgRgb230 => background(Color256.rgb230);
  Style get bgRgb231 => background(Color256.rgb231);
  Style get bgRgb232 => background(Color256.rgb232);
  Style get bgRgb233 => background(Color256.rgb233);
  Style get bgRgb234 => background(Color256.rgb234);
  Style get bgRgb235 => background(Color256.rgb235);
  Style get bgRgb240 => background(Color256.rgb240);
  Style get bgRgb241 => background(Color256.rgb241);
  Style get bgRgb242 => background(Color256.rgb242);
  Style get bgRgb243 => background(Color256.rgb243);
  Style get bgRgb244 => background(Color256.rgb244);
  Style get bgRgb245 => background(Color256.rgb245);
  Style get bgRgb250 => background(Color256.rgb250);
  Style get bgRgb251 => background(Color256.rgb251);
  Style get bgRgb252 => background(Color256.rgb252);
  Style get bgRgb253 => background(Color256.rgb253);
  Style get bgRgb254 => background(Color256.rgb254);
  Style get bgRgb255 => background(Color256.rgb255);
  Style get bgRgb300 => background(Color256.rgb300);
  Style get bgRgb301 => background(Color256.rgb301);
  Style get bgRgb302 => background(Color256.rgb302);
  Style get bgRgb303 => background(Color256.rgb303);
  Style get bgRgb304 => background(Color256.rgb304);
  Style get bgRgb305 => background(Color256.rgb305);
  Style get bgRgb310 => background(Color256.rgb310);
  Style get bgRgb311 => background(Color256.rgb311);
  Style get bgRgb312 => background(Color256.rgb312);
  Style get bgRgb313 => background(Color256.rgb313);
  Style get bgRgb314 => background(Color256.rgb314);
  Style get bgRgb315 => background(Color256.rgb315);
  Style get bgRgb320 => background(Color256.rgb320);
  Style get bgRgb321 => background(Color256.rgb321);
  Style get bgRgb322 => background(Color256.rgb322);
  Style get bgRgb323 => background(Color256.rgb323);
  Style get bgRgb324 => background(Color256.rgb324);
  Style get bgRgb325 => background(Color256.rgb325);
  Style get bgRgb330 => background(Color256.rgb330);
  Style get bgRgb331 => background(Color256.rgb331);
  Style get bgRgb332 => background(Color256.rgb332);
  Style get bgRgb333 => background(Color256.rgb333);
  Style get bgRgb334 => background(Color256.rgb334);
  Style get bgRgb335 => background(Color256.rgb335);
  Style get bgRgb340 => background(Color256.rgb340);
  Style get bgRgb341 => background(Color256.rgb341);
  Style get bgRgb342 => background(Color256.rgb342);
  Style get bgRgb343 => background(Color256.rgb343);
  Style get bgRgb344 => background(Color256.rgb344);
  Style get bgRgb345 => background(Color256.rgb345);
  Style get bgRgb350 => background(Color256.rgb350);
  Style get bgRgb351 => background(Color256.rgb351);
  Style get bgRgb352 => background(Color256.rgb352);
  Style get bgRgb353 => background(Color256.rgb353);
  Style get bgRgb354 => background(Color256.rgb354);
  Style get bgRgb355 => background(Color256.rgb355);
  Style get bgRgb400 => background(Color256.rgb400);
  Style get bgRgb401 => background(Color256.rgb401);
  Style get bgRgb402 => background(Color256.rgb402);
  Style get bgRgb403 => background(Color256.rgb403);
  Style get bgRgb404 => background(Color256.rgb404);
  Style get bgRgb405 => background(Color256.rgb405);
  Style get bgRgb410 => background(Color256.rgb410);
  Style get bgRgb411 => background(Color256.rgb411);
  Style get bgRgb412 => background(Color256.rgb412);
  Style get bgRgb413 => background(Color256.rgb413);
  Style get bgRgb414 => background(Color256.rgb414);
  Style get bgRgb415 => background(Color256.rgb415);
  Style get bgRgb420 => background(Color256.rgb420);
  Style get bgRgb421 => background(Color256.rgb421);
  Style get bgRgb422 => background(Color256.rgb422);
  Style get bgRgb423 => background(Color256.rgb423);
  Style get bgRgb424 => background(Color256.rgb424);
  Style get bgRgb425 => background(Color256.rgb425);
  Style get bgRgb430 => background(Color256.rgb430);
  Style get bgRgb431 => background(Color256.rgb431);
  Style get bgRgb432 => background(Color256.rgb432);
  Style get bgRgb433 => background(Color256.rgb433);
  Style get bgRgb434 => background(Color256.rgb434);
  Style get bgRgb435 => background(Color256.rgb435);
  Style get bgRgb440 => background(Color256.rgb440);
  Style get bgRgb441 => background(Color256.rgb441);
  Style get bgRgb442 => background(Color256.rgb442);
  Style get bgRgb443 => background(Color256.rgb443);
  Style get bgRgb444 => background(Color256.rgb444);
  Style get bgRgb445 => background(Color256.rgb445);
  Style get bgRgb450 => background(Color256.rgb450);
  Style get bgRgb451 => background(Color256.rgb451);
  Style get bgRgb452 => background(Color256.rgb452);
  Style get bgRgb453 => background(Color256.rgb453);
  Style get bgRgb454 => background(Color256.rgb454);
  Style get bgRgb455 => background(Color256.rgb455);
  Style get bgRgb500 => background(Color256.rgb500);
  Style get bgRgb501 => background(Color256.rgb501);
  Style get bgRgb502 => background(Color256.rgb502);
  Style get bgRgb503 => background(Color256.rgb503);
  Style get bgRgb504 => background(Color256.rgb504);
  Style get bgRgb505 => background(Color256.rgb505);
  Style get bgRgb510 => background(Color256.rgb510);
  Style get bgRgb511 => background(Color256.rgb511);
  Style get bgRgb512 => background(Color256.rgb512);
  Style get bgRgb513 => background(Color256.rgb513);
  Style get bgRgb514 => background(Color256.rgb514);
  Style get bgRgb515 => background(Color256.rgb515);
  Style get bgRgb520 => background(Color256.rgb520);
  Style get bgRgb521 => background(Color256.rgb521);
  Style get bgRgb522 => background(Color256.rgb522);
  Style get bgRgb523 => background(Color256.rgb523);
  Style get bgRgb524 => background(Color256.rgb524);
  Style get bgRgb525 => background(Color256.rgb525);
  Style get bgRgb530 => background(Color256.rgb530);
  Style get bgRgb531 => background(Color256.rgb531);
  Style get bgRgb532 => background(Color256.rgb532);
  Style get bgRgb533 => background(Color256.rgb533);
  Style get bgRgb534 => background(Color256.rgb534);
  Style get bgRgb535 => background(Color256.rgb535);
  Style get bgRgb540 => background(Color256.rgb540);
  Style get bgRgb541 => background(Color256.rgb541);
  Style get bgRgb542 => background(Color256.rgb542);
  Style get bgRgb543 => background(Color256.rgb543);
  Style get bgRgb544 => background(Color256.rgb544);
  Style get bgRgb545 => background(Color256.rgb545);
  Style get bgRgb550 => background(Color256.rgb550);
  Style get bgRgb551 => background(Color256.rgb551);
  Style get bgRgb552 => background(Color256.rgb552);
  Style get bgRgb553 => background(Color256.rgb553);
  Style get bgRgb554 => background(Color256.rgb554);
  Style get bgRgb555 => background(Color256.rgb555);
  Style get bgGray0 => background(Color256.gray0);
  Style get bgGray1 => background(Color256.gray1);
  Style get bgGray2 => background(Color256.gray2);
  Style get bgGray3 => background(Color256.gray3);
  Style get bgGray4 => background(Color256.gray4);
  Style get bgGray5 => background(Color256.gray5);
  Style get bgGray6 => background(Color256.gray6);
  Style get bgGray7 => background(Color256.gray7);
  Style get bgGray8 => background(Color256.gray8);
  Style get bgGray9 => background(Color256.gray9);
  Style get bgGray10 => background(Color256.gray10);
  Style get bgGray11 => background(Color256.gray11);
  Style get bgGray12 => background(Color256.gray12);
  Style get bgGray13 => background(Color256.gray13);
  Style get bgGray14 => background(Color256.gray14);
  Style get bgGray15 => background(Color256.gray15);
  Style get bgGray16 => background(Color256.gray16);
  Style get bgGray17 => background(Color256.gray17);
  Style get bgGray18 => background(Color256.gray18);
  Style get bgGray19 => background(Color256.gray19);
  Style get bgGray20 => background(Color256.gray20);
  Style get bgGray21 => background(Color256.gray21);
  Style get bgGray22 => background(Color256.gray22);
  Style get bgGray23 => background(Color256.gray23);
}
