import 'sgr_colors.dart';

//
// ANSI escape codes for background from 256-color table.
//

// Standard colors.

const String bg256Black = '${bg256Open}0$bg256Close';
const String bg256Red = '${bg256Open}1$bg256Close';
const String bg256Green = '${bg256Open}2$bg256Close';
const String bg256Yellow = '${bg256Open}3$bg256Close';
const String bg256Blue = '${bg256Open}4$bg256Close';
const String bg256Magenta = '${bg256Open}5$bg256Close';
const String bg256Cyan = '${bg256Open}6$bg256Close';
const String bg256White = '${bg256Open}7$bg256Close';

// High intensity colors.

const String bg256HighBlack = '${bg256Open}8$bg256Close';
const String bg256HighRed = '${bg256Open}9$bg256Close';
const String bg256HighGreen = '${bg256Open}10$bg256Close';
const String bg256HighYellow = '${bg256Open}11$bg256Close';
const String bg256HighBlue = '${bg256Open}12$bg256Close';
const String bg256HighMagenta = '${bg256Open}13$bg256Close';
const String bg256HighCyan = '${bg256Open}14$bg256Close';
const String bg256HighWhite = '${bg256Open}15$bg256Close';

// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b (r,g,b = 0..5).

const String bg256Rgb000 = '${bg256Open}16$bg256Close';
const String bg256Rgb001 = '${bg256Open}17$bg256Close';
const String bg256Rgb002 = '${bg256Open}18$bg256Close';
const String bg256Rgb003 = '${bg256Open}19$bg256Close';
const String bg256Rgb004 = '${bg256Open}20$bg256Close';
const String bg256Rgb005 = '${bg256Open}21$bg256Close';
const String bg256Rgb010 = '${bg256Open}22$bg256Close';
const String bg256Rgb011 = '${bg256Open}23$bg256Close';
const String bg256Rgb012 = '${bg256Open}24$bg256Close';
const String bg256Rgb013 = '${bg256Open}25$bg256Close';
const String bg256Rgb014 = '${bg256Open}26$bg256Close';
const String bg256Rgb015 = '${bg256Open}27$bg256Close';
const String bg256Rgb020 = '${bg256Open}28$bg256Close';
const String bg256Rgb021 = '${bg256Open}29$bg256Close';
const String bg256Rgb022 = '${bg256Open}30$bg256Close';
const String bg256Rgb023 = '${bg256Open}31$bg256Close';
const String bg256Rgb024 = '${bg256Open}32$bg256Close';
const String bg256Rgb025 = '${bg256Open}33$bg256Close';
const String bg256Rgb030 = '${bg256Open}34$bg256Close';
const String bg256Rgb031 = '${bg256Open}35$bg256Close';
const String bg256Rgb032 = '${bg256Open}36$bg256Close';
const String bg256Rgb033 = '${bg256Open}37$bg256Close';
const String bg256Rgb034 = '${bg256Open}38$bg256Close';
const String bg256Rgb035 = '${bg256Open}39$bg256Close';
const String bg256Rgb040 = '${bg256Open}40$bg256Close';
const String bg256Rgb041 = '${bg256Open}41$bg256Close';
const String bg256Rgb042 = '${bg256Open}42$bg256Close';
const String bg256Rgb043 = '${bg256Open}43$bg256Close';
const String bg256Rgb044 = '${bg256Open}44$bg256Close';
const String bg256Rgb045 = '${bg256Open}45$bg256Close';
const String bg256Rgb050 = '${bg256Open}46$bg256Close';
const String bg256Rgb051 = '${bg256Open}47$bg256Close';
const String bg256Rgb052 = '${bg256Open}48$bg256Close';
const String bg256Rgb053 = '${bg256Open}49$bg256Close';
const String bg256Rgb054 = '${bg256Open}50$bg256Close';
const String bg256Rgb055 = '${bg256Open}51$bg256Close';
const String bg256Rgb100 = '${bg256Open}52$bg256Close';
const String bg256Rgb101 = '${bg256Open}53$bg256Close';
const String bg256Rgb102 = '${bg256Open}54$bg256Close';
const String bg256Rgb103 = '${bg256Open}55$bg256Close';
const String bg256Rgb104 = '${bg256Open}56$bg256Close';
const String bg256Rgb105 = '${bg256Open}57$bg256Close';
const String bg256Rgb110 = '${bg256Open}58$bg256Close';
const String bg256Rgb111 = '${bg256Open}59$bg256Close';
const String bg256Rgb112 = '${bg256Open}60$bg256Close';
const String bg256Rgb113 = '${bg256Open}61$bg256Close';
const String bg256Rgb114 = '${bg256Open}62$bg256Close';
const String bg256Rgb115 = '${bg256Open}63$bg256Close';
const String bg256Rgb120 = '${bg256Open}64$bg256Close';
const String bg256Rgb121 = '${bg256Open}65$bg256Close';
const String bg256Rgb122 = '${bg256Open}66$bg256Close';
const String bg256Rgb123 = '${bg256Open}67$bg256Close';
const String bg256Rgb124 = '${bg256Open}68$bg256Close';
const String bg256Rgb125 = '${bg256Open}69$bg256Close';
const String bg256Rgb130 = '${bg256Open}70$bg256Close';
const String bg256Rgb131 = '${bg256Open}71$bg256Close';
const String bg256Rgb132 = '${bg256Open}72$bg256Close';
const String bg256Rgb133 = '${bg256Open}73$bg256Close';
const String bg256Rgb134 = '${bg256Open}74$bg256Close';
const String bg256Rgb135 = '${bg256Open}75$bg256Close';
const String bg256Rgb140 = '${bg256Open}76$bg256Close';
const String bg256Rgb141 = '${bg256Open}77$bg256Close';
const String bg256Rgb142 = '${bg256Open}78$bg256Close';
const String bg256Rgb143 = '${bg256Open}79$bg256Close';
const String bg256Rgb144 = '${bg256Open}80$bg256Close';
const String bg256Rgb145 = '${bg256Open}81$bg256Close';
const String bg256Rgb150 = '${bg256Open}82$bg256Close';
const String bg256Rgb151 = '${bg256Open}83$bg256Close';
const String bg256Rgb152 = '${bg256Open}84$bg256Close';
const String bg256Rgb153 = '${bg256Open}85$bg256Close';
const String bg256Rgb154 = '${bg256Open}86$bg256Close';
const String bg256Rgb155 = '${bg256Open}87$bg256Close';
const String bg256Rgb200 = '${bg256Open}88$bg256Close';
const String bg256Rgb201 = '${bg256Open}89$bg256Close';
const String bg256Rgb202 = '${bg256Open}90$bg256Close';
const String bg256Rgb203 = '${bg256Open}91$bg256Close';
const String bg256Rgb204 = '${bg256Open}92$bg256Close';
const String bg256Rgb205 = '${bg256Open}93$bg256Close';
const String bg256Rgb210 = '${bg256Open}94$bg256Close';
const String bg256Rgb211 = '${bg256Open}95$bg256Close';
const String bg256Rgb212 = '${bg256Open}96$bg256Close';
const String bg256Rgb213 = '${bg256Open}97$bg256Close';
const String bg256Rgb214 = '${bg256Open}98$bg256Close';
const String bg256Rgb215 = '${bg256Open}99$bg256Close';
const String bg256Rgb220 = '${bg256Open}100$bg256Close';
const String bg256Rgb221 = '${bg256Open}101$bg256Close';
const String bg256Rgb222 = '${bg256Open}102$bg256Close';
const String bg256Rgb223 = '${bg256Open}103$bg256Close';
const String bg256Rgb224 = '${bg256Open}104$bg256Close';
const String bg256Rgb225 = '${bg256Open}105$bg256Close';
const String bg256Rgb230 = '${bg256Open}106$bg256Close';
const String bg256Rgb231 = '${bg256Open}107$bg256Close';
const String bg256Rgb232 = '${bg256Open}108$bg256Close';
const String bg256Rgb233 = '${bg256Open}109$bg256Close';
const String bg256Rgb234 = '${bg256Open}110$bg256Close';
const String bg256Rgb235 = '${bg256Open}111$bg256Close';
const String bg256Rgb240 = '${bg256Open}112$bg256Close';
const String bg256Rgb241 = '${bg256Open}113$bg256Close';
const String bg256Rgb242 = '${bg256Open}114$bg256Close';
const String bg256Rgb243 = '${bg256Open}115$bg256Close';
const String bg256Rgb244 = '${bg256Open}116$bg256Close';
const String bg256Rgb245 = '${bg256Open}117$bg256Close';
const String bg256Rgb250 = '${bg256Open}118$bg256Close';
const String bg256Rgb251 = '${bg256Open}119$bg256Close';
const String bg256Rgb252 = '${bg256Open}120$bg256Close';
const String bg256Rgb253 = '${bg256Open}121$bg256Close';
const String bg256Rgb254 = '${bg256Open}122$bg256Close';
const String bg256Rgb255 = '${bg256Open}123$bg256Close';
const String bg256Rgb300 = '${bg256Open}124$bg256Close';
const String bg256Rgb301 = '${bg256Open}125$bg256Close';
const String bg256Rgb302 = '${bg256Open}126$bg256Close';
const String bg256Rgb303 = '${bg256Open}127$bg256Close';
const String bg256Rgb304 = '${bg256Open}128$bg256Close';
const String bg256Rgb305 = '${bg256Open}129$bg256Close';
const String bg256Rgb310 = '${bg256Open}130$bg256Close';
const String bg256Rgb311 = '${bg256Open}131$bg256Close';
const String bg256Rgb312 = '${bg256Open}132$bg256Close';
const String bg256Rgb313 = '${bg256Open}133$bg256Close';
const String bg256Rgb314 = '${bg256Open}134$bg256Close';
const String bg256Rgb315 = '${bg256Open}135$bg256Close';
const String bg256Rgb320 = '${bg256Open}136$bg256Close';
const String bg256Rgb321 = '${bg256Open}137$bg256Close';
const String bg256Rgb322 = '${bg256Open}138$bg256Close';
const String bg256Rgb323 = '${bg256Open}139$bg256Close';
const String bg256Rgb324 = '${bg256Open}140$bg256Close';
const String bg256Rgb325 = '${bg256Open}141$bg256Close';
const String bg256Rgb330 = '${bg256Open}142$bg256Close';
const String bg256Rgb331 = '${bg256Open}143$bg256Close';
const String bg256Rgb332 = '${bg256Open}144$bg256Close';
const String bg256Rgb333 = '${bg256Open}145$bg256Close';
const String bg256Rgb334 = '${bg256Open}146$bg256Close';
const String bg256Rgb335 = '${bg256Open}147$bg256Close';
const String bg256Rgb340 = '${bg256Open}148$bg256Close';
const String bg256Rgb341 = '${bg256Open}149$bg256Close';
const String bg256Rgb342 = '${bg256Open}150$bg256Close';
const String bg256Rgb343 = '${bg256Open}151$bg256Close';
const String bg256Rgb344 = '${bg256Open}152$bg256Close';
const String bg256Rgb345 = '${bg256Open}153$bg256Close';
const String bg256Rgb350 = '${bg256Open}154$bg256Close';
const String bg256Rgb351 = '${bg256Open}155$bg256Close';
const String bg256Rgb352 = '${bg256Open}156$bg256Close';
const String bg256Rgb353 = '${bg256Open}157$bg256Close';
const String bg256Rgb354 = '${bg256Open}158$bg256Close';
const String bg256Rgb355 = '${bg256Open}159$bg256Close';
const String bg256Rgb400 = '${bg256Open}160$bg256Close';
const String bg256Rgb401 = '${bg256Open}161$bg256Close';
const String bg256Rgb402 = '${bg256Open}162$bg256Close';
const String bg256Rgb403 = '${bg256Open}163$bg256Close';
const String bg256Rgb404 = '${bg256Open}164$bg256Close';
const String bg256Rgb405 = '${bg256Open}165$bg256Close';
const String bg256Rgb410 = '${bg256Open}166$bg256Close';
const String bg256Rgb411 = '${bg256Open}167$bg256Close';
const String bg256Rgb412 = '${bg256Open}168$bg256Close';
const String bg256Rgb413 = '${bg256Open}169$bg256Close';
const String bg256Rgb414 = '${bg256Open}170$bg256Close';
const String bg256Rgb415 = '${bg256Open}171$bg256Close';
const String bg256Rgb420 = '${bg256Open}172$bg256Close';
const String bg256Rgb421 = '${bg256Open}173$bg256Close';
const String bg256Rgb422 = '${bg256Open}174$bg256Close';
const String bg256Rgb423 = '${bg256Open}175$bg256Close';
const String bg256Rgb424 = '${bg256Open}176$bg256Close';
const String bg256Rgb425 = '${bg256Open}177$bg256Close';
const String bg256Rgb430 = '${bg256Open}178$bg256Close';
const String bg256Rgb431 = '${bg256Open}179$bg256Close';
const String bg256Rgb432 = '${bg256Open}180$bg256Close';
const String bg256Rgb433 = '${bg256Open}181$bg256Close';
const String bg256Rgb434 = '${bg256Open}182$bg256Close';
const String bg256Rgb435 = '${bg256Open}183$bg256Close';
const String bg256Rgb440 = '${bg256Open}184$bg256Close';
const String bg256Rgb441 = '${bg256Open}185$bg256Close';
const String bg256Rgb442 = '${bg256Open}186$bg256Close';
const String bg256Rgb443 = '${bg256Open}187$bg256Close';
const String bg256Rgb444 = '${bg256Open}188$bg256Close';
const String bg256Rgb445 = '${bg256Open}189$bg256Close';
const String bg256Rgb450 = '${bg256Open}190$bg256Close';
const String bg256Rgb451 = '${bg256Open}191$bg256Close';
const String bg256Rgb452 = '${bg256Open}192$bg256Close';
const String bg256Rgb453 = '${bg256Open}193$bg256Close';
const String bg256Rgb454 = '${bg256Open}194$bg256Close';
const String bg256Rgb455 = '${bg256Open}195$bg256Close';
const String bg256Rgb500 = '${bg256Open}196$bg256Close';
const String bg256Rgb501 = '${bg256Open}197$bg256Close';
const String bg256Rgb502 = '${bg256Open}198$bg256Close';
const String bg256Rgb503 = '${bg256Open}199$bg256Close';
const String bg256Rgb504 = '${bg256Open}200$bg256Close';
const String bg256Rgb505 = '${bg256Open}201$bg256Close';
const String bg256Rgb510 = '${bg256Open}202$bg256Close';
const String bg256Rgb511 = '${bg256Open}203$bg256Close';
const String bg256Rgb512 = '${bg256Open}204$bg256Close';
const String bg256Rgb513 = '${bg256Open}205$bg256Close';
const String bg256Rgb514 = '${bg256Open}206$bg256Close';
const String bg256Rgb515 = '${bg256Open}207$bg256Close';
const String bg256Rgb520 = '${bg256Open}208$bg256Close';
const String bg256Rgb521 = '${bg256Open}209$bg256Close';
const String bg256Rgb522 = '${bg256Open}210$bg256Close';
const String bg256Rgb523 = '${bg256Open}211$bg256Close';
const String bg256Rgb524 = '${bg256Open}212$bg256Close';
const String bg256Rgb525 = '${bg256Open}213$bg256Close';
const String bg256Rgb530 = '${bg256Open}214$bg256Close';
const String bg256Rgb531 = '${bg256Open}215$bg256Close';
const String bg256Rgb532 = '${bg256Open}216$bg256Close';
const String bg256Rgb533 = '${bg256Open}217$bg256Close';
const String bg256Rgb534 = '${bg256Open}218$bg256Close';
const String bg256Rgb535 = '${bg256Open}219$bg256Close';
const String bg256Rgb540 = '${bg256Open}220$bg256Close';
const String bg256Rgb541 = '${bg256Open}221$bg256Close';
const String bg256Rgb542 = '${bg256Open}222$bg256Close';
const String bg256Rgb543 = '${bg256Open}223$bg256Close';
const String bg256Rgb544 = '${bg256Open}224$bg256Close';
const String bg256Rgb545 = '${bg256Open}225$bg256Close';
const String bg256Rgb550 = '${bg256Open}226$bg256Close';
const String bg256Rgb551 = '${bg256Open}227$bg256Close';
const String bg256Rgb552 = '${bg256Open}228$bg256Close';
const String bg256Rgb553 = '${bg256Open}229$bg256Close';
const String bg256Rgb554 = '${bg256Open}230$bg256Close';
const String bg256Rgb555 = '${bg256Open}231$bg256Close';

