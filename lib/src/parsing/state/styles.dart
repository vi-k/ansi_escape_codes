// A table of styles, where the name is the documentation, as in
// color_16.dart and color_256.dart.
// ignore_for_file: public_member_api_docs

part of 'state.dart';

/// Every style that carries one thing, named and constant.
///
/// The fifteen properties — `Styles.bold`, `Styles.italic` — and the
/// 256-colour table three times over: `Styles.red` for the colour of the
/// text, `Styles.bgRed` for the colour behind it, `Styles.underlineRed` for
/// the colour of the underline. The names are those of [Color256], and the
/// ready-to-use strings carry the same ones: `Styles.red` is the style,
/// `fgRed` the string that writes it.
///
/// They are constants, so a style can be held in one:
///
/// ```dart
/// const error = Styles.red;
/// ```
///
/// What is built on top of one is not a constant — `Styles.red.bold` is a
/// call — and the chain is where a style carrying more than one thing comes
/// from: see [StyleColors] for the colours as getters, and [Style] for the
/// properties.
///
/// Every chain starts at one of these, so nothing has to be reached for to
/// begin one. A colour the table does not name is the constructor's:
/// `Style(foreground: ColorRgb(1, 2, 3)).bold` is what
/// `Styles.bold.foreground(ColorRgb(1, 2, 3))` says the other way round.
///
/// The colour each of them holds is set on its target already, so it names
/// itself the way a parsed one does: `Styles.red.foregroundColor` answers
/// `fg256Red` to [Color.id], and `Styles.bgRed` answers `bg256Red`. That is
/// what [Color256.on] is for, being the const constructor [Color.on] cannot
/// be.
abstract final class Styles {
  static const Style bold = Style(bold: true);
  static const Style dim = Style(dim: true);
  static const Style italic = Style(italic: true);
  static const Style underline = Style(underline: true);
  static const Style doublyUnderline = Style(doublyUnderline: true);
  static const Style blink = Style(blink: true);
  static const Style blinkRapid = Style(blinkRapid: true);
  static const Style inverse = Style(inverse: true);
  static const Style invisible = Style(invisible: true);
  static const Style strikethrough = Style(strikethrough: true);
  static const Style frame = Style(frame: true);
  static const Style encircle = Style(encircle: true);
  static const Style overline = Style(overline: true);
  static const Style superscript = Style(superscript: true);
  static const Style subscript = Style(subscript: true);

