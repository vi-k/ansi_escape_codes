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

Both halves of that, in one import:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

// Writing: by a style, or by constants that cost nothing at run time.
print('${Styles.red.bold('ERROR')} the roof is on fire');
print('${fgCyan}the same in cyan$reset');

// Reading: what a string says, how long it is without the codes, and what
// the style is at any point of it.
const line = '${fgRed}ERROR$reset: the roof is on fire';
final parser = Parser(line);

print(parser.removeAll()); // ERROR: the roof is on fire
print(parser.length); // 26
print(parser.stateAt(3).foregroundColor?.id); // fgRed
print(parser.showControlFunctions()); // [fgRed]ERROR[reset]: the roof is on fire
```


## Features

- coloring: you can use ready-to-use values to create constant strings and
  [maximize performance](#maximum-performance), or choose the power of
  [styles](#the-power-of-styles).
- cursor and terminal control
- [reading](#reading) strings that carry escape codes: what they say, how wide
  they are, what style is in force at any point
- [a default style](#printer) for everything the application prints


## Table of contents

- [Quick start](#quick-start)
  - [How do I color text?](#how-do-i-color-text)
- [The names this package brings](#the-names-this-package-brings)
- [Writing](#writing)
  - [Constants, and the strings built from them](#constants-and-the-strings-built-from-them)
  - [Ready-to-use functions and constants](#ready-to-use-functions-and-constants)
  - [Styles](#styles)
  - [Printer](#printer)
  - [StackedPrinter](#stackedprinter)
  - [Printing to a sink](#printing-to-a-sink)
  - [A default style for everything printed](#a-default-style-for-everything-printed)
  - [Logging](#logging)
- [Reading](#reading)
  - [Parser](#parser)
  - [Quick analysis](#quick-analysis)
  - [Sequence types](#sequence-types)
  - [Unknown sequences](#unknown-sequences)
- [Utilities](#utilities)
- [The bytes and what they mean](doc/reference.md) — the tables of the standard


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

Every one of them is listed in [the reference](doc/reference.md), and they live
in [lib/src/ansi](https://github.com/vi-k/ansi_escape_codes/tree/main/lib/src/ansi).

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

The reference names them beside the codes they write, and they live in
[lib/src/ready_to_use](https://github.com/vi-k/ansi_escape_codes/tree/main/lib/src/ready_to_use).

#### The power of styles

```dart
import 'package:ansi_escape_codes/style.dart';

void main() {
  final defaultStyle = Styles.gray12;
  final greenStyle = Styles.green.bold;
  final highlighedStyle = Styles.red.bgYellow.underline;

  print(
    defaultStyle(
      'Normal text'
      ' ${greenStyle('Green ${highlighedStyle('Highlighted text')} text')}'
      ' Normal text',
    ),
  );
}
```

First, you can assemble your own style from any pieces. Every style that
carries one thing is a constant on `Styles` — a property, or a colour of the
table — and a chain goes on from whichever of them comes first:

```dart
final mine = Styles.rgb050.bgRgb010.bold.italic.underline;
final warning = Styles.red.bold;
```

Second, styles can be nested: after completing the action of a nested style,
the style will return to the parent style.


## The names this package brings

Each entry point brings a different part of the package:

| Import | Names | What it brings |
|:---|---:|:---|
| `ansi_escape_codes.dart` | ~1000 | all of it: the ready-to-use strings (`fgRed`, `cursorUp`), the styles, the parser, the state, the control function tables, the `String` extensions and the two terminal utilities |
| `ansi.dart` | ~500 | the bytes the standard names: `CSI`, `CUU`, `BOLD`, `RESERVED_5F`. The only one that is not part of the first — the ready-to-use strings are built from these, and neither brings the other |
| `style.dart` | 77 | the styles and the parser, without the tables of ready-to-use strings |
| `parsing.dart` | 82 | the parser, the state and the control function tables |
| `extensions.dart` | 6 | the `String` extensions alone |
| `utils.dart` | 2 | `tabs` and `currentCursorPos` alone |

The bottom four are parts of the first, and are there for the times a smaller
namespace is worth an import of its own — a program that only reads escape
codes has no use for the 900 constants that write them.

One import is usually enough:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

print('${bold}by the string$reset');
print(Styles.bold('by the style'));
```

