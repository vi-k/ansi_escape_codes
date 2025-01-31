# ansi_escape_codes

This is yet another package of many for
[ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code). It differs
from the others only in that it focuses on using **constants** rather than
functions or methods.

Since version 1.4.0, analysis has also been added.

## Usage

```dart
const text =
    // 4-bit colors.
    '${fgBrightGreen}Lorem'
    ' ${fgGreen}ipsum'
    ' $bgBrightBlack${fgWhite}dolor$bgDefault'
    ' $bgBrightWhite${fgBlack}sit$bgDefault'
    // 8-bit colors.
    ' ${fg256HighRed}amet,'
    ' ${fg256Red}consectetur$fgDefault'
    // 24-bit colors.
    ' ${bgRgbOpen}249;105;14$bgRgbClose'
    '${fgRgbOpen}64;48;32$fgRgbClose'
    'adipiscing'
    // Inverted colors.
    ' $invert elit,$notInverted'
    '$fgDefault$bgDefault'
    // Italic.
    ' ${italic}sed$notItalic'
    ' do'
    // Bold and faint.
    ' ${bold}eiusmod$notBoldNotFaint'
    ' ${faint}tempor$notBoldNotFaint'
    '$fgCyan'
    ' incididunt'
    ' ${increasedIntensity}ut$normalIntensity'
    ' ${decreasedIntensity}labore$normalIntensity'
    '$fgDefault'
    // Etc.
    ' ${underline}et$notUnderlined'
    ' ${strike}dolore$notStriked'
    ' ${hide}magna$notHidden'
    ' ${blink}aliqua$notBlinking.';

print(text);

print(removeBackgroundColors(text));
print(removeEscapeSequences(text));
print(
  showEscapeSequences(
    text,
    recognizeSequences: true,
  ),
);
print(
  handleEscapeSequences(
    text,
    (seq) => '$seq${showEscapeSequences(seq, recognizeSequences: true)}',
  ),
);
```

### Colors

#### 4-bit colors

<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>

| Foreground      | Background      |
|:----------------|:----------------|
| fgBlack         | bgBlack         |
| fgRed           | bgRed           |
| fgGreen         | bgGreen         |
| fgYellow        | bgYellow        |
| fgBlue          | bgBlue          |
| fgMagenta       | bgMagenta       |
| fgCyan          | bgCyan          |
| fgWhite         | bgWhite         |
| fgBrightBlack   | bgBrightBlack   |
| fgBrightRed     | bgBrightRed     |
| fgBrightGreen   | bgBrightGreen   |
| fgBrightYellow  | bgBrightYellow  |
| fgBrightBlue    | bgBrightBlue    |
| fgBrightMagenta | bgBrightMagenta |
| fgBrightCyan    | bgBrightCyan    |
| fgBrightWhite   | bgBrightWhite   |

Example:

```dart
print('$fgBrightYellow$bgGreen Yellow text on green field $reset');
```

#### 8-bit colors (256-color table)

<https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>

Templates for using a color from a 256-color table:

- Foreground:

  ```dart
  '${fg256Open}${colorIndex}${fg256Close}'
  ```

- Background:

  ```dart
  '${bg256Open}${colorIndex}${bg256Close}'
  ```

- Underline:

  ```dart
  '${underline256Open}${colorIndex}${underline256Close}'
  ```

Where `colorIndex` is the color index from the 256-color table. You can use
predefined values from the following table:

|   Index | Name        | Comment |
|--------:|:------------|:--------|
|       0 | black       |         |
|       1 | red         |         |
|       2 | green       |         |
|       3 | yellow      |         |
|       4 | blue        |         |
|       5 | magenta     |         |
|       6 | cyan        |         |
|       7 | white       |         |
|       8 | highBlack   |         |
|       9 | highRed     |         |
|      10 | highGreen   |         |
|      11 | highYellow  |         |
|      12 | highBlue    |         |
|      13 | highMagenta |         |
|      14 | highCyan    |         |
|      15 | highWhite   |         |
|  16-231 | rgb**NNN**  | N are numbers from 0 to 5 (6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b) |
| 232-255 | gray**N**   | N is a number from 0 to 23 (grayscale from dark to light in 24 steps) |

Example:

```dart
print('$fg256Open$highYellow$fg256Close$bg256Open$green$bg256Close Yellow text on green field $fgDefault');
```

You don't have to use templates and take the predefined values from the
following table:

