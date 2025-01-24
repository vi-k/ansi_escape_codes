const _colorComponentAssert = 'The color component must be in the range 0..5';

//
// 256-color table.
//

//
// Standard color indices.
//

/// Black index from 256-color table.
const int black = 0;

/// Red index from 256-color table.
const int red = 1;

/// Green index from 256-color table.
const int green = 2;

/// Yellow index from 256-color table.
const int yellow = 3;

/// Blue index from 256-color table.
const int blue = 4;

/// Magenta index from 256-color table.
const int magenta = 5;

/// Cyan index from 256-color table.
const int cyan = 6;

/// White index from 256-color table.
const int white = 7;

//
// High intensity color indices.
//

/// High black index from 256-color table.
const int highBlack = 8;

/// High red index from 256-color table.
const int highRed = 9;

/// High green index from 256-color table.
const int highGreen = 10;

/// High yellow index from 256-color table.
const int highYellow = 11;

/// High blue index from 256-color table.
const int highBlue = 12;

/// High magenta index from 256-color table.
const int highMagenta = 13;

/// High cyan index from 256-color table.
const int highCyan = 14;

/// High white index from 256-color table.
const int highWhite = 15;

//
// RGB color indices.

// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).
//

/// RGB 000 index from 256-color table.
const int rgb000 = 16;

/// RGB 001 index from 256-color table.
const int rgb001 = 17;

/// RGB 002 index from 256-color table.
const int rgb002 = 18;

/// RGB 003 index from 256-color table.
const int rgb003 = 19;

/// RGB 004 index from 256-color table.
const int rgb004 = 20;

/// RGB 005 index from 256-color table.
const int rgb005 = 21;

/// RGB 010 index from 256-color table.
const int rgb010 = 22;

/// RGB 011 index from 256-color table.
const int rgb011 = 23;

/// RGB 012 index from 256-color table.
const int rgb012 = 24;

/// RGB 013 index from 256-color table.
const int rgb013 = 25;

/// RGB 014 index from 256-color table.
const int rgb014 = 26;

/// RGB 015 index from 256-color table.
const int rgb015 = 27;

/// RGB 020 index from 256-color table.
const int rgb020 = 28;

/// RGB 021 index from 256-color table.
const int rgb021 = 29;

/// RGB 022 index from 256-color table.
const int rgb022 = 30;

/// RGB 023 index from 256-color table.
const int rgb023 = 31;

/// RGB 024 index from 256-color table.
const int rgb024 = 32;

/// RGB 025 index from 256-color table.
const int rgb025 = 33;

/// RGB 030 index from 256-color table.
const int rgb030 = 34;

/// RGB 031 index from 256-color table.
const int rgb031 = 35;

/// RGB 032 index from 256-color table.
const int rgb032 = 36;

/// RGB 033 index from 256-color table.
const int rgb033 = 37;

/// RGB 034 index from 256-color table.
const int rgb034 = 38;

/// RGB 035 index from 256-color table.
const int rgb035 = 39;

/// RGB 040 index from 256-color table.
const int rgb040 = 40;

/// RGB 041 index from 256-color table.
const int rgb041 = 41;

/// RGB 042 index from 256-color table.
const int rgb042 = 42;

/// RGB 043 index from 256-color table.
const int rgb043 = 43;

/// RGB 044 index from 256-color table.
const int rgb044 = 44;

/// RGB 045 index from 256-color table.
const int rgb045 = 45;

/// RGB 050 index from 256-color table.
const int rgb050 = 46;

/// RGB 051 index from 256-color table.
const int rgb051 = 47;

/// RGB 052 index from 256-color table.
const int rgb052 = 48;

/// RGB 053 index from 256-color table.
const int rgb053 = 49;

/// RGB 054 index from 256-color table.
const int rgb054 = 50;

/// RGB 055 index from 256-color table.
const int rgb055 = 51;

/// RGB 100 index from 256-color table.
const int rgb100 = 52;

/// RGB 101 index from 256-color table.
const int rgb101 = 53;

/// RGB 102 index from 256-color table.
const int rgb102 = 54;

/// RGB 103 index from 256-color table.
const int rgb103 = 55;

/// RGB 104 index from 256-color table.
const int rgb104 = 56;

/// RGB 105 index from 256-color table.
const int rgb105 = 57;

/// RGB 110 index from 256-color table.
const int rgb110 = 58;

/// RGB 111 index from 256-color table.
const int rgb111 = 59;

/// RGB 112 index from 256-color table.
const int rgb112 = 60;

/// RGB 113 index from 256-color table.
const int rgb113 = 61;

/// RGB 114 index from 256-color table.
const int rgb114 = 62;

/// RGB 115 index from 256-color table.
const int rgb115 = 63;

/// RGB 120 index from 256-color table.
const int rgb120 = 64;

