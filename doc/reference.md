# The bytes and what they mean

Every control function this package names, in the order the standard puts them
in: what the byte is, what it does, and the constant that writes it.

This is the reference. The [readme](../README.md) is the part that is read
rather than searched, and it carries the table of ready-to-use values a writer
reaches for while writing.

The constants of this page come from one import:

```dart
import 'package:ansi_escape_codes/ansi.dart';
```

Their ready-to-use counterparts — `fgRed` beside `FG_RED`, `cursorUp` beside
`CUU` — come from the main one:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
```

## Table of contents

- [Control codes (C0 set)](#control-codes-c0-set)
- [Control functions ESC Fe (C1 set)](#control-functions-esc-fe-c1-set)
- [Control sequences (CSI)](#control-sequences-csi)
- [Independent control functions ESC Fs](#independent-control-functions-esc-fs)
- [Select graphic rendition (SGR)](#select-graphic-rendition-sgr)
- [256-color table](#256-color-table)
- [24-bit RGB colors](#24-bit-rgb-colors)


## Control codes (C0 set)

These control functions (control codes) are represented by codes from 0x00 to
0x1F. Some control functions from the C0 set:

| Constant   | Code           | Description                                  |
|:-----------|:--------------:|:---------------------------------------------|
| `NUL`      | `\x00`         | Null                                         |
| `BEL`      | `\x07`         | Bell (terminals can block the bell)          |
| `BS`       | `\b` or `\x08` | Backspace                                    |
| `HT`       | `\t` or `\x09` | Horizontal tabulation                        |
| `LF`       | `\n` or `\x0A` | Line feed                                    |
| `FF`       | `\f` or `\x0C` | Form feed                                    |
| `CR`       | `\r` or `\x0D` | Carriage return                              |
| `ESC`      | `\x1B`         | Escape (is used for code extension purposes) |


```dart
import 'package:ansi_escape_codes/ansi.dart';

…

// The following examples are equivalent:
print('\t\r\n');
print('$HT$CR$LF');
```


## Control functions ESC Fe (C1 set)

These control functions are represented by 2-character escape sequences
of the form ESC Fe, where ESC is represented by code 0x1B and Fe is
represented by codes from 0x40 to 0x5F.

Some control functions from the C1 set:

| Constant   | Code    | Description                 |
|:-----------|:--------|:----------------------------|
| `CSI`      | `ESC [` | Control Sequence Introducer |
| `ST`       | `ESC \` | String Terminator           |
| `OSC`      | `ESC ]` | Operating System Command    |
| `HTS`      | `ESC H` | Character Tabulation Set    |

```dart
import 'package:ansi_escape_codes/ansi.dart';

…

// Clear screen
print('Erase screen${CSI}2JScreen erased');

// Set new tabulation stops
print('$HTS  $HTS  $HTS  $HTS');
print('1\t2\t3\t4'); // 1 2 3 4
print('${CSI}3g'); // Reset tabulations stops to default

// Link (it doesn't work everywhere)
print('Go to ${OSC}8;;https://pub.dev/packages/ansi_escape_codes${ST}pub.dev${OSC}8;;$ST');
```


## Control sequences (CSI)

A control sequence is a string starting with the control function CONTROL
SEQUENCE INTRODUCER [CSI] followed by one or more bytes representing
parameters, if any, and by one or more bytes identifying the control
function. The control function [CSI] itself is an element of the C1
set.

Some control functions from this set:

| Constant   | Code         | Description                                                           |
|:-----------|:-------------|:----------------------------------------------------------------------|
| `CUU`      | `CSI n A`    | Cursor up by `n` lines                                                |
| `CUD`      | `CSI n B`    | Cursor down by `n` lines                                              |
| `CUF`      | `CSI n C`    | Cursor right (forward) by `n` characters                              |
| `CUB`      | `CSI n D`    | Cursor left (backward) by `n` characters                              |
| `CUP`      | `CSI n;m H`  | Cursor position to `n`-th line, `m`-th character                      |
| `ED`       | `CSI s J`    | Erase in page (in display) (`s`=2 - entire screen)                    |
| `DCH`      | `CSI n P`    | Delete n characters                                                   |
| `ECH`      | `CSI n X`    | Erase n characters                                                    |
| `TBC`      | `CSI s g`    | Tabulation clear (`s`=3 - all character tabulation stops are cleared) |
| `SM`       | `CSI s h`    | Set mode (`s`=4 - INSERTION REPLACEMENT MODE)                         |
| `RM`       | `CSI s l`    | Reset mode                                                            |
| `SGR`      | `CSI s… m`   | Select graphic rendition                                              |

```dart
import 'package:ansi_escape_codes/ansi.dart';

