// ignore_for_file: constant_identifier_names

///
/// 256-color table.
///
library;

//
// Standard color indexes.
//

/// Black index from 256-color table.
const int BLACK = 0;

/// Red index from 256-color table.
const int RED = 1;

/// Green index from 256-color table.
const int GREEN = 2;

/// Yellow index from 256-color table.
const int YELLOW = 3;

/// Blue index from 256-color table.
const int BLUE = 4;

/// Magenta index from 256-color table.
const int MAGENTA = 5;

/// Cyan index from 256-color table.
const int CYAN = 6;

/// White index from 256-color table.
const int WHITE = 7;

//
// High intensity color indexes.
//

/// High black index from 256-color table.
const int HIGH_BLACK = 8;

/// High red index from 256-color table.
const int HIGH_RED = 9;

/// High green index from 256-color table.
const int HIGH_GREEN = 10;

/// High yellow index from 256-color table.
const int HIGH_YELLOW = 11;

/// High blue index from 256-color table.
const int HIGH_BLUE = 12;

/// High magenta index from 256-color table.
const int HIGH_MAGENTA = 13;

/// High cyan index from 256-color table.
const int HIGH_CYAN = 14;

/// High white index from 256-color table.
const int HIGH_WHITE = 15;

//
// RGB color indexes.

// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).
//

/// RGB 000 index from 256-color table.
const int RGB_000 = 16;

/// RGB 001 index from 256-color table.
const int RGB_001 = 17;

/// RGB 002 index from 256-color table.
const int RGB_002 = 18;

/// RGB 003 index from 256-color table.
const int RGB_003 = 19;

/// RGB 004 index from 256-color table.
const int RGB_004 = 20;

/// RGB 005 index from 256-color table.
const int RGB_005 = 21;

/// RGB 010 index from 256-color table.
const int RGB_010 = 22;

/// RGB 011 index from 256-color table.
const int RGB_011 = 23;

/// RGB 012 index from 256-color table.
const int RGB_012 = 24;

/// RGB 013 index from 256-color table.
const int RGB_013 = 25;

/// RGB 014 index from 256-color table.
const int RGB_014 = 26;

/// RGB 015 index from 256-color table.
const int RGB_015 = 27;

/// RGB 020 index from 256-color table.
const int RGB_020 = 28;

/// RGB 021 index from 256-color table.
const int RGB_021 = 29;

/// RGB 022 index from 256-color table.
const int RGB_022 = 30;

/// RGB 023 index from 256-color table.
const int RGB_023 = 31;

/// RGB 024 index from 256-color table.
const int RGB_024 = 32;

/// RGB 025 index from 256-color table.
const int RGB_025 = 33;

/// RGB 030 index from 256-color table.
const int RGB_030 = 34;

/// RGB 031 index from 256-color table.
const int RGB_031 = 35;

/// RGB 032 index from 256-color table.
const int RGB_032 = 36;

/// RGB 033 index from 256-color table.
const int RGB_033 = 37;

/// RGB 034 index from 256-color table.
const int RGB_034 = 38;

/// RGB 035 index from 256-color table.
const int RGB_035 = 39;

/// RGB 040 index from 256-color table.
const int RGB_040 = 40;

/// RGB 041 index from 256-color table.
const int RGB_041 = 41;

/// RGB 042 index from 256-color table.
const int RGB_042 = 42;

/// RGB 043 index from 256-color table.
const int RGB_043 = 43;

/// RGB 044 index from 256-color table.
const int RGB_044 = 44;

/// RGB 045 index from 256-color table.
const int RGB_045 = 45;

/// RGB 050 index from 256-color table.
const int RGB_050 = 46;

/// RGB 051 index from 256-color table.
const int RGB_051 = 47;

/// RGB 052 index from 256-color table.
const int RGB_052 = 48;

/// RGB 053 index from 256-color table.
const int RGB_053 = 49;