|    Index | Name                            | Comment |
|---------:|:--------------------------------|:--------|
|        0 | (fg/bg/underline)256Black       |         |
|        1 | (fg/bg/underline)256Red         |         |
|        2 | (fg/bg/underline)256Green       |         |
|        3 | (fg/bg/underline)256Yellow      |         |
|        4 | (fg/bg/underline)256Blue        |         |
|        5 | (fg/bg/underline)256Magenta     |         |
|        6 | (fg/bg/underline)256Cyan        |         |
|        7 | (fg/bg/underline)256White       |         |
|        8 | (fg/bg/underline)256HighBlack   |         |
|        9 | (fg/bg/underline)256HighRed     |         |
|       10 | (fg/bg/underline)256HighGreen   |         |
|       11 | (fg/bg/underline)256HighYellow  |         |
|       12 | (fg/bg/underline)256HighBlue    |         |
|       13 | (fg/bg/underline)256HighMagenta |         |
|       14 | (fg/bg/underline)256HighCyan    |         |
|       15 | (fg/bg/underline)256HighWhite   |         |
|  16..231 | (fg/bg/underline)256Rgb**NNN**  | N are numbers from 0 to 5 (6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b) |
| 232..255 | (fg/bg/underline)256Gray**N**   | N is a number from 0 to 23 (grayscale from dark to light in 24 steps) |

Example:

```dart
print('$fg256HighYellow$bg256Green Yellow text on green field $reset');
print('$fg256Rgb550$bg256Rgb240 Yellow text on green field $reset');
```

You can use the following functions:

- to get color indexes:

  ```dart
  int rgb(int r, int g, int b);
  int gray(int level);
  ```

  Where `r`, `g`, `b` are values from 0 to 5. And where `level` is a value
  from 0 to 23.

  Example:

  ```dart
  print('$fg256Open${rgb(5, 5, 0)}$fg256Close$bg256Open${rgb(2, 4, 0)}$bg256Close Yellow text on green field $reset');
  print('$fg256Open${gray(16)}$fg256Close$bg256Open${gray(8)}$bg256Close Gray text on gray field $reset');
  ```

- to set the color:

  ```dart
  String fg256(int colorIndex);
  String bg256(int colorIndex);
  String underline256(int colorIndex);
  ```

  Example:

  ```dart
  print('${fg256(highYellow)}${bg256(green)} Yellow text on green field $reset');
  ```

#### 24-bit colors (RGB)

<https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit>

Templates for using a RGB color:

- Foreground:

  ```dart
  '${fgRgbOpen}${r};${g};${b}${fgRgbClose}'
  ```