…

// Cursor left by 4 characters
// Delete 1 character ('1')
// Cursor right by 1 character
// Erase 1 character ('3')
print('1234${CSI}4$CUB$CSI$DCH$CSI$CUF$CSI$ECH'); // '2 4'

// Insertion mode
print('${CSI}4${SM}tree${CSI}3${CUB}h'); // three
print('${CSI}4${RM}tree${CSI}3${CUB}h'); // thee

// Italic text
print('${CSI}3$SGR Italic text ${CSI}0$SGR');
```


## Independent control functions ESC Fs

These control functions are represented by 2-character escape sequences of the
form ESC Fs, where ESC is represented by code 0x1B and Fs is represented by
codes from 0x60 to 0x7E.

They are called independent because the shift states and the announced code
structure do not affect them: whatever the terminal has been told about the
coding in use, these keep their meaning.

| Constant | Code    | Description                                        |
|:---------|:--------|:---------------------------------------------------|
| `DMI`    | `ESC` `` ` `` | Disable manual input                         |
| `INT`    | `ESC a` | Interrupt                                          |
| `EMI`    | `ESC b` | Enable manual input                                |
| `RIS`    | `ESC c` | Reset to initial state                             |
| `CMD`    | `ESC d` | Coding method delimiter                            |
| `LS2`    | `ESC n` | Locking-shift two: invoke G2 into columns 02 to 07 |
| `LS3`    | `ESC o` | Locking-shift three: invoke G3 into columns 02 to 07 |
| `LS3R`   | `ESC \|` | Locking-shift three right: invoke G3 into columns 10 to 15 |
| `LS2R`   | `ESC }` | Locking-shift two right: invoke G2 into columns 10 to 15 |
| `LS1R`   | `ESC ~` | Locking-shift one right: invoke G1 into columns 10 to 15 |

The one in everyday use is `RIS`. It resets the terminal to the state it has
when it is made operational: the screen is cleared, the tabulation stops and
the graphic rendition go back to their defaults, and the cursor returns to the
first position of the first line. `reset` (SGR 0), by comparison, ends the
graphic rendition and touches nothing else.

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