/// RGB 054 index from 256-color table.
const int RGB_054 = 50;

/// RGB 055 index from 256-color table.
const int RGB_055 = 51;

/// RGB 100 index from 256-color table.
const int RGB_100 = 52;

/// RGB 101 index from 256-color table.
const int RGB_101 = 53;

/// RGB 102 index from 256-color table.
const int RGB_102 = 54;

/// RGB 103 index from 256-color table.
const int RGB_103 = 55;

/// RGB 104 index from 256-color table.
const int RGB_104 = 56;

/// RGB 105 index from 256-color table.
const int RGB_105 = 57;

/// RGB 110 index from 256-color table.
const int RGB_110 = 58;

/// RGB 111 index from 256-color table.
const int RGB_111 = 59;

/// RGB 112 index from 256-color table.
const int RGB_112 = 60;

/// RGB 113 index from 256-color table.
const int RGB_113 = 61;

/// RGB 114 index from 256-color table.
const int RGB_114 = 62;

/// RGB 115 index from 256-color table.
const int RGB_115 = 63;

/// RGB 120 index from 256-color table.
const int RGB_120 = 64;

/// RGB 121 index from 256-color table.
const int RGB_121 = 65;

/// RGB 122 index from 256-color table.
const int RGB_122 = 66;

/// RGB 123 index from 256-color table.
const int RGB_123 = 67;

/// RGB 124 index from 256-color table.
const int RGB_124 = 68;

/// RGB 125 index from 256-color table.
const int RGB_125 = 69;

/// RGB 130 index from 256-color table.
const int RGB_130 = 70;

/// RGB 131 index from 256-color table.
const int RGB_131 = 71;

/// RGB 132 index from 256-color table.
const int RGB_132 = 72;

/// RGB 133 index from 256-color table.
const int RGB_133 = 73;

/// RGB 134 index from 256-color table.
const int RGB_134 = 74;

/// RGB 135 index from 256-color table.
const int RGB_135 = 75;

/// RGB 140 index from 256-color table.
const int RGB_140 = 76;

/// RGB 141 index from 256-color table.
const int RGB_141 = 77;

/// RGB 142 index from 256-color table.
const int RGB_142 = 78;

/// RGB 143 index from 256-color table.
const int RGB_143 = 79;

/// RGB 144 index from 256-color table.
const int RGB_144 = 80;

/// RGB 145 index from 256-color table.
const int RGB_145 = 81;

/// RGB 150 index from 256-color table.
const int RGB_150 = 82;

/// RGB 151 index from 256-color table.
const int RGB_151 = 83;

/// RGB 152 index from 256-color table.
const int RGB_152 = 84;

/// RGB 153 index from 256-color table.
const int RGB_153 = 85;

/// RGB 154 index from 256-color table.
const int RGB_154 = 86;

/// RGB 155 index from 256-color table.
const int RGB_155 = 87;

/// RGB 200 index from 256-color table.
const int RGB_200 = 88;

/// RGB 201 index from 256-color table.
const int RGB_201 = 89;

/// RGB 202 index from 256-color table.
const int RGB_202 = 90;

/// RGB 203 index from 256-color table.
const int RGB_203 = 91;

/// RGB 204 index from 256-color table.
const int RGB_204 = 92;

/// RGB 205 index from 256-color table.
const int RGB_205 = 93;

/// RGB 210 index from 256-color table.
const int RGB_210 = 94;

/// RGB 211 index from 256-color table.
const int RGB_211 = 95;

/// RGB 212 index from 256-color table.
const int RGB_212 = 96;

/// RGB 213 index from 256-color table.
const int RGB_213 = 97;

/// RGB 214 index from 256-color table.
const int RGB_214 = 98;

/// RGB 215 index from 256-color table.
const int RGB_215 = 99;

/// RGB 220 index from 256-color table.
const int RGB_220 = 100;

/// RGB 221 index from 256-color table.
const int RGB_221 = 101;