/// RGB 121 index from 256-color table.
const int rgb121 = 65;

/// RGB 122 index from 256-color table.
const int rgb122 = 66;

/// RGB 123 index from 256-color table.
const int rgb123 = 67;

/// RGB 124 index from 256-color table.
const int rgb124 = 68;

/// RGB 125 index from 256-color table.
const int rgb125 = 69;

/// RGB 130 index from 256-color table.
const int rgb130 = 70;

/// RGB 131 index from 256-color table.
const int rgb131 = 71;

/// RGB 132 index from 256-color table.
const int rgb132 = 72;

/// RGB 133 index from 256-color table.
const int rgb133 = 73;

/// RGB 134 index from 256-color table.
const int rgb134 = 74;

/// RGB 135 index from 256-color table.
const int rgb135 = 75;

/// RGB 140 index from 256-color table.
const int rgb140 = 76;

/// RGB 141 index from 256-color table.
const int rgb141 = 77;

/// RGB 142 index from 256-color table.
const int rgb142 = 78;

/// RGB 143 index from 256-color table.
const int rgb143 = 79;

/// RGB 144 index from 256-color table.
const int rgb144 = 80;

/// RGB 145 index from 256-color table.
const int rgb145 = 81;

/// RGB 150 index from 256-color table.
const int rgb150 = 82;

/// RGB 151 index from 256-color table.
const int rgb151 = 83;

/// RGB 152 index from 256-color table.
const int rgb152 = 84;

/// RGB 153 index from 256-color table.
const int rgb153 = 85;

/// RGB 154 index from 256-color table.
const int rgb154 = 86;

/// RGB 155 index from 256-color table.
const int rgb155 = 87;

/// RGB 200 index from 256-color table.
const int rgb200 = 88;

/// RGB 201 index from 256-color table.
const int rgb201 = 89;

/// RGB 202 index from 256-color table.
const int rgb202 = 90;

/// RGB 203 index from 256-color table.
const int rgb203 = 91;

/// RGB 204 index from 256-color table.
const int rgb204 = 92;

/// RGB 205 index from 256-color table.
const int rgb205 = 93;

/// RGB 210 index from 256-color table.
const int rgb210 = 94;

/// RGB 211 index from 256-color table.
const int rgb211 = 95;

/// RGB 212 index from 256-color table.
const int rgb212 = 96;

/// RGB 213 index from 256-color table.
const int rgb213 = 97;

/// RGB 214 index from 256-color table.
const int rgb214 = 98;

/// RGB 215 index from 256-color table.
const int rgb215 = 99;

/// RGB 220 index from 256-color table.
const int rgb220 = 100;

/// RGB 221 index from 256-color table.
const int rgb221 = 101;

/// RGB 222 index from 256-color table.
const int rgb222 = 102;

/// RGB 223 index from 256-color table.
const int rgb223 = 103;

/// RGB 224 index from 256-color table.
const int rgb224 = 104;

/// RGB 225 index from 256-color table.
const int rgb225 = 105;

/// RGB 230 index from 256-color table.
const int rgb230 = 106;

/// RGB 231 index from 256-color table.
const int rgb231 = 107;

/// RGB 232 index from 256-color table.
const int rgb232 = 108;

/// RGB 233 index from 256-color table.
const int rgb233 = 109;

/// RGB 234 index from 256-color table.
const int rgb234 = 110;

/// RGB 235 index from 256-color table.
const int rgb235 = 111;

/// RGB 240 index from 256-color table.
const int rgb240 = 112;

/// RGB 241 index from 256-color table.
const int rgb241 = 113;

/// RGB 242 index from 256-color table.
const int rgb242 = 114;

/// RGB 243 index from 256-color table.
const int rgb243 = 115;

/// RGB 244 index from 256-color table.
const int rgb244 = 116;

/// RGB 245 index from 256-color table.
const int rgb245 = 117;

/// RGB 250 index from 256-color table.
const int rgb250 = 118;

/// RGB 251 index from 256-color table.
const int rgb251 = 119;

/// RGB 252 index from 256-color table.
const int rgb252 = 120;

/// RGB 253 index from 256-color table.
const int rgb253 = 121;

/// RGB 254 index from 256-color table.
const int rgb254 = 122;

/// RGB 255 index from 256-color table.
const int rgb255 = 123;

/// RGB 300 index from 256-color table.
const int rgb300 = 124;

/// RGB 301 index from 256-color table.
const int rgb301 = 125;

/// RGB 302 index from 256-color table.
const int rgb302 = 126;

/// RGB 303 index from 256-color table.
const int rgb303 = 127;

/// RGB 304 index from 256-color table.
const int rgb304 = 128;

/// RGB 305 index from 256-color table.
const int rgb305 = 129;