// The following examples are equivalent:
print('\x1Bc');
print(RIS);
print(resetTerminal);
```

The parser names them:

```dart
print(Parser('${resetTerminal}Fresh start').showControlFunctions());
// [ESC RIS]Fresh start
```


## Select graphic rendition (SGR)

Template for working with graphic rendition:

```
CSI s… SGR
```

Or, on Dart:

```dart
const str = '$CSI$s$SGR';
```

Where `s` is:

| Value | Constant                  | Using                    | Description                                                |
|------:|:--------------------------|:-------------------------|:-----------------------------------------------------------|
|     0 | `RESET`                   | `reset`                  | Default rendition (implementation-defined), cancels the effect of any preceding occurrence of SGR |
|     1 | `BOLD`                    | `bold`                   | Bold or increased intensity |
|     2 | `DIM`                     | `dim`                    | Dim, decreased intensity or second color |
|     3 | `ITALIC`                  | `italic`                 | Italic |
|     4 | `UNDERLINE`               | `underline`              | Underline |
|     5 | `BLINK`                   | `blink`                  | Blink |
|     6 | `BLINK_RAPID`             | `blinkRapid`             | Blink rapid |
|     7 | `INVERSE`                 | `inverse`                | Inverse |
|     8 | `INVISIBLE`               | `invisible`              | Invisible characters |
|     9 | `STRIKETHROUGH`           | `strikethrough`          | Strikethrough (characters still legible but marked as to be deleted) |
|    10 | `PRIMARY_FONT`            |                          | Primary (default) font |
|    11 | `ALT_FONT_1`              |                          | First alternative font |
|    12 | `ALT_FONT_2`              |                          | Second alternative font |
|    13 | `ALT_FONT_3`              |                          | Third alternative font |
|    14 | `ALT_FONT_4`              |                          | Fourth alternative font |
|    15 | `ALT_FONT_5`              |                          | Fifth alternative font |
|    16 | `ALT_FONT_6`              |                          | Sixth alternative font |
|    17 | `ALT_FONT_7`              |                          | Seventh alternative font |
|    18 | `ALT_FONT_8`              |                          | Eighth alternative font |
|    19 | `ALT_FONT_9`              |                          | Ninth alternative font |
|    20 | `FRAKTUR`                 |                          | Fraktur (Gothic) |
|    21 | `DOUBLY_UNDERLINE`        | `doublyUnderline`        | Doubly underline |
|    22 | `NOT_BOLD_NOT_DIM`        | `resetBoldAndDim`        | Normal colour or normal intensity (neither bold nor dim) |
|    23 | `NOT_ITALIC`              | `resetItalic`            | Not italic, not fraktur |
|    24 | `NOT_UNDERLINE`           | `resetUnderline`         | Not underline (neither singly nor doubly) |
|    25 | `NOT_BLINK`               | `resetBlink`             | Steady (not blink) |
|    27 | `NOT_INVERSE`             | `resetInverse`           | Positive image (not inverse) |
|    28 | `NOT_INVISIBLE`           | `resetInvisible`         | Revealed characters (not invisible) |
|    29 | `NOT_STRIKETHROUGH`       | `resetStrikethrough`     | Not strikethrough |
|    30 | `FG_BLACK`                | `fgBlack`                | Black display |
|    31 | `FG_RED`                  | `fgRed`                  | Red display |
|    32 | `FG_GREEN`                | `fgGreen`                | Green display |
|    33 | `FG_YELLOW`               | `fgYellow`               | Yellow display |
|    34 | `FG_BLUE`                 | `fgBlue`                 | Blue display |
|    35 | `FG_MAGENTA`              | `fgMagenta`              | Magenta display |
|    36 | `FG_CYAN`                 | `fgCyan`                 | Cyan display |
|    37 | `FG_WHITE`                | `fgWhite`                | White display |
|    38 | `FOREGROUND`              | `fg256…/fgRgb…`          | Display color from [256-color table](#256-color-table) or by [RGB](#24-bit-rgb-colors) |
|    39 | `FG_DEFAULT`              | `resetFg`                | Default display color (implementation-defined) |
|    40 | `BG_BLACK`                | `bgBlack`                | Black background |
|    41 | `BG_RED`                  | `bgRed`                  | Red background |
|    42 | `BG_GREEN`                | `bgGreen`                | Green background |
|    43 | `BG_YELLOW`               | `bgYellow`               | Yellow background |
|    44 | `BG_BLUE`                 | `bgBlue`                 | Blue background |
|    45 | `BG_MAGENTA`              | `bgMagenta`              | Magenta background |
|    46 | `BG_CYAN`                 | `bgCyan`                 | Cyan background |
|    47 | `BG_WHITE`                | `bgWhite`                | White background |
|    48 | `BACKGROUND`              | `bg256…/bgRgb…`          | Background color from [256-color table](#256-color-table) or by [RGB](#24-bit-rgb-colors) |
|    49 | `BG_DEFAULT`              | `resetBg`                | Default background color (implementation-defined) |
|    51 | `FRAME`                   | `frame`                  | Frame |
|    52 | `ENCIRCLE`                | `encircle`               | Encircle |
|    53 | `OVERLINE`                | `overline`               | Overline |
|    54 | `NOT_FRAME_NOT_ENCIRCLE`  | `resetFrameAndEncircle`  | Not frame, not encircle |
|    55 | `NOT_OVERLINE`            | `resetOverline`          | Not overline |
|    58 | `UNDERLINE_COLOR`         | `underline256…/underlineRgb…` | Underline color from [256-color table](#256-color-table) or by [RGB](#24-bit-rgb-colors) |
|    59 | `UNDERLINE_COLOR_DEFAULT` | `resetUnderlineColor`    | Default underline color |
|    73 | `SUPERSCRIPT`             | `superscript`            | Superscript |
|    74 | `SUBSCRIPT`               | `subscript`              | Subscript |
|    75 | `NOT_SUPER_NOT_SUBSCRIPT` | `resetSuperAndSubscript` | Not superscript, not subscript |
|    90 | `FG_HIGH_BLACK`           | `fgHighBlack`            | High black display |
|    91 | `FG_HIGH_RED`             | `fgHighRed`              | High red display |
|    92 | `FG_HIGH_GREEN`           | `fgHighGreen`            | High green display |
|    93 | `FG_HIGH_YELLOW`          | `fgHighYellow`           | High yellow display |
|    94 | `FG_HIGH_BLUE`            | `fgHighBlue`             | High blue display |
|    95 | `FG_HIGH_MAGENTA`         | `fgHighMagenta`          | High magenta display |
|    96 | `FG_HIGH_CYAN`            | `fgHighCyan`             | High cyan display |
|    97 | `FG_HIGH_WHITE`           | `fgHighWhite`            | High white display |
|   100 | `BG_HIGH_BLACK`           | `bgHighBlack`            | High black background |
|   101 | `BG_HIGH_RED`             | `bgHighRed`              | High red background |
|   102 | `BG_HIGH_GREEN`           | `bgHighGreen`            | High green background |
|   103 | `BG_HIGH_YELLOW`          | `bgHighYellow`           | High yellow background |
|   104 | `BG_HIGH_BLUE`            | `bgHighBlue`             | High blue background |
|   105 | `BG_HIGH_MAGENTA`         | `bgHighMagenta`          | High magenta background |
|   106 | `BG_HIGH_CYAN`            | `bgHighCyan`             | High cyan background |
|   107 | `BG_HIGH_WHITE`           | `bgHighWhite`            | High white background |

All of the following examples are equivalent:

```dart
import 'package:ansi_escape_codes/ansi.dart';

