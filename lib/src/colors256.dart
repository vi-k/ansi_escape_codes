//
// 256-color table.
//

// Standard colors.

const int black = 0;
const int red = 1;
const int green = 2;
const int yellow = 3;
const int blue = 4;
const int magenta = 5;
const int cyan = 6;
const int white = 7;

// High intensity colors.

const int highBlack = 8;
const int highRed = 9;
const int highGreen = 10;
const int highYellow = 11;
const int highBlue = 12;
const int highMagenta = 13;
const int highCyan = 14;
const int highWhite = 15;

// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).

const int rgb000 = 16;
const int rgb001 = 17;
const int rgb002 = 18;
const int rgb003 = 19;
const int rgb004 = 20;
const int rgb005 = 21;
const int rgb010 = 22;
const int rgb011 = 23;
const int rgb012 = 24;
const int rgb013 = 25;
const int rgb014 = 26;
const int rgb015 = 27;
const int rgb020 = 28;
const int rgb021 = 29;
const int rgb022 = 30;
const int rgb023 = 31;
const int rgb024 = 32;
const int rgb025 = 33;
const int rgb030 = 34;
const int rgb031 = 35;
const int rgb032 = 36;
const int rgb033 = 37;
const int rgb034 = 38;
const int rgb035 = 39;
const int rgb040 = 40;
const int rgb041 = 41;
const int rgb042 = 42;
const int rgb043 = 43;
const int rgb044 = 44;
const int rgb045 = 45;
const int rgb050 = 46;
const int rgb051 = 47;
const int rgb052 = 48;
const int rgb053 = 49;
const int rgb054 = 50;
const int rgb055 = 51;
const int rgb100 = 52;
const int rgb101 = 53;
const int rgb102 = 54;
const int rgb103 = 55;
const int rgb104 = 56;
const int rgb105 = 57;
const int rgb110 = 58;
const int rgb111 = 59;
const int rgb112 = 60;
const int rgb113 = 61;
const int rgb114 = 62;
const int rgb115 = 63;
const int rgb120 = 64;
const int rgb121 = 65;
const int rgb122 = 66;
const int rgb123 = 67;
const int rgb124 = 68;
const int rgb125 = 69;
const int rgb130 = 70;
const int rgb131 = 71;
const int rgb132 = 72;
const int rgb133 = 73;
const int rgb134 = 74;
const int rgb135 = 75;
const int rgb140 = 76;
const int rgb141 = 77;
const int rgb142 = 78;
const int rgb143 = 79;
const int rgb144 = 80;
const int rgb145 = 81;
const int rgb150 = 82;
const int rgb151 = 83;
const int rgb152 = 84;
const int rgb153 = 85;
const int rgb154 = 86;
const int rgb155 = 87;
const int rgb200 = 88;
const int rgb201 = 89;
const int rgb202 = 90;
const int rgb203 = 91;
const int rgb204 = 92;
const int rgb205 = 93;
const int rgb210 = 94;
const int rgb211 = 95;
const int rgb212 = 96;
const int rgb213 = 97;
const int rgb214 = 98;
const int rgb215 = 99;
const int rgb220 = 100;
const int rgb221 = 101;
const int rgb222 = 102;
const int rgb223 = 103;
const int rgb224 = 104;
const int rgb225 = 105;
const int rgb230 = 106;
const int rgb231 = 107;
const int rgb232 = 108;
const int rgb233 = 109;
const int rgb234 = 110;
const int rgb235 = 111;
const int rgb240 = 112;
const int rgb241 = 113;
const int rgb242 = 114;
const int rgb243 = 115;
const int rgb244 = 116;
const int rgb245 = 117;
const int rgb250 = 118;
const int rgb251 = 119;
const int rgb252 = 120;
const int rgb253 = 121;
const int rgb254 = 122;
const int rgb255 = 123;
const int rgb300 = 124;
const int rgb301 = 125;
const int rgb302 = 126;
const int rgb303 = 127;
const int rgb304 = 128;
const int rgb305 = 129;
const int rgb310 = 130;
const int rgb311 = 131;
const int rgb312 = 132;
const int rgb313 = 133;
const int rgb314 = 134;
const int rgb315 = 135;
const int rgb320 = 136;
const int rgb321 = 137;
const int rgb322 = 138;
const int rgb323 = 139;
const int rgb324 = 140;
const int rgb325 = 141;
const int rgb330 = 142;
const int rgb331 = 143;
const int rgb332 = 144;
const int rgb333 = 145;
const int rgb334 = 146;
const int rgb335 = 147;
const int rgb340 = 148;
const int rgb341 = 149;
const int rgb342 = 150;
const int rgb343 = 151;
const int rgb344 = 152;
const int rgb345 = 153;
const int rgb350 = 154;
const int rgb351 = 155;
const int rgb352 = 156;
const int rgb353 = 157;
const int rgb354 = 158;
const int rgb355 = 159;
const int rgb400 = 160;
const int rgb401 = 161;
const int rgb402 = 162;
const int rgb403 = 163;
const int rgb404 = 164;
const int rgb405 = 165;
const int rgb410 = 166;
const int rgb411 = 167;
const int rgb412 = 168;
const int rgb413 = 169;
const int rgb414 = 170;
const int rgb415 = 171;
const int rgb420 = 172;
const int rgb421 = 173;
const int rgb422 = 174;
const int rgb423 = 175;
const int rgb424 = 176;
const int rgb425 = 177;
const int rgb430 = 178;
const int rgb431 = 179;
const int rgb432 = 180;
const int rgb433 = 181;
const int rgb434 = 182;
const int rgb435 = 183;
const int rgb440 = 184;
const int rgb441 = 185;
const int rgb442 = 186;
const int rgb443 = 187;
const int rgb444 = 188;
const int rgb445 = 189;
const int rgb450 = 190;
const int rgb451 = 191;
const int rgb452 = 192;
const int rgb453 = 193;
const int rgb454 = 194;
const int rgb455 = 195;
const int rgb500 = 196;
const int rgb501 = 197;
const int rgb502 = 198;
const int rgb503 = 199;
const int rgb504 = 200;
const int rgb505 = 201;
const int rgb510 = 202;
const int rgb511 = 203;
const int rgb512 = 204;
const int rgb513 = 205;
const int rgb514 = 206;
const int rgb515 = 207;
const int rgb520 = 208;
const int rgb521 = 209;
const int rgb522 = 210;
const int rgb523 = 211;
const int rgb524 = 212;
const int rgb525 = 213;
const int rgb530 = 214;
const int rgb531 = 215;
const int rgb532 = 216;
const int rgb533 = 217;
const int rgb534 = 218;
const int rgb535 = 219;
const int rgb540 = 220;
const int rgb541 = 221;
const int rgb542 = 222;
const int rgb543 = 223;
const int rgb544 = 224;
const int rgb545 = 225;
const int rgb550 = 226;
const int rgb551 = 227;
const int rgb552 = 228;
const int rgb553 = 229;
const int rgb554 = 230;
const int rgb555 = 231;

