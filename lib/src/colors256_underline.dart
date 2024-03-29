import 'sgr_colors.dart';

//
// ANSI escape codes for underline from 256-color table.
//

// Standard colors.

const String underline256Black = '${underline256Open}0$underline256Close';
const String underline256Red = '${underline256Open}1$underline256Close';
const String underline256Green = '${underline256Open}2$underline256Close';
const String underline256Yellow = '${underline256Open}3$underline256Close';
const String underline256Blue = '${underline256Open}4$underline256Close';
const String underline256Magenta = '${underline256Open}5$underline256Close';
const String underline256Cyan = '${underline256Open}6$underline256Close';
const String underline256White = '${underline256Open}7$underline256Close';

// High intensity colors.

const String underline256HighBlack = '${underline256Open}8$underline256Close';
const String underline256HighRed = '${underline256Open}9$underline256Close';
const String underline256HighGreen = '${underline256Open}10$underline256Close';
const String underline256HighYellow = '${underline256Open}11$underline256Close';
const String underline256HighBlue = '${underline256Open}12$underline256Close';
const String underline256HighMagenta =
    '${underline256Open}13$underline256Close';
const String underline256HighCyan = '${underline256Open}14$underline256Close';
const String underline256HighWhite = '${underline256Open}15$underline256Close';

// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).