/// RGB 222 index from 256-color table.
const int RGB_222 = 102;

/// RGB 223 index from 256-color table.
const int RGB_223 = 103;

/// RGB 224 index from 256-color table.
const int RGB_224 = 104;

/// RGB 225 index from 256-color table.
const int RGB_225 = 105;

/// RGB 230 index from 256-color table.
const int RGB_230 = 106;

/// RGB 231 index from 256-color table.
const int RGB_231 = 107;

/// RGB 232 index from 256-color table.
const int RGB_232 = 108;

/// RGB 233 index from 256-color table.
const int RGB_233 = 109;

/// RGB 234 index from 256-color table.
const int RGB_234 = 110;

/// RGB 235 index from 256-color table.
const int RGB_235 = 111;

/// RGB 240 index from 256-color table.
const int RGB_240 = 112;

/// RGB 241 index from 256-color table.
const int RGB_241 = 113;

/// RGB 242 index from 256-color table.
const int RGB_242 = 114;

/// RGB 243 index from 256-color table.
const int RGB_243 = 115;

/// RGB 244 index from 256-color table.
const int RGB_244 = 116;

/// RGB 245 index from 256-color table.
const int RGB_245 = 117;

/// RGB 250 index from 256-color table.
const int RGB_250 = 118;

/// RGB 251 index from 256-color table.
const int RGB_251 = 119;

/// RGB 252 index from 256-color table.
const int RGB_252 = 120;

/// RGB 253 index from 256-color table.
const int RGB_253 = 121;

/// RGB 254 index from 256-color table.
const int RGB_254 = 122;

/// RGB 255 index from 256-color table.
const int RGB_255 = 123;

/// RGB 300 index from 256-color table.
const int RGB_300 = 124;

/// RGB 301 index from 256-color table.
const int RGB_301 = 125;

/// RGB 302 index from 256-color table.
const int RGB_302 = 126;

/// RGB 303 index from 256-color table.
const int RGB_303 = 127;

/// RGB 304 index from 256-color table.
const int RGB_304 = 128;

/// RGB 305 index from 256-color table.
const int RGB_305 = 129;

/// RGB 310 index from 256-color table.
const int RGB_310 = 130;

/// RGB 311 index from 256-color table.
const int RGB_311 = 131;

/// RGB 312 index from 256-color table.
const int RGB_312 = 132;

/// RGB 313 index from 256-color table.
const int RGB_313 = 133;

/// RGB 314 index from 256-color table.
const int RGB_314 = 134;

/// RGB 315 index from 256-color table.
const int RGB_315 = 135;

/// RGB 320 index from 256-color table.
const int RGB_320 = 136;

/// RGB 321 index from 256-color table.
const int RGB_321 = 137;

/// RGB 322 index from 256-color table.
const int RGB_322 = 138;

/// RGB 323 index from 256-color table.
const int RGB_323 = 139;

/// RGB 324 index from 256-color table.
const int RGB_324 = 140;

/// RGB 325 index from 256-color table.
const int RGB_325 = 141;

/// RGB 330 index from 256-color table.
const int RGB_330 = 142;

/// RGB 331 index from 256-color table.
const int RGB_331 = 143;

/// RGB 332 index from 256-color table.
const int RGB_332 = 144;

/// RGB 333 index from 256-color table.
const int RGB_333 = 145;

/// RGB 334 index from 256-color table.
const int RGB_334 = 146;

/// RGB 335 index from 256-color table.
const int RGB_335 = 147;

/// RGB 340 index from 256-color table.
const int RGB_340 = 148;

/// RGB 341 index from 256-color table.
const int RGB_341 = 149;

/// RGB 342 index from 256-color table.
const int RGB_342 = 150;

/// RGB 343 index from 256-color table.
const int RGB_343 = 151;

/// RGB 344 index from 256-color table.
const int RGB_344 = 152;

/// RGB 345 index from 256-color table.
const int RGB_345 = 153;