- Background:

  ```dart
  '${bgRgbOpen}${r};${g};${b}${bgRgbClose}`'
  ```

- Underline:
  ```dart
  '${underlineRgbOpen}${r};${g};${b}${underlineRgbClose}'
  ```

Where `r`, `g`, `b` are values from 0 to 255.

You can use the following functions to dynamically generate a value:

```dart
String fgRgb(int r, int g, int b);
String bgRgb(int r, int g, int b);
String underlineRgb(int r, int g, int b);
```

Example:

```dart
print('${fgRgb(255, 255, 0)}${bgRgb(128, 192, 0)} Yellow text on green field $reset');
```

#### Reset color

You can reset the set color with `fgDefault`, `bgDefault` and
`underlineColorDefault`. Or with `reset`, which will turn off all attributes.

### Control sequences

| Default constant | Template                                               | Function                  | Description                                                                         |
|:-----------------|:-------------------------------------------------------|:--------------------------|:------------------------------------------------------------------------------------|
| `cursorUp`       | `${cursorUpOpen}[${n}]${cursorUpClose}`                | `cursorUpN(n)`            | Moves the cursor up `n` (default `1`) lines.                                        |
| `cursorDown`     | `${cursorDownOpen}[${n}]${cursorDownClose}`            | `cursorDownN(n)`          | Moves the cursor down `n` (default `1`) lines.                                      |
| `cursorForward`  | `${cursorForwardOpen}[${n}]${cursorForwardClose}`      | `cursorForwardN(n)`       | Moves the cursor forward `n` (default `1`) cells.                                   |
| `cursorBack`     | `${cursorBackOpen}[${n}]${cursorBackClose}`            | `cursorBackN(n)`          | Moves the cursor back `n` (default `1`) cells.                                      |
| `cursorNextLine` | `${cursorNextLineOpen}[${n}]${cursorNextLineClose}`    | `cursorNextLineN(n)`      | Moves cursor to beginning of the line `n` (default `1`) lines down.                 |
| `cursorPrevLine` | `${cursorPrevLineOpen}[${n}]${cursorPrevLineClose}`    | `cursorPrevLineN(n)`      | Moves cursor to beginning of the line `n` (default `1`) lines up.                   |
| `cursorHPos`     | `${cursorHPosOpen}[${n}]${cursorHPosClose}`            | `cursorHPosN(n)`          | Moves the cursor to column `n` (default `1`).                                       |
| `cursorPos`      | `${cursorPosOpen}[${row};${col}]${cursorPosClose}`     | `cursorPosTo(row, col)`   | Moves the cursor to `row` and `col`. The values are 1-based, and default to `1` (top left corner) if omitted. |
| `cursorHVPos`    | `${cursorHVPosOpen}[${row};${col}]${cursorHVPosClose}` | `cursorHVPosTo(row, col)` | Same as `cursorPos`, but counts as a format effector function (like `cr` or `lf`) rather than an editor function (like `cursorUp` or `cursorNextLine`). This can lead to different handling in certain terminal modes. |
| `clearScreen…`   | `${clearScreenOpen}[${n}]${clearScreenClose}`          |                           | Clears part of the screen. If `n` is `0` (or missing), clear from cursor to end of screen (`clearScreenToEnd`). If `n` is `1`, clear from cursor to beginning of the screen (`clearScreenToBegin`). If `n` is `2`, clear entire screen and moves cursor to upper left (`clearScreen`). If `n` is `3`, clear entire screen and delete all lines saved in the scrollback buffer (`clearScreenWithBuf`). |
| `eraseLine…`     | `${eraseLineOpen}[${n}]${eraseLineClose}`              |                           | Erases part of the line. If `n` is `0` (or missing), clear from cursor to the end of the line (`eraseLineToEnd`). If `n` is `1`, clear from cursor to beginning of the line (`eraseLineToBegin`). If `n` is `2`, clear entire line (`eraseLine`). Cursor position does not change. |
| `scrollUp`       | `${scrollUpOpen}[${n}]${scrollUpClose}`                | `scrollUpN(n)`            | Scroll whole page up by `n` (default `1`) lines. New lines are added at the bottom. |
| `scrollDown`     | `${scrollDownOpen}[${n}]${scrollDownClose}`            | `scrollDownN(n)`          | Scroll whole page down by `n` (default `1`) lines. New lines are added at the top.  |
| `hideCursor`     |                                                        |                           | Shows the cursor.                                                                   |
| `showCursor`     |                                                        |                           | Hides the cursor.                                                                   |
| `saveCursor`     |                                                        |                           | Saves the cursor position, encoding shift state and formatting attributes.          |
| `restoreCursor`  |                                                        |                           | Restores the cursor position, encoding shift state and formatting attributes from the previous `saveCursor` if any, otherwise resets these all to their defaults. |

## Analysis

### `has...()`

With the `hasEscapeSequences`, `hasCsi`, `hasSgr`, `hasForegroundColor` and
`hasBackgroundColor` methods you can find out if the escape sequences are
contained in the text:

```dart
hasEscapeSequences('${fgRed}ERROR$reset'); // true
```

### `showEscapeSequences()`

You can convert the escape sequence into a readable form using the
`showEscapeSequences` method:

```dart
print(showEscapeSequences('${fgRed}ERROR$reset'));
```

```
[CSI 31 SGR]ERROR[CSI 0 SGR]
```

Escape sequences can also be recognized:

```dart
print(showEscapeSequences('${fgRed}ERROR$reset', recognizeSequences: true));
```

```
[fgRed]ERROR[reset]
```

### `showControlCodes()`

You can convert the control codes (0x00-0x1F and 0x7F) into a readable form
using the `showControlCodes` method:

```dart
final text = 'Title\nKey:\tValue';
print(showControlCodes(text));
print(showControlCodes(text, preferStyle: ControlCodeStyle.abbr));
print(showControlCodes(text, preferStyle: ControlCodeStyle.emoji));
print(showControlCodes(text, preferStyle: ControlCodeStyle.charCode));
```

```
Title\nKey:\tValue
Title[LF]Key:[HT]Value
Title␊Key:␉Value
Title\x0AKey:\x09Value
```

### `remove...()`

With the `removeEscapeSequences`, `removeCsi`, `removeSgr`,
`removeForegroundColor` and `removeBackgroundColor` methods, you can remove
escape sequences from the text:

```dart
const text = '${fgRed}ERROR$reset';
print(showEscapeSequences(text));
print(showEscapeSequences(removeEscapeSequences(text)));
```

```
CSI 31 SGR]ERROR[CSI 0 SGR]
ERROR
```

### `all...()`

With the `allEscapeSequences`, `allCsi`, `allSgr`, `foregroundColors` and
`backgroundColors` methods you can get a list of all escape sequences in the
text:

```dart
allEscapeSequences('${fgRed}ERROR$reset')).forEach(print);
```

```
Match(code: [CSI 31 SGR], recognize: [fgRed], start: 0, end: 5)
Match(code: [CSI 0 SGR], recognize: [reset], start: 10, end: 14)
```

### `handle...()`

With the `handleEscapeSequences` and `handlePlainText` methods, you can handle
escape sequences and plain text as you see fit:

```dart
print(
  handleEscapeSequences(
    '${bold}Title$reset\nKey:\tValue',
    (seq) => '(ansi escape code)',
    handlePlainText: showControlCodes,
  ),
);
```

```
(ansi escape code)Title(ansi escape code)\nKey:\tValue
```

The `handlePlainText` method handles only plain text.