print('\x1B[1m bold \x1B[0m');
print('$CSI$BOLD$SGR bold $CSI$RESET$SGR');
print('$bold bold $reset');
```


## 256-color table

<https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>

Template for setting the color from 256-color table:

```
CSI FOREGROUND;COLOR_256;n SGR
CSI BACKGROUND;COLOR_256;n SGR
CSI UNDERLINE_COLOR;COLOR_256;n SGR
```

Or, on Dart:

```dart
const str = '$CSI$FOREGROUND;$COLOR_256;$n$SGR';
const str = '$CSI$BACKGROUND;$COLOR_256;$n$SGR';
const str = '$CSI$UNDERLINE_COLOR;$COLOR_256;$n$SGR';
```

Where `n` is:

|   Value | Constant        | Using | Comment |
|--------:|:----------------|:-----------------------------------------|:-|
|       0 | `BLACK`         | `fg256Black`<br>`bg256Black`<br>`underline256Black` | |
|       1 | `RED`           | `fg256Red`<br>`bg256Red`<br>`underline256Red` | |
|       2 | `GREEN`         | `fg256Green`<br>`bg256Green`<br>`underline256Green` | |
|       3 | `YELLOW`        | `fg256Yellow`<br>`bg256Yellow`<br>`underline256Yellow` | |
|       4 | `BLUE`          | `fg256Blue`<br>`bg256Blue`<br>`underline256Blue` | |
|       5 | `MAGENTA`       | `fg256Magenta`<br>`bg256Magenta`<br>`underline256Magenta` | |
|       6 | `CYAN`          | `fg256Cyan`<br>`bg256Cyan`<br>`underline256Cyan` | |
|       7 | `WHITE`         | `fg256White`<br>`bg256White`<br>`underline256White` | |
|       8 | `HIGH_BLACK`    | `fg256HighBlack`<br>`bg256HighBlack`<br>`underline256HighBlack` | |
|       9 | `HIGH_RED`      | `fg256HighRed`<br>`bg256HighRed`<br>`underline256HighRed` | |
|      10 | `HIGH_GREEN`    | `fg256HighGreen`<br>`bg256HighGreen`<br>`underline256HighGreen` | |
|      11 | `HIGH_YELLOW`   | `fg256HighYellow`<br>`bg256HighYellow`<br>`underline256HighYellow` | |
|      12 | `HIGH_BLUE`     | `fg256HighBlue`<br>`bg256HighBlue`<br>`underline256HighBlue` | |
|      13 | `HIGH_MAGENTA`  | `fg256HighMagenta`<br>`bg256HighMagenta`<br>`underline256HighMagenta` | |
|      14 | `HIGH_CYAN`     | `fg256HighCyan`<br>`bg256HighCyan`<br>`underline256HighCyan` | |
|      15 | `HIGH_WHITE`    | `fg256HighWhite`<br>`bg256HighWhite`<br>`underline256HighWhite`  | |
|  16-231 | `RGB_<r><g><b>` | `fg256Rgb<r><g><b>`<br>`bg256Rgb<r><g><b>`<br>`underline256Rgb<r><g><b>` | `r`,`g`,`b` are numbers from 0 to 5 (6 × 6 × 6 cube (216 colors): 16 + 36 × `r` + 6 × `g` + `b`) |
| 232-255 | `GRAY<n>`       | `fg256Gray<n>`<br>`bg256Gray<n>`<br>`underline256Gray<n>` | `n` is a number from 0 to 23 (grayscale from dark to light in 24 steps) |

All of the following examples are equivalent:

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

print('\x1B[38;5;3m Yellow text \x1B[39m');
print('$CSI$FOREGROUND;$COLOR_256;$YELLOW$SGR Yellow text $CSI$FG_DEFAULT$SGR');
print('$fg256Open$YELLOW$fg256Close Yellow text $resetFg');
print('$fg256Yellow Yellow text $resetFg');
print('${fg256(YELLOW)} Yellow text $resetFg'); // Not constant!
```