  // BEGIN GENERATED — by tool/generate.dart; edit the generator, not this.
  static const Style black =
      Style(foreground: Color256.on(Colors.black, ColorTarget.foreground));
  static const Style red =
      Style(foreground: Color256.on(Colors.red, ColorTarget.foreground));
  static const Style green =
      Style(foreground: Color256.on(Colors.green, ColorTarget.foreground));
  static const Style yellow =
      Style(foreground: Color256.on(Colors.yellow, ColorTarget.foreground));
  static const Style blue =
      Style(foreground: Color256.on(Colors.blue, ColorTarget.foreground));
  static const Style magenta =
      Style(foreground: Color256.on(Colors.magenta, ColorTarget.foreground));
  static const Style cyan =
      Style(foreground: Color256.on(Colors.cyan, ColorTarget.foreground));
  static const Style white =
      Style(foreground: Color256.on(Colors.white, ColorTarget.foreground));
  static const Style highBlack =
      Style(foreground: Color256.on(Colors.highBlack, ColorTarget.foreground));
  static const Style highRed =
      Style(foreground: Color256.on(Colors.highRed, ColorTarget.foreground));
  static const Style highGreen =
      Style(foreground: Color256.on(Colors.highGreen, ColorTarget.foreground));
  static const Style highYellow =
      Style(foreground: Color256.on(Colors.highYellow, ColorTarget.foreground));
  static const Style highBlue =
      Style(foreground: Color256.on(Colors.highBlue, ColorTarget.foreground));
  static const Style highMagenta = Style(
    foreground: Color256.on(Colors.highMagenta, ColorTarget.foreground),
  );
  static const Style highCyan =
      Style(foreground: Color256.on(Colors.highCyan, ColorTarget.foreground));
  static const Style highWhite =
      Style(foreground: Color256.on(Colors.highWhite, ColorTarget.foreground));
  static const Style rgb000 =
      Style(foreground: Color256.on(Colors.rgb000, ColorTarget.foreground));
  static const Style rgb001 =
      Style(foreground: Color256.on(Colors.rgb001, ColorTarget.foreground));
  static const Style rgb002 =
      Style(foreground: Color256.on(Colors.rgb002, ColorTarget.foreground));
  static const Style rgb003 =
      Style(foreground: Color256.on(Colors.rgb003, ColorTarget.foreground));
  static const Style rgb004 =
      Style(foreground: Color256.on(Colors.rgb004, ColorTarget.foreground));
  static const Style rgb005 =
      Style(foreground: Color256.on(Colors.rgb005, ColorTarget.foreground));
  static const Style rgb010 =
      Style(foreground: Color256.on(Colors.rgb010, ColorTarget.foreground));
  static const Style rgb011 =
      Style(foreground: Color256.on(Colors.rgb011, ColorTarget.foreground));
  static const Style rgb012 =
      Style(foreground: Color256.on(Colors.rgb012, ColorTarget.foreground));
  static const Style rgb013 =
      Style(foreground: Color256.on(Colors.rgb013, ColorTarget.foreground));
  static const Style rgb014 =
      Style(foreground: Color256.on(Colors.rgb014, ColorTarget.foreground));
  static const Style rgb015 =
      Style(foreground: Color256.on(Colors.rgb015, ColorTarget.foreground));
  static const Style rgb020 =
      Style(foreground: Color256.on(Colors.rgb020, ColorTarget.foreground));
  static const Style rgb021 =
      Style(foreground: Color256.on(Colors.rgb021, ColorTarget.foreground));
  static const Style rgb022 =
      Style(foreground: Color256.on(Colors.rgb022, ColorTarget.foreground));
  static const Style rgb023 =
      Style(foreground: Color256.on(Colors.rgb023, ColorTarget.foreground));
  static const Style rgb024 =
      Style(foreground: Color256.on(Colors.rgb024, ColorTarget.foreground));
  static const Style rgb025 =
      Style(foreground: Color256.on(Colors.rgb025, ColorTarget.foreground));
  static const Style rgb030 =
      Style(foreground: Color256.on(Colors.rgb030, ColorTarget.foreground));
  static const Style rgb031 =
      Style(foreground: Color256.on(Colors.rgb031, ColorTarget.foreground));
  static const Style rgb032 =
      Style(foreground: Color256.on(Colors.rgb032, ColorTarget.foreground));
  static const Style rgb033 =
      Style(foreground: Color256.on(Colors.rgb033, ColorTarget.foreground));
  static const Style rgb034 =
      Style(foreground: Color256.on(Colors.rgb034, ColorTarget.foreground));
  static const Style rgb035 =
      Style(foreground: Color256.on(Colors.rgb035, ColorTarget.foreground));
  static const Style rgb040 =
      Style(foreground: Color256.on(Colors.rgb040, ColorTarget.foreground));
  static const Style rgb041 =
      Style(foreground: Color256.on(Colors.rgb041, ColorTarget.foreground));
  static const Style rgb042 =
      Style(foreground: Color256.on(Colors.rgb042, ColorTarget.foreground));
  static const Style rgb043 =
      Style(foreground: Color256.on(Colors.rgb043, ColorTarget.foreground));
  static const Style rgb044 =
      Style(foreground: Color256.on(Colors.rgb044, ColorTarget.foreground));
  static const Style rgb045 =
      Style(foreground: Color256.on(Colors.rgb045, ColorTarget.foreground));
  static const Style rgb050 =
      Style(foreground: Color256.on(Colors.rgb050, ColorTarget.foreground));
  static const Style rgb051 =
      Style(foreground: Color256.on(Colors.rgb051, ColorTarget.foreground));
  static const Style rgb052 =
      Style(foreground: Color256.on(Colors.rgb052, ColorTarget.foreground));
  static const Style rgb053 =
      Style(foreground: Color256.on(Colors.rgb053, ColorTarget.foreground));
  static const Style rgb054 =
      Style(foreground: Color256.on(Colors.rgb054, ColorTarget.foreground));
  static const Style rgb055 =
      Style(foreground: Color256.on(Colors.rgb055, ColorTarget.foreground));
  static const Style rgb100 =
      Style(foreground: Color256.on(Colors.rgb100, ColorTarget.foreground));
  static const Style rgb101 =
      Style(foreground: Color256.on(Colors.rgb101, ColorTarget.foreground));
  static const Style rgb102 =
      Style(foreground: Color256.on(Colors.rgb102, ColorTarget.foreground));
  static const Style rgb103 =
      Style(foreground: Color256.on(Colors.rgb103, ColorTarget.foreground));
  static const Style rgb104 =
      Style(foreground: Color256.on(Colors.rgb104, ColorTarget.foreground));
  static const Style rgb105 =
      Style(foreground: Color256.on(Colors.rgb105, ColorTarget.foreground));
  static const Style rgb110 =
      Style(foreground: Color256.on(Colors.rgb110, ColorTarget.foreground));
  static const Style rgb111 =
      Style(foreground: Color256.on(Colors.rgb111, ColorTarget.foreground));
  static const Style rgb112 =
      Style(foreground: Color256.on(Colors.rgb112, ColorTarget.foreground));
  static const Style rgb113 =
      Style(foreground: Color256.on(Colors.rgb113, ColorTarget.foreground));
  static const Style rgb114 =
      Style(foreground: Color256.on(Colors.rgb114, ColorTarget.foreground));
  static const Style rgb115 =
      Style(foreground: Color256.on(Colors.rgb115, ColorTarget.foreground));
  static const Style rgb120 =
      Style(foreground: Color256.on(Colors.rgb120, ColorTarget.foreground));
  static const Style rgb121 =
      Style(foreground: Color256.on(Colors.rgb121, ColorTarget.foreground));
  static const Style rgb122 =
      Style(foreground: Color256.on(Colors.rgb122, ColorTarget.foreground));
  static const Style rgb123 =
      Style(foreground: Color256.on(Colors.rgb123, ColorTarget.foreground));
  static const Style rgb124 =
      Style(foreground: Color256.on(Colors.rgb124, ColorTarget.foreground));
  static const Style rgb125 =
      Style(foreground: Color256.on(Colors.rgb125, ColorTarget.foreground));
  static const Style rgb130 =
      Style(foreground: Color256.on(Colors.rgb130, ColorTarget.foreground));
  static const Style rgb131 =
      Style(foreground: Color256.on(Colors.rgb131, ColorTarget.foreground));
  static const Style rgb132 =
      Style(foreground: Color256.on(Colors.rgb132, ColorTarget.foreground));
  static const Style rgb133 =
      Style(foreground: Color256.on(Colors.rgb133, ColorTarget.foreground));
  static const Style rgb134 =
      Style(foreground: Color256.on(Colors.rgb134, ColorTarget.foreground));
  static const Style rgb135 =
      Style(foreground: Color256.on(Colors.rgb135, ColorTarget.foreground));
  static const Style rgb140 =
      Style(foreground: Color256.on(Colors.rgb140, ColorTarget.foreground));
  static const Style rgb141 =
      Style(foreground: Color256.on(Colors.rgb141, ColorTarget.foreground));
  static const Style rgb142 =
      Style(foreground: Color256.on(Colors.rgb142, ColorTarget.foreground));
  static const Style rgb143 =
      Style(foreground: Color256.on(Colors.rgb143, ColorTarget.foreground));
  static const Style rgb144 =
      Style(foreground: Color256.on(Colors.rgb144, ColorTarget.foreground));
  static const Style rgb145 =
      Style(foreground: Color256.on(Colors.rgb145, ColorTarget.foreground));
  static const Style rgb150 =
      Style(foreground: Color256.on(Colors.rgb150, ColorTarget.foreground));
  static const Style rgb151 =
      Style(foreground: Color256.on(Colors.rgb151, ColorTarget.foreground));
  static const Style rgb152 =
      Style(foreground: Color256.on(Colors.rgb152, ColorTarget.foreground));
  static const Style rgb153 =
      Style(foreground: Color256.on(Colors.rgb153, ColorTarget.foreground));
  static const Style rgb154 =
      Style(foreground: Color256.on(Colors.rgb154, ColorTarget.foreground));
  static const Style rgb155 =
      Style(foreground: Color256.on(Colors.rgb155, ColorTarget.foreground));
  static const Style rgb200 =
      Style(foreground: Color256.on(Colors.rgb200, ColorTarget.foreground));
  static const Style rgb201 =
      Style(foreground: Color256.on(Colors.rgb201, ColorTarget.foreground));
  static const Style rgb202 =
      Style(foreground: Color256.on(Colors.rgb202, ColorTarget.foreground));
  static const Style rgb203 =
      Style(foreground: Color256.on(Colors.rgb203, ColorTarget.foreground));
  static const Style rgb204 =
      Style(foreground: Color256.on(Colors.rgb204, ColorTarget.foreground));
  static const Style rgb205 =
      Style(foreground: Color256.on(Colors.rgb205, ColorTarget.foreground));
  static const Style rgb210 =
      Style(foreground: Color256.on(Colors.rgb210, ColorTarget.foreground));
  static const Style rgb211 =
      Style(foreground: Color256.on(Colors.rgb211, ColorTarget.foreground));
  static const Style rgb212 =
      Style(foreground: Color256.on(Colors.rgb212, ColorTarget.foreground));
  static const Style rgb213 =
      Style(foreground: Color256.on(Colors.rgb213, ColorTarget.foreground));
  static const Style rgb214 =
      Style(foreground: Color256.on(Colors.rgb214, ColorTarget.foreground));
  static const Style rgb215 =
      Style(foreground: Color256.on(Colors.rgb215, ColorTarget.foreground));
  static const Style rgb220 =
      Style(foreground: Color256.on(Colors.rgb220, ColorTarget.foreground));
  static const Style rgb221 =
      Style(foreground: Color256.on(Colors.rgb221, ColorTarget.foreground));
  static const Style rgb222 =
      Style(foreground: Color256.on(Colors.rgb222, ColorTarget.foreground));
  static const Style rgb223 =
      Style(foreground: Color256.on(Colors.rgb223, ColorTarget.foreground));
  static const Style rgb224 =
      Style(foreground: Color256.on(Colors.rgb224, ColorTarget.foreground));
  static const Style rgb225 =
      Style(foreground: Color256.on(Colors.rgb225, ColorTarget.foreground));
  static const Style rgb230 =
      Style(foreground: Color256.on(Colors.rgb230, ColorTarget.foreground));
  static const Style rgb231 =
      Style(foreground: Color256.on(Colors.rgb231, ColorTarget.foreground));
  static const Style rgb232 =
      Style(foreground: Color256.on(Colors.rgb232, ColorTarget.foreground));
  static const Style rgb233 =
      Style(foreground: Color256.on(Colors.rgb233, ColorTarget.foreground));
  static const Style rgb234 =
      Style(foreground: Color256.on(Colors.rgb234, ColorTarget.foreground));
  static const Style rgb235 =
      Style(foreground: Color256.on(Colors.rgb235, ColorTarget.foreground));
  static const Style rgb240 =
      Style(foreground: Color256.on(Colors.rgb240, ColorTarget.foreground));
  static const Style rgb241 =
      Style(foreground: Color256.on(Colors.rgb241, ColorTarget.foreground));
  static const Style rgb242 =
      Style(foreground: Color256.on(Colors.rgb242, ColorTarget.foreground));
  static const Style rgb243 =
      Style(foreground: Color256.on(Colors.rgb243, ColorTarget.foreground));
  static const Style rgb244 =
      Style(foreground: Color256.on(Colors.rgb244, ColorTarget.foreground));
  static const Style rgb245 =
      Style(foreground: Color256.on(Colors.rgb245, ColorTarget.foreground));
  static const Style rgb250 =
      Style(foreground: Color256.on(Colors.rgb250, ColorTarget.foreground));
  static const Style rgb251 =
      Style(foreground: Color256.on(Colors.rgb251, ColorTarget.foreground));
  static const Style rgb252 =
      Style(foreground: Color256.on(Colors.rgb252, ColorTarget.foreground));
  static const Style rgb253 =
      Style(foreground: Color256.on(Colors.rgb253, ColorTarget.foreground));
  static const Style rgb254 =
      Style(foreground: Color256.on(Colors.rgb254, ColorTarget.foreground));
  static const Style rgb255 =
      Style(foreground: Color256.on(Colors.rgb255, ColorTarget.foreground));
  static const Style rgb300 =
      Style(foreground: Color256.on(Colors.rgb300, ColorTarget.foreground));
  static const Style rgb301 =
      Style(foreground: Color256.on(Colors.rgb301, ColorTarget.foreground));
  static const Style rgb302 =
      Style(foreground: Color256.on(Colors.rgb302, ColorTarget.foreground));
  static const Style rgb303 =
      Style(foreground: Color256.on(Colors.rgb303, ColorTarget.foreground));
  static const Style rgb304 =
      Style(foreground: Color256.on(Colors.rgb304, ColorTarget.foreground));
  static const Style rgb305 =
      Style(foreground: Color256.on(Colors.rgb305, ColorTarget.foreground));
  static const Style rgb310 =
      Style(foreground: Color256.on(Colors.rgb310, ColorTarget.foreground));
  static const Style rgb311 =
      Style(foreground: Color256.on(Colors.rgb311, ColorTarget.foreground));
  static const Style rgb312 =
      Style(foreground: Color256.on(Colors.rgb312, ColorTarget.foreground));
  static const Style rgb313 =
      Style(foreground: Color256.on(Colors.rgb313, ColorTarget.foreground));
  static const Style rgb314 =
      Style(foreground: Color256.on(Colors.rgb314, ColorTarget.foreground));
  static const Style rgb315 =
      Style(foreground: Color256.on(Colors.rgb315, ColorTarget.foreground));
  static const Style rgb320 =
      Style(foreground: Color256.on(Colors.rgb320, ColorTarget.foreground));
  static const Style rgb321 =
      Style(foreground: Color256.on(Colors.rgb321, ColorTarget.foreground));
  static const Style rgb322 =
      Style(foreground: Color256.on(Colors.rgb322, ColorTarget.foreground));
  static const Style rgb323 =
      Style(foreground: Color256.on(Colors.rgb323, ColorTarget.foreground));
  static const Style rgb324 =
      Style(foreground: Color256.on(Colors.rgb324, ColorTarget.foreground));
  static const Style rgb325 =
      Style(foreground: Color256.on(Colors.rgb325, ColorTarget.foreground));
  static const Style rgb330 =
      Style(foreground: Color256.on(Colors.rgb330, ColorTarget.foreground));
  static const Style rgb331 =
      Style(foreground: Color256.on(Colors.rgb331, ColorTarget.foreground));
  static const Style rgb332 =
      Style(foreground: Color256.on(Colors.rgb332, ColorTarget.foreground));
  static const Style rgb333 =
      Style(foreground: Color256.on(Colors.rgb333, ColorTarget.foreground));
  static const Style rgb334 =
      Style(foreground: Color256.on(Colors.rgb334, ColorTarget.foreground));
  static const Style rgb335 =
      Style(foreground: Color256.on(Colors.rgb335, ColorTarget.foreground));
  static const Style rgb340 =
      Style(foreground: Color256.on(Colors.rgb340, ColorTarget.foreground));
  static const Style rgb341 =
      Style(foreground: Color256.on(Colors.rgb341, ColorTarget.foreground));
  static const Style rgb342 =
      Style(foreground: Color256.on(Colors.rgb342, ColorTarget.foreground));
  static const Style rgb343 =
      Style(foreground: Color256.on(Colors.rgb343, ColorTarget.foreground));
  static const Style rgb344 =
      Style(foreground: Color256.on(Colors.rgb344, ColorTarget.foreground));
  static const Style rgb345 =
      Style(foreground: Color256.on(Colors.rgb345, ColorTarget.foreground));
  static const Style rgb350 =
      Style(foreground: Color256.on(Colors.rgb350, ColorTarget.foreground));
  static const Style rgb351 =
      Style(foreground: Color256.on(Colors.rgb351, ColorTarget.foreground));
  static const Style rgb352 =
      Style(foreground: Color256.on(Colors.rgb352, ColorTarget.foreground));
  static const Style rgb353 =
      Style(foreground: Color256.on(Colors.rgb353, ColorTarget.foreground));
  static const Style rgb354 =
      Style(foreground: Color256.on(Colors.rgb354, ColorTarget.foreground));
  static const Style rgb355 =
      Style(foreground: Color256.on(Colors.rgb355, ColorTarget.foreground));
  static const Style rgb400 =
      Style(foreground: Color256.on(Colors.rgb400, ColorTarget.foreground));
  static const Style rgb401 =
      Style(foreground: Color256.on(Colors.rgb401, ColorTarget.foreground));
  static const Style rgb402 =
      Style(foreground: Color256.on(Colors.rgb402, ColorTarget.foreground));
  static const Style rgb403 =
      Style(foreground: Color256.on(Colors.rgb403, ColorTarget.foreground));
  static const Style rgb404 =
      Style(foreground: Color256.on(Colors.rgb404, ColorTarget.foreground));
  static const Style rgb405 =
      Style(foreground: Color256.on(Colors.rgb405, ColorTarget.foreground));
  static const Style rgb410 =
      Style(foreground: Color256.on(Colors.rgb410, ColorTarget.foreground));
  static const Style rgb411 =
      Style(foreground: Color256.on(Colors.rgb411, ColorTarget.foreground));
  static const Style rgb412 =
      Style(foreground: Color256.on(Colors.rgb412, ColorTarget.foreground));
  static const Style rgb413 =
      Style(foreground: Color256.on(Colors.rgb413, ColorTarget.foreground));
  static const Style rgb414 =
      Style(foreground: Color256.on(Colors.rgb414, ColorTarget.foreground));
  static const Style rgb415 =
      Style(foreground: Color256.on(Colors.rgb415, ColorTarget.foreground));
  static const Style rgb420 =
      Style(foreground: Color256.on(Colors.rgb420, ColorTarget.foreground));
  static const Style rgb421 =
      Style(foreground: Color256.on(Colors.rgb421, ColorTarget.foreground));
  static const Style rgb422 =
      Style(foreground: Color256.on(Colors.rgb422, ColorTarget.foreground));
  static const Style rgb423 =
      Style(foreground: Color256.on(Colors.rgb423, ColorTarget.foreground));
  static const Style rgb424 =
      Style(foreground: Color256.on(Colors.rgb424, ColorTarget.foreground));
  static const Style rgb425 =
      Style(foreground: Color256.on(Colors.rgb425, ColorTarget.foreground));
  static const Style rgb430 =
      Style(foreground: Color256.on(Colors.rgb430, ColorTarget.foreground));
  static const Style rgb431 =
      Style(foreground: Color256.on(Colors.rgb431, ColorTarget.foreground));
  static const Style rgb432 =
      Style(foreground: Color256.on(Colors.rgb432, ColorTarget.foreground));
  static const Style rgb433 =
      Style(foreground: Color256.on(Colors.rgb433, ColorTarget.foreground));
  static const Style rgb434 =
      Style(foreground: Color256.on(Colors.rgb434, ColorTarget.foreground));
  static const Style rgb435 =
      Style(foreground: Color256.on(Colors.rgb435, ColorTarget.foreground));
  static const Style rgb440 =
      Style(foreground: Color256.on(Colors.rgb440, ColorTarget.foreground));
  static const Style rgb441 =
      Style(foreground: Color256.on(Colors.rgb441, ColorTarget.foreground));
  static const Style rgb442 =
      Style(foreground: Color256.on(Colors.rgb442, ColorTarget.foreground));
  static const Style rgb443 =
      Style(foreground: Color256.on(Colors.rgb443, ColorTarget.foreground));
  static const Style rgb444 =
      Style(foreground: Color256.on(Colors.rgb444, ColorTarget.foreground));
  static const Style rgb445 =
      Style(foreground: Color256.on(Colors.rgb445, ColorTarget.foreground));
  static const Style rgb450 =
      Style(foreground: Color256.on(Colors.rgb450, ColorTarget.foreground));
  static const Style rgb451 =
      Style(foreground: Color256.on(Colors.rgb451, ColorTarget.foreground));
  static const Style rgb452 =
      Style(foreground: Color256.on(Colors.rgb452, ColorTarget.foreground));
  static const Style rgb453 =
      Style(foreground: Color256.on(Colors.rgb453, ColorTarget.foreground));
  static const Style rgb454 =
      Style(foreground: Color256.on(Colors.rgb454, ColorTarget.foreground));
  static const Style rgb455 =
      Style(foreground: Color256.on(Colors.rgb455, ColorTarget.foreground));
  static const Style rgb500 =
      Style(foreground: Color256.on(Colors.rgb500, ColorTarget.foreground));
  static const Style rgb501 =
      Style(foreground: Color256.on(Colors.rgb501, ColorTarget.foreground));
  static const Style rgb502 =
      Style(foreground: Color256.on(Colors.rgb502, ColorTarget.foreground));
  static const Style rgb503 =
      Style(foreground: Color256.on(Colors.rgb503, ColorTarget.foreground));
  static const Style rgb504 =
      Style(foreground: Color256.on(Colors.rgb504, ColorTarget.foreground));
  static const Style rgb505 =
      Style(foreground: Color256.on(Colors.rgb505, ColorTarget.foreground));
  static const Style rgb510 =
      Style(foreground: Color256.on(Colors.rgb510, ColorTarget.foreground));
  static const Style rgb511 =
      Style(foreground: Color256.on(Colors.rgb511, ColorTarget.foreground));
  static const Style rgb512 =
      Style(foreground: Color256.on(Colors.rgb512, ColorTarget.foreground));
  static const Style rgb513 =
      Style(foreground: Color256.on(Colors.rgb513, ColorTarget.foreground));
  static const Style rgb514 =
      Style(foreground: Color256.on(Colors.rgb514, ColorTarget.foreground));
  static const Style rgb515 =
      Style(foreground: Color256.on(Colors.rgb515, ColorTarget.foreground));
  static const Style rgb520 =
      Style(foreground: Color256.on(Colors.rgb520, ColorTarget.foreground));
  static const Style rgb521 =
      Style(foreground: Color256.on(Colors.rgb521, ColorTarget.foreground));
  static const Style rgb522 =
      Style(foreground: Color256.on(Colors.rgb522, ColorTarget.foreground));
  static const Style rgb523 =
      Style(foreground: Color256.on(Colors.rgb523, ColorTarget.foreground));
  static const Style rgb524 =
      Style(foreground: Color256.on(Colors.rgb524, ColorTarget.foreground));
  static const Style rgb525 =
      Style(foreground: Color256.on(Colors.rgb525, ColorTarget.foreground));
  static const Style rgb530 =
      Style(foreground: Color256.on(Colors.rgb530, ColorTarget.foreground));
  static const Style rgb531 =
      Style(foreground: Color256.on(Colors.rgb531, ColorTarget.foreground));
  static const Style rgb532 =
      Style(foreground: Color256.on(Colors.rgb532, ColorTarget.foreground));
  static const Style rgb533 =
      Style(foreground: Color256.on(Colors.rgb533, ColorTarget.foreground));
  static const Style rgb534 =
      Style(foreground: Color256.on(Colors.rgb534, ColorTarget.foreground));
  static const Style rgb535 =
      Style(foreground: Color256.on(Colors.rgb535, ColorTarget.foreground));
  static const Style rgb540 =
      Style(foreground: Color256.on(Colors.rgb540, ColorTarget.foreground));
  static const Style rgb541 =
      Style(foreground: Color256.on(Colors.rgb541, ColorTarget.foreground));
  static const Style rgb542 =
      Style(foreground: Color256.on(Colors.rgb542, ColorTarget.foreground));
  static const Style rgb543 =
      Style(foreground: Color256.on(Colors.rgb543, ColorTarget.foreground));
  static const Style rgb544 =
      Style(foreground: Color256.on(Colors.rgb544, ColorTarget.foreground));
  static const Style rgb545 =
      Style(foreground: Color256.on(Colors.rgb545, ColorTarget.foreground));
  static const Style rgb550 =
      Style(foreground: Color256.on(Colors.rgb550, ColorTarget.foreground));
  static const Style rgb551 =
      Style(foreground: Color256.on(Colors.rgb551, ColorTarget.foreground));
  static const Style rgb552 =
      Style(foreground: Color256.on(Colors.rgb552, ColorTarget.foreground));
  static const Style rgb553 =
      Style(foreground: Color256.on(Colors.rgb553, ColorTarget.foreground));
  static const Style rgb554 =
      Style(foreground: Color256.on(Colors.rgb554, ColorTarget.foreground));
  static const Style rgb555 =
      Style(foreground: Color256.on(Colors.rgb555, ColorTarget.foreground));
  static const Style gray0 =
      Style(foreground: Color256.on(Colors.gray0, ColorTarget.foreground));
  static const Style gray1 =
      Style(foreground: Color256.on(Colors.gray1, ColorTarget.foreground));
  static const Style gray2 =
      Style(foreground: Color256.on(Colors.gray2, ColorTarget.foreground));
  static const Style gray3 =
      Style(foreground: Color256.on(Colors.gray3, ColorTarget.foreground));
  static const Style gray4 =
      Style(foreground: Color256.on(Colors.gray4, ColorTarget.foreground));
  static const Style gray5 =
      Style(foreground: Color256.on(Colors.gray5, ColorTarget.foreground));
  static const Style gray6 =
      Style(foreground: Color256.on(Colors.gray6, ColorTarget.foreground));
  static const Style gray7 =
      Style(foreground: Color256.on(Colors.gray7, ColorTarget.foreground));
  static const Style gray8 =
      Style(foreground: Color256.on(Colors.gray8, ColorTarget.foreground));
  static const Style gray9 =
      Style(foreground: Color256.on(Colors.gray9, ColorTarget.foreground));
  static const Style gray10 =
      Style(foreground: Color256.on(Colors.gray10, ColorTarget.foreground));
  static const Style gray11 =
      Style(foreground: Color256.on(Colors.gray11, ColorTarget.foreground));
  static const Style gray12 =
      Style(foreground: Color256.on(Colors.gray12, ColorTarget.foreground));
  static const Style gray13 =
      Style(foreground: Color256.on(Colors.gray13, ColorTarget.foreground));
  static const Style gray14 =
      Style(foreground: Color256.on(Colors.gray14, ColorTarget.foreground));
  static const Style gray15 =
      Style(foreground: Color256.on(Colors.gray15, ColorTarget.foreground));
  static const Style gray16 =
      Style(foreground: Color256.on(Colors.gray16, ColorTarget.foreground));
  static const Style gray17 =
      Style(foreground: Color256.on(Colors.gray17, ColorTarget.foreground));
  static const Style gray18 =
      Style(foreground: Color256.on(Colors.gray18, ColorTarget.foreground));
  static const Style gray19 =
      Style(foreground: Color256.on(Colors.gray19, ColorTarget.foreground));
  static const Style gray20 =
      Style(foreground: Color256.on(Colors.gray20, ColorTarget.foreground));
  static const Style gray21 =
      Style(foreground: Color256.on(Colors.gray21, ColorTarget.foreground));
  static const Style gray22 =
      Style(foreground: Color256.on(Colors.gray22, ColorTarget.foreground));
  static const Style gray23 =
      Style(foreground: Color256.on(Colors.gray23, ColorTarget.foreground));