/// RGB 310 index from 256-color table.
const int rgb310 = 130;

/// RGB 311 index from 256-color table.
const int rgb311 = 131;

/// RGB 312 index from 256-color table.
const int rgb312 = 132;

/// RGB 313 index from 256-color table.
const int rgb313 = 133;

/// RGB 314 index from 256-color table.
const int rgb314 = 134;

/// RGB 315 index from 256-color table.
const int rgb315 = 135;

/// RGB 320 index from 256-color table.
const int rgb320 = 136;

/// RGB 321 index from 256-color table.
const int rgb321 = 137;

/// RGB 322 index from 256-color table.
const int rgb322 = 138;

/// RGB 323 index from 256-color table.
const int rgb323 = 139;

/// RGB 324 index from 256-color table.
const int rgb324 = 140;

/// RGB 325 index from 256-color table.
const int rgb325 = 141;

/// RGB 330 index from 256-color table.
const int rgb330 = 142;

/// RGB 331 index from 256-color table.
const int rgb331 = 143;

/// RGB 332 index from 256-color table.
const int rgb332 = 144;

/// RGB 333 index from 256-color table.
const int rgb333 = 145;

/// RGB 334 index from 256-color table.
const int rgb334 = 146;

/// RGB 335 index from 256-color table.
const int rgb335 = 147;

/// RGB 340 index from 256-color table.
const int rgb340 = 148;

/// RGB 341 index from 256-color table.
const int rgb341 = 149;

/// RGB 342 index from 256-color table.
const int rgb342 = 150;

/// RGB 343 index from 256-color table.
const int rgb343 = 151;

/// RGB 344 index from 256-color table.
const int rgb344 = 152;

/// RGB 345 index from 256-color table.
const int rgb345 = 153;

/// RGB 350 index from 256-color table.
const int rgb350 = 154;

/// RGB 351 index from 256-color table.
const int rgb351 = 155;

/// RGB 352 index from 256-color table.
const int rgb352 = 156;

/// RGB 353 index from 256-color table.
const int rgb353 = 157;

/// RGB 354 index from 256-color table.
const int rgb354 = 158;

/// RGB 355 index from 256-color table.
const int rgb355 = 159;

/// RGB 400 index from 256-color table.
const int rgb400 = 160;

/// RGB 401 index from 256-color table.
const int rgb401 = 161;

/// RGB 402 index from 256-color table.
const int rgb402 = 162;

/// RGB 403 index from 256-color table.
const int rgb403 = 163;

/// RGB 404 index from 256-color table.
const int rgb404 = 164;

/// RGB 405 index from 256-color table.
const int rgb405 = 165;

/// RGB 410 index from 256-color table.
const int rgb410 = 166;

/// RGB 411 index from 256-color table.
const int rgb411 = 167;

/// RGB 412 index from 256-color table.
const int rgb412 = 168;

/// RGB 413 index from 256-color table.
const int rgb413 = 169;

/// RGB 414 index from 256-color table.
const int rgb414 = 170;

/// RGB 415 index from 256-color table.
const int rgb415 = 171;

/// RGB 420 index from 256-color table.
const int rgb420 = 172;

/// RGB 421 index from 256-color table.
const int rgb421 = 173;

/// RGB 422 index from 256-color table.
const int rgb422 = 174;

/// RGB 423 index from 256-color table.
const int rgb423 = 175;

/// RGB 424 index from 256-color table.
const int rgb424 = 176;

/// RGB 425 index from 256-color table.
const int rgb425 = 177;

/// RGB 430 index from 256-color table.
const int rgb430 = 178;

/// RGB 431 index from 256-color table.
const int rgb431 = 179;

/// RGB 432 index from 256-color table.
const int rgb432 = 180;

/// RGB 433 index from 256-color table.
const int rgb433 = 181;

/// RGB 434 index from 256-color table.
const int rgb434 = 182;

/// RGB 435 index from 256-color table.
const int rgb435 = 183;

/// RGB 440 index from 256-color table.
const int rgb440 = 184;

/// RGB 441 index from 256-color table.
const int rgb441 = 185;

/// RGB 442 index from 256-color table.
const int rgb442 = 186;

/// RGB 443 index from 256-color table.
const int rgb443 = 187;

/// RGB 444 index from 256-color table.
const int rgb444 = 188;

/// RGB 445 index from 256-color table.
const int rgb445 = 189;

/// RGB 450 index from 256-color table.
const int rgb450 = 190;

/// RGB 451 index from 256-color table.
const int rgb451 = 191;

/// RGB 452 index from 256-color table.
const int rgb452 = 192;

/// RGB 453 index from 256-color table.
const int rgb453 = 193;

/// RGB 454 index from 256-color table.
const int rgb454 = 194;

