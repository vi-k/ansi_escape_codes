[![Dart CI](https://github.com/vi-k/ansi_escape_codes/actions/workflows/dart.yml/badge.svg)](https://github.com/vi-k/ansi_escape_codes/actions/workflows/dart.yml)
[![GitHub Repo](https://img.shields.io/badge/github-repo-blue?logo=github)](https://github.com/vi-k/ansi_escape_codes)
[![Pub Publisher](https://img.shields.io/pub/publisher/ansi_escape_codes)](https://pub.dev/publishers/yet-another.dev/packages)
![Pub Version](https://img.shields.io/pub/v/ansi_escape_codes)
![GitHub License](https://img.shields.io/github/license/vi-k/ansi_escape_codes)
[![Dart](https://img.shields.io/badge/Dart-blue?logo=dart)](https://dart.dev/)

A toolkit for working with **ANSI escape codes**
and analyzing strings containing them.

> ANSI escape sequences are a standard for in-band signaling to control cursor
> location, color, font styling, and other options on video text terminals and
> terminal emulators. Certain sequences of bytes, most starting with an ASCII
> escape character and a bracket character, are embedded into text. The
> terminal interprets these sequences as commands, rather than text to display
> verbatim. [Wikipedia](https://en.wikipedia.org/wiki/ANSI_escape_code)


## Features

- coloring: emphasis on using **constants** instead of functions and classes
- cursor and terminal control
- **analyzing** and **parsing** and  strings containing escape codes
- **default style for all application output**


## Quick start

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  print('$fgGreen Green text $resetFg'
    '$bgYellow Yellow background $resetBg'
    '$bold Bold text $resetBoldAndFaint'
    '$italicized Italicized text $resetItalicized'
    '$underlined Underlined text $resetUnderlined'
    '$reset');
}
```

`fgGreen` is an ANSI escape sequence that sets the text color to green.
`bgYellow` sets the background color to yellow. And so on.

`resetFg` resets the text color to the default color set in your terminal.
`resetBg` resets the background color to the default color. And so on.

> [!NOTE]
> Please note the following example:
>
> ```dart
> print('$fgGreen Green text $fgYellow Yellow text $resetFg Default text');
> ```
>
> After `resetFg`, the text color will not revert to `fgGreen`, but will return
> to the standard terminal text color!
>
> If you need the ability to roll back to the previous color, use
> [Stacked AnsiPrinter](#stacked-ansiprinter).

Since you cannot set `bold` and `faint` at the same time, a single escape
sequence is used in ANSI to reset both: `resetBoldAndFaint`.

`reset` returns all settings to default.

All the ready-to-use values can be seen in:

- [Select graphic rendition (SGR)](#select-graphic-rendition-sgr)
- [256-color table](#256-color-table)
- [24-bit RGB colors](#24-bit-rgb-colors)


## Table of contents

- [Control function constants and predefined values](#control-function-constants-and-predefined-values)
  - [Control codes (C0 set)](#control-codes-c0-set)
  - [Control functions ESC Fe (C1 set)](#control-functions-esc-fe-c1-set)
  - [Control sequences (CSI)](#control-sequences-csi)
  - [Predefined values](#predefined-values)
  - [Independent control functions ESC Fs](#independent-control-functions-esc-fs)
  - [Select graphic rendition (SGR)](#select-graphic-rendition-sgr)
  - [256-color table](#256-color-table)
  - [24-bit RGB colors](#24-bit-rgb-colors)
- [Analyzing and parsing](#analyzing-and-parsing)
  - [AnsiParser](#ansiparser)
  - [Quick analysis](#quick-analysis)
  - [AnsiPrinter](#ansiprinter)
  - [Stacked AnsiPrinter](#stacked-ansiprinter)


## Control function constants and ready-to-use values

Strings containing ANSI escape codes can be constants:

```dart
const text = '$fgGreen Green text $resetFg'
    '$bgYellow Yellow background $resetBg'
    '$bold Bold text $resetBoldAndFaint'
    '$italicized Italicized text $resetItalicized'
    '$underlined Underlined text $resetUnderlined';
print(text);
```

For complex cases there are functions:

```dart
final nonConstantText = '${fgRgb(255, 128, 0)} Orange text $resetFg';
print(nonConstantText);
```

But even in these cases it is possible to switch to constants:

```dart
const constantText = '${fgRgbOpen}255;128;0$fgRgbClose Orange text $resetFg';
print(constantText);
```

Of course, nothing prevents you from using the escape codes themselves
directly. But even in this case you can use predefined constants to make the
text more readable.

All of the following examples are equivalent:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

print('\x1B[38;2;255;128;0m Orange text \x1B[0m');
print('$ESC[38;2;255;128;0m Orange text $ESC[0m');
print('${CSI}38;2;255;128;0$SGR Orange text ${CSI}0$SGR');
print('$CSI$FOREGROUND;$COLOR_RGB;255;128;0$SGR Orange text $CSI$RESET$SGR');
print('${fgRgbOpen}255;128;0$fgRgbClose Orange text $resetFg'); // Not constant!
print('${fgRgb(255, 128, 0)} Orange text $resetFg'); // Not constant!
```

Control codes are deliberately named in **SCREAMING_SNAKE_CASE** as opposed to
the common Dart **camelCase**. First, this is how they are named in the
Standard. Second, in this form they will not prevent you from naming your own
variables. **Thirdly, and most importantly, most users do not need to use them
directly.**


### Control codes (C0 set)

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
import 'package:ansi_escape_codes/controls.dart';

…

// The following examples are equivalent:
print('\t\r\n');
print('$HT$CR$LF');
```


### Control functions ESC Fe (C1 set)

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
import 'package:ansi_escape_codes/controls.dart';

…

// Clear screen
print('Erase screen${CSI}2JScreen erased');

// Set new tabulation stops
print('$HTS  $HTS  $HTS  $HTS');
print('1\t2\t3\t4'); // 1 2 3 4
print('${CSI}3g'); // Reset tabulations stops to default

// Link (it doesn't work everywhere)
print('Go to ${OSC}8;;https://pub.dev/packages/ansi_escape_codes${ST}pub.dev${OSC}8;;$ST')
```


### Control sequences (CSI)

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
| `TBC`      | `CSI n g`    | Tabulation clear (`s`=3 - all character tabulation stops are cleared) |
| `SM`       | `CSI s h`    | Set mode (`s`=4 - INSERTION REPLACEMENT MODE)                         |
| `RM`       | `CSI s l`    | Reset mode                                                            |
| `SGR`      | `CSI s… m`   | Select graphic rendition                                              |

```dart
import 'package:ansi_escape_codes/controls.dart';

…

// Cursor left by 4 characters
// Delete 1 character ('1')
// Cursor right by 1 character
// Erase 1 character ('3')
print('1234${CSI}4$CUB$CSI$DCH$CSI$CUF$CSI$ECH'); // '2 4'

// Insertion mode
print('${CSI}4${SM}tree${CSI}3${CUB}h'); // three
print('${CSI}4${RM}tree${CSI}3${CUB}h'); // thee

// Italicized text
print('${CSI}3$SGR Italicized text ${CSI}0$SGR');
```


### Ready-to-use functions and constants

Ready-to-use functions and constants replace the use of control functions with
the style used in Dart.

| Goal                               | Template                                       | Function                          | Default constant | Description                                                                 |
|:-----------------------------------|:-----------------------------------------------|:----------------------------------|:-----------------|:----------------------------------------------------------------------------|
| Cursor up                          | `${cursorUpOpen}$n$cursorUpClose`              | `cursorUpN(int n)`                | `cursorUp`       | Moves the cursor up `n` (default 1) lines.                                  |
| Cursor down                        | `${cursorDownOpen}$n$cursorDownClose`          | `cursorDownN(int n)`              | `cursorDown`     | Moves the cursor down `n` (default 1) lines.                                |
| Cursor forward                     | `${cursorRightOpen}$n$cursorRightClose`        | `cursorRightN(int n)`             | `cursorRight`    | Moves the cursor right `n` (default 1) characters.                          |
| Cursor back                        | `${cursorLeftOpen}$n$cursorLeftClose`          | `cursorLeftN(int n)`              | `cursorLeft`     | Moves the cursor left `n` (default 1) characters.                           |
| Cursor next line                   | `${cursorNextLineOpen}$n$cursorNextLineClose`  | `cursorNextLineN(int n)`          | `cursorNextLine` | Moves cursor to beginning of the line `n` (default 1) lines down.           |
| Cursor prev line                   | `${cursorPrevLineOpen}$n$cursorPrevLineClose`  | `cursorPrevLineN(int n)`          | `cursorPrevLine` | Moves cursor to beginning of the line `n` (default 1) lines up.             |
| Cursor horizontal pos              | `${cursorHPosOpen}$n$cursorHPosClose`          | `cursorHPosN(int n)`              | `cursorHPos`     | Moves the cursor to column `n` (default 1).                                 |
| Cursor pos                         | `${cursorPosOpen}$row;$col$cursorPosClose`     | `cursorPosTo(int row, int col)`   | `cursorPos`      | Moves the cursor to `row` and `col`.                                        |
| Cursor horizontal and vertical pos | `${cursorHVPosOpen}$row;$col$cursorHVPosClose` | `cursorHVPosTo(int row, int col)` | `cursorHVPos`    | Same as `cursorPos`, just with some differences.                            |
| Erase in page                      | `${eraseInPageOpen}$s$eraseInPageClose`        |                                   | `eraseInPage…`   | Erases part of the page: `s`=0 (or missing) - to end (`eraseInPageToEnd`), `s`=1 - to beginning (`eraseInPageToBegin`), `s`=2 - entire page (`erasePage`). |
| Erase in line                      | `${eraseInLineOpen}$s$eraseInLineClose`        |                                   | `eraseInLine…`   | Erases part of the line: `s`=0 (or missing) - to end (`eraseInLineToEnd`), `s`=2 - to beginning (`eraseInLineToBegin`), `s`=2 - entire line (`eraseLine`). |
| Scroll up                          | `${scrollUpOpen}$n$scrollUpClose`              | `scrollUpN(int n)`                | `scrollUp`       | Scroll page up by `n` (default 1) lines. New lines are added at the bottom. |
| Scroll down                        | `${scrollDownOpen}$n$scrollDownClose`          | `scrollDownN(int n)`              | `scrollDown`     | Scroll page down by `n` (default 1) lines. New lines are added at the top.  |
| Hide cursor                        |                                                |                                   | `hideCursor`     | Shows the cursor.                                                           |
| Show cursor                        |                                                |                                   | `showCursor`     | Hides the cursor.                                                           |
| Save cursor                        |                                                |                                   | `saveCursor`     | Saves the cursor position, encoding shift state and formatting attributes.  |
| Restore cursor                     |                                                |                                   | `restoreCursor`  | Restores the cursor position, encoding shift state and formatting attributes from the previous `saveCursor` if any, otherwise resets these all to their defaults. |

All of the following examples are equivalent:

```dart
print('\x1B[4A');
print('${CSI}4$CUU');
print(cursorUpN(4)); // Not constant!
print('${cursorUpOpen}4$cursorUpClose');
```


### Independent control functions ESC Fs

> [!NOTE]
> The paragraph will appear later.


### Select graphic rendition (SGR)

Template for working with graphic rendition:

```
CSI s… SGR
```

Or, on Dart:

```dart
const str = '$CSI$s$SGR';
```

Where `s` is:

| Value | Constant                    | Ready-to-use constant (CSI+s+SGR)       | Description                                                |
|------:|:----------------------------|:----------------------------------------|:-----------------------------------------------------------|
|     0 | `RESET`                     | `reset`                                 | Default rendition (implementation-defined), cancels the effect of any preceding occurrence of SGR |
|     1 | `BOLD`                      | `bold`                                  | Bold or increased intensity                                |
|     2 | `FAINT`                     | `faint`                                 | Faint, decreased intensity or second color                 |
|     3 | `ITALICIZED`                | `italicized`                            | Italicized                                                 |
|     4 | `UNDERLINED`                | `underlined`                            | Singly underlined                                          |
|     5 | `SLOWLY_BLINKING`           | `slowlyBlinking`                        | Slowly blinking (less then 150 per minute)                 |
|     6 | `RAPIDLY_BLINKING`          | `rapidlyBlinking`                       | Rapidly blinking (150 per minute or more)                  |
|     7 | `NEGATIVE`                  | `negative`                              | Negative image                                             |
|     8 | `CONCEALED`                 | `concealed`                             | Concealed characters                                       |
|     9 | `CROSSEDOUT`                | `crossedOut`                            | Crossed-out (characters still legible but marked as to be deleted) |
|    10 | `PRIMARY_FONT`              |                                         | Primary (default) font                                     |
|    11 | `ALT_FONT_1`                |                                         | First alternative font                                     |
|    12 | `ALT_FONT_2`                |                                         | Second alternative font                                    |
|    13 | `ALT_FONT_3`                |                                         | Third alternative font                                     |
|    14 | `ALT_FONT_4`                |                                         | Fourth alternative font                                    |
|    15 | `ALT_FONT_5`                |                                         | Fifth alternative font                                     |
|    16 | `ALT_FONT_6`                |                                         | Sixth alternative font                                     |
|    17 | `ALT_FONT_7`                |                                         | Seventh alternative font                                   |
|    18 | `ALT_FONT_8`                |                                         | Eighth alternative font                                    |
|    19 | `ALT_FONT_9`                |                                         | Ninth alternative font                                     |
|    20 | `FRAKTUR`                   |                                         | Fraktur (Gothic)                                           |
|    21 | `DOUBLY_UNDERLINED`         | `doublyUnderlined`                      | Doubly underlined                                          |
|    22 | `NOT_BOLD_NOT_FAINT`        | `resetBoldAndFaint`                     | Normal colour or normal intensity (neither bold nor faint) |
|    23 | `NOT_ITALICIZED`            | `resetItalicized`                       | Not italicized, not fraktur                                |
|    24 | `NOT_UNDERLINED`            | `resetUnderlined`                       | Not underlined (neither singly nor doubly)                 |
|    25 | `NOT_BLINKING`              | `resetBlinking`                         | Steady (not blinking)                                      |
|    27 | `NOT_NEGATIVE`              | `resetNegative`                         | Positive image (not negative)                              |
|    28 | `NOT_CONCEALED`             | `resetConcealed`                        | Revealed characters (not concealed)                        |
|    29 | `NOT_CROSSEDOUT`            | `resetCrossedOut`                       | Not crossed out                                            |
|    30 | `FG_BLACK`                  | `fgBlack`                               | Black display (color #0 from 256-color table)              |
|    31 | `FG_RED`                    | `fgRed`                                 | Red display (color #1 from 256-color table)                |
|    32 | `FG_GREEN`                  | `fgGreen`                               | Green display (color #2 from 256-color table)              |
|    33 | `FG_YELLOW`                 | `fgYellow`                              | Yellow display (color #3 from 256-color table)             |
|    34 | `FG_BLUE`                   | `fgBlue`                                | Blue display (color #4 from 256-color table)               |
|    35 | `FG_MAGENTA`                | `fgMagenta`                             | Magenta display (color #5 from 256-color table)            |
|    36 | `FG_CYAN`                   | `fgCyan`                                | Cyan display (color #6 from 256-color table)               |
|    37 | `FG_WHITE`                  | `fgWhite`                               | White display (color #7 from 256-color table)              |
|    38 | `FOREGROUND`                | `fg256…/fgRgb…`                         | Display color from 256-color table or by RGB. See [256-color table](#256-color-table) |
|    39 | `FG_DEFAULT`                | `resetFg`                               | Default display color (implementation-defined)             |
|    40 | `BG_BLACK`                  | `bgBlack`                               | Black background (color #0 from 256-color table)           |
|    41 | `BG_RED`                    | `bgRed`                                 | Red background (color #1 from 256-color table)             |
|    42 | `BG_GREEN`                  | `bgGreen`                               | Green background (color #2 from 256-color table)           |
|    43 | `BG_YELLOW`                 | `bgYellow`                              | Yellow background (color #3 from 256-color table)          |
|    44 | `BG_BLUE`                   | `bgBlue`                                | Blue background (color #4 from 256-color table)            |
|    45 | `BG_MAGENTA`                | `bgMagenta`                             | Magenta background (color #5 from 256-color table)         |
|    46 | `BG_CYAN`                   | `bgCyan`                                | Cyan background (color #6 from 256-color table)            |
|    47 | `BG_WHITE`                  | `bgWhite`                               | White background (color #7 from 256-color table)           |
|    48 | `BACKGROUND`                | `bg256…/bgRgb…`                         | Background color from 256-color table or by RGB. See [256-color table](#256-color-table) |
|    49 | `BG_DEFAULT`                | `resetBg`                               | Default background color (implementation-defined)          |
|    51 | `FRAMED`                    | `framed`                                | Framed                                                     |
|    52 | `ENCIRCLED`                 | `encircled`                             | Encircled                                                  |
|    53 | `OVERLINED`                 | `overlined`                             | Overlined                                                  |
|    54 | `NOT_FRAMED_NOT_ENCIRCLED`  | `resetFramedAndEncircled`               | Not framed, not encircled                                  |
|    55 | `NOT_OVERLINED`             | `resetOverlined`                        | Not overlined                                              |
|    58 | `UNDERLINE_COLOR`           | `underlineColor256…/underlineColorRgb…` | Underline color from 256-color table or by RGB. See [256-color table](#256-color-table) |
|    59 | `UNDERLINE_COLOR_DEFAULT`   | `underlineColorDefault`                 | Default underline color                                    |
|    73 | `SUPERSCRIPTED`             | `superscripted`                         | Superscripted                                              |
|    74 | `SUBSCRIPTED`               | `subscripted`                           | Subscripted                                                |
|    75 | `NOT_SUPER_NOT_SUBSCRIPTED` | `resetSuperAnsSubscripted`              | Not superscripted, not subscipted                          |
|    90 | `FG_HIGH_BLACK`             | `fgHighBlack`                           | High black display (color #8 from 256-color table)         |
|    91 | `FG_HIGH_RED`               | `fgHighRed`                             | High red display (color #9 from 256-color table)           |
|    92 | `FG_HIGH_GREEN`             | `fgHighGreen`                           | High green display (color #10 from 256-color table)        |
|    93 | `FG_HIGH_YELLOW`            | `fgHighYellow`                          | High yellow display (color #11 from 256-color table)       |
|    94 | `FG_HIGH_BLUE`              | `fgHighBlue`                            | High blue display (color #12 from 256-color table)         |
|    95 | `FG_HIGH_MAGENTA`           | `fgHighMagenta`                         | High magenta display (color #13 from 256-color table)      |
|    96 | `FG_HIGH_CYAN`              | `fgHighCyan`                            | High cyan display (color #14 from 256-color table)         |
|    97 | `FG_HIGH_WHITE`             | `fgHighWhite`                           | High white display (color #15 from 256-color table)        |
|   100 | `BG_HIGH_BLACK`             | `bgHighBlack`                           | High black background (color #8 from 256-color table)      |
|   101 | `BG_HIGH_RED`               | `bgHighRed`                             | High red background (color #9 from 256-color table)        |
|   102 | `BG_HIGH_GREEN`             | `bgHighGreen`                           | High green background (color #10 from 256-color table)     |
|   103 | `BG_HIGH_YELLOW`            | `bgHighYellow`                          | High yellow background (color #11 from 256-color table)    |
|   104 | `BG_HIGH_BLUE`              | `bgHighBlue`                            | High blue background (color #12 from 256-color table)      |
|   105 | `BG_HIGH_MAGENTA`           | `bgHighMagenta`                         | High magenta background (color #13 from 256-color table)   |
|   106 | `BG_HIGH_CYAN`              | `bgHighCyan`                            | High cyan background (color #14 from 256-color table)      |
|   107 | `BG_HIGH_WHITE`             | `bgHighWhite`                           | High white background (color #15 from 256-color table)     |

All of the following examples are equivalent:

```dart
print('\x1B[1m bold \x1B[0m');
print('$CSI$BOLD$SGR bold $SCI$RESET$SGR');
print('$bold bold $reset');
```


### 256-color table

<https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>

Template for setting the color from 256-color table:

```
CSI FOREGROUND/BACKGROUND/UNDERLINE_COLOR;COLOR_256;n SGR
```

Or, on Dart:

```dart
const str = '$CSI$FOREGROUND;$COLOR_256;$n$SGR';
const str = '$CSI$BACKGROUND;$COLOR_256;$n$SGR';
const str = '$CSI$UNDERLINE_COLOR;$COLOR_256;$n$SGR';
```

Where `n` is:

|   Value | Constant        | Ready-to-use constant                    | Comment |
|--------:|:----------------|:-----------------------------------------|:--------|
|       0 | `BLACK`         | (`fg`/`bg`/`underline`)`256Black`        |         |
|       1 | `RED`           | (`fg`/`bg`/`underline`)`256Red`          |         |
|       2 | `GREEN`         | (`fg`/`bg`/`underline`)`256Green`        |         |
|       3 | `YELLOW`        | (`fg`/`bg`/`underline`)`256Yellow`       |         |
|       4 | `BLUE`          | (`fg`/`bg`/`underline`)`256Blue`         |         |
|       5 | `MAGENTA`       | (`fg`/`bg`/`underline`)`256Magenta`      |         |
|       6 | `CYAN`          | (`fg`/`bg`/`underline`)`256Cyan`         |         |
|       7 | `WHITE`         | (`fg`/`bg`/`underline`)`256White`        |         |
|       8 | `HIGH_BLACK`    | (`fg`/`bg`/`underline`)`256HighBlack`    |         |
|       9 | `HIGH_RED`      | (`fg`/`bg`/`underline`)`256HighRed`      |         |
|      10 | `HIGH_GREEN`    | (`fg`/`bg`/`underline`)`256HighGreen`    |         |
|      11 | `HIGH_YELLOW`   | (`fg`/`bg`/`underline`)`256HighYellow`   |         |
|      12 | `HIGH_BLUE`     | (`fg`/`bg`/`underline`)`256HighBlue`     |         |
|      13 | `HIGH_MAGENTA`  | (`fg`/`bg`/`underline`)`256HighMagenta`  |         |
|      14 | `HIGH_CYAN`     | (`fg`/`bg`/`underline`)`256HighCyan`     |         |
|      15 | `HIGH_WHITE`    | (`fg`/`bg`/`underline`)`256HighWhite`    |         |
|  16-231 | `RGB_<r><g><b>` | (`fg`/`bg`/`underline`)`256Rgb<r><g><b>` | `r`,`g`,`b` are numbers from 0 to 5 (6 × 6 × 6 cube (216 colors): 16 + 36 × `r` + 6 × `g` + `b`) |
| 232-255 | `GRAY<n>`       | (`fg`/`bg`/`underline`)`256Gray<n>`      | `n` is a number from 0 to 23 (grayscale from dark to light in 24 steps)                          |

All of the following examples are equivalent:

```dart
print('\x1B[38;5;3m Yellow text \x1B[39m');
print('$CSI$FOREGROUND;$COLOR_256;$YELLOW$SGR Yellow text $CSI$FG_DEFAULT$SGR');
print('$fg256Open$YELLOW$fg256Close Yellow text $resetFg');
print('$fg256Yellow Yellow text $resetFg');
print('${fg256(YELLOW)} Yellow text $resetFg'); // Not constant!
```

You can also use functions to get the color index:

```dart
int rgb(int r, int g, int b); // r,g,b are numbers from 0 to 5
int gray(int level); // level is number from 0 to 23
```

And use next functions to set the color from 256-color table by index:

```dart
String fg256(int index); // index is number from 0 to 255
String bg256(int index);
String underline256(int index);
```

All of the following examples are equivalent:

```dart
print('\x1B[38;5;226m Yellow text \x1B[39m');
print('$CSI$FOREGROUND;$COLOR_256;$RGB_550$SGR Yellow text $CSI$FG_DEFAULT$SGR');
print('$fg256Open$RGB_550$fg256Close Yellow text $resetFg');
print('$fg256Rgb550 Yellow text $resetFg');
print('${fg256(RGB_550)} Yellow text $resetFg'); // Not constant!
print('${fg256(rgb(5, 5, 0))} Yellow text $resetFg'); // Not constant!
```


### 24-bit RGB colors

<https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit>

Template for setting the color from 256-color table:

```
CSI FOREGROUND/BACKGROUND/UNDERLINE_COLOR;COLOR_RGB;r;g;b SGR
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


## Analyzing and parsing


### AnsiParser

AnsiParser allows you to analyze text containing escape codes:

```dart
const text = '$bold Bold $fgCyan Bold+cyan $resetBoldAndFaint Cyan ';
final parser = AnsiParser(text);
parser.matches.forEach(print);
// Match(start: 0, end: 4, entity: Sgr(bold), state: SgrState(bold))
// Match(start: 4, end: 10, entity: Text(' Bold '), state: SgrState(bold))
// Match(start: 10, end: 15, entity: Sgr(fgCyan), state: SgrState(bold, foreground: Color16(Colors.cyan)))
// Match(start: 15, end: 26, entity: Text(' Bold+cyan '), state: SgrState(bold, foreground: Color16(Colors.cyan)))
// Match(start: 26, end: 31, entity: Sgr(resetBoldAndFaint), state: SgrState(foreground: Color16(Colors.cyan)))
// Match(start: 31, end: 37, entity: Text(' Cyan '), state: SgrState(foreground: Color16(Colors.cyan)))
```

In this way we can, for example, remove all escape codes:

```dart
final buf = StringBuffer();
for (final m in parser.matches) {
  switch (m.entity) {
    case Text(:final string):
      buf.write(string);
    case EscapeCode():
      break;
  }
}
print(buf); // ' Bold  Bold+cyan  Cyan '
```

There is a ready-to-use method for this:

```dart
print(parser.removeAll());
```

Or replace the escape codes with a readable form:

```dart
final buf = StringBuffer();
for (final m in parser.matches) {
  final result = switch (m.entity) {
    EscapeCode(:final id) => '[$id]',
    Text(:final string) => string,
  };
  buf.write(result);
}
print(buf); // [bold] Bold [fgCyan] Bold+cyan [resetBoldAndFaint] Cyan
```

You can also use ready-to-use methods for this:

```dart
print(parser.replaceAll((e) => '[${e.id}]'));
print(parser.showControlFunctions());
```

You can find out the length of plain text without escape codes using `length`:

```dart
print(parser.length == parser.removeAll().length); // true
print(parser.length); // 23
```

The state at a particular position can be found with `stateAtPos`.

```dart
final state = parser.stateAtPos(7);
print(state); // SgrState(bold, foreground: Color16(Colors.cyan))
print(state.isBold); // true
print(state.isItalicized); // false
print(state.foreground?.id); // fgCyan
print(state.background?.id); // null
```

The position in `stateAtPos` is specified in the plaintext range
(`pos` < `parser.length`) and can also point to the position behind the text
(`pos` == `parser.length`) to find out the final state. The final state can
also be obtained using `finalState`.

```dart
print(parser.stateAtPos(23) == parser.finalState); // true
print(parser.finalState); // SgrState(foreground: Color16(Colors.cyan))
```

In the above example, the text state was not set to default, i.e. the text was
not closed:

```dart
print(parser.isClosed); // false
```

The easiest way to close a text is to add a `reset` at the end of it:

```dart
const closedText = '$text$reset';
print(AnsiParser(closedText).isClosed); // true
```

The `substring` method allows you to retrieve a piece of text by computing
together its state:

```dart
final substring = parser.substring(7, maxLength: 9);
print(AnsiParser(substring).showControlFunctions()); // [fgCyan;bold]Bold+cyan[reset]
```

By default, the substring is closed. Escape codes is always included in the
string in optimized form:

```dart
const test1 = '$fgCyan$bold';
final test2 = substring.substring(0, substring.indexOf('Bold'));
print(test1.showEscapeCodes()); // [CSI 36 SGR][CSI 1 SGR]
print(test2.showEscapeCodes()); // [CSI 36;1 SGR]
print(AnsiParser(test1).showControlFunctions()); // [fgCyan][bold]
print(AnsiParser(test2).showControlFunctions()); // [fgCyan;bold]
print(test1.length); // 9
print(test2.length); // 7
```

To optimize the entire string, there is an `optimize` method:

```dart
const text = '$fgWhite$bold$resetBoldAndFaint$fgGreen$underlined'
    "$resetUnderlined$faint$faint What's in here? $resetBoldAndFaint$resetFg";
print(text.length); // 63
final parser = AnsiParser(text);
print(parser.showControlFunctions());
// [fgWhite][bold][resetBoldAndFaint][fgGreen][underlined][resetUnderlined][faint][faint] What's in here? [resetBoldAndFaint][resetFg]

final optimizedText = parser.optimize();
print(optimizedText.length); // 28
print(AnsiParser(optimizedText).showControlFunctions());
// [fgGreen;faint] What's in here? [reset]
```

### Quick analysis

You can quickly analyze a string without using `AnsiParser` by using
extensions.

```dart
import 'package:ansi_escape_codes/extensions.dart';

…

const text = '${fgRed}ERROR$reset';
print(text.hasEscapeCodes); // true
print(text.hasCsi); // true
print(text.hasSgr); // true
print(text.hasForeground); // true
print(text.hasBackground); // false
print(text.showEscapeCodes()); // [CSI 31 SGR]ERROR[CSI 0 SGR]
```

The method `showControlCodes` allows to show all control codes from C0 set in
a string:

```dart
const text = 'Tab: \t Line feed: \n Carriage return: \r Bell: \x07';

print(text.showControlCodes());
// Tab: \t Line feed: \n Carriage return: \r Bell: \x07

print(text.showControlCodes(preferStyle: ControlCodeStyle.charCode));
// Tab: \x09 Line feed: \x0A Carriage return: \x0D Bell: \x07

print(text.showControlCodes(preferStyle: ControlCodeStyle.abbr));
// Tab: [HT] Line feed: [LF] Carriage return: [CR] Bell: [BEL]

print(text.showControlCodes(preferStyle: ControlCodeStyle.unicodeSymbol));
// Tab: ␉ Line feed: ␊ Carriage return: ␍ Bell: ␇
```

You can quickly remove all codes using the methods:

```dart
const text = '$saveCursor$cursorRight$italicized$bgGreen$fgYellow Text $resetFg$resetBg$resetItalicized$restoreCursor';
print(AnsiParser(text).showControlFunctions());
// [saveCursor][CSI CUF][italicized][bgGreen][fgYellow] Text [resetFg][resetBg][resetItalicized][restoreCursor]

print(AnsiParser(text.removeBackground()).showControlFunctions());
// [saveCursor][CSI CUF][italicized][fgYellow] Text [resetFg][resetItalicized][restoreCursor]

print(AnsiParser(text.removeBackground().removeForeground()).showControlFunctions());
// [saveCursor][CSI CUF][italicized] Text [resetItalicized][restoreCursor]

print(AnsiParser(text.removeSgr()).showControlFunctions());
// [saveCursor][CSI CUF] Text [restoreCursor]

print(AnsiParser(text.removeCsi()).showControlFunctions());
// [saveCursor] Text [restoreCursor]

print(text.removeEscapeCodes().showEscapeCodes());
// ' Text '
```

### AnsiPrinter

Escape codes do not allow you to set default values for your text. The
foreground and background colors depend on the implementation of the terminal
you are using. And so if you want to use some other values, you cannot use
`resetFg` (CSI FOREGROUND_DEFAULT SGR) and `resetBg` (CSI BACKGROUND_DEFAULT
SGR). Each time you will have to substitute your own values instead:

```dart
const text =
    '${bgRgbOpen}44;43;124$bgRgbClose${fgRgbOpen}224;192;64$fgRgbClose Default text '
    '$bgWhite$fgBlack Highlighted text '
    '${bgRgbOpen}44;43;124$bgRgbClose${fgRgbOpen}224;192;64$fgRgbClose Default text again $reset';
print(text);
```

You can move the color setting to constants and use them everywhere:

```dart
const bgDefault = '${bgRgbOpen}44;43;124$bgRgbClose';
const fgDefault = '${fgRgbOpen}224;192;64$fgRgbClose';
const text = '$bgDefault$fgDefault Default text '
    '$bgWhite$fgBlack Highlighted text '
    '$bgDefault$fgDefault Default text again $reset';
print(text);
```

Or you can use `AnsiPrinter`:

```dart
const text = ' Default text '
    '$bgWhite$fgBlack Highlighted text '
    '$resetBg$resetFg Default text again $reset';
final printer = AnsiPrinter(
  defaultState: SgrPlainState(
    background: ColorRgb(44, 43, 124),
    foreground: ColorRgb(224, 192, 64),
  ),
);
printer.print(text);
```

The printer itself will substitute the correct values where the state returns
to default. The texts will remain clean, and you can change the default values
or remove them altogether at any time.

Additionally, Dart allows you to use zones to hide the use of the printer under
the hood:

```dart
void main() {
  runZonedAnsiPrinter(
    defaultState: SgrPlainState(
      background: ColorRgb(44, 43, 124),
      foreground: ColorRgb(224, 192, 64),
    ),
    () {
      // … Your application code …

      const text = ' Default text '
          '$bgWhite$fgBlack Highlighted text '
          '$resetBg$resetFg Default text again $reset';

      print(text); // Use the usual print
    },
  );
}
```

All calls to the `print` function will be intercepted and modified to use the
values you need.

If you need the codes for debugging Flutter apps, you'll notice that when
debugging iOS apps, the console will receive messages with escaped escape codes
in them. This is a known issue and is currently (02.2025) unresolved:
https://github.com/flutter/flutter/issues/20663. There is no way around this
issue. But there are two ways to minimize it.

The first way is to use the `log` method from 'dart:developer'. The `log`
outputs the escape codes on iOS correctly:

```dart
import 'dart:developer';

…

runZonedAnsiPrinter(
  defaultState: const SgrPlainState(
    background: Color16.green,
    foreground: Color16.yellow,
  ),
  output: log,
  () {
    const text = ' Default text '
        '$bgWhite$fgBlack Highlighted text '
        '$resetBg$resetFg Default text again $reset';
    print(text);
  },
);
```

Unfortunately, the `log` method outputs long messages (more than 128
characters) as `<collected>`. And it is easy to exceed the allowed size when
using escape codes. In the example above, the `text` does not fit in this size
if RGB colors are used.

And secondly, `log` works only from IDE. Testers who don't use IDE won't
see anything in the console.

So in most cases on iOS, it's left to disable escape codes for the most part:

```dart
runZonedAnsiPrinter(
  defaultState: …,
  ansiCodesEnabled: !Platform.isIOS,
  () {
    const text = ' Default text '
        '$bgWhite$fgBlack Highlighted text '
        '$resetBg$resetFg Default text again $reset';
    print(text);
  },
);
```

### Stacked AnsiPrinter

Escape codes allow you to do simple text decoration. But a slightly more
complex design requires much more effort. One example is given above, when you
need a default style different from the one provided by the terminal.

Imagine that you have a template for text into which you will insert other
text, that is sent to you externally. But the person who sends you this text
decides to highlight it:

```dart
String makeMessage(String name) {
  const template = 'Dear {name}! We are pleased to present to you …';

  return template.replaceAll('{name}', name);
}

…

const name = '${bold}Sam$resetBoldAndFaint';

…

final text = makeMessage(name);
print(text);
// Dear [bold]Sam[resetBoldAndFaint]! We are pleased to present to you …
```

Without noticing it, at some point your designer decides to make changes to the
template:

```dart
const template = '${bold}Dear {name}, welcome to us!$resetBoldAndFaint We are pleased to present to you …';

…

final text = makeMessage(name);
print(text);
// [bold]Dear [bold]Sam[resetBoldAndFaint], welcome to us![resetBoldAndFaint] We are pleased to present to you …
```

But the escape codes don't accumulate, double `bold` equals single `bold`. And
first `resetBoldAndFaint` cancels the bold text. And we don't get what we want
at all. To fix it, we need to return the state of the text after insertion to
the state it was before insertion. But it makes it much more difficult to use
the escape codes. `AnsiPrinter` helps solve this problem:

```dart
final printer = AnsiPrinter(stacked: true);
printer.print(text);
// [bold]Dear Sam, welcome to us![resetBoldAndFaint] We are pleased to present to you …
```

AnsiPrinter with the `stacked` parameter accumulates state changes and
sequentially disables them, translating the current state into the standard
escape sequence on output:

```dart
const text = '$bold 1 $bold 2 $bold 3 $resetBoldAndFaint 2 $resetBoldAndFaint 1 $resetBoldAndFaint';
final printer1 = AnsiPrinter();
final printer2 = AnsiPrinter(stacked: true);
printer1.print(text); // '[bold] 1  2  3 [resetBoldAndFaint] 2  1 '
printer2.print(text); // '[bold] 1  2  3  2  1 [resetBoldAndFaint]'
```

---

That's all for now.