You can also use functions to get the color index:

```dart
int rgb256(int r, int g, int b); // r,g,b are numbers from 0 to 5
int gray256(int level); // level is number from 0 to 23

print('${fg256(rgb256(5, 5, 0))}');
print('${fg256(gray256(16))}');
```

And use next functions to set the color from 256-color table by index:

```dart
String fg256(int index); // index is number from 0 to 255
String bg256(int index);
String underline256(int index);
```

All of the following examples are equivalent:

```dart
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

print('\x1B[38;5;226m Yellow text \x1B[39m');
print('$CSI$FOREGROUND;$COLOR_256;$RGB_550$SGR Yellow text $CSI$FG_DEFAULT$SGR');
print('$fg256Open$RGB_550$fg256Close Yellow text $resetFg');
print('$fg256Rgb550 Yellow text $resetFg');
print('${fg256(RGB_550)} Yellow text $resetFg'); // Not constant!
print('${fg256(rgb256(5, 5, 0))} Yellow text $resetFg'); // Not constant!
```


## 24-bit RGB colors

<https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit>

Template for setting the color from 256-color table:

```
CSI FOREGROUND;COLOR_RGB;r;g;b SGR
CSI BACKGROUND;COLOR_RGB;r;g;b SGR
CSI UNDERLINE_COLOR;COLOR_RGB;r;g;b SGR
```

Or, on Dart:

```dart
const str = '$CSI$FOREGROUND;$COLOR_RGB;$r;$g;$b$SGR';
const str = '$CSI$BACKGROUND;$COLOR_RGB;$r;$g;$b$SGR';
const str = '$CSI$UNDERLINE_COLOR;$COLOR_RGB;$r;$g;$b$SGR';
```

Where `r`, `g` and `b` are the corresponding color components in the RGB form.

You can use next functions to set the color by RGB:

```dart
String fgRgb(int r, int g, int b); // r,g,b are numbers from 0 to 255
String bgRgb(int r, int g, int b);
String underlineRgb(int r, int g, int b);
```

All of the following examples are equivalent:

```dart
print('\x1B[48;2;44;43;124m Ultramarine \x1B[49m');
print('$CSI$BACKGROUND;$COLOR_RGB;44;43;124$SGR Ultramarine $CSI$BG_DEFAULT$SGR');
print('${bgRgbOpen}44;43;124$bgRgbClose Ultramarine $resetBg');
print('${bgRgb(44, 43, 124)} Ultramarine $resetBg'); // Not constant!
```