/// RGB 350 index from 256-color table.
const int RGB_350 = 154;

/// RGB 351 index from 256-color table.
const int RGB_351 = 155;

/// RGB 352 index from 256-color table.
const int RGB_352 = 156;

/// RGB 353 index from 256-color table.
const int RGB_353 = 157;

/// RGB 354 index from 256-color table.
const int RGB_354 = 158;

/// RGB 355 index from 256-color table.
const int RGB_355 = 159;

/// RGB 400 index from 256-color table.
const int RGB_400 = 160;

/// RGB 401 index from 256-color table.
const int RGB_401 = 161;

/// RGB 402 index from 256-color table.
const int RGB_402 = 162;

/// RGB 403 index from 256-color table.
const int RGB_403 = 163;

/// RGB 404 index from 256-color table.
const int RGB_404 = 164;

/// RGB 405 index from 256-color table.
const int RGB_405 = 165;

/// RGB 410 index from 256-color table.
const int RGB_410 = 166;

/// RGB 411 index from 256-color table.
const int RGB_411 = 167;

/// RGB 412 index from 256-color table.
const int RGB_412 = 168;

/// RGB 413 index from 256-color table.
const int RGB_413 = 169;

/// RGB 414 index from 256-color table.
const int RGB_414 = 170;

/// RGB 415 index from 256-color table.
const int RGB_415 = 171;

/// RGB 420 index from 256-color table.
const int RGB_420 = 172;

/// RGB 421 index from 256-color table.
const int RGB_421 = 173;

/// RGB 422 index from 256-color table.
const int RGB_422 = 174;

/// RGB 423 index from 256-color table.
const int RGB_423 = 175;

/// RGB 424 index from 256-color table.
const int RGB_424 = 176;

/// RGB 425 index from 256-color table.
const int RGB_425 = 177;

/// RGB 430 index from 256-color table.
const int RGB_430 = 178;

/// RGB 431 index from 256-color table.
const int RGB_431 = 179;

/// RGB 432 index from 256-color table.
const int RGB_432 = 180;

/// RGB 433 index from 256-color table.
const int RGB_433 = 181;

/// RGB 434 index from 256-color table.
const int RGB_434 = 182;

/// RGB 435 index from 256-color table.
const int RGB_435 = 183;

/// RGB 440 index from 256-color table.
const int RGB_440 = 184;

/// RGB 441 index from 256-color table.
const int RGB_441 = 185;

/// RGB 442 index from 256-color table.
const int RGB_442 = 186;

/// RGB 443 index from 256-color table.
const int RGB_443 = 187;

/// RGB 444 index from 256-color table.
const int RGB_444 = 188;

/// RGB 445 index from 256-color table.
const int RGB_445 = 189;

/// RGB 450 index from 256-color table.
const int RGB_450 = 190;

/// RGB 451 index from 256-color table.
const int RGB_451 = 191;

/// RGB 452 index from 256-color table.
const int RGB_452 = 192;

/// RGB 453 index from 256-color table.
const int RGB_453 = 193;

/// RGB 454 index from 256-color table.
const int RGB_454 = 194;

/// RGB 455 index from 256-color table.
const int RGB_455 = 195;

/// RGB 500 index from 256-color table.
const int RGB_500 = 196;

/// RGB 501 index from 256-color table.
const int RGB_501 = 197;

/// RGB 502 index from 256-color table.
const int RGB_502 = 198;

/// RGB 503 index from 256-color table.
const int RGB_503 = 199;

/// RGB 504 index from 256-color table.
const int RGB_504 = 200;

/// RGB 505 index from 256-color table.
const int RGB_505 = 201;

/// RGB 510 index from 256-color table.
const int RGB_510 = 202;

/// RGB 511 index from 256-color table.
const int RGB_511 = 203;

/// RGB 512 index from 256-color table.
const int RGB_512 = 204;