The string and the style are told apart by where they are: `bold` is a `String`
of escape codes, `Styles.bold` is the style. Of the styles nothing is written
in lowercase, so the two never collide.

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

What is exported in lowercase is the ready-to-use strings — `fgRed`,
`cursorUp`, `bold` — and `tabs`. The styles are not among them: they are
constants on `Styles`, so the name most likely to meet one of your own is
`tabs`, and `hide` or a prefix settles that the same way.


## Writing

The constants and the styles are the two ways of dressing a string; the
printers are for dressing everything a program prints, whether it asked to
be dressed or not.

### Constants, and the strings built from them

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
print('${fgRgbOpen}255;128;0$fgRgbClose Orange text $reset');
print('${fgRgb(255, 128, 0)} Orange text $reset'); // Not constant!
```

Control codes are deliberately named in **SCREAMING_SNAKE_CASE** as opposed to
the common Dart **camelCase**.  First, this is how they are named in the
Standard. Second, in this form they will not prevent you from naming your own
variables. **Thirdly, and most importantly, most users do not need to use them
directly.**

Every one of them is listed in
[the reference](doc/reference.md) — the C0 and C1 sets, the final bytes of the
control sequences, the independent functions, all the SGR parameters, the
256-color table and the 24-bit colors — with what each does and the
ready-to-use name beside it. What follows here is the table that is reached for
while writing rather than searched.

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

### Styles

`Styles` holds every style that carries one thing, and there are 783 of them:
the fifteen properties — `Styles.bold`, `Styles.italic` — and the 256-colour
table three times over, `Styles.red` for the colour of the text, `Styles.bgRed`
for the colour behind it, `Styles.underlineRed` for the colour of the
underline. Being constants, a style can be held in one:
`const error = Styles.red`.

A chain builds on them — `Styles.red.bold.bgYellow` — and the colors the table
does not name are passed as values:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/extensions.dart';

final mine = Styles.underline
    .foreground(Color256.rgb(5, 2, 0)) // the 6x6x6 cube
    .background(ColorRgb(0x33, 0x66, 0x99)) // 24-bit
    .underlineColor(Color256.gray(12)) // one of the 24 grays
    .underline;

print(mine('text').ansiShowEscapeSequences());
// [CSI 0 SGR][CSI 38;5;208 SGR][CSI 48;2;51;102;153 SGR][CSI 58;5;244 SGR]
// [CSI 4 SGR]text[CSI 0 SGR]
```

Every entry of the table has a name of its own as well — `Color256.rgb520`,
`Color256.gray12`, `Color256.red` — and `Color16` holds the sixteen the
terminal names itself, which are the ones the short `CSI 31` form writes. The
underline is the one that takes no `Color16`: the standard gives it no
sixteen-color form, so `underlineColor` asks for an `ExtendedColor`.

A style hands the colors back as it was given them, and each knows what it was
set on:

```dart
print(mine.foregroundColor?.id); // fg256Rgb520
print(mine.backgroundColor?.id); // bgRgb(51,102,153)
print(mine.underlineColorValue?.id); // underline256Gray12
```

That is what `ColorTarget` is for. A color on its own has no target and says so
with a `?`; `foreground`, `background` and `underlineColor` set it themselves,
so `on` is only needed to name a color outside a style:

```dart
print(Color256.rgb(5, 2, 0).id); // ?256Rgb520
print(Color256.rgb(5, 2, 0).on(ColorTarget.background).id); // bg256Rgb520
```

Calling a style wraps a string. Where the two halves are wanted apart — a
buffer written to in pieces, a style that outlives one call — they are `open`
and `close`:

```dart
final warning = Styles.red.bold;

print(warning.open.ansiShowEscapeSequences()); // [CSI 38;5;1 SGR][CSI 1 SGR]
print(warning.close.ansiShowEscapeSequences()); // [CSI 0 SGR]
print(warning('text').ansiShowEscapeSequences());
// [CSI 0 SGR][CSI 38;5;1 SGR][CSI 1 SGR]text[CSI 0 SGR]
```