  static const Style bgBlack =
      Style(background: Color256.on(Colors.black, ColorTarget.background));
  static const Style bgRed =
      Style(background: Color256.on(Colors.red, ColorTarget.background));
  static const Style bgGreen =
      Style(background: Color256.on(Colors.green, ColorTarget.background));
  static const Style bgYellow =
      Style(background: Color256.on(Colors.yellow, ColorTarget.background));
  static const Style bgBlue =
      Style(background: Color256.on(Colors.blue, ColorTarget.background));
  static const Style bgMagenta =
      Style(background: Color256.on(Colors.magenta, ColorTarget.background));
  static const Style bgCyan =
      Style(background: Color256.on(Colors.cyan, ColorTarget.background));
  static const Style bgWhite =
      Style(background: Color256.on(Colors.white, ColorTarget.background));
  static const Style bgHighBlack =
      Style(background: Color256.on(Colors.highBlack, ColorTarget.background));
  static const Style bgHighRed =
      Style(background: Color256.on(Colors.highRed, ColorTarget.background));
  static const Style bgHighGreen =
      Style(background: Color256.on(Colors.highGreen, ColorTarget.background));
  static const Style bgHighYellow =
      Style(background: Color256.on(Colors.highYellow, ColorTarget.background));
  static const Style bgHighBlue =
      Style(background: Color256.on(Colors.highBlue, ColorTarget.background));
  static const Style bgHighMagenta = Style(
    background: Color256.on(Colors.highMagenta, ColorTarget.background),
  );
  static const Style bgHighCyan =
      Style(background: Color256.on(Colors.highCyan, ColorTarget.background));
  static const Style bgHighWhite =
      Style(background: Color256.on(Colors.highWhite, ColorTarget.background));
  static const Style bgRgb000 =
      Style(background: Color256.on(Colors.rgb000, ColorTarget.background));
  static const Style bgRgb001 =
      Style(background: Color256.on(Colors.rgb001, ColorTarget.background));
  static const Style bgRgb002 =
      Style(background: Color256.on(Colors.rgb002, ColorTarget.background));
  static const Style bgRgb003 =
      Style(background: Color256.on(Colors.rgb003, ColorTarget.background));
  static const Style bgRgb004 =
      Style(background: Color256.on(Colors.rgb004, ColorTarget.background));
  static const Style bgRgb005 =
      Style(background: Color256.on(Colors.rgb005, ColorTarget.background));
  static const Style bgRgb010 =
      Style(background: Color256.on(Colors.rgb010, ColorTarget.background));
  static const Style bgRgb011 =
      Style(background: Color256.on(Colors.rgb011, ColorTarget.background));
  static const Style bgRgb012 =
      Style(background: Color256.on(Colors.rgb012, ColorTarget.background));
  static const Style bgRgb013 =
      Style(background: Color256.on(Colors.rgb013, ColorTarget.background));
  static const Style bgRgb014 =
      Style(background: Color256.on(Colors.rgb014, ColorTarget.background));
  static const Style bgRgb015 =
      Style(background: Color256.on(Colors.rgb015, ColorTarget.background));
  static const Style bgRgb020 =
      Style(background: Color256.on(Colors.rgb020, ColorTarget.background));
  static const Style bgRgb021 =
      Style(background: Color256.on(Colors.rgb021, ColorTarget.background));
  static const Style bgRgb022 =
      Style(background: Color256.on(Colors.rgb022, ColorTarget.background));
  static const Style bgRgb023 =
      Style(background: Color256.on(Colors.rgb023, ColorTarget.background));
  static const Style bgRgb024 =
      Style(background: Color256.on(Colors.rgb024, ColorTarget.background));
  static const Style bgRgb025 =
      Style(background: Color256.on(Colors.rgb025, ColorTarget.background));
  static const Style bgRgb030 =
      Style(background: Color256.on(Colors.rgb030, ColorTarget.background));
  static const Style bgRgb031 =
      Style(background: Color256.on(Colors.rgb031, ColorTarget.background));
  static const Style bgRgb032 =
      Style(background: Color256.on(Colors.rgb032, ColorTarget.background));
  static const Style bgRgb033 =
      Style(background: Color256.on(Colors.rgb033, ColorTarget.background));
  static const Style bgRgb034 =
      Style(background: Color256.on(Colors.rgb034, ColorTarget.background));
  static const Style bgRgb035 =
      Style(background: Color256.on(Colors.rgb035, ColorTarget.background));
  static const Style bgRgb040 =
      Style(background: Color256.on(Colors.rgb040, ColorTarget.background));
  static const Style bgRgb041 =
      Style(background: Color256.on(Colors.rgb041, ColorTarget.background));
  static const Style bgRgb042 =
      Style(background: Color256.on(Colors.rgb042, ColorTarget.background));
  static const Style bgRgb043 =
      Style(background: Color256.on(Colors.rgb043, ColorTarget.background));
  static const Style bgRgb044 =
      Style(background: Color256.on(Colors.rgb044, ColorTarget.background));
  static const Style bgRgb045 =
      Style(background: Color256.on(Colors.rgb045, ColorTarget.background));
  static const Style bgRgb050 =
      Style(background: Color256.on(Colors.rgb050, ColorTarget.background));
  static const Style bgRgb051 =
      Style(background: Color256.on(Colors.rgb051, ColorTarget.background));
  static const Style bgRgb052 =
      Style(background: Color256.on(Colors.rgb052, ColorTarget.background));
  static const Style bgRgb053 =
      Style(background: Color256.on(Colors.rgb053, ColorTarget.background));
  static const Style bgRgb054 =
      Style(background: Color256.on(Colors.rgb054, ColorTarget.background));
  static const Style bgRgb055 =
      Style(background: Color256.on(Colors.rgb055, ColorTarget.background));
  static const Style bgRgb100 =
      Style(background: Color256.on(Colors.rgb100, ColorTarget.background));
  static const Style bgRgb101 =
      Style(background: Color256.on(Colors.rgb101, ColorTarget.background));
  static const Style bgRgb102 =
      Style(background: Color256.on(Colors.rgb102, ColorTarget.background));
  static const Style bgRgb103 =
      Style(background: Color256.on(Colors.rgb103, ColorTarget.background));
  static const Style bgRgb104 =
      Style(background: Color256.on(Colors.rgb104, ColorTarget.background));
  static const Style bgRgb105 =
      Style(background: Color256.on(Colors.rgb105, ColorTarget.background));
  static const Style bgRgb110 =
      Style(background: Color256.on(Colors.rgb110, ColorTarget.background));
  static const Style bgRgb111 =
      Style(background: Color256.on(Colors.rgb111, ColorTarget.background));
  static const Style bgRgb112 =
      Style(background: Color256.on(Colors.rgb112, ColorTarget.background));
  static const Style bgRgb113 =
      Style(background: Color256.on(Colors.rgb113, ColorTarget.background));
  static const Style bgRgb114 =
      Style(background: Color256.on(Colors.rgb114, ColorTarget.background));
  static const Style bgRgb115 =
      Style(background: Color256.on(Colors.rgb115, ColorTarget.background));
  static const Style bgRgb120 =
      Style(background: Color256.on(Colors.rgb120, ColorTarget.background));
  static const Style bgRgb121 =
      Style(background: Color256.on(Colors.rgb121, ColorTarget.background));
  static const Style bgRgb122 =
      Style(background: Color256.on(Colors.rgb122, ColorTarget.background));
  static const Style bgRgb123 =
      Style(background: Color256.on(Colors.rgb123, ColorTarget.background));
  static const Style bgRgb124 =
      Style(background: Color256.on(Colors.rgb124, ColorTarget.background));
  static const Style bgRgb125 =
      Style(background: Color256.on(Colors.rgb125, ColorTarget.background));
  static const Style bgRgb130 =
      Style(background: Color256.on(Colors.rgb130, ColorTarget.background));
  static const Style bgRgb131 =
      Style(background: Color256.on(Colors.rgb131, ColorTarget.background));
  static const Style bgRgb132 =
      Style(background: Color256.on(Colors.rgb132, ColorTarget.background));
  static const Style bgRgb133 =
      Style(background: Color256.on(Colors.rgb133, ColorTarget.background));
  static const Style bgRgb134 =
      Style(background: Color256.on(Colors.rgb134, ColorTarget.background));
  static const Style bgRgb135 =
      Style(background: Color256.on(Colors.rgb135, ColorTarget.background));
  static const Style bgRgb140 =
      Style(background: Color256.on(Colors.rgb140, ColorTarget.background));
  static const Style bgRgb141 =
      Style(background: Color256.on(Colors.rgb141, ColorTarget.background));
  static const Style bgRgb142 =
      Style(background: Color256.on(Colors.rgb142, ColorTarget.background));
  static const Style bgRgb143 =
      Style(background: Color256.on(Colors.rgb143, ColorTarget.background));
  static const Style bgRgb144 =
      Style(background: Color256.on(Colors.rgb144, ColorTarget.background));
  static const Style bgRgb145 =
      Style(background: Color256.on(Colors.rgb145, ColorTarget.background));
  static const Style bgRgb150 =
      Style(background: Color256.on(Colors.rgb150, ColorTarget.background));
  static const Style bgRgb151 =
      Style(background: Color256.on(Colors.rgb151, ColorTarget.background));
  static const Style bgRgb152 =
      Style(background: Color256.on(Colors.rgb152, ColorTarget.background));
  static const Style bgRgb153 =
      Style(background: Color256.on(Colors.rgb153, ColorTarget.background));
  static const Style bgRgb154 =
      Style(background: Color256.on(Colors.rgb154, ColorTarget.background));
  static const Style bgRgb155 =
      Style(background: Color256.on(Colors.rgb155, ColorTarget.background));
  static const Style bgRgb200 =
      Style(background: Color256.on(Colors.rgb200, ColorTarget.background));
  static const Style bgRgb201 =
      Style(background: Color256.on(Colors.rgb201, ColorTarget.background));
  static const Style bgRgb202 =
      Style(background: Color256.on(Colors.rgb202, ColorTarget.background));
  static const Style bgRgb203 =
      Style(background: Color256.on(Colors.rgb203, ColorTarget.background));
  static const Style bgRgb204 =
      Style(background: Color256.on(Colors.rgb204, ColorTarget.background));
  static const Style bgRgb205 =
      Style(background: Color256.on(Colors.rgb205, ColorTarget.background));
  static const Style bgRgb210 =
      Style(background: Color256.on(Colors.rgb210, ColorTarget.background));
  static const Style bgRgb211 =
      Style(background: Color256.on(Colors.rgb211, ColorTarget.background));
  static const Style bgRgb212 =
      Style(background: Color256.on(Colors.rgb212, ColorTarget.background));
  static const Style bgRgb213 =
      Style(background: Color256.on(Colors.rgb213, ColorTarget.background));
  static const Style bgRgb214 =
      Style(background: Color256.on(Colors.rgb214, ColorTarget.background));
  static const Style bgRgb215 =
      Style(background: Color256.on(Colors.rgb215, ColorTarget.background));
  static const Style bgRgb220 =
      Style(background: Color256.on(Colors.rgb220, ColorTarget.background));
  static const Style bgRgb221 =
      Style(background: Color256.on(Colors.rgb221, ColorTarget.background));
  static const Style bgRgb222 =
      Style(background: Color256.on(Colors.rgb222, ColorTarget.background));
  static const Style bgRgb223 =
      Style(background: Color256.on(Colors.rgb223, ColorTarget.background));
  static const Style bgRgb224 =
      Style(background: Color256.on(Colors.rgb224, ColorTarget.background));
  static const Style bgRgb225 =
      Style(background: Color256.on(Colors.rgb225, ColorTarget.background));
  static const Style bgRgb230 =
      Style(background: Color256.on(Colors.rgb230, ColorTarget.background));
  static const Style bgRgb231 =
      Style(background: Color256.on(Colors.rgb231, ColorTarget.background));
  static const Style bgRgb232 =
      Style(background: Color256.on(Colors.rgb232, ColorTarget.background));
  static const Style bgRgb233 =
      Style(background: Color256.on(Colors.rgb233, ColorTarget.background));
  static const Style bgRgb234 =
      Style(background: Color256.on(Colors.rgb234, ColorTarget.background));
  static const Style bgRgb235 =
      Style(background: Color256.on(Colors.rgb235, ColorTarget.background));
  static const Style bgRgb240 =
      Style(background: Color256.on(Colors.rgb240, ColorTarget.background));
  static const Style bgRgb241 =
      Style(background: Color256.on(Colors.rgb241, ColorTarget.background));
  static const Style bgRgb242 =
      Style(background: Color256.on(Colors.rgb242, ColorTarget.background));
  static const Style bgRgb243 =
      Style(background: Color256.on(Colors.rgb243, ColorTarget.background));
  static const Style bgRgb244 =
      Style(background: Color256.on(Colors.rgb244, ColorTarget.background));
  static const Style bgRgb245 =
      Style(background: Color256.on(Colors.rgb245, ColorTarget.background));
  static const Style bgRgb250 =
      Style(background: Color256.on(Colors.rgb250, ColorTarget.background));
  static const Style bgRgb251 =
      Style(background: Color256.on(Colors.rgb251, ColorTarget.background));
  static const Style bgRgb252 =
      Style(background: Color256.on(Colors.rgb252, ColorTarget.background));
  static const Style bgRgb253 =
      Style(background: Color256.on(Colors.rgb253, ColorTarget.background));
  static const Style bgRgb254 =
      Style(background: Color256.on(Colors.rgb254, ColorTarget.background));
  static const Style bgRgb255 =
      Style(background: Color256.on(Colors.rgb255, ColorTarget.background));
  static const Style bgRgb300 =
      Style(background: Color256.on(Colors.rgb300, ColorTarget.background));
  static const Style bgRgb301 =
      Style(background: Color256.on(Colors.rgb301, ColorTarget.background));
  static const Style bgRgb302 =
      Style(background: Color256.on(Colors.rgb302, ColorTarget.background));
  static const Style bgRgb303 =
      Style(background: Color256.on(Colors.rgb303, ColorTarget.background));
  static const Style bgRgb304 =
      Style(background: Color256.on(Colors.rgb304, ColorTarget.background));
  static const Style bgRgb305 =
      Style(background: Color256.on(Colors.rgb305, ColorTarget.background));
  static const Style bgRgb310 =
      Style(background: Color256.on(Colors.rgb310, ColorTarget.background));
  static const Style bgRgb311 =
      Style(background: Color256.on(Colors.rgb311, ColorTarget.background));
  static const Style bgRgb312 =
      Style(background: Color256.on(Colors.rgb312, ColorTarget.background));
  static const Style bgRgb313 =
      Style(background: Color256.on(Colors.rgb313, ColorTarget.background));
  static const Style bgRgb314 =
      Style(background: Color256.on(Colors.rgb314, ColorTarget.background));
  static const Style bgRgb315 =
      Style(background: Color256.on(Colors.rgb315, ColorTarget.background));
  static const Style bgRgb320 =
      Style(background: Color256.on(Colors.rgb320, ColorTarget.background));
  static const Style bgRgb321 =
      Style(background: Color256.on(Colors.rgb321, ColorTarget.background));
  static const Style bgRgb322 =
      Style(background: Color256.on(Colors.rgb322, ColorTarget.background));
  static const Style bgRgb323 =
      Style(background: Color256.on(Colors.rgb323, ColorTarget.background));
  static const Style bgRgb324 =
      Style(background: Color256.on(Colors.rgb324, ColorTarget.background));
  static const Style bgRgb325 =
      Style(background: Color256.on(Colors.rgb325, ColorTarget.background));
  static const Style bgRgb330 =
      Style(background: Color256.on(Colors.rgb330, ColorTarget.background));
  static const Style bgRgb331 =
      Style(background: Color256.on(Colors.rgb331, ColorTarget.background));
  static const Style bgRgb332 =
      Style(background: Color256.on(Colors.rgb332, ColorTarget.background));
  static const Style bgRgb333 =
      Style(background: Color256.on(Colors.rgb333, ColorTarget.background));
  static const Style bgRgb334 =
      Style(background: Color256.on(Colors.rgb334, ColorTarget.background));
  static const Style bgRgb335 =
      Style(background: Color256.on(Colors.rgb335, ColorTarget.background));
  static const Style bgRgb340 =
      Style(background: Color256.on(Colors.rgb340, ColorTarget.background));
  static const Style bgRgb341 =
      Style(background: Color256.on(Colors.rgb341, ColorTarget.background));
  static const Style bgRgb342 =
      Style(background: Color256.on(Colors.rgb342, ColorTarget.background));
  static const Style bgRgb343 =
      Style(background: Color256.on(Colors.rgb343, ColorTarget.background));
  static const Style bgRgb344 =
      Style(background: Color256.on(Colors.rgb344, ColorTarget.background));
  static const Style bgRgb345 =
      Style(background: Color256.on(Colors.rgb345, ColorTarget.background));
  static const Style bgRgb350 =
      Style(background: Color256.on(Colors.rgb350, ColorTarget.background));
  static const Style bgRgb351 =
      Style(background: Color256.on(Colors.rgb351, ColorTarget.background));
  static const Style bgRgb352 =
      Style(background: Color256.on(Colors.rgb352, ColorTarget.background));
  static const Style bgRgb353 =
      Style(background: Color256.on(Colors.rgb353, ColorTarget.background));
  static const Style bgRgb354 =
      Style(background: Color256.on(Colors.rgb354, ColorTarget.background));
  static const Style bgRgb355 =
      Style(background: Color256.on(Colors.rgb355, ColorTarget.background));
  static const Style bgRgb400 =
      Style(background: Color256.on(Colors.rgb400, ColorTarget.background));
  static const Style bgRgb401 =
      Style(background: Color256.on(Colors.rgb401, ColorTarget.background));
  static const Style bgRgb402 =
      Style(background: Color256.on(Colors.rgb402, ColorTarget.background));
  static const Style bgRgb403 =
      Style(background: Color256.on(Colors.rgb403, ColorTarget.background));
  static const Style bgRgb404 =
      Style(background: Color256.on(Colors.rgb404, ColorTarget.background));
  static const Style bgRgb405 =
      Style(background: Color256.on(Colors.rgb405, ColorTarget.background));
  static const Style bgRgb410 =
      Style(background: Color256.on(Colors.rgb410, ColorTarget.background));
  static const Style bgRgb411 =
      Style(background: Color256.on(Colors.rgb411, ColorTarget.background));
  static const Style bgRgb412 =
      Style(background: Color256.on(Colors.rgb412, ColorTarget.background));
  static const Style bgRgb413 =
      Style(background: Color256.on(Colors.rgb413, ColorTarget.background));
  static const Style bgRgb414 =
      Style(background: Color256.on(Colors.rgb414, ColorTarget.background));
  static const Style bgRgb415 =
      Style(background: Color256.on(Colors.rgb415, ColorTarget.background));
  static const Style bgRgb420 =
      Style(background: Color256.on(Colors.rgb420, ColorTarget.background));
  static const Style bgRgb421 =
      Style(background: Color256.on(Colors.rgb421, ColorTarget.background));
  static const Style bgRgb422 =
      Style(background: Color256.on(Colors.rgb422, ColorTarget.background));
  static const Style bgRgb423 =
      Style(background: Color256.on(Colors.rgb423, ColorTarget.background));
  static const Style bgRgb424 =
      Style(background: Color256.on(Colors.rgb424, ColorTarget.background));
  static const Style bgRgb425 =
      Style(background: Color256.on(Colors.rgb425, ColorTarget.background));
  static const Style bgRgb430 =
      Style(background: Color256.on(Colors.rgb430, ColorTarget.background));
  static const Style bgRgb431 =
      Style(background: Color256.on(Colors.rgb431, ColorTarget.background));
  static const Style bgRgb432 =
      Style(background: Color256.on(Colors.rgb432, ColorTarget.background));
  static const Style bgRgb433 =
      Style(background: Color256.on(Colors.rgb433, ColorTarget.background));
  static const Style bgRgb434 =
      Style(background: Color256.on(Colors.rgb434, ColorTarget.background));
  static const Style bgRgb435 =
      Style(background: Color256.on(Colors.rgb435, ColorTarget.background));
  static const Style bgRgb440 =
      Style(background: Color256.on(Colors.rgb440, ColorTarget.background));
  static const Style bgRgb441 =
      Style(background: Color256.on(Colors.rgb441, ColorTarget.background));
  static const Style bgRgb442 =
      Style(background: Color256.on(Colors.rgb442, ColorTarget.background));
  static const Style bgRgb443 =
      Style(background: Color256.on(Colors.rgb443, ColorTarget.background));
  static const Style bgRgb444 =
      Style(background: Color256.on(Colors.rgb444, ColorTarget.background));
  static const Style bgRgb445 =
      Style(background: Color256.on(Colors.rgb445, ColorTarget.background));
  static const Style bgRgb450 =
      Style(background: Color256.on(Colors.rgb450, ColorTarget.background));
  static const Style bgRgb451 =
      Style(background: Color256.on(Colors.rgb451, ColorTarget.background));
  static const Style bgRgb452 =
      Style(background: Color256.on(Colors.rgb452, ColorTarget.background));
  static const Style bgRgb453 =
      Style(background: Color256.on(Colors.rgb453, ColorTarget.background));
  static const Style bgRgb454 =
      Style(background: Color256.on(Colors.rgb454, ColorTarget.background));
  static const Style bgRgb455 =
      Style(background: Color256.on(Colors.rgb455, ColorTarget.background));
  static const Style bgRgb500 =
      Style(background: Color256.on(Colors.rgb500, ColorTarget.background));
  static const Style bgRgb501 =
      Style(background: Color256.on(Colors.rgb501, ColorTarget.background));
  static const Style bgRgb502 =
      Style(background: Color256.on(Colors.rgb502, ColorTarget.background));
  static const Style bgRgb503 =
      Style(background: Color256.on(Colors.rgb503, ColorTarget.background));
  static const Style bgRgb504 =
      Style(background: Color256.on(Colors.rgb504, ColorTarget.background));
  static const Style bgRgb505 =
      Style(background: Color256.on(Colors.rgb505, ColorTarget.background));
  static const Style bgRgb510 =
      Style(background: Color256.on(Colors.rgb510, ColorTarget.background));
  static const Style bgRgb511 =
      Style(background: Color256.on(Colors.rgb511, ColorTarget.background));
  static const Style bgRgb512 =
      Style(background: Color256.on(Colors.rgb512, ColorTarget.background));
  static const Style bgRgb513 =
      Style(background: Color256.on(Colors.rgb513, ColorTarget.background));
  static const Style bgRgb514 =
      Style(background: Color256.on(Colors.rgb514, ColorTarget.background));
  static const Style bgRgb515 =
      Style(background: Color256.on(Colors.rgb515, ColorTarget.background));
  static const Style bgRgb520 =
      Style(background: Color256.on(Colors.rgb520, ColorTarget.background));
  static const Style bgRgb521 =
      Style(background: Color256.on(Colors.rgb521, ColorTarget.background));
  static const Style bgRgb522 =
      Style(background: Color256.on(Colors.rgb522, ColorTarget.background));
  static const Style bgRgb523 =
      Style(background: Color256.on(Colors.rgb523, ColorTarget.background));
  static const Style bgRgb524 =
      Style(background: Color256.on(Colors.rgb524, ColorTarget.background));
  static const Style bgRgb525 =
      Style(background: Color256.on(Colors.rgb525, ColorTarget.background));
  static const Style bgRgb530 =
      Style(background: Color256.on(Colors.rgb530, ColorTarget.background));
  static const Style bgRgb531 =
      Style(background: Color256.on(Colors.rgb531, ColorTarget.background));
  static const Style bgRgb532 =
      Style(background: Color256.on(Colors.rgb532, ColorTarget.background));
  static const Style bgRgb533 =
      Style(background: Color256.on(Colors.rgb533, ColorTarget.background));
  static const Style bgRgb534 =
      Style(background: Color256.on(Colors.rgb534, ColorTarget.background));
  static const Style bgRgb535 =
      Style(background: Color256.on(Colors.rgb535, ColorTarget.background));
  static const Style bgRgb540 =
      Style(background: Color256.on(Colors.rgb540, ColorTarget.background));
  static const Style bgRgb541 =
      Style(background: Color256.on(Colors.rgb541, ColorTarget.background));
  static const Style bgRgb542 =
      Style(background: Color256.on(Colors.rgb542, ColorTarget.background));
  static const Style bgRgb543 =
      Style(background: Color256.on(Colors.rgb543, ColorTarget.background));
  static const Style bgRgb544 =
      Style(background: Color256.on(Colors.rgb544, ColorTarget.background));
  static const Style bgRgb545 =
      Style(background: Color256.on(Colors.rgb545, ColorTarget.background));
  static const Style bgRgb550 =
      Style(background: Color256.on(Colors.rgb550, ColorTarget.background));
  static const Style bgRgb551 =
      Style(background: Color256.on(Colors.rgb551, ColorTarget.background));
  static const Style bgRgb552 =
      Style(background: Color256.on(Colors.rgb552, ColorTarget.background));
  static const Style bgRgb553 =
      Style(background: Color256.on(Colors.rgb553, ColorTarget.background));
  static const Style bgRgb554 =
      Style(background: Color256.on(Colors.rgb554, ColorTarget.background));
  static const Style bgRgb555 =
      Style(background: Color256.on(Colors.rgb555, ColorTarget.background));
  static const Style bgGray0 =
      Style(background: Color256.on(Colors.gray0, ColorTarget.background));
  static const Style bgGray1 =
      Style(background: Color256.on(Colors.gray1, ColorTarget.background));
  static const Style bgGray2 =
      Style(background: Color256.on(Colors.gray2, ColorTarget.background));
  static const Style bgGray3 =
      Style(background: Color256.on(Colors.gray3, ColorTarget.background));
  static const Style bgGray4 =
      Style(background: Color256.on(Colors.gray4, ColorTarget.background));
  static const Style bgGray5 =
      Style(background: Color256.on(Colors.gray5, ColorTarget.background));
  static const Style bgGray6 =
      Style(background: Color256.on(Colors.gray6, ColorTarget.background));
  static const Style bgGray7 =
      Style(background: Color256.on(Colors.gray7, ColorTarget.background));
  static const Style bgGray8 =
      Style(background: Color256.on(Colors.gray8, ColorTarget.background));
  static const Style bgGray9 =
      Style(background: Color256.on(Colors.gray9, ColorTarget.background));
  static const Style bgGray10 =
      Style(background: Color256.on(Colors.gray10, ColorTarget.background));
  static const Style bgGray11 =
      Style(background: Color256.on(Colors.gray11, ColorTarget.background));
  static const Style bgGray12 =
      Style(background: Color256.on(Colors.gray12, ColorTarget.background));
  static const Style bgGray13 =
      Style(background: Color256.on(Colors.gray13, ColorTarget.background));
  static const Style bgGray14 =
      Style(background: Color256.on(Colors.gray14, ColorTarget.background));
  static const Style bgGray15 =
      Style(background: Color256.on(Colors.gray15, ColorTarget.background));
  static const Style bgGray16 =
      Style(background: Color256.on(Colors.gray16, ColorTarget.background));
  static const Style bgGray17 =
      Style(background: Color256.on(Colors.gray17, ColorTarget.background));
  static const Style bgGray18 =
      Style(background: Color256.on(Colors.gray18, ColorTarget.background));
  static const Style bgGray19 =
      Style(background: Color256.on(Colors.gray19, ColorTarget.background));
  static const Style bgGray20 =
      Style(background: Color256.on(Colors.gray20, ColorTarget.background));
  static const Style bgGray21 =
      Style(background: Color256.on(Colors.gray21, ColorTarget.background));
  static const Style bgGray22 =
      Style(background: Color256.on(Colors.gray22, ColorTarget.background));
  static const Style bgGray23 =
      Style(background: Color256.on(Colors.gray23, ColorTarget.background));