/// RGB 513 index from 256-color table.
const int RGB_513 = 205;

/// RGB 514 index from 256-color table.
const int RGB_514 = 206;

/// RGB 515 index from 256-color table.
const int RGB_515 = 207;

/// RGB 520 index from 256-color table.
const int RGB_520 = 208;

/// RGB 521 index from 256-color table.
const int RGB_521 = 209;

/// RGB 522 index from 256-color table.
const int RGB_522 = 210;

/// RGB 523 index from 256-color table.
const int RGB_523 = 211;

/// RGB 524 index from 256-color table.
const int RGB_524 = 212;

/// RGB 525 index from 256-color table.
const int RGB_525 = 213;

/// RGB 530 index from 256-color table.
const int RGB_530 = 214;

/// RGB 531 index from 256-color table.
const int RGB_531 = 215;

/// RGB 532 index from 256-color table.
const int RGB_532 = 216;

/// RGB 533 index from 256-color table.
const int RGB_533 = 217;

/// RGB 534 index from 256-color table.
const int RGB_534 = 218;

/// RGB 535 index from 256-color table.
const int RGB_535 = 219;

/// RGB 540 index from 256-color table.
const int RGB_540 = 220;

/// RGB 541 index from 256-color table.
const int RGB_541 = 221;

/// RGB 542 index from 256-color table.
const int RGB_542 = 222;

/// RGB 543 index from 256-color table.
const int RGB_543 = 223;

/// RGB 544 index from 256-color table.
const int RGB_544 = 224;

/// RGB 545 index from 256-color table.
const int RGB_545 = 225;

/// RGB 550 index from 256-color table.
const int RGB_550 = 226;

/// RGB 551 index from 256-color table.
const int RGB_551 = 227;

/// RGB 552 index from 256-color table.
const int RGB_552 = 228;

/// RGB 553 index from 256-color table.
const int RGB_553 = 229;

/// RGB 554 index from 256-color table.
const int RGB_554 = 230;

/// RGB 555 index from 256-color table.
const int RGB_555 = 231;

//
// Grayscale indexes.
//
// Gray colors from dark to light in 24 steps.
//

/// Gray 0 index from 256-color table.
const int GRAY0 = 232;

/// Gray 1 index from 256-color table.
const int GRAY1 = 233;

/// Gray 2 index from 256-color table.
const int GRAY2 = 234;

/// Gray 3 index from 256-color table.
const int GRAY3 = 235;

/// Gray 4 index from 256-color table.
const int GRAY4 = 236;

/// Gray 5 index from 256-color table.
const int GRAY5 = 237;

/// Gray 6 index from 256-color table.
const int GRAY6 = 238;

/// Gray 7 index from 256-color table.
const int GRAY7 = 239;

/// Gray 8 index from 256-color table.
const int GRAY8 = 240;

/// Gray 9 index from 256-color table.
const int GRAY9 = 241;

/// Gray 10 index from 256-color table.
const int GRAY10 = 242;

/// Gray 11 index from 256-color table.
const int GRAY11 = 243;

/// Gray 12 index from 256-color table.
const int GRAY12 = 244;

/// Gray 13 index from 256-color table.
const int GRAY13 = 245;

/// Gray 14 index from 256-color table.
const int GRAY14 = 246;

/// Gray 15 index from 256-color table.
const int GRAY15 = 247;

/// Gray 16 index from 256-color table.
const int GRAY16 = 248;

/// Gray 17 index from 256-color table.
const int GRAY17 = 249;

/// Gray 18 index from 256-color table.
const int GRAY18 = 250;

/// Gray 19 index from 256-color table.
const int GRAY19 = 251;

/// Gray 20 index from 256-color table.
const int GRAY20 = 252;

/// Gray 21 index from 256-color table.
const int GRAY21 = 253;

/// Gray 22 index from 256-color table.
const int GRAY22 = 254;

/// Gray 23 index from 256-color table.
const int GRAY23 = 255;