`open` does not begin with a reset: it writes the difference from the
terminal's own colors, and assumes the terminal is in them. The call form
writes the reset first. `NoStyle` answers with an empty string to both, so code
holding a style needs no test for it.

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
// [reset][bold]Dear Sam, welcome to us![reset] We are pleased to present to you …
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
SinkPrinter(buf, defaultStyle: Styles.bgGray3)
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

### A default style for everything printed

You cannot set default colors for the entire terminal. However, Dart allows you
to intercept calls to the `print` and override the default style in those
calls.

Example (if you use styles):

```dart
import 'package:ansi_escape_codes/style.dart';

void main() {
  final greenStyle = Styles.green.bold;
  final highlighedStyle = Styles.red.bgYellow.underline;

  runZonedPrinter(
    defaultStyle: Styles.gray12,
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
> `Styles.bold` is the style. See [the names this package
> brings](#the-names-this-package-brings).

### Logging

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


## Reading

A string that already carries escape codes is what `Parser` is for: what it
says with the codes taken out, how wide it is on the screen, what style is in
force at any point of it, and what every sequence in it means.

### Parser

`Parser` allows you to analyze text containing escape codes. There are two of
them, and everything below holds for both: `Parser` keeps the style in force
at each point, `StackedParser` keeps the history of how it got there, so that a
`resetFg` goes back to the color before the last one rather than to the
terminal's own. The difference is the one between
[Printer and StackedPrinter](#stackedprinter), and the state it hands out is a
`Stack` instead of a `Style`.

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

It keeps its place as well as its reading, so asking about position after
position — which is what laying text out does — costs one walk of the string
in all rather than one walk each. Going back is allowed and starts the walk
over.

`prepare` reads the whole string in one go and builds the plain text that
`length`, `indexOf`, `contains` and the rest of the string methods work on:

```dart
final parser = Parser(text)..prepare();
```

Those methods are what it is for. `stateAt` and `substring` do not gain by it,
and lose by it where the questions are not going to reach the end of the
string. `benchmark/` measures both.

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
They are also the quicker way when one answer is all that is wanted: they work
by regular expression, where `Parser` builds an entity for every code it meets
— on a page of colored log, `ansiRemoveEscapeCodes` takes about two thirds of
what `Parser.removeAll` does.

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

The rest of the extensions, in one breath: `ansiHasUnderlineColor` and
`ansiRemoveUnderlineColor` do for the color of the underline what the pairs
above do for the foreground and the background; `ansiHasControlCodes` and
`ansiRemoveControlCodes` ask about and take out the C0 bytes and `DEL` rather
than the escape codes — `ESC` is one of those bytes, so take the escape codes
out first or their bodies are left behind as text, and name the ones to keep
with `exclude: {ControlFunctionsC0.LF}`; `lengthWithoutEscapeCodes` is
`Parser.length` for a string read once; `ansiShowControlFunctions` and
`ansiOptimizeControlFunctions` are `Parser.showControlFunctions` and
`Parser.optimize` for a string read once.

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

Every recognized sequence keeps its parameters as they were written, in
`params`: a `CsiParamNumber` where the parameter is a number, a
`CsiParamDefault` where it was left out, and a `CsiParamNumbers` where it
carries sub-parameters after a colon. The colon form is read as the standard
means it, so `CSI 4:3 m` is an underline and `CSI 38:2::51:102:153 m` is an RGB
color, and what the sub-parameters say beyond that — a curly underline rather
than a straight one — is in `params` rather than in the style:

```dart
const text = '\x1B[4:3m wavy \x1B[;5H\x1B[38:2::51:102:153m';

for (final m in Parser(text).matches) {
  if (m.entity case Sgr(:final params, :final id) ||
      CsiCommon(:final params, :final id)) {
    print('$id  $params');
  }
}
// underline  [4:3]
// CSI ;5 CUP  [, 5]
// fgRgb(51,102,153)  [38:2:0:51:102:153]
```

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
