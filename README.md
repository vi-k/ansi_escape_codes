[![Dart CI](https://github.com/vi-k/ansi_escape_codes/actions/workflows/dart.yml/badge.svg)](https://github.com/vi-k/ansi_escape_codes/actions/workflows/dart.yml)
[![Pub Publisher](https://img.shields.io/pub/publisher/ansi_escape_codes)](https://pub.dev/publishers/yet-another.dev/packages)
![Pub Version](https://img.shields.io/pub/v/ansi_escape_codes)
![GitHub License](https://img.shields.io/github/license/vi-k/ansi_escape_codes)

A toolkit for working with **ANSI escape codes** and analyzing strings
containing them.

> ANSI escape sequences are a standard for in-band signaling to control cursor
> location, color, font styling, and other options on video text terminals and
> terminal emulators. Certain sequences of bytes, most starting with an ASCII
> escape character and a bracket character, are embedded into text. The
> terminal interprets these sequences as commands, rather than text to display
> verbatim. [Wikipedia](https://en.wikipedia.org/wiki/ANSI_escape_code)


## Features

- coloring: you can use ready-to-use values to create constant strings and
  [maximize performance](#maximum-performance), or choose the power of
  [styles](#the-power-of-styles).
- cursor and terminal control
- [analyzing and parsing](#analyzing-and-parsing) strings containing escape
  codes
- [default style](#printer) for all application output


## Table of contents

- [Quick start](#quick-start)
  - [How do I color text?](#how-do-i-color-text)
  - [How can I change the default style?](#how-can-i-change-the-default-style)
- [The names this package brings](#the-names-this-package-brings)
- [Control function constants and ready-to-use values](#control-function-constants-and-ready-to-use-values)
  - [Control codes (C0 set)](#control-codes-c0-set)
  - [Control functions ESC Fe (C1 set)](#control-functions-esc-fe-c1-set)
  - [Control sequences (CSI)](#control-sequences-csi)
  - [Ready-to-use functions and constants](#ready-to-use-functions-and-constants)
  - [Independent control functions ESC Fs](#independent-control-functions-esc-fs)
  - [Select graphic rendition (SGR)](#select-graphic-rendition-sgr)
  - [256-color table](#256-color-table)
  - [24-bit RGB colors](#24-bit-rgb-colors)
- [Analyzing and parsing](#analyzing-and-parsing)
  - [Parser](#parser)
  - [Quick analysis](#quick-analysis)
  - [Sequence types](#sequence-types)
  - [Unknown sequences](#unknown-sequences)
  - [Printer](#printer)
  - [StackedPrinter](#stackedprinter)
  - [Printing to a sink](#printing-to-a-sink)
- [Utilities](#utilities)
- [Logging](#logging)


## Quick start


### How do I color text?

You can use different levels of coloring.

#### Close to ANSI standard

If you need a level that is as close as possible to ANSI, you can use
ready-made constants that comply with the standard.

```dart
import 'package:ansi_escape_codes/ansi.dart';

void main() {
  const text = '$CSI$FG_GREEN$SGR Green text $CSI$FG_DEFAULT$SGR$LF'
    '$CSI$FOREGROUND;$COLOR_256;$RGB_520$SGR Orange text $CSI$RESET$SGR';

  print(text);
}
```

Most likely, this option will only be of interest to specialists in the
standard.

All constants can be found in this folder:
[ansi](https://github.com/vi-k/ansi_escape_codes/tree/main/lib/src/ansi)

#### Maximum performance

A convenient and highly efficient option is to use ready-to-use values that
hide the complexity of ANSI:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const text = '$fgGreen Green text $resetFg'
    '$bgYellow Yellow background $resetBg'
    '$bold Bold text $resetBoldAndDim'
    '$italic Italic text $resetItalic'
    '$underline Underline text $resetUnderline'
    '$reset';

  print(text);
}
```

Its main feature is that it allows you to create constant strings that are
ready to use.

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
> [styles](#the-power-of-styles) or [StackedPrinter](#stackedprinter).

Since you cannot set `bold` and `dim` at the same time, a single escape
sequence is used in ANSI to reset both: `resetBoldAndDim`.

`reset` returns all settings to default.

All the ready-to-use values can be found in this folder:
[ready_to_use](https://github.com/vi-k/ansi_escape_codes/tree/main/lib/src/ready_to_use)


#### The power of styles

```dart
import 'package:ansi_escape_codes/style.dart';

void main() {
  final defaultStyle = style.gray12;
  final greenStyle = green.bold;
  final highlighedStyle = red.bgYellow.underline;

  print(
    defaultStyle(
      'Normal text'
      ' ${greenStyle('Green ${highlighedStyle('Highlighted text')} text')}'
      ' Normal text',
    ),
  );
}
```

First, you can assemble your own style from any pieces. A chain starts at one
of the sixteen colors, or at `style`, which carries nothing:

```dart
final mine = style.rgb050.bgRgb010.bold.italic.underline;
final warning = red.bold;
```

Second, styles can be nested: after completing the action of a nested style,
the style will return to the parent style.


### How can I change the default style?

You cannot set default colors for the entire terminal. However, Dart allows you
to intercept calls to the `print` and override the default style in those
calls.

Example (if you use styles):

```dart
import 'package:ansi_escape_codes/style.dart';

void main() {
  final greenStyle = green.bold;
  final highlighedStyle = red.bgYellow.underline;

  runZonedPrinter(
    defaultStyle: style.gray12,
    () {
      print(
        'Normal text'
        ' ${greenStyle('Green ${highlighedStyle('Highlighted text')} text')}'
        ' Normal text',
      );
    },
  );
}
```

If you are using [ready-to-use values](#maximum-performance), you can also
use `runZonedPrinter`. But in this case, all `reset...` functions will return
`defaultStyle`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  runZonedPrinter(
    defaultStyle: const Style(
      foreground: Color256.gray12,
    ),
    () {
      print(
        'Normal text'
        ' ${fgGreen}Green text ${fgRed}Highlighted text$resetFg Not a green text$resetFg'
        ' Normal text',
      );
    },
  );
}
```

If you need nested styles, use `runZonedStackedPrinter`:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  runZonedStackedPrinter(
    defaultStyle: const Style(
      foreground: Color256.gray12,
    ),
    () {
      print(
        'Normal text'
        ' ${fgGreen}Green text ${fgRed}Highlighted text$resetFg Green text$resetFg'
        ' Normal text',
      );
    },
  );
}
```

> [!NOTE]
>
> The two ways of writing a colour can be used side by side, and
> `ansi_escape_codes.dart` brings both: `bold` is the string of escape codes,
> `style.bold` is the style. See [the names this package
> brings](#the-names-this-package-brings).

## The names this package brings

Each entry point brings a different part of the package:

| Import | What it brings |
|:---|:---|
| `ansi.dart` | the bytes the standard names: `CSI`, `CUU`, `BOLD`, `RESERVED_5F` |
| `ansi_escape_codes.dart` | the ready-to-use strings (`fgRed`, `cursorUp`), the styles, the parser, the state and the control function tables |
| `style.dart` | the styles — `Style`, `style`, the sixteen colors — and, because the styles are built on it, the whole parser |
| `parsing.dart` | the parser, the state and the control function tables |
| `extensions.dart` | the `String` extensions: `ansiRemoveEscapeCodes`, `ansiShowEscapeSequences` and the rest |
| `utils.dart` | `tabs` and `currentCursorPos` |

The last two are separate imports on purpose: everything else can be had from
`ansi_escape_codes.dart`, but the extensions and the terminal utilities are
brought only by their own.

They can be imported together, and `ansi_escape_codes.dart` already holds the
styles, so one import is usually enough:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

print('${bold}by the string$reset');
print(style.bold('by the style'));
```

The string and the style are told apart by what they are: `bold` is a `String`
of escape codes, and the styles are reached through `style` or through one of
the sixteen colors — `red.bold`, `style.bgYellow`.

The package also exports names Dart and Flutter use for their own: `Match` is
`dart:core`'s, and `Text`, `State`, `Stack`, `Colors` and `Color` are Flutter's.
Nothing breaks until one of them is written, and then the compiler asks which
was meant. In a Flutter app, hide the side you are not calling by that name:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart'
    hide Color, Colors, Match, Stack, State, Text;
```

The same hiding is wanted for `style.dart` and `parsing.dart`: the parser is
what defines those six names, and all three of these imports bring it. Only
`ansi.dart`, `extensions.dart` and `utils.dart` are free of them — the first
brings constants, the last two nothing but functions.

The parser is still `Parser`, and `Matches` — its own name — is untouched by
this.

The colors and `style` are exported as plain lowercase names — `red`, `green`,
`blue` and the thirteen others, `foreground`, `background`, `underlineColor`.
They are the ones most likely to meet a name of your own, and `hide` or a
prefix settles that the same way.


## Control function constants and ready-to-use values

Strings containing ANSI escape codes can be constants:

```dart
const text = '$fgGreen Green text $resetFg'
    '$bgYellow Yellow background $resetBg'
    '$bold Bold text $resetBoldAndDim'
    '$italic Italic text $resetItalic'
    '$underline Underline text $resetUnderline';
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
import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

print('\x1B[38;2;255;128;0m Orange text \x1B[0m');
print('$ESC[38;2;255;128;0m Orange text $ESC[0m');
print('${CSI}38;2;255;128;0$SGR Orange text ${CSI}0$SGR');
print('$CSI$FOREGROUND;$COLOR_RGB;255;128;0$SGR Orange text $CSI$RESET$SGR');
print('${fgRgbOpen}255;128;0$fgRgbClose Orange text $resetFg'); // Not constant!
print('${fgRgb(255, 128, 0)} Orange text $resetFg'); // Not constant!
```

Control codes are deliberately named in **SCREAMING_SNAKE_CASE** as opposed to
the common Dart **camelCase**.  First, this is how they are named in the
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
import 'package:ansi_escape_codes/ansi.dart';

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


### Ready-to-use functions and constants

Ready-to-use functions and constants replace the use of control functions with
the style used in Dart.

| Goal                               | Using                         | Description       |
|:-----------------------------------|:------------------------------|:------------------|
| Cursor up                          | **template:** `${cursorUpOpen}$n$cursorUpClose`              <br>**function:** `cursorUpN(int n)`                <br>**default constant:** `cursorUp`             | Moves the cursor up `n` (default 1) lines. |
| Cursor down                        | **template:** `${cursorDownOpen}$n$cursorDownClose`          <br>**function:** `cursorDownN(int n)`              <br>**default constant:** `cursorDown`           | Moves the cursor down `n` (default 1) lines. |
| Cursor forward                     | **template:** `${cursorRightOpen}$n$cursorRightClose`        <br>**function:** `cursorRightN(int n)`             <br>**default constant:** `cursorRight`          | Moves the cursor right `n` (default 1) characters. |
| Cursor back                        | **template:** `${cursorLeftOpen}$n$cursorLeftClose`          <br>**function:** `cursorLeftN(int n)`              <br>**default constant:** `cursorLeft`           | Moves the cursor left `n` (default 1) characters. |
| Cursor next line                   | **template:** `${cursorNextLineOpen}$n$cursorNextLineClose`  <br>**function:** `cursorNextLineN(int n)`          <br>**default constant:** `cursorNextLine`       | Moves cursor to beginning of the line `n` (default 1) lines down. |
| Cursor prev line                   | **template:** `${cursorPrevLineOpen}$n$cursorPrevLineClose`  <br>**function:** `cursorPrevLineN(int n)`          <br>**default constant:** `cursorPrevLine`       | Moves cursor to beginning of the line `n` (default 1) lines up. |
| Cursor horizontal pos              | **template:** `${cursorHPosOpen}$n$cursorHPosClose`          <br>**function:** `cursorHPosTo(int n)`             <br>**default constant:** `cursorHPosToBegin`    | Moves the cursor to column `n` (default 1). |
| Cursor pos                         | **template:** `${cursorPosOpen}$row;$col$cursorPosClose`     <br>**function:** `cursorPosTo(int row, int col)`   <br>**default constant:** `cursorPosToTopLeft`   | Moves the cursor to `row` and `col`. |
| Cursor horizontal and vertical pos | **template:** `${cursorHVPosOpen}$row;$col$cursorHVPosClose` <br>**function:** `cursorHVPosTo(int row, int col)` <br>**default constant:** `cursorHVPosToTopLeft` | Same as `cursorPosTo`, just with some differences. |
| Erase in page                      | **template:** `${eraseInPageOpen}$s$eraseInPageClose`        <br>**function:**                                   <br>**default constants:** `erasePage`, `eraseInPageToBegin`, `eraseInPageToEnd` | Erases part of the page: `s`=0 (or missing) - to end, `s`=1 - to beginning, `s`=2 - entire page. |
| Erase in line                      | **template:** `${eraseInLineOpen}$s$eraseInLineClose`        <br>**function:**                                   <br>**default constants:** `eraseLine`, `eraseInLineToBegin`, `eraseInLineToEnd` | Erases part of the line: `s`=0 (or missing) - to end, `s`=1 - to beginning, `s`=2 - entire line. |
| Scroll up                          | **template:** `${scrollUpOpen}$n$scrollUpClose`              <br>**function:** `scrollUpN(int n)`                <br>**default constant:** `scrollUp`             | Scroll page up by `n` (default 1) lines. New lines are added at the bottom. |
| Scroll down                        | **template:** `${scrollDownOpen}$n$scrollDownClose`          <br>**function:** `scrollDownN(int n)`              <br>**default constant:** `scrollDown`           | Scroll page down by `n` (default 1) lines. New lines are added at the top. |
| Hide cursor                        | **constant:** `hideCursor`    | Hides the cursor. |
| Show cursor                        | **constant:** `showCursor`    | Shows the cursor. |
| Save cursor                        | **constant:** `saveCursor`    | Saves the cursor position, encoding shift state and formatting attributes. |
| Restore cursor                     | **constant:** `restoreCursor` | Restores the cursor position, encoding shift state and formatting attributes from the previous `saveCursor` if any, otherwise resets these all to their defaults. |
| Alternate screen                   | **constant:** `useAlternateScreen` | Switches to the screen a full-screen program draws on: the cursor is saved, the alternate screen is cleared, and the screen the program was started from is left untouched. |
| Main screen                        | **constant:** `useMainScreen` | Switches back to the screen the program was started from, scrollback and all, with the cursor where `useAlternateScreen` left it. |

All of the following examples are equivalent:

```dart
print('\x1B[4A');
print('${CSI}4$CUU');
print('${cursorUpOpen}4$cursorUpClose');
print(cursorUpN(4)); // Not constant!
```


### Independent control functions ESC Fs

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


### 256-color table

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
int rgb(int r, int g, int b); // r,g,b are numbers from 0 to 5
int gray(int level); // level is number from 0 to 23

print('${fg256(rgb(5, 5, 0))}');
print('${fg256(gray(16))}');
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
print('${fg256(rgb(5, 5, 0))} Yellow text $resetFg'); // Not constant!
```


### 24-bit RGB colors

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


## Analyzing and parsing


### Parser

`Parser` allows you to analyze text containing escape codes:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';

const text = '$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ';
final parser = Parser(text);
parser.matches.forEach(print);
// Match<Style>(start: 0, end: 4, entity: Sgr(bold), state: Style(bold))
// Match<Style>(start: 4, end: 10, entity: Text(' Bold '), state: Style(bold))
// Match<Style>(start: 10, end: 15, entity: Sgr(fgCyan), state: Style(bold, foreground: Color16.cyan))
// Match<Style>(start: 15, end: 26, entity: Text(' Bold+cyan '), state: Style(bold, foreground: Color16.cyan))
// Match<Style>(start: 26, end: 31, entity: Sgr(resetBoldAndDim), state: Style(foreground: Color16.cyan))
// Match<Style>(start: 31, end: 37, entity: Text(' Cyan '), state: Style(foreground: Color16.cyan))
```

In this way we can, for example, remove all escape codes:

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
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
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final buf = StringBuffer();
for (final m in parser.matches) {
  final result = switch (m.entity) {
    EscapeCode(:final id) => '[$id]',
    Text(:final string) => string,
  };
  buf.write(result);
}
print(buf); // [bold] Bold [fgCyan] Bold+cyan [resetBoldAndDim] Cyan
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

The style at a particular position can be found with `stateAt`.

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final atSeven = parser.stateAt(7);
print(atSeven); // Style(bold, foreground: Color16.cyan)
print(atSeven.isBold); // true
print(atSeven.isItalic); // false
print(atSeven.foregroundColor?.id); // fgCyan
print(atSeven.backgroundColor?.id); // null
```

The position in `stateAt` is specified in the plaintext range
(`pos` < `parser.length`) and can also point to the position behind the text
(`pos` == `parser.length`) to find out the final state. The final state can
also be obtained using `finalState`.

```dart
print(parser.stateAt(23) == parser.finalState); // true
print(parser.finalState); // Style(foreground: Color16.cyan)
```

Reading happens as late as it can. `stateAt` reads the string up to the
position asked about and stops there, and what it read is kept, so the next
question picks up where the last one left off instead of starting over:

```dart
final parser = Parser('$bold one $fgCyan two $resetBoldAndDim three ');
parser.stateAt(2); // reads as far as the third character
parser.finalState; // reads on from there, not from the beginning
```

`prepare` reads the whole string in one go rather than letting it grow question
by question, and builds the plain text that `length`, `indexOf`, `contains` and
the rest of the string methods work on:

```dart
final parser = Parser(text)..prepare();
```

It is worth calling when many questions are coming and pointless before one.

In the above example, the text state was not set to default, i.e. the text was
not closed:

```dart
const text = '$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ';
final parser = Parser(text);
print(parser.isClosed); // false
```

The easiest way to close a text is to add a `reset` at the end of it:

```dart
const closedText = '$text$reset';
print(Parser(closedText).isClosed); // true
```

The `substring` method allows you to retrieve a piece of text by computing
together its state:

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final substr = parser.substring(7, maxLength: 9); // "Bold+cyan"
print(Parser(substr).showControlFunctions()); // [fgCyan;bold]Bold+cyan[reset]
```

By default, the substring is closed. Escape codes is always included in the
string in optimized form:

```dart
final parser = Parser('$bold Bold $fgCyan Bold+cyan $resetBoldAndDim Cyan ');
final substr = parser.substring(7, maxLength: 9); // "Bold+cyan"
const test1 = '$fgCyan$bold';
final test2 = substr.substring(0, substr.indexOf('Bold'));
print(test1.ansiShowEscapeSequences()); // [CSI 36 SGR][CSI 1 SGR]
print(test2.ansiShowEscapeSequences()); // [CSI 36;1 SGR]
print(Parser(test1).showControlFunctions()); // [fgCyan][bold]
print(Parser(test2).showControlFunctions()); // [fgCyan;bold]
print(test1.length); // 9
print(test2.length); // 7
```

To optimize the entire string, there is an `optimize` method:

```dart
const text = '$fgWhite$bold$resetBoldAndDim$fgGreen$underline'
    "$resetUnderline$dim$dim What's in here? $resetBoldAndDim$resetFg";
print(text.length); // 63
final parser = Parser(text);
print(parser.showControlFunctions());
// [fgWhite][bold][resetBoldAndDim][fgGreen][underline][resetUnderline][dim][dim] What's in here? [resetBoldAndDim][resetFg]

final optimizedText = parser.optimize();
print(optimizedText.length); // 28
print(Parser(optimizedText).showControlFunctions());
// [fgGreen;dim] What's in here? [reset]
```

The `insertBefore` and `insertAfter` methods put text into a string without
disturbing what is already there. The inserted text takes the style of the
place it lands in, and whatever codes it carries of its own are closed after
it, so the rest of the string keeps the look it had:

```dart
const text = '${fgRed}Hello world$reset';
final inserted = Parser(text).insertBefore(6, '${fgGreen}brave ');
print(Parser(inserted).showControlFunctions());
// [fgRed]Hello [fgGreen]brave [fgRed]world[reset]
```

The position is counted in the string without escape codes, as everywhere else
in `Parser`. The two methods part ways only when escape codes stand at that
very position: one goes in front of them, the other behind:

```dart
const text = '${fgRed}Hello$reset world';
print(Parser(text).insertBefore(5, '!').ansiShowControlFunctions());
// [fgRed]Hello![reset] world
print(Parser(text).insertAfter(5, '!').ansiShowControlFunctions());
// [fgRed]Hello[reset]! world
```

For a string parsed only once there are the `ansiInsertBefore` and
`ansiInsertAfter` extensions, like the other shortcuts below.

### Quick analysis

You can quickly analyze a string without using `Parser` by using extensions.

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';

…

const text = '${fgRed}ERROR$reset';
print(text.ansiHasEscapeCodes); // true
print(text.ansiHasCsi); // true
print(text.ansiHasSgr); // true
print(text.ansiHasForeground); // true
print(text.ansiHasBackground); // false
print(text.ansiShowEscapeSequences()); // [CSI 31 SGR]ERROR[CSI 0 SGR]
```

The method `ansiShowControlCodes` allows to show all control codes from C0
set in a string:

```dart
const text = 'Tab: \t Line feed: \n Carriage return: \r Bell: \x07';

print(text.ansiShowControlCodes()); // preferStyle: ControlCodeStyle.escapeOrCharCode
// Tab: \t Line feed: \n Carriage return: \r Bell: \x07

print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.charCode));
// Tab: \x09 Line feed: \x0A Carriage return: \x0D Bell: \x07


print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr));
// Tab: [HT] Line feed: [LF] Carriage return: [CR] Bell: [BEL]

print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.escapeOrAbbr));
// Tab: \t Line feed: \n Carriage return: \r Bell: [BEL]

print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.unicode));
// Tab: ␉ Line feed: ␊ Carriage return: ␍ Bell: ␇

print(text.ansiShowControlCodes(preferStyle: ControlCodeStyle.escapeOrUnicode));
// Tab: \t Line feed: \n Carriage return: \r Bell: ␇
```

You can quickly remove all codes using the methods:

```dart
const text =
    '$saveCursor$cursorRight$italic$bgGreen$fgYellow Text $resetFg$resetBg$resetItalic$restoreCursor';
print(Parser(text).showControlFunctions());
// [saveCursor][CSI CUF][italic][bgGreen][fgYellow] Text [resetFg][resetBg][resetItalic][restoreCursor]

final withoutBackground = text.ansiRemoveBackground();
print(Parser(withoutBackground).showControlFunctions());
// [saveCursor][CSI CUF][italic][fgYellow] Text [resetFg][resetItalic][restoreCursor]

final andWithoutForeground = withoutBackground.ansiRemoveForeground();
print(Parser(andWithoutForeground).showControlFunctions());
// [saveCursor][CSI CUF][italic] Text [resetItalic][restoreCursor]

final andWithoutSgr = andWithoutForeground.ansiRemoveSgr();
print(Parser(andWithoutSgr).showControlFunctions());
// [saveCursor][CSI CUF] Text [restoreCursor]

final andWithoutCsi = andWithoutSgr.ansiRemoveCsi();
print(Parser(andWithoutCsi).showControlFunctions());
// [saveCursor] Text [restoreCursor]

final withoutAllEscapeCodes = text.ansiRemoveEscapeCodes();
print(withoutAllEscapeCodes.ansiShowEscapeSequences());
// ' Text '
```

### Sequence types

The sequences that carry something worth reading say it themselves, so a
`switch` over `matches` can ask for the sequence and for what it holds in one
pattern:

```dart
final text = '${cursorUpN(4)}$erasePage Hello $hideCursor';

for (final m in Parser(text).matches) {
  switch (m.entity) {
    case CursorUp(:final n):
      print('the cursor goes up $n lines');
    case EraseInPage(:final part):
      print('the page is erased: $part');
    case HideCursor():
      print('the cursor is hidden');
    case Text(:final string):
      print('the text says "$string"');
    default:
  }
}
// the cursor goes up 4 lines
// the page is erased: ErasePart.all
// the text says " Hello "
// the cursor is hidden
```

`CursorUp`, `CursorDown`, `CursorRight`, `CursorLeft`, `CursorNextLine`,
`CursorPrevLine`, `CursorHPos`, `ScrollUp` and `ScrollDown` carry `n`, the
number of places to move by, which is `1` when the sequence leaves it out.
`CursorPos` and `CursorHVPos` carry `row` and `col`. `EraseInPage` and
`EraseInLine` carry an `ErasePart` — `toEnd`, `toBegin` or `all`. `ShowCursor`,
`HideCursor`, `UseAlternateScreen` and `UseMainScreen` stand for the four
private modes this package writes itself.

All but the last four extend `CsiCommon`, so `is CsiCommon`, `controlSequence`
and the identifiers they are shown by are what they always were; the four
private modes stand beside `CsiPrivate` instead, the way `SaveCursor` stands
beside the other ESC sequences, and are shown by the name of the constant they
are written with.

A sequence carrying something other than what its type promises — two
parameters where one is taken, or a part `ErasePart` has no name for, like the
xterm `CSI 3 J` — keeps its parameters and stays a plain `CsiCommon` rather
than being given made-up values.

### Unknown sequences

The parser never throws on what it cannot name. Whatever it fails to recognize
comes back as an entity of its own with the raw bytes kept intact: `CsiUnknown`,
`EscUnknown`, `OscUnknown` and `UnknownEscapeCode` for what has no meaning here,
and `CsiPrivate` for the private-use sequences, whose meaning the standard
leaves to the terminal. All of them carry the `UnrecognizedEscapeCode` mixin, so
a single check covers them:

```dart
const text = 'a\x1B[!pb\x1B[?7hc';
for (final m in Parser(text).matches) {
  if (m.entity case final UnrecognizedEscapeCode e) {
    print('${m.start}..${m.end}: ${e.id}');
  }
}
// 1..5: CSI !p
// 6..11: CSI ?7 SM
```

`start` and `end` are positions in the original string, so a complaint can point
at the bytes it is about.

To put something else in their place, `replaceAll` walks the string once and
writes back whatever is returned:

```dart
print(Parser(text).replaceAll((e) => e is UnrecognizedEscapeCode ? '?' : e.string));
// a?b?c
```

### Printer

Escape codes do not allow you to set default values for your text. The
foreground and background colors depend on the implementation of the terminal
you are using. And so if you want to use some other values, you cannot use
`resetFg` (CSI FOREGROUND_DEFAULT SGR) and `resetBg` (CSI BACKGROUND_DEFAULT
SGR). Each time you will have to substitute your own values instead:

```dart
const text =
    '$bg256Rgb113$fg256Rgb442 Default text '
    '$bgWhite$fgBlack Highlighted text '
    '$bg256Rgb113$fg256Rgb442 Default text again $reset';
print(text);
```

You can move the color setting to constants and use them everywhere:

```dart
const defaultStyle = '$bg256Rgb113$fg256Rgb442';
const text = '$defaultStyle Default text '
    '$bgWhite$fgBlack Highlighted text '
    '$defaultStyle Default text again $reset';
print(text);
```

Or you can use `Printer`:

```dart
const text = ' Default text '
    '$bgWhite$fgBlack Highlighted text $reset'
    ' Default text again';
final printer = Printer(
  defaultStyle: const Style(
    background: Color256.rgb113,
    foreground: Color256.rgb442,
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
  runZonedPrinter(
    defaultStyle: const Style(
    background: Color256.rgb113,
    foreground: Color256.rgb442,
    ),
    () {
      // … Your application code …

      const text = ' Default text '
          '$bgWhite$fgBlack Highlighted text $reset'
          ' Default text again';

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

runZonedPrinter(
  defaultStyle: const Style(
    background: Color16.green,
    foreground: Color16.yellow,
  ),
  output: log,
  () {
    const text = ' Default text '
        '$bgWhite$fgBlack Highlighted text $resetBg$resetFg'
        ' Default text again $reset';
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
runZonedPrinter(
  defaultStyle: …,
  ansiCodesEnabled: !Platform.isIOS,
  () {
    const text = ' Default text '
        '$bgWhite$fgBlack Highlighted text $reset'
        ' Default text again';
    print(text);
  },
);
```

### StackedPrinter

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

const name = '${bold}Sam$resetBoldAndDim';

…

final text = makeMessage(name);
print(text);
// Dear [bold]Sam[resetBoldAndDim]! We are pleased to present to you …
```

Without noticing it, at some point your designer decides to make changes to the
template:

```dart
const template = '${bold}Dear {name}, welcome to us!$resetBoldAndDim We are pleased to present to you …';

…

final text = makeMessage(name);
print(text);
// [bold]Dear [bold]Sam[resetBoldAndDim], welcome to us![resetBoldAndDim] We are pleased to present to you …
```

But the escape codes don't accumulate, double `bold` equals single `bold`. And
first `resetBoldAndDim` cancels the bold text. And we don't get what we want
at all. To fix it, we need to return the state of the text after insertion to
the state it was before insertion. But it makes it much more difficult to use
the escape codes. `StackedPrinter` helps solve this problem:

```dart
final printer = StackedPrinter();
printer.print(text);
// [bold]Dear Sam, welcome to us![resetBoldAndDim] We are pleased to present to you …
```

`StackedPrinter` accumulates state changes and sequentially disables them,
translating the current state into the standard escape sequence on output:

```dart
const text = '$bold 1 $bold 2 $bold 3 $resetBoldAndDim 2 $resetBoldAndDim 1 $resetBoldAndDim';
final printer1 = Printer();
final printer2 = StackedPrinter();
printer1.print(text); // '[reset][bold] 1  2  3 [reset] 2  1 '
printer2.print(text); // '[reset][bold] 1  2  3  2  1 [reset]'
```

### Printing to a sink

`Printer` and `StackedPrinter` hand their output to a print function.
`SinkPrinter` and `StackedSinkPrinter` write it to a `StringSink` instead —
a `StringBuffer`, a file, `stdout` — and keep the style across the writes:

```dart
final buf = StringBuffer();
SinkPrinter(buf, defaultStyle: style.bgGray3)
  ..write('one ')
  ..write('${fgRed}two$reset');

print(Parser(buf.toString()).showControlFunctions());
// [reset][bg256Gray3]one [reset][reset][bg256Gray3][fgRed]two[reset]
```

Both take the same `defaultStyle` as the others, and both take
`ansiCodesEnabled`. Setting it to `false` writes the text without any escape
codes at all — the codes the text carries included:

```dart
final plain = StringBuffer();
SinkPrinter(plain, ansiCodesEnabled: false).write('${fgRed}two$reset');
print(plain); // two
```

That is the switch for output that is not a terminal. `NoStyle` is a different
thing: it stops the printer from putting a style of its own around the text,
but the codes the text carries still go through.


## Utilities

Two things a terminal will only tell or take in person, both in `utils.dart`.

`tabs` sets the tabulation stops. The stops that were there are always cleared
first, so a call without arguments leaves the terminal with none — it does not
bring back the ones it started with:

```dart
tabs(defaultTab: 4); // a stop every 4 columns, to the width of the terminal
tabs(tabs: [8, 4, 4]); // stops at 8, 12 and 16
```

Nothing is written when `stdout` is not a terminal: there are no stops to set
and no width to fit them into.

`currentCursorPos` asks the terminal where the cursor is — `CSI 6 n` out, and
`CSI n ; m R` back through stdin:

```dart
final (row, col) = await currentCursorPos(stdout, stdin);
```

The terminal is given 100 milliseconds to answer by default; a terminal that
does not answer at all throws `UnsupportedError`. Stdin can only be listened to
once, so to ask twice — or to keep reading input afterwards — pass a broadcast
stream over it as `input`.


## Logging

Nothing has to be tied to a logging package: a record is a string and the
constants are strings, so coloring a level name needs no help. What does need
help are the two places where escape codes bite.

The first is width. `String.length` counts the escape codes, so padding a
colored level name pads it by the wrong amount. `Parser` counts what is seen:

```dart
const level = '${fgRed}SEVERE$reset';
print(level.length); // 15
print(Parser(level).length); // 6
print('[${level.padRight(10)}]'); // [SEVERE] — the codes ate the padding
print('[${Parser(level).padRight(10)}]'); // [SEVERE    ]
print('[${Parser(level).padLeft(10)}]'); // [    SEVERE]
```

A padding of more than one character overshoots the width, the way
`String.padRight` overshoots it: it is written once for every character still
wanted, not once for every place it fills.

The second is the sink. A terminal reads the codes, a log file keeps them as
bytes nobody will read back, so the same line goes out twice in two shapes:

```dart
void write(String line) {
  stdout.writeln(line);
  logFile.writeAsStringSync('${line.ansiRemoveEscapeCodes()}\n',
      mode: FileMode.append);
}
```

And a message that arrives already styled from elsewhere is the case
[StackedPrinter](#stackedprinter) was written for: whatever the message opens is
closed at its end, and the next line starts in the style it should.