// Grayscale from dark to light in 24 steps.

const int minGray = 232;
const int gray0 = 232;
const int gray1 = 233;
const int gray2 = 234;
const int gray3 = 235;
const int gray4 = 236;
const int gray5 = 237;
const int gray6 = 238;
const int gray7 = 239;
const int gray8 = 240;
const int gray9 = 241;
const int gray10 = 242;
const int gray11 = 243;
const int gray12 = 244;
const int gray13 = 245;
const int gray14 = 246;
const int gray15 = 247;
const int gray16 = 248;
const int gray17 = 249;
const int gray18 = 250;
const int gray19 = 251;
const int gray20 = 252;
const int gray21 = 253;
const int gray22 = 254;
const int gray23 = 255;
const int maxGray = 255;

const _colorComponentAssert = 'The color component must be in the range 0..5';

/// Returns the color index from 256-color table by rgb levels (r,g,b: 0..5).
///
/// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b.
int rgb(int r, int g, int b) {
  assert(r >= 0 && r <= 5, _colorComponentAssert);
  assert(g >= 0 && g <= 5, _colorComponentAssert);
  assert(b >= 0 && b <= 5, _colorComponentAssert);

  return 16 + 36 * r + 6 * g + b;
}

/// Returns the color index from 256-color table by gray level (g: 0..23).
///
/// Grayscale from dark to light in 24 steps.
int gray(int g) {
  assert(g >= 0 && g <= 23, 'The gray color must be in the range 0..23');

  return 232 + g;
}