const String underline256Rgb000 = '${underline256Open}16$underline256Close';
const String underline256Rgb001 = '${underline256Open}17$underline256Close';
const String underline256Rgb002 = '${underline256Open}18$underline256Close';
const String underline256Rgb003 = '${underline256Open}19$underline256Close';
const String underline256Rgb004 = '${underline256Open}20$underline256Close';
const String underline256Rgb005 = '${underline256Open}21$underline256Close';
const String underline256Rgb010 = '${underline256Open}22$underline256Close';
const String underline256Rgb011 = '${underline256Open}23$underline256Close';
const String underline256Rgb012 = '${underline256Open}24$underline256Close';
const String underline256Rgb013 = '${underline256Open}25$underline256Close';
const String underline256Rgb014 = '${underline256Open}26$underline256Close';
const String underline256Rgb015 = '${underline256Open}27$underline256Close';
const String underline256Rgb020 = '${underline256Open}28$underline256Close';
const String underline256Rgb021 = '${underline256Open}29$underline256Close';
const String underline256Rgb022 = '${underline256Open}30$underline256Close';
const String underline256Rgb023 = '${underline256Open}31$underline256Close';
const String underline256Rgb024 = '${underline256Open}32$underline256Close';
const String underline256Rgb025 = '${underline256Open}33$underline256Close';
const String underline256Rgb030 = '${underline256Open}34$underline256Close';
const String underline256Rgb031 = '${underline256Open}35$underline256Close';
const String underline256Rgb032 = '${underline256Open}36$underline256Close';
const String underline256Rgb033 = '${underline256Open}37$underline256Close';
const String underline256Rgb034 = '${underline256Open}38$underline256Close';
const String underline256Rgb035 = '${underline256Open}39$underline256Close';
const String underline256Rgb040 = '${underline256Open}40$underline256Close';
const String underline256Rgb041 = '${underline256Open}41$underline256Close';
const String underline256Rgb042 = '${underline256Open}42$underline256Close';
const String underline256Rgb043 = '${underline256Open}43$underline256Close';
const String underline256Rgb044 = '${underline256Open}44$underline256Close';
const String underline256Rgb045 = '${underline256Open}45$underline256Close';
const String underline256Rgb050 = '${underline256Open}46$underline256Close';
const String underline256Rgb051 = '${underline256Open}47$underline256Close';
const String underline256Rgb052 = '${underline256Open}48$underline256Close';
const String underline256Rgb053 = '${underline256Open}49$underline256Close';
const String underline256Rgb054 = '${underline256Open}50$underline256Close';
const String underline256Rgb055 = '${underline256Open}51$underline256Close';
const String underline256Rgb100 = '${underline256Open}52$underline256Close';
const String underline256Rgb101 = '${underline256Open}53$underline256Close';
const String underline256Rgb102 = '${underline256Open}54$underline256Close';
const String underline256Rgb103 = '${underline256Open}55$underline256Close';
const String underline256Rgb104 = '${underline256Open}56$underline256Close';
const String underline256Rgb105 = '${underline256Open}57$underline256Close';
const String underline256Rgb110 = '${underline256Open}58$underline256Close';
const String underline256Rgb111 = '${underline256Open}59$underline256Close';
const String underline256Rgb112 = '${underline256Open}60$underline256Close';
const String underline256Rgb113 = '${underline256Open}61$underline256Close';
const String underline256Rgb114 = '${underline256Open}62$underline256Close';
const String underline256Rgb115 = '${underline256Open}63$underline256Close';
const String underline256Rgb120 = '${underline256Open}64$underline256Close';
const String underline256Rgb121 = '${underline256Open}65$underline256Close';
const String underline256Rgb122 = '${underline256Open}66$underline256Close';
const String underline256Rgb123 = '${underline256Open}67$underline256Close';
const String underline256Rgb124 = '${underline256Open}68$underline256Close';
const String underline256Rgb125 = '${underline256Open}69$underline256Close';
const String underline256Rgb130 = '${underline256Open}70$underline256Close';
const String underline256Rgb131 = '${underline256Open}71$underline256Close';
const String underline256Rgb132 = '${underline256Open}72$underline256Close';
const String underline256Rgb133 = '${underline256Open}73$underline256Close';
const String underline256Rgb134 = '${underline256Open}74$underline256Close';
const String underline256Rgb135 = '${underline256Open}75$underline256Close';
const String underline256Rgb140 = '${underline256Open}76$underline256Close';
const String underline256Rgb141 = '${underline256Open}77$underline256Close';
const String underline256Rgb142 = '${underline256Open}78$underline256Close';
const String underline256Rgb143 = '${underline256Open}79$underline256Close';
const String underline256Rgb144 = '${underline256Open}80$underline256Close';
const String underline256Rgb145 = '${underline256Open}81$underline256Close';
const String underline256Rgb150 = '${underline256Open}82$underline256Close';
const String underline256Rgb151 = '${underline256Open}83$underline256Close';
const String underline256Rgb152 = '${underline256Open}84$underline256Close';
const String underline256Rgb153 = '${underline256Open}85$underline256Close';
const String underline256Rgb154 = '${underline256Open}86$underline256Close';
const String underline256Rgb155 = '${underline256Open}87$underline256Close';
const String underline256Rgb200 = '${underline256Open}88$underline256Close';
const String underline256Rgb201 = '${underline256Open}89$underline256Close';
const String underline256Rgb202 = '${underline256Open}90$underline256Close';
const String underline256Rgb203 = '${underline256Open}91$underline256Close';
const String underline256Rgb204 = '${underline256Open}92$underline256Close';
const String underline256Rgb205 = '${underline256Open}93$underline256Close';
const String underline256Rgb210 = '${underline256Open}94$underline256Close';
const String underline256Rgb211 = '${underline256Open}95$underline256Close';
const String underline256Rgb212 = '${underline256Open}96$underline256Close';
const String underline256Rgb213 = '${underline256Open}97$underline256Close';
const String underline256Rgb214 = '${underline256Open}98$underline256Close';
const String underline256Rgb215 = '${underline256Open}99$underline256Close';
const String underline256Rgb220 = '${underline256Open}100$underline256Close';
const String underline256Rgb221 = '${underline256Open}101$underline256Close';
const String underline256Rgb222 = '${underline256Open}102$underline256Close';
const String underline256Rgb223 = '${underline256Open}103$underline256Close';
const String underline256Rgb224 = '${underline256Open}104$underline256Close';
const String underline256Rgb225 = '${underline256Open}105$underline256Close';
const String underline256Rgb230 = '${underline256Open}106$underline256Close';
const String underline256Rgb231 = '${underline256Open}107$underline256Close';
const String underline256Rgb232 = '${underline256Open}108$underline256Close';
const String underline256Rgb233 = '${underline256Open}109$underline256Close';
const String underline256Rgb234 = '${underline256Open}110$underline256Close';
const String underline256Rgb235 = '${underline256Open}111$underline256Close';
const String underline256Rgb240 = '${underline256Open}112$underline256Close';
const String underline256Rgb241 = '${underline256Open}113$underline256Close';
const String underline256Rgb242 = '${underline256Open}114$underline256Close';
const String underline256Rgb243 = '${underline256Open}115$underline256Close';
const String underline256Rgb244 = '${underline256Open}116$underline256Close';
const String underline256Rgb245 = '${underline256Open}117$underline256Close';
const String underline256Rgb250 = '${underline256Open}118$underline256Close';
const String underline256Rgb251 = '${underline256Open}119$underline256Close';
const String underline256Rgb252 = '${underline256Open}120$underline256Close';
const String underline256Rgb253 = '${underline256Open}121$underline256Close';
const String underline256Rgb254 = '${underline256Open}122$underline256Close';
const String underline256Rgb255 = '${underline256Open}123$underline256Close';
const String underline256Rgb300 = '${underline256Open}124$underline256Close';
const String underline256Rgb301 = '${underline256Open}125$underline256Close';
const String underline256Rgb302 = '${underline256Open}126$underline256Close';
const String underline256Rgb303 = '${underline256Open}127$underline256Close';
const String underline256Rgb304 = '${underline256Open}128$underline256Close';
const String underline256Rgb305 = '${underline256Open}129$underline256Close';
const String underline256Rgb310 = '${underline256Open}130$underline256Close';
const String underline256Rgb311 = '${underline256Open}131$underline256Close';
const String underline256Rgb312 = '${underline256Open}132$underline256Close';
const String underline256Rgb313 = '${underline256Open}133$underline256Close';
const String underline256Rgb314 = '${underline256Open}134$underline256Close';
const String underline256Rgb315 = '${underline256Open}135$underline256Close';
const String underline256Rgb320 = '${underline256Open}136$underline256Close';
const String underline256Rgb321 = '${underline256Open}137$underline256Close';
const String underline256Rgb322 = '${underline256Open}138$underline256Close';
const String underline256Rgb323 = '${underline256Open}139$underline256Close';
const String underline256Rgb324 = '${underline256Open}140$underline256Close';
const String underline256Rgb325 = '${underline256Open}141$underline256Close';
const String underline256Rgb330 = '${underline256Open}142$underline256Close';
const String underline256Rgb331 = '${underline256Open}143$underline256Close';
const String underline256Rgb332 = '${underline256Open}144$underline256Close';
const String underline256Rgb333 = '${underline256Open}145$underline256Close';
const String underline256Rgb334 = '${underline256Open}146$underline256Close';
const String underline256Rgb335 = '${underline256Open}147$underline256Close';
const String underline256Rgb340 = '${underline256Open}148$underline256Close';
const String underline256Rgb341 = '${underline256Open}149$underline256Close';
const String underline256Rgb342 = '${underline256Open}150$underline256Close';
const String underline256Rgb343 = '${underline256Open}151$underline256Close';
const String underline256Rgb344 = '${underline256Open}152$underline256Close';
const String underline256Rgb345 = '${underline256Open}153$underline256Close';
const String underline256Rgb350 = '${underline256Open}154$underline256Close';
const String underline256Rgb351 = '${underline256Open}155$underline256Close';
const String underline256Rgb352 = '${underline256Open}156$underline256Close';
const String underline256Rgb353 = '${underline256Open}157$underline256Close';
const String underline256Rgb354 = '${underline256Open}158$underline256Close';
const String underline256Rgb355 = '${underline256Open}159$underline256Close';
const String underline256Rgb400 = '${underline256Open}160$underline256Close';
const String underline256Rgb401 = '${underline256Open}161$underline256Close';
const String underline256Rgb402 = '${underline256Open}162$underline256Close';
const String underline256Rgb403 = '${underline256Open}163$underline256Close';
const String underline256Rgb404 = '${underline256Open}164$underline256Close';
const String underline256Rgb405 = '${underline256Open}165$underline256Close';
const String underline256Rgb410 = '${underline256Open}166$underline256Close';
const String underline256Rgb411 = '${underline256Open}167$underline256Close';
const String underline256Rgb412 = '${underline256Open}168$underline256Close';
const String underline256Rgb413 = '${underline256Open}169$underline256Close';
const String underline256Rgb414 = '${underline256Open}170$underline256Close';
const String underline256Rgb415 = '${underline256Open}171$underline256Close';
const String underline256Rgb420 = '${underline256Open}172$underline256Close';
const String underline256Rgb421 = '${underline256Open}173$underline256Close';
const String underline256Rgb422 = '${underline256Open}174$underline256Close';
const String underline256Rgb423 = '${underline256Open}175$underline256Close';
const String underline256Rgb424 = '${underline256Open}176$underline256Close';
const String underline256Rgb425 = '${underline256Open}177$underline256Close';
const String underline256Rgb430 = '${underline256Open}178$underline256Close';
const String underline256Rgb431 = '${underline256Open}179$underline256Close';
const String underline256Rgb432 = '${underline256Open}180$underline256Close';
const String underline256Rgb433 = '${underline256Open}181$underline256Close';
const String underline256Rgb434 = '${underline256Open}182$underline256Close';
const String underline256Rgb435 = '${underline256Open}183$underline256Close';
const String underline256Rgb440 = '${underline256Open}184$underline256Close';
const String underline256Rgb441 = '${underline256Open}185$underline256Close';
const String underline256Rgb442 = '${underline256Open}186$underline256Close';
const String underline256Rgb443 = '${underline256Open}187$underline256Close';
const String underline256Rgb444 = '${underline256Open}188$underline256Close';
const String underline256Rgb445 = '${underline256Open}189$underline256Close';
const String underline256Rgb450 = '${underline256Open}190$underline256Close';
const String underline256Rgb451 = '${underline256Open}191$underline256Close';
const String underline256Rgb452 = '${underline256Open}192$underline256Close';
const String underline256Rgb453 = '${underline256Open}193$underline256Close';
const String underline256Rgb454 = '${underline256Open}194$underline256Close';
const String underline256Rgb455 = '${underline256Open}195$underline256Close';
const String underline256Rgb500 = '${underline256Open}196$underline256Close';
const String underline256Rgb501 = '${underline256Open}197$underline256Close';
const String underline256Rgb502 = '${underline256Open}198$underline256Close';
const String underline256Rgb503 = '${underline256Open}199$underline256Close';
const String underline256Rgb504 = '${underline256Open}200$underline256Close';
const String underline256Rgb505 = '${underline256Open}201$underline256Close';
const String underline256Rgb510 = '${underline256Open}202$underline256Close';
const String underline256Rgb511 = '${underline256Open}203$underline256Close';
const String underline256Rgb512 = '${underline256Open}204$underline256Close';
const String underline256Rgb513 = '${underline256Open}205$underline256Close';
const String underline256Rgb514 = '${underline256Open}206$underline256Close';
const String underline256Rgb515 = '${underline256Open}207$underline256Close';
const String underline256Rgb520 = '${underline256Open}208$underline256Close';
const String underline256Rgb521 = '${underline256Open}209$underline256Close';
const String underline256Rgb522 = '${underline256Open}210$underline256Close';
const String underline256Rgb523 = '${underline256Open}211$underline256Close';
const String underline256Rgb524 = '${underline256Open}212$underline256Close';
const String underline256Rgb525 = '${underline256Open}213$underline256Close';
const String underline256Rgb530 = '${underline256Open}214$underline256Close';
const String underline256Rgb531 = '${underline256Open}215$underline256Close';
const String underline256Rgb532 = '${underline256Open}216$underline256Close';
const String underline256Rgb533 = '${underline256Open}217$underline256Close';
const String underline256Rgb534 = '${underline256Open}218$underline256Close';
const String underline256Rgb535 = '${underline256Open}219$underline256Close';
const String underline256Rgb540 = '${underline256Open}220$underline256Close';
const String underline256Rgb541 = '${underline256Open}221$underline256Close';
const String underline256Rgb542 = '${underline256Open}222$underline256Close';
const String underline256Rgb543 = '${underline256Open}223$underline256Close';
const String underline256Rgb544 = '${underline256Open}224$underline256Close';
const String underline256Rgb545 = '${underline256Open}225$underline256Close';
const String underline256Rgb550 = '${underline256Open}226$underline256Close';
const String underline256Rgb551 = '${underline256Open}227$underline256Close';
const String underline256Rgb552 = '${underline256Open}228$underline256Close';
const String underline256Rgb553 = '${underline256Open}229$underline256Close';
const String underline256Rgb554 = '${underline256Open}230$underline256Close';
const String underline256Rgb555 = '${underline256Open}231$underline256Close';