// Grayscale from dark to light in 24 steps.

const String bg256Gray0 = '${bg256Open}232$bg256Close';
const String bg256Gray1 = '${bg256Open}233$bg256Close';
const String bg256Gray2 = '${bg256Open}234$bg256Close';
const String bg256Gray3 = '${bg256Open}235$bg256Close';
const String bg256Gray4 = '${bg256Open}236$bg256Close';
const String bg256Gray5 = '${bg256Open}237$bg256Close';
const String bg256Gray6 = '${bg256Open}238$bg256Close';
const String bg256Gray7 = '${bg256Open}239$bg256Close';
const String bg256Gray8 = '${bg256Open}240$bg256Close';
const String bg256Gray9 = '${bg256Open}241$bg256Close';
const String bg256Gray10 = '${bg256Open}242$bg256Close';
const String bg256Gray11 = '${bg256Open}243$bg256Close';
const String bg256Gray12 = '${bg256Open}244$bg256Close';
const String bg256Gray13 = '${bg256Open}245$bg256Close';
const String bg256Gray14 = '${bg256Open}246$bg256Close';
const String bg256Gray15 = '${bg256Open}247$bg256Close';
const String bg256Gray16 = '${bg256Open}248$bg256Close';
const String bg256Gray17 = '${bg256Open}249$bg256Close';
const String bg256Gray18 = '${bg256Open}250$bg256Close';
const String bg256Gray19 = '${bg256Open}251$bg256Close';
const String bg256Gray20 = '${bg256Open}252$bg256Close';
const String bg256Gray21 = '${bg256Open}253$bg256Close';
const String bg256Gray22 = '${bg256Open}254$bg256Close';
const String bg256Gray23 = '${bg256Open}255$bg256Close';