/// RGB 455 index from 256-color table.
const int rgb455 = 195;

/// RGB 500 index from 256-color table.
const int rgb500 = 196;

/// RGB 501 index from 256-color table.
const int rgb501 = 197;

/// RGB 502 index from 256-color table.
const int rgb502 = 198;

/// RGB 503 index from 256-color table.
const int rgb503 = 199;

/// RGB 504 index from 256-color table.
const int rgb504 = 200;

/// RGB 505 index from 256-color table.
const int rgb505 = 201;

/// RGB 510 index from 256-color table.
const int rgb510 = 202;

/// RGB 511 index from 256-color table.
const int rgb511 = 203;

/// RGB 512 index from 256-color table.
const int rgb512 = 204;

/// RGB 513 index from 256-color table.
const int rgb513 = 205;

/// RGB 514 index from 256-color table.
const int rgb514 = 206;

/// RGB 515 index from 256-color table.
const int rgb515 = 207;

/// RGB 520 index from 256-color table.
const int rgb520 = 208;

/// RGB 521 index from 256-color table.
const int rgb521 = 209;

/// RGB 522 index from 256-color table.
const int rgb522 = 210;

/// RGB 523 index from 256-color table.
const int rgb523 = 211;

/// RGB 524 index from 256-color table.
const int rgb524 = 212;

/// RGB 525 index from 256-color table.
const int rgb525 = 213;

/// RGB 530 index from 256-color table.
const int rgb530 = 214;

/// RGB 531 index from 256-color table.
const int rgb531 = 215;

/// RGB 532 index from 256-color table.
const int rgb532 = 216;

/// RGB 533 index from 256-color table.
const int rgb533 = 217;

/// RGB 534 index from 256-color table.
const int rgb534 = 218;

/// RGB 535 index from 256-color table.
const int rgb535 = 219;

/// RGB 540 index from 256-color table.
const int rgb540 = 220;

/// RGB 541 index from 256-color table.
const int rgb541 = 221;

/// RGB 542 index from 256-color table.
const int rgb542 = 222;

/// RGB 543 index from 256-color table.
const int rgb543 = 223;

/// RGB 544 index from 256-color table.
const int rgb544 = 224;

/// RGB 545 index from 256-color table.
const int rgb545 = 225;

/// RGB 550 index from 256-color table.
const int rgb550 = 226;

/// RGB 551 index from 256-color table.
const int rgb551 = 227;

/// RGB 552 index from 256-color table.
const int rgb552 = 228;

/// RGB 553 index from 256-color table.
const int rgb553 = 229;

/// RGB 554 index from 256-color table.
const int rgb554 = 230;

/// RGB 555 index from 256-color table.
const int rgb555 = 231;

//
// Grayscale indices.
//
// Gray colors from dark to light in 24 steps.
//

/// Min gray index from 256-color table.
const int minGray = 232;

/// Gray 0 index from 256-color table.
const int gray0 = 232;

/// Gray 1 index from 256-color table.
const int gray1 = 233;

/// Gray 2 index from 256-color table.
const int gray2 = 234;

/// Gray 3 index from 256-color table.
const int gray3 = 235;

/// Gray 4 index from 256-color table.
const int gray4 = 236;

/// Gray 5 index from 256-color table.
const int gray5 = 237;

/// Gray 6 index from 256-color table.
const int gray6 = 238;

/// Gray 7 index from 256-color table.
const int gray7 = 239;

/// Gray 8 index from 256-color table.
const int gray8 = 240;

/// Gray 9 index from 256-color table.
const int gray9 = 241;

/// Gray 10 index from 256-color table.
const int gray10 = 242;

/// Gray 11 index from 256-color table.
const int gray11 = 243;

/// Gray 12 index from 256-color table.
const int gray12 = 244;

/// Gray 13 index from 256-color table.
const int gray13 = 245;

/// Gray 14 index from 256-color table.
const int gray14 = 246;

/// Gray 15 index from 256-color table.
const int gray15 = 247;

/// Gray 16 index from 256-color table.
const int gray16 = 248;

/// Gray 17 index from 256-color table.
const int gray17 = 249;

/// Gray 18 index from 256-color table.
const int gray18 = 250;

/// Gray 19 index from 256-color table.
const int gray19 = 251;

/// Gray 20 index from 256-color table.
const int gray20 = 252;

/// Gray 21 index from 256-color table.
const int gray21 = 253;

/// Gray 22 index from 256-color table.
const int gray22 = 254;

/// Gray 23 index from 256-color table.
const int gray23 = 255;

/// Max gray index from 256-color table.
const int maxGray = 255;

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
/// Gray scale from dark to light in 24 steps.
int gray(int g) {
  assert(g >= 0 && g <= 23, 'The gray color must be in the range 0..23');

  return 232 + g;
}