// Grayscale from dark to light in 24 steps.

const String underline256Gray0 = '${underline256Open}232$underline256Close';
const String underline256Gray1 = '${underline256Open}233$underline256Close';
const String underline256Gray2 = '${underline256Open}234$underline256Close';
const String underline256Gray3 = '${underline256Open}235$underline256Close';
const String underline256Gray4 = '${underline256Open}236$underline256Close';
const String underline256Gray5 = '${underline256Open}237$underline256Close';
const String underline256Gray6 = '${underline256Open}238$underline256Close';
const String underline256Gray7 = '${underline256Open}239$underline256Close';
const String underline256Gray8 = '${underline256Open}240$underline256Close';
const String underline256Gray9 = '${underline256Open}241$underline256Close';
const String underline256Gray10 = '${underline256Open}242$underline256Close';
const String underline256Gray11 = '${underline256Open}243$underline256Close';
const String underline256Gray12 = '${underline256Open}244$underline256Close';
const String underline256Gray13 = '${underline256Open}245$underline256Close';
const String underline256Gray14 = '${underline256Open}246$underline256Close';
const String underline256Gray15 = '${underline256Open}247$underline256Close';
const String underline256Gray16 = '${underline256Open}248$underline256Close';
const String underline256Gray17 = '${underline256Open}249$underline256Close';
const String underline256Gray18 = '${underline256Open}250$underline256Close';
const String underline256Gray19 = '${underline256Open}251$underline256Close';
const String underline256Gray20 = '${underline256Open}252$underline256Close';
const String underline256Gray21 = '${underline256Open}253$underline256Close';
const String underline256Gray22 = '${underline256Open}254$underline256Close';
const String underline256Gray23 = '${underline256Open}255$underline256Close';
