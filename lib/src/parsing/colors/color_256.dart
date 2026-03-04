part of 'color.dart';

final class Color256 extends ExtendedColor {
  final Colors color;

  const Color256(this.color);

  Color256.rgb(int r, int g, int b)
      : assert(
          r >= 0 && r <= 5 && g >= 0 && g <= 5 && b >= 0 && b <= 5,
          'RGB values must be between 0 and 5',
        ),
        color = Colors.values[16 + r * 36 + g * 6 + b];

  Color256.gray(int level)
      : assert(
          level >= 0 && level <= 23,
          'Grayscale level must be between 0 and 23',
        ),
        color = Colors.values[232 + level];

  const Color256._(this.color, [super._prefix]);

  @override
  Color256 withPrefix(String prefix) => Color256._(color, prefix);

  static const Color256 black = Color256(Colors.black);
  static const Color256 red = Color256(Colors.red);
  static const Color256 green = Color256(Colors.green);
  static const Color256 yellow = Color256(Colors.yellow);
  static const Color256 blue = Color256(Colors.blue);
  static const Color256 magenta = Color256(Colors.magenta);
  static const Color256 cyan = Color256(Colors.cyan);
  static const Color256 white = Color256(Colors.white);
  static const Color256 highBlack = Color256(Colors.highBlack);
  static const Color256 highRed = Color256(Colors.highRed);
  static const Color256 highGreen = Color256(Colors.highGreen);
  static const Color256 highYellow = Color256(Colors.highYellow);
  static const Color256 highBlue = Color256(Colors.highBlue);
  static const Color256 highMagenta = Color256(Colors.highMagenta);
  static const Color256 highCyan = Color256(Colors.highCyan);
  static const Color256 highWhite = Color256(Colors.highWhite);
  static const Color256 rgb000 = Color256(Colors.rgb000);
  static const Color256 rgb001 = Color256(Colors.rgb001);
  static const Color256 rgb002 = Color256(Colors.rgb002);
  static const Color256 rgb003 = Color256(Colors.rgb003);
  static const Color256 rgb004 = Color256(Colors.rgb004);
  static const Color256 rgb005 = Color256(Colors.rgb005);
  static const Color256 rgb010 = Color256(Colors.rgb010);
  static const Color256 rgb011 = Color256(Colors.rgb011);
  static const Color256 rgb012 = Color256(Colors.rgb012);
  static const Color256 rgb013 = Color256(Colors.rgb013);
  static const Color256 rgb014 = Color256(Colors.rgb014);
  static const Color256 rgb015 = Color256(Colors.rgb015);
  static const Color256 rgb020 = Color256(Colors.rgb020);
  static const Color256 rgb021 = Color256(Colors.rgb021);
  static const Color256 rgb022 = Color256(Colors.rgb022);
  static const Color256 rgb023 = Color256(Colors.rgb023);
  static const Color256 rgb024 = Color256(Colors.rgb024);
  static const Color256 rgb025 = Color256(Colors.rgb025);
  static const Color256 rgb030 = Color256(Colors.rgb030);
  static const Color256 rgb031 = Color256(Colors.rgb031);
  static const Color256 rgb032 = Color256(Colors.rgb032);
  static const Color256 rgb033 = Color256(Colors.rgb033);
  static const Color256 rgb034 = Color256(Colors.rgb034);
  static const Color256 rgb035 = Color256(Colors.rgb035);
  static const Color256 rgb040 = Color256(Colors.rgb040);
  static const Color256 rgb041 = Color256(Colors.rgb041);
  static const Color256 rgb042 = Color256(Colors.rgb042);
  static const Color256 rgb043 = Color256(Colors.rgb043);
  static const Color256 rgb044 = Color256(Colors.rgb044);
  static const Color256 rgb045 = Color256(Colors.rgb045);
  static const Color256 rgb050 = Color256(Colors.rgb050);
  static const Color256 rgb051 = Color256(Colors.rgb051);
  static const Color256 rgb052 = Color256(Colors.rgb052);
  static const Color256 rgb053 = Color256(Colors.rgb053);
  static const Color256 rgb054 = Color256(Colors.rgb054);
  static const Color256 rgb055 = Color256(Colors.rgb055);
  static const Color256 rgb100 = Color256(Colors.rgb100);
  static const Color256 rgb101 = Color256(Colors.rgb101);
  static const Color256 rgb102 = Color256(Colors.rgb102);
  static const Color256 rgb103 = Color256(Colors.rgb103);
  static const Color256 rgb104 = Color256(Colors.rgb104);
  static const Color256 rgb105 = Color256(Colors.rgb105);
  static const Color256 rgb110 = Color256(Colors.rgb110);
  static const Color256 rgb111 = Color256(Colors.rgb111);
  static const Color256 rgb112 = Color256(Colors.rgb112);
  static const Color256 rgb113 = Color256(Colors.rgb113);
  static const Color256 rgb114 = Color256(Colors.rgb114);
  static const Color256 rgb115 = Color256(Colors.rgb115);
  static const Color256 rgb120 = Color256(Colors.rgb120);
  static const Color256 rgb121 = Color256(Colors.rgb121);
  static const Color256 rgb122 = Color256(Colors.rgb122);
  static const Color256 rgb123 = Color256(Colors.rgb123);
  static const Color256 rgb124 = Color256(Colors.rgb124);
  static const Color256 rgb125 = Color256(Colors.rgb125);
  static const Color256 rgb130 = Color256(Colors.rgb130);
  static const Color256 rgb131 = Color256(Colors.rgb131);
  static const Color256 rgb132 = Color256(Colors.rgb132);
  static const Color256 rgb133 = Color256(Colors.rgb133);
  static const Color256 rgb134 = Color256(Colors.rgb134);
  static const Color256 rgb135 = Color256(Colors.rgb135);
  static const Color256 rgb140 = Color256(Colors.rgb140);
  static const Color256 rgb141 = Color256(Colors.rgb141);
  static const Color256 rgb142 = Color256(Colors.rgb142);
  static const Color256 rgb143 = Color256(Colors.rgb143);
  static const Color256 rgb144 = Color256(Colors.rgb144);
  static const Color256 rgb145 = Color256(Colors.rgb145);
  static const Color256 rgb150 = Color256(Colors.rgb150);
  static const Color256 rgb151 = Color256(Colors.rgb151);
  static const Color256 rgb152 = Color256(Colors.rgb152);
  static const Color256 rgb153 = Color256(Colors.rgb153);
  static const Color256 rgb154 = Color256(Colors.rgb154);
  static const Color256 rgb155 = Color256(Colors.rgb155);
  static const Color256 rgb200 = Color256(Colors.rgb200);
  static const Color256 rgb201 = Color256(Colors.rgb201);
  static const Color256 rgb202 = Color256(Colors.rgb202);
  static const Color256 rgb203 = Color256(Colors.rgb203);
  static const Color256 rgb204 = Color256(Colors.rgb204);
  static const Color256 rgb205 = Color256(Colors.rgb205);
  static const Color256 rgb210 = Color256(Colors.rgb210);
  static const Color256 rgb211 = Color256(Colors.rgb211);
  static const Color256 rgb212 = Color256(Colors.rgb212);
  static const Color256 rgb213 = Color256(Colors.rgb213);
  static const Color256 rgb214 = Color256(Colors.rgb214);
  static const Color256 rgb215 = Color256(Colors.rgb215);
  static const Color256 rgb220 = Color256(Colors.rgb220);
  static const Color256 rgb221 = Color256(Colors.rgb221);
  static const Color256 rgb222 = Color256(Colors.rgb222);
  static const Color256 rgb223 = Color256(Colors.rgb223);
  static const Color256 rgb224 = Color256(Colors.rgb224);
  static const Color256 rgb225 = Color256(Colors.rgb225);
  static const Color256 rgb230 = Color256(Colors.rgb230);
  static const Color256 rgb231 = Color256(Colors.rgb231);
  static const Color256 rgb232 = Color256(Colors.rgb232);
  static const Color256 rgb233 = Color256(Colors.rgb233);
  static const Color256 rgb234 = Color256(Colors.rgb234);
  static const Color256 rgb235 = Color256(Colors.rgb235);
  static const Color256 rgb240 = Color256(Colors.rgb240);
  static const Color256 rgb241 = Color256(Colors.rgb241);
  static const Color256 rgb242 = Color256(Colors.rgb242);
  static const Color256 rgb243 = Color256(Colors.rgb243);
  static const Color256 rgb244 = Color256(Colors.rgb244);
  static const Color256 rgb245 = Color256(Colors.rgb245);
  static const Color256 rgb250 = Color256(Colors.rgb250);
  static const Color256 rgb251 = Color256(Colors.rgb251);
  static const Color256 rgb252 = Color256(Colors.rgb252);
  static const Color256 rgb253 = Color256(Colors.rgb253);
  static const Color256 rgb254 = Color256(Colors.rgb254);
  static const Color256 rgb255 = Color256(Colors.rgb255);
  static const Color256 rgb300 = Color256(Colors.rgb300);
  static const Color256 rgb301 = Color256(Colors.rgb301);
  static const Color256 rgb302 = Color256(Colors.rgb302);
  static const Color256 rgb303 = Color256(Colors.rgb303);
  static const Color256 rgb304 = Color256(Colors.rgb304);
  static const Color256 rgb305 = Color256(Colors.rgb305);
  static const Color256 rgb310 = Color256(Colors.rgb310);
  static const Color256 rgb311 = Color256(Colors.rgb311);
  static const Color256 rgb312 = Color256(Colors.rgb312);
  static const Color256 rgb313 = Color256(Colors.rgb313);
  static const Color256 rgb314 = Color256(Colors.rgb314);
  static const Color256 rgb315 = Color256(Colors.rgb315);
  static const Color256 rgb320 = Color256(Colors.rgb320);
  static const Color256 rgb321 = Color256(Colors.rgb321);
  static const Color256 rgb322 = Color256(Colors.rgb322);
  static const Color256 rgb323 = Color256(Colors.rgb323);
  static const Color256 rgb324 = Color256(Colors.rgb324);
  static const Color256 rgb325 = Color256(Colors.rgb325);
  static const Color256 rgb330 = Color256(Colors.rgb330);
  static const Color256 rgb331 = Color256(Colors.rgb331);
  static const Color256 rgb332 = Color256(Colors.rgb332);
  static const Color256 rgb333 = Color256(Colors.rgb333);
  static const Color256 rgb334 = Color256(Colors.rgb334);
  static const Color256 rgb335 = Color256(Colors.rgb335);
  static const Color256 rgb340 = Color256(Colors.rgb340);
  static const Color256 rgb341 = Color256(Colors.rgb341);
  static const Color256 rgb342 = Color256(Colors.rgb342);
  static const Color256 rgb343 = Color256(Colors.rgb343);
  static const Color256 rgb344 = Color256(Colors.rgb344);
  static const Color256 rgb345 = Color256(Colors.rgb345);
  static const Color256 rgb350 = Color256(Colors.rgb350);
  static const Color256 rgb351 = Color256(Colors.rgb351);
  static const Color256 rgb352 = Color256(Colors.rgb352);
  static const Color256 rgb353 = Color256(Colors.rgb353);
  static const Color256 rgb354 = Color256(Colors.rgb354);
  static const Color256 rgb355 = Color256(Colors.rgb355);
  static const Color256 rgb400 = Color256(Colors.rgb400);
  static const Color256 rgb401 = Color256(Colors.rgb401);
  static const Color256 rgb402 = Color256(Colors.rgb402);
  static const Color256 rgb403 = Color256(Colors.rgb403);
  static const Color256 rgb404 = Color256(Colors.rgb404);
  static const Color256 rgb405 = Color256(Colors.rgb405);
  static const Color256 rgb410 = Color256(Colors.rgb410);
  static const Color256 rgb411 = Color256(Colors.rgb411);
  static const Color256 rgb412 = Color256(Colors.rgb412);
  static const Color256 rgb413 = Color256(Colors.rgb413);
  static const Color256 rgb414 = Color256(Colors.rgb414);
  static const Color256 rgb415 = Color256(Colors.rgb415);
  static const Color256 rgb420 = Color256(Colors.rgb420);
  static const Color256 rgb421 = Color256(Colors.rgb421);
  static const Color256 rgb422 = Color256(Colors.rgb422);
  static const Color256 rgb423 = Color256(Colors.rgb423);
  static const Color256 rgb424 = Color256(Colors.rgb424);
  static const Color256 rgb425 = Color256(Colors.rgb425);
  static const Color256 rgb430 = Color256(Colors.rgb430);
  static const Color256 rgb431 = Color256(Colors.rgb431);
  static const Color256 rgb432 = Color256(Colors.rgb432);
  static const Color256 rgb433 = Color256(Colors.rgb433);
  static const Color256 rgb434 = Color256(Colors.rgb434);
  static const Color256 rgb435 = Color256(Colors.rgb435);
  static const Color256 rgb440 = Color256(Colors.rgb440);
  static const Color256 rgb441 = Color256(Colors.rgb441);
  static const Color256 rgb442 = Color256(Colors.rgb442);
  static const Color256 rgb443 = Color256(Colors.rgb443);
  static const Color256 rgb444 = Color256(Colors.rgb444);
  static const Color256 rgb445 = Color256(Colors.rgb445);
  static const Color256 rgb450 = Color256(Colors.rgb450);
  static const Color256 rgb451 = Color256(Colors.rgb451);
  static const Color256 rgb452 = Color256(Colors.rgb452);
  static const Color256 rgb453 = Color256(Colors.rgb453);
  static const Color256 rgb454 = Color256(Colors.rgb454);
  static const Color256 rgb455 = Color256(Colors.rgb455);
  static const Color256 rgb500 = Color256(Colors.rgb500);
  static const Color256 rgb501 = Color256(Colors.rgb501);
  static const Color256 rgb502 = Color256(Colors.rgb502);
  static const Color256 rgb503 = Color256(Colors.rgb503);
  static const Color256 rgb504 = Color256(Colors.rgb504);
  static const Color256 rgb505 = Color256(Colors.rgb505);
  static const Color256 rgb510 = Color256(Colors.rgb510);
  static const Color256 rgb511 = Color256(Colors.rgb511);
  static const Color256 rgb512 = Color256(Colors.rgb512);
  static const Color256 rgb513 = Color256(Colors.rgb513);
  static const Color256 rgb514 = Color256(Colors.rgb514);
  static const Color256 rgb515 = Color256(Colors.rgb515);
  static const Color256 rgb520 = Color256(Colors.rgb520);
  static const Color256 rgb521 = Color256(Colors.rgb521);
  static const Color256 rgb522 = Color256(Colors.rgb522);
  static const Color256 rgb523 = Color256(Colors.rgb523);
  static const Color256 rgb524 = Color256(Colors.rgb524);
  static const Color256 rgb525 = Color256(Colors.rgb525);
  static const Color256 rgb530 = Color256(Colors.rgb530);
  static const Color256 rgb531 = Color256(Colors.rgb531);
  static const Color256 rgb532 = Color256(Colors.rgb532);
  static const Color256 rgb533 = Color256(Colors.rgb533);
  static const Color256 rgb534 = Color256(Colors.rgb534);
  static const Color256 rgb535 = Color256(Colors.rgb535);
  static const Color256 rgb540 = Color256(Colors.rgb540);
  static const Color256 rgb541 = Color256(Colors.rgb541);
  static const Color256 rgb542 = Color256(Colors.rgb542);
  static const Color256 rgb543 = Color256(Colors.rgb543);
  static const Color256 rgb544 = Color256(Colors.rgb544);
  static const Color256 rgb545 = Color256(Colors.rgb545);
  static const Color256 rgb550 = Color256(Colors.rgb550);
  static const Color256 rgb551 = Color256(Colors.rgb551);
  static const Color256 rgb552 = Color256(Colors.rgb552);
  static const Color256 rgb553 = Color256(Colors.rgb553);
  static const Color256 rgb554 = Color256(Colors.rgb554);
  static const Color256 rgb555 = Color256(Colors.rgb555);
  static const Color256 gray0 = Color256(Colors.gray0);
  static const Color256 gray1 = Color256(Colors.gray1);
  static const Color256 gray2 = Color256(Colors.gray2);
  static const Color256 gray3 = Color256(Colors.gray3);
  static const Color256 gray4 = Color256(Colors.gray4);
  static const Color256 gray5 = Color256(Colors.gray5);
  static const Color256 gray6 = Color256(Colors.gray6);
  static const Color256 gray7 = Color256(Colors.gray7);
  static const Color256 gray8 = Color256(Colors.gray8);
  static const Color256 gray9 = Color256(Colors.gray9);
  static const Color256 gray10 = Color256(Colors.gray10);
  static const Color256 gray11 = Color256(Colors.gray11);
  static const Color256 gray12 = Color256(Colors.gray12);
  static const Color256 gray13 = Color256(Colors.gray13);
  static const Color256 gray14 = Color256(Colors.gray14);
  static const Color256 gray15 = Color256(Colors.gray15);
  static const Color256 gray16 = Color256(Colors.gray16);
  static const Color256 gray17 = Color256(Colors.gray17);
  static const Color256 gray18 = Color256(Colors.gray18);
  static const Color256 gray19 = Color256(Colors.gray19);
  static const Color256 gray20 = Color256(Colors.gray20);
  static const Color256 gray21 = Color256(Colors.gray21);
  static const Color256 gray22 = Color256(Colors.gray22);
  static const Color256 gray23 = Color256(Colors.gray23);

  int get index => color.index;

  @override
  int get hashCode => color.hashCode;

  @override
  bool operator ==(Object other) => other is Color256 && color == other.color;

  @override
  String get id => '${_prefix ?? '?'}256${color.name.capitalize()}';

  @override
  String toString() => '$Color256.${color.name}';
}