  static const Style underlineBlack =
      Style(underlineColor: Color256.on(Colors.black, ColorTarget.underline));
  static const Style underlineRed =
      Style(underlineColor: Color256.on(Colors.red, ColorTarget.underline));
  static const Style underlineGreen =
      Style(underlineColor: Color256.on(Colors.green, ColorTarget.underline));
  static const Style underlineYellow =
      Style(underlineColor: Color256.on(Colors.yellow, ColorTarget.underline));
  static const Style underlineBlue =
      Style(underlineColor: Color256.on(Colors.blue, ColorTarget.underline));
  static const Style underlineMagenta =
      Style(underlineColor: Color256.on(Colors.magenta, ColorTarget.underline));
  static const Style underlineCyan =
      Style(underlineColor: Color256.on(Colors.cyan, ColorTarget.underline));
  static const Style underlineWhite =
      Style(underlineColor: Color256.on(Colors.white, ColorTarget.underline));
  static const Style underlineHighBlack = Style(
    underlineColor: Color256.on(Colors.highBlack, ColorTarget.underline),
  );
  static const Style underlineHighRed =
      Style(underlineColor: Color256.on(Colors.highRed, ColorTarget.underline));
  static const Style underlineHighGreen = Style(
    underlineColor: Color256.on(Colors.highGreen, ColorTarget.underline),
  );
  static const Style underlineHighYellow = Style(
    underlineColor: Color256.on(Colors.highYellow, ColorTarget.underline),
  );
  static const Style underlineHighBlue = Style(
    underlineColor: Color256.on(Colors.highBlue, ColorTarget.underline),
  );
  static const Style underlineHighMagenta = Style(
    underlineColor: Color256.on(Colors.highMagenta, ColorTarget.underline),
  );
  static const Style underlineHighCyan = Style(
    underlineColor: Color256.on(Colors.highCyan, ColorTarget.underline),
  );
  static const Style underlineHighWhite = Style(
    underlineColor: Color256.on(Colors.highWhite, ColorTarget.underline),
  );
  static const Style underlineRgb000 =
      Style(underlineColor: Color256.on(Colors.rgb000, ColorTarget.underline));
  static const Style underlineRgb001 =
      Style(underlineColor: Color256.on(Colors.rgb001, ColorTarget.underline));
  static const Style underlineRgb002 =
      Style(underlineColor: Color256.on(Colors.rgb002, ColorTarget.underline));
  static const Style underlineRgb003 =
      Style(underlineColor: Color256.on(Colors.rgb003, ColorTarget.underline));
  static const Style underlineRgb004 =
      Style(underlineColor: Color256.on(Colors.rgb004, ColorTarget.underline));
  static const Style underlineRgb005 =
      Style(underlineColor: Color256.on(Colors.rgb005, ColorTarget.underline));
  static const Style underlineRgb010 =
      Style(underlineColor: Color256.on(Colors.rgb010, ColorTarget.underline));
  static const Style underlineRgb011 =
      Style(underlineColor: Color256.on(Colors.rgb011, ColorTarget.underline));
  static const Style underlineRgb012 =
      Style(underlineColor: Color256.on(Colors.rgb012, ColorTarget.underline));
  static const Style underlineRgb013 =
      Style(underlineColor: Color256.on(Colors.rgb013, ColorTarget.underline));
  static const Style underlineRgb014 =
      Style(underlineColor: Color256.on(Colors.rgb014, ColorTarget.underline));
  static const Style underlineRgb015 =
      Style(underlineColor: Color256.on(Colors.rgb015, ColorTarget.underline));
  static const Style underlineRgb020 =
      Style(underlineColor: Color256.on(Colors.rgb020, ColorTarget.underline));
  static const Style underlineRgb021 =
      Style(underlineColor: Color256.on(Colors.rgb021, ColorTarget.underline));
  static const Style underlineRgb022 =
      Style(underlineColor: Color256.on(Colors.rgb022, ColorTarget.underline));
  static const Style underlineRgb023 =
      Style(underlineColor: Color256.on(Colors.rgb023, ColorTarget.underline));
  static const Style underlineRgb024 =
      Style(underlineColor: Color256.on(Colors.rgb024, ColorTarget.underline));
  static const Style underlineRgb025 =
      Style(underlineColor: Color256.on(Colors.rgb025, ColorTarget.underline));
  static const Style underlineRgb030 =
      Style(underlineColor: Color256.on(Colors.rgb030, ColorTarget.underline));
  static const Style underlineRgb031 =
      Style(underlineColor: Color256.on(Colors.rgb031, ColorTarget.underline));
  static const Style underlineRgb032 =
      Style(underlineColor: Color256.on(Colors.rgb032, ColorTarget.underline));
  static const Style underlineRgb033 =
      Style(underlineColor: Color256.on(Colors.rgb033, ColorTarget.underline));
  static const Style underlineRgb034 =
      Style(underlineColor: Color256.on(Colors.rgb034, ColorTarget.underline));
  static const Style underlineRgb035 =
      Style(underlineColor: Color256.on(Colors.rgb035, ColorTarget.underline));
  static const Style underlineRgb040 =
      Style(underlineColor: Color256.on(Colors.rgb040, ColorTarget.underline));
  static const Style underlineRgb041 =
      Style(underlineColor: Color256.on(Colors.rgb041, ColorTarget.underline));
  static const Style underlineRgb042 =
      Style(underlineColor: Color256.on(Colors.rgb042, ColorTarget.underline));
  static const Style underlineRgb043 =
      Style(underlineColor: Color256.on(Colors.rgb043, ColorTarget.underline));
  static const Style underlineRgb044 =
      Style(underlineColor: Color256.on(Colors.rgb044, ColorTarget.underline));
  static const Style underlineRgb045 =
      Style(underlineColor: Color256.on(Colors.rgb045, ColorTarget.underline));
  static const Style underlineRgb050 =
      Style(underlineColor: Color256.on(Colors.rgb050, ColorTarget.underline));
  static const Style underlineRgb051 =
      Style(underlineColor: Color256.on(Colors.rgb051, ColorTarget.underline));
  static const Style underlineRgb052 =
      Style(underlineColor: Color256.on(Colors.rgb052, ColorTarget.underline));
  static const Style underlineRgb053 =
      Style(underlineColor: Color256.on(Colors.rgb053, ColorTarget.underline));
  static const Style underlineRgb054 =
      Style(underlineColor: Color256.on(Colors.rgb054, ColorTarget.underline));
  static const Style underlineRgb055 =
      Style(underlineColor: Color256.on(Colors.rgb055, ColorTarget.underline));
  static const Style underlineRgb100 =
      Style(underlineColor: Color256.on(Colors.rgb100, ColorTarget.underline));
  static const Style underlineRgb101 =
      Style(underlineColor: Color256.on(Colors.rgb101, ColorTarget.underline));
  static const Style underlineRgb102 =
      Style(underlineColor: Color256.on(Colors.rgb102, ColorTarget.underline));
  static const Style underlineRgb103 =
      Style(underlineColor: Color256.on(Colors.rgb103, ColorTarget.underline));
  static const Style underlineRgb104 =
      Style(underlineColor: Color256.on(Colors.rgb104, ColorTarget.underline));
  static const Style underlineRgb105 =
      Style(underlineColor: Color256.on(Colors.rgb105, ColorTarget.underline));
  static const Style underlineRgb110 =
      Style(underlineColor: Color256.on(Colors.rgb110, ColorTarget.underline));
  static const Style underlineRgb111 =
      Style(underlineColor: Color256.on(Colors.rgb111, ColorTarget.underline));
  static const Style underlineRgb112 =
      Style(underlineColor: Color256.on(Colors.rgb112, ColorTarget.underline));
  static const Style underlineRgb113 =
      Style(underlineColor: Color256.on(Colors.rgb113, ColorTarget.underline));
  static const Style underlineRgb114 =
      Style(underlineColor: Color256.on(Colors.rgb114, ColorTarget.underline));
  static const Style underlineRgb115 =
      Style(underlineColor: Color256.on(Colors.rgb115, ColorTarget.underline));
  static const Style underlineRgb120 =
      Style(underlineColor: Color256.on(Colors.rgb120, ColorTarget.underline));
  static const Style underlineRgb121 =
      Style(underlineColor: Color256.on(Colors.rgb121, ColorTarget.underline));
  static const Style underlineRgb122 =
      Style(underlineColor: Color256.on(Colors.rgb122, ColorTarget.underline));
  static const Style underlineRgb123 =
      Style(underlineColor: Color256.on(Colors.rgb123, ColorTarget.underline));
  static const Style underlineRgb124 =
      Style(underlineColor: Color256.on(Colors.rgb124, ColorTarget.underline));
  static const Style underlineRgb125 =
      Style(underlineColor: Color256.on(Colors.rgb125, ColorTarget.underline));
  static const Style underlineRgb130 =
      Style(underlineColor: Color256.on(Colors.rgb130, ColorTarget.underline));
  static const Style underlineRgb131 =
      Style(underlineColor: Color256.on(Colors.rgb131, ColorTarget.underline));
  static const Style underlineRgb132 =
      Style(underlineColor: Color256.on(Colors.rgb132, ColorTarget.underline));
  static const Style underlineRgb133 =
      Style(underlineColor: Color256.on(Colors.rgb133, ColorTarget.underline));
  static const Style underlineRgb134 =
      Style(underlineColor: Color256.on(Colors.rgb134, ColorTarget.underline));
  static const Style underlineRgb135 =
      Style(underlineColor: Color256.on(Colors.rgb135, ColorTarget.underline));
  static const Style underlineRgb140 =
      Style(underlineColor: Color256.on(Colors.rgb140, ColorTarget.underline));
  static const Style underlineRgb141 =
      Style(underlineColor: Color256.on(Colors.rgb141, ColorTarget.underline));
  static const Style underlineRgb142 =
      Style(underlineColor: Color256.on(Colors.rgb142, ColorTarget.underline));
  static const Style underlineRgb143 =
      Style(underlineColor: Color256.on(Colors.rgb143, ColorTarget.underline));
  static const Style underlineRgb144 =
      Style(underlineColor: Color256.on(Colors.rgb144, ColorTarget.underline));
  static const Style underlineRgb145 =
      Style(underlineColor: Color256.on(Colors.rgb145, ColorTarget.underline));
  static const Style underlineRgb150 =
      Style(underlineColor: Color256.on(Colors.rgb150, ColorTarget.underline));
  static const Style underlineRgb151 =
      Style(underlineColor: Color256.on(Colors.rgb151, ColorTarget.underline));
  static const Style underlineRgb152 =
      Style(underlineColor: Color256.on(Colors.rgb152, ColorTarget.underline));
  static const Style underlineRgb153 =
      Style(underlineColor: Color256.on(Colors.rgb153, ColorTarget.underline));
  static const Style underlineRgb154 =
      Style(underlineColor: Color256.on(Colors.rgb154, ColorTarget.underline));
  static const Style underlineRgb155 =
      Style(underlineColor: Color256.on(Colors.rgb155, ColorTarget.underline));
  static const Style underlineRgb200 =
      Style(underlineColor: Color256.on(Colors.rgb200, ColorTarget.underline));
  static const Style underlineRgb201 =
      Style(underlineColor: Color256.on(Colors.rgb201, ColorTarget.underline));
  static const Style underlineRgb202 =
      Style(underlineColor: Color256.on(Colors.rgb202, ColorTarget.underline));
  static const Style underlineRgb203 =
      Style(underlineColor: Color256.on(Colors.rgb203, ColorTarget.underline));
  static const Style underlineRgb204 =
      Style(underlineColor: Color256.on(Colors.rgb204, ColorTarget.underline));
  static const Style underlineRgb205 =
      Style(underlineColor: Color256.on(Colors.rgb205, ColorTarget.underline));
  static const Style underlineRgb210 =
      Style(underlineColor: Color256.on(Colors.rgb210, ColorTarget.underline));
  static const Style underlineRgb211 =
      Style(underlineColor: Color256.on(Colors.rgb211, ColorTarget.underline));
  static const Style underlineRgb212 =
      Style(underlineColor: Color256.on(Colors.rgb212, ColorTarget.underline));
  static const Style underlineRgb213 =
      Style(underlineColor: Color256.on(Colors.rgb213, ColorTarget.underline));
  static const Style underlineRgb214 =
      Style(underlineColor: Color256.on(Colors.rgb214, ColorTarget.underline));
  static const Style underlineRgb215 =
      Style(underlineColor: Color256.on(Colors.rgb215, ColorTarget.underline));
  static const Style underlineRgb220 =
      Style(underlineColor: Color256.on(Colors.rgb220, ColorTarget.underline));
  static const Style underlineRgb221 =
      Style(underlineColor: Color256.on(Colors.rgb221, ColorTarget.underline));
  static const Style underlineRgb222 =
      Style(underlineColor: Color256.on(Colors.rgb222, ColorTarget.underline));
  static const Style underlineRgb223 =
      Style(underlineColor: Color256.on(Colors.rgb223, ColorTarget.underline));
  static const Style underlineRgb224 =
      Style(underlineColor: Color256.on(Colors.rgb224, ColorTarget.underline));
  static const Style underlineRgb225 =
      Style(underlineColor: Color256.on(Colors.rgb225, ColorTarget.underline));
  static const Style underlineRgb230 =
      Style(underlineColor: Color256.on(Colors.rgb230, ColorTarget.underline));
  static const Style underlineRgb231 =
      Style(underlineColor: Color256.on(Colors.rgb231, ColorTarget.underline));
  static const Style underlineRgb232 =
      Style(underlineColor: Color256.on(Colors.rgb232, ColorTarget.underline));
  static const Style underlineRgb233 =
      Style(underlineColor: Color256.on(Colors.rgb233, ColorTarget.underline));
  static const Style underlineRgb234 =
      Style(underlineColor: Color256.on(Colors.rgb234, ColorTarget.underline));
  static const Style underlineRgb235 =
      Style(underlineColor: Color256.on(Colors.rgb235, ColorTarget.underline));
  static const Style underlineRgb240 =
      Style(underlineColor: Color256.on(Colors.rgb240, ColorTarget.underline));
  static const Style underlineRgb241 =
      Style(underlineColor: Color256.on(Colors.rgb241, ColorTarget.underline));
  static const Style underlineRgb242 =
      Style(underlineColor: Color256.on(Colors.rgb242, ColorTarget.underline));
  static const Style underlineRgb243 =
      Style(underlineColor: Color256.on(Colors.rgb243, ColorTarget.underline));
  static const Style underlineRgb244 =
      Style(underlineColor: Color256.on(Colors.rgb244, ColorTarget.underline));
  static const Style underlineRgb245 =
      Style(underlineColor: Color256.on(Colors.rgb245, ColorTarget.underline));
  static const Style underlineRgb250 =
      Style(underlineColor: Color256.on(Colors.rgb250, ColorTarget.underline));
  static const Style underlineRgb251 =
      Style(underlineColor: Color256.on(Colors.rgb251, ColorTarget.underline));
  static const Style underlineRgb252 =
      Style(underlineColor: Color256.on(Colors.rgb252, ColorTarget.underline));
  static const Style underlineRgb253 =
      Style(underlineColor: Color256.on(Colors.rgb253, ColorTarget.underline));
  static const Style underlineRgb254 =
      Style(underlineColor: Color256.on(Colors.rgb254, ColorTarget.underline));
  static const Style underlineRgb255 =
      Style(underlineColor: Color256.on(Colors.rgb255, ColorTarget.underline));
  static const Style underlineRgb300 =
      Style(underlineColor: Color256.on(Colors.rgb300, ColorTarget.underline));
  static const Style underlineRgb301 =
      Style(underlineColor: Color256.on(Colors.rgb301, ColorTarget.underline));
  static const Style underlineRgb302 =
      Style(underlineColor: Color256.on(Colors.rgb302, ColorTarget.underline));
  static const Style underlineRgb303 =
      Style(underlineColor: Color256.on(Colors.rgb303, ColorTarget.underline));
  static const Style underlineRgb304 =
      Style(underlineColor: Color256.on(Colors.rgb304, ColorTarget.underline));
  static const Style underlineRgb305 =
      Style(underlineColor: Color256.on(Colors.rgb305, ColorTarget.underline));
  static const Style underlineRgb310 =
      Style(underlineColor: Color256.on(Colors.rgb310, ColorTarget.underline));
  static const Style underlineRgb311 =
      Style(underlineColor: Color256.on(Colors.rgb311, ColorTarget.underline));
  static const Style underlineRgb312 =
      Style(underlineColor: Color256.on(Colors.rgb312, ColorTarget.underline));
  static const Style underlineRgb313 =
      Style(underlineColor: Color256.on(Colors.rgb313, ColorTarget.underline));
  static const Style underlineRgb314 =
      Style(underlineColor: Color256.on(Colors.rgb314, ColorTarget.underline));
  static const Style underlineRgb315 =
      Style(underlineColor: Color256.on(Colors.rgb315, ColorTarget.underline));
  static const Style underlineRgb320 =
      Style(underlineColor: Color256.on(Colors.rgb320, ColorTarget.underline));
  static const Style underlineRgb321 =
      Style(underlineColor: Color256.on(Colors.rgb321, ColorTarget.underline));
  static const Style underlineRgb322 =
      Style(underlineColor: Color256.on(Colors.rgb322, ColorTarget.underline));
  static const Style underlineRgb323 =
      Style(underlineColor: Color256.on(Colors.rgb323, ColorTarget.underline));
  static const Style underlineRgb324 =
      Style(underlineColor: Color256.on(Colors.rgb324, ColorTarget.underline));
  static const Style underlineRgb325 =
      Style(underlineColor: Color256.on(Colors.rgb325, ColorTarget.underline));
  static const Style underlineRgb330 =
      Style(underlineColor: Color256.on(Colors.rgb330, ColorTarget.underline));
  static const Style underlineRgb331 =
      Style(underlineColor: Color256.on(Colors.rgb331, ColorTarget.underline));
  static const Style underlineRgb332 =
      Style(underlineColor: Color256.on(Colors.rgb332, ColorTarget.underline));
  static const Style underlineRgb333 =
      Style(underlineColor: Color256.on(Colors.rgb333, ColorTarget.underline));
  static const Style underlineRgb334 =
      Style(underlineColor: Color256.on(Colors.rgb334, ColorTarget.underline));
  static const Style underlineRgb335 =
      Style(underlineColor: Color256.on(Colors.rgb335, ColorTarget.underline));
  static const Style underlineRgb340 =
      Style(underlineColor: Color256.on(Colors.rgb340, ColorTarget.underline));
  static const Style underlineRgb341 =
      Style(underlineColor: Color256.on(Colors.rgb341, ColorTarget.underline));
  static const Style underlineRgb342 =
      Style(underlineColor: Color256.on(Colors.rgb342, ColorTarget.underline));
  static const Style underlineRgb343 =
      Style(underlineColor: Color256.on(Colors.rgb343, ColorTarget.underline));
  static const Style underlineRgb344 =
      Style(underlineColor: Color256.on(Colors.rgb344, ColorTarget.underline));
  static const Style underlineRgb345 =
      Style(underlineColor: Color256.on(Colors.rgb345, ColorTarget.underline));
  static const Style underlineRgb350 =
      Style(underlineColor: Color256.on(Colors.rgb350, ColorTarget.underline));
  static const Style underlineRgb351 =
      Style(underlineColor: Color256.on(Colors.rgb351, ColorTarget.underline));
  static const Style underlineRgb352 =
      Style(underlineColor: Color256.on(Colors.rgb352, ColorTarget.underline));
  static const Style underlineRgb353 =
      Style(underlineColor: Color256.on(Colors.rgb353, ColorTarget.underline));
  static const Style underlineRgb354 =
      Style(underlineColor: Color256.on(Colors.rgb354, ColorTarget.underline));
  static const Style underlineRgb355 =
      Style(underlineColor: Color256.on(Colors.rgb355, ColorTarget.underline));
  static const Style underlineRgb400 =
      Style(underlineColor: Color256.on(Colors.rgb400, ColorTarget.underline));
  static const Style underlineRgb401 =
      Style(underlineColor: Color256.on(Colors.rgb401, ColorTarget.underline));
  static const Style underlineRgb402 =
      Style(underlineColor: Color256.on(Colors.rgb402, ColorTarget.underline));
  static const Style underlineRgb403 =
      Style(underlineColor: Color256.on(Colors.rgb403, ColorTarget.underline));
  static const Style underlineRgb404 =
      Style(underlineColor: Color256.on(Colors.rgb404, ColorTarget.underline));
  static const Style underlineRgb405 =
      Style(underlineColor: Color256.on(Colors.rgb405, ColorTarget.underline));
  static const Style underlineRgb410 =
      Style(underlineColor: Color256.on(Colors.rgb410, ColorTarget.underline));
  static const Style underlineRgb411 =
      Style(underlineColor: Color256.on(Colors.rgb411, ColorTarget.underline));
  static const Style underlineRgb412 =
      Style(underlineColor: Color256.on(Colors.rgb412, ColorTarget.underline));
  static const Style underlineRgb413 =
      Style(underlineColor: Color256.on(Colors.rgb413, ColorTarget.underline));
  static const Style underlineRgb414 =
      Style(underlineColor: Color256.on(Colors.rgb414, ColorTarget.underline));
  static const Style underlineRgb415 =
      Style(underlineColor: Color256.on(Colors.rgb415, ColorTarget.underline));
  static const Style underlineRgb420 =
      Style(underlineColor: Color256.on(Colors.rgb420, ColorTarget.underline));
  static const Style underlineRgb421 =
      Style(underlineColor: Color256.on(Colors.rgb421, ColorTarget.underline));
  static const Style underlineRgb422 =
      Style(underlineColor: Color256.on(Colors.rgb422, ColorTarget.underline));
  static const Style underlineRgb423 =
      Style(underlineColor: Color256.on(Colors.rgb423, ColorTarget.underline));
  static const Style underlineRgb424 =
      Style(underlineColor: Color256.on(Colors.rgb424, ColorTarget.underline));
  static const Style underlineRgb425 =
      Style(underlineColor: Color256.on(Colors.rgb425, ColorTarget.underline));
  static const Style underlineRgb430 =
      Style(underlineColor: Color256.on(Colors.rgb430, ColorTarget.underline));
  static const Style underlineRgb431 =
      Style(underlineColor: Color256.on(Colors.rgb431, ColorTarget.underline));
  static const Style underlineRgb432 =
      Style(underlineColor: Color256.on(Colors.rgb432, ColorTarget.underline));
  static const Style underlineRgb433 =
      Style(underlineColor: Color256.on(Colors.rgb433, ColorTarget.underline));
  static const Style underlineRgb434 =
      Style(underlineColor: Color256.on(Colors.rgb434, ColorTarget.underline));
  static const Style underlineRgb435 =
      Style(underlineColor: Color256.on(Colors.rgb435, ColorTarget.underline));
  static const Style underlineRgb440 =
      Style(underlineColor: Color256.on(Colors.rgb440, ColorTarget.underline));
  static const Style underlineRgb441 =
      Style(underlineColor: Color256.on(Colors.rgb441, ColorTarget.underline));
  static const Style underlineRgb442 =
      Style(underlineColor: Color256.on(Colors.rgb442, ColorTarget.underline));
  static const Style underlineRgb443 =
      Style(underlineColor: Color256.on(Colors.rgb443, ColorTarget.underline));
  static const Style underlineRgb444 =
      Style(underlineColor: Color256.on(Colors.rgb444, ColorTarget.underline));
  static const Style underlineRgb445 =
      Style(underlineColor: Color256.on(Colors.rgb445, ColorTarget.underline));
  static const Style underlineRgb450 =
      Style(underlineColor: Color256.on(Colors.rgb450, ColorTarget.underline));
  static const Style underlineRgb451 =
      Style(underlineColor: Color256.on(Colors.rgb451, ColorTarget.underline));
  static const Style underlineRgb452 =
      Style(underlineColor: Color256.on(Colors.rgb452, ColorTarget.underline));
  static const Style underlineRgb453 =
      Style(underlineColor: Color256.on(Colors.rgb453, ColorTarget.underline));
  static const Style underlineRgb454 =
      Style(underlineColor: Color256.on(Colors.rgb454, ColorTarget.underline));
  static const Style underlineRgb455 =
      Style(underlineColor: Color256.on(Colors.rgb455, ColorTarget.underline));
  static const Style underlineRgb500 =
      Style(underlineColor: Color256.on(Colors.rgb500, ColorTarget.underline));
  static const Style underlineRgb501 =
      Style(underlineColor: Color256.on(Colors.rgb501, ColorTarget.underline));
  static const Style underlineRgb502 =
      Style(underlineColor: Color256.on(Colors.rgb502, ColorTarget.underline));
  static const Style underlineRgb503 =
      Style(underlineColor: Color256.on(Colors.rgb503, ColorTarget.underline));
  static const Style underlineRgb504 =
      Style(underlineColor: Color256.on(Colors.rgb504, ColorTarget.underline));
  static const Style underlineRgb505 =
      Style(underlineColor: Color256.on(Colors.rgb505, ColorTarget.underline));
  static const Style underlineRgb510 =
      Style(underlineColor: Color256.on(Colors.rgb510, ColorTarget.underline));
  static const Style underlineRgb511 =
      Style(underlineColor: Color256.on(Colors.rgb511, ColorTarget.underline));
  static const Style underlineRgb512 =
      Style(underlineColor: Color256.on(Colors.rgb512, ColorTarget.underline));
  static const Style underlineRgb513 =
      Style(underlineColor: Color256.on(Colors.rgb513, ColorTarget.underline));
  static const Style underlineRgb514 =
      Style(underlineColor: Color256.on(Colors.rgb514, ColorTarget.underline));
  static const Style underlineRgb515 =
      Style(underlineColor: Color256.on(Colors.rgb515, ColorTarget.underline));
  static const Style underlineRgb520 =
      Style(underlineColor: Color256.on(Colors.rgb520, ColorTarget.underline));
  static const Style underlineRgb521 =
      Style(underlineColor: Color256.on(Colors.rgb521, ColorTarget.underline));
  static const Style underlineRgb522 =
      Style(underlineColor: Color256.on(Colors.rgb522, ColorTarget.underline));
  static const Style underlineRgb523 =
      Style(underlineColor: Color256.on(Colors.rgb523, ColorTarget.underline));
  static const Style underlineRgb524 =
      Style(underlineColor: Color256.on(Colors.rgb524, ColorTarget.underline));
  static const Style underlineRgb525 =
      Style(underlineColor: Color256.on(Colors.rgb525, ColorTarget.underline));
  static const Style underlineRgb530 =
      Style(underlineColor: Color256.on(Colors.rgb530, ColorTarget.underline));
  static const Style underlineRgb531 =
      Style(underlineColor: Color256.on(Colors.rgb531, ColorTarget.underline));
  static const Style underlineRgb532 =
      Style(underlineColor: Color256.on(Colors.rgb532, ColorTarget.underline));
  static const Style underlineRgb533 =
      Style(underlineColor: Color256.on(Colors.rgb533, ColorTarget.underline));
  static const Style underlineRgb534 =
      Style(underlineColor: Color256.on(Colors.rgb534, ColorTarget.underline));
  static const Style underlineRgb535 =
      Style(underlineColor: Color256.on(Colors.rgb535, ColorTarget.underline));
  static const Style underlineRgb540 =
      Style(underlineColor: Color256.on(Colors.rgb540, ColorTarget.underline));
  static const Style underlineRgb541 =
      Style(underlineColor: Color256.on(Colors.rgb541, ColorTarget.underline));
  static const Style underlineRgb542 =
      Style(underlineColor: Color256.on(Colors.rgb542, ColorTarget.underline));
  static const Style underlineRgb543 =
      Style(underlineColor: Color256.on(Colors.rgb543, ColorTarget.underline));
  static const Style underlineRgb544 =
      Style(underlineColor: Color256.on(Colors.rgb544, ColorTarget.underline));
  static const Style underlineRgb545 =
      Style(underlineColor: Color256.on(Colors.rgb545, ColorTarget.underline));
  static const Style underlineRgb550 =
      Style(underlineColor: Color256.on(Colors.rgb550, ColorTarget.underline));
  static const Style underlineRgb551 =
      Style(underlineColor: Color256.on(Colors.rgb551, ColorTarget.underline));
  static const Style underlineRgb552 =
      Style(underlineColor: Color256.on(Colors.rgb552, ColorTarget.underline));
  static const Style underlineRgb553 =
      Style(underlineColor: Color256.on(Colors.rgb553, ColorTarget.underline));
  static const Style underlineRgb554 =
      Style(underlineColor: Color256.on(Colors.rgb554, ColorTarget.underline));
  static const Style underlineRgb555 =
      Style(underlineColor: Color256.on(Colors.rgb555, ColorTarget.underline));
  static const Style underlineGray0 =
      Style(underlineColor: Color256.on(Colors.gray0, ColorTarget.underline));
  static const Style underlineGray1 =
      Style(underlineColor: Color256.on(Colors.gray1, ColorTarget.underline));
  static const Style underlineGray2 =
      Style(underlineColor: Color256.on(Colors.gray2, ColorTarget.underline));
  static const Style underlineGray3 =
      Style(underlineColor: Color256.on(Colors.gray3, ColorTarget.underline));
  static const Style underlineGray4 =
      Style(underlineColor: Color256.on(Colors.gray4, ColorTarget.underline));
  static const Style underlineGray5 =
      Style(underlineColor: Color256.on(Colors.gray5, ColorTarget.underline));
  static const Style underlineGray6 =
      Style(underlineColor: Color256.on(Colors.gray6, ColorTarget.underline));
  static const Style underlineGray7 =
      Style(underlineColor: Color256.on(Colors.gray7, ColorTarget.underline));
  static const Style underlineGray8 =
      Style(underlineColor: Color256.on(Colors.gray8, ColorTarget.underline));
  static const Style underlineGray9 =
      Style(underlineColor: Color256.on(Colors.gray9, ColorTarget.underline));
  static const Style underlineGray10 =
      Style(underlineColor: Color256.on(Colors.gray10, ColorTarget.underline));
  static const Style underlineGray11 =
      Style(underlineColor: Color256.on(Colors.gray11, ColorTarget.underline));
  static const Style underlineGray12 =
      Style(underlineColor: Color256.on(Colors.gray12, ColorTarget.underline));
  static const Style underlineGray13 =
      Style(underlineColor: Color256.on(Colors.gray13, ColorTarget.underline));
  static const Style underlineGray14 =
      Style(underlineColor: Color256.on(Colors.gray14, ColorTarget.underline));
  static const Style underlineGray15 =
      Style(underlineColor: Color256.on(Colors.gray15, ColorTarget.underline));
  static const Style underlineGray16 =
      Style(underlineColor: Color256.on(Colors.gray16, ColorTarget.underline));
  static const Style underlineGray17 =
      Style(underlineColor: Color256.on(Colors.gray17, ColorTarget.underline));
  static const Style underlineGray18 =
      Style(underlineColor: Color256.on(Colors.gray18, ColorTarget.underline));
  static const Style underlineGray19 =
      Style(underlineColor: Color256.on(Colors.gray19, ColorTarget.underline));
  static const Style underlineGray20 =
      Style(underlineColor: Color256.on(Colors.gray20, ColorTarget.underline));
  static const Style underlineGray21 =
      Style(underlineColor: Color256.on(Colors.gray21, ColorTarget.underline));
  static const Style underlineGray22 =
      Style(underlineColor: Color256.on(Colors.gray22, ColorTarget.underline));
  static const Style underlineGray23 =
      Style(underlineColor: Color256.on(Colors.gray23, ColorTarget.underline));
  // END GENERATED
}
