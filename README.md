# ansi_escape_codes

This is yet another package of many for [ANSI escape codes](https://en.wikipedia.org/wiki/ANSI_escape_code). It differs from the
others only in that it focuses on using **constants** rather than functions or
methods.

```dart
const text = '${fgGreen}Lorem$fgDefault'
    ' $fgYellow${bgBrightBlack}ipsum$fgDefault$bgDefault'
    ' $fg256Open$red${fg256Close}dolor$fgDefault'
    ' $fg256Open$rgb531${fg256Close}sit$fgDefault'
    ' $fg256Open$gray9${fg256Close}amet,$fgDefault'
    ' $fg256Open$gray13${fg256Close}consectetur$fgDefault'
    ' $fg256Open$gray17${fg256Close}adipiscing$fgDefault'
    ' ${fgRgbOpen}249;105;14${fgRgbClose}elit,$fgDefault'
    ' ${bold}sed ${normalIntensity}do ${faint}eiusmod$reset'
    ' ${italic}tempor$notItalic'
    ' ${strike}incididunt$notStrike'
    ' ${underline}ut$notUnderlined'
    ' ${subscript}labore$notSuperscriptNotSubscript'
    ' et'
    ' ${superscript}dolore$notSuperscriptNotSubscript'
    ' ${blink}magna$notBlinking'
    ' ${invert}aliqua.$notInverted';

print(text);
```

## Colors

### Standarts 16 colors

<https://en.wikipedia.org/wiki/ANSI_escape_code#3-bit_and_4-bit>

| foreground      | background      |
|:----------------|:----------------|
| fgBlack         | bgBlack         |
| fgRed           | bgRed           |
| fgGreen         | bgGreen         |
| fgYellow        | bgYellow        |
| fgBlue          | bgBlue          |
| fgMagenta       | bgMagenta       |
| fgCyan          | bgCyan          |
| fgWhite         | bgWhite         |
| fgDefault       | bgDefault       |
| fgBrightBlack   | bgBrightBlack   |
| fgBrightRed     | bgBrightRed     |
| fgBrightGreen   | bgBrightGreen   |
| fgBrightYellow  | bgBrightYellow  |
| fgBrightBlue    | bgBrightBlue    |
| fgBrightMagenta | bgBrightMagenta |
| fgBrightCyan    | bgBrightCyan    |
| fgBrightWhite   | bgBrightWhite   |

### 256-color table

<https://en.wikipedia.org/wiki/ANSI_escape_code#8-bit>

A template for using a color from a 256-color table:

```dart
print('$fg256Open$n$fg256Close');
print('$bg256Open$n$bg256Close');
print('$underline256Open$n$underline256Close');
```

Where `n` is a number from 0 to 255 or a color from the following table:

|  Number | Name                                        |
|--------:|:--------------------------------------------|
|       0 | black                                       |
|       1 | red                                         |
|       2 | green                                       |
|       3 | yellow                                      |
|       4 | blue                                        |
|       5 | magenta                                     |
|       6 | cyan                                        |
|       7 | white                                       |
|       8 | highBlack                                   |
|       9 | highRed                                     |
|      10 | highGreen                                   |
|      11 | highYellow                                  |
|      12 | highBlue                                    |
|      13 | highMagenta                                 |
|      14 | highCyan                                    |
|      15 | highWhite                                   |
|  16-231 | rgb**NNN**, where N are numbers from 0 to 5 |
| 232-255 | gray**N**, where N is a number from 0 to 23 |

You don't have to use a template, but take the ready-made values from the
following table:

|   Number | Name                                                          |
|---------:|:--------------------------------------------------------------|
|        0 | (fg/bg)256Black                                               |
|        1 | (fg/bg)256Red                                                 |
|        2 | (fg/bg)256Green                                               |
|        3 | (fg/bg)256Yellow                                              |
|        4 | (fg/bg)256Blue                                                |
|        5 | (fg/bg)256Magenta                                             |
|        6 | (fg/bg)256Cyan                                                |
|        7 | (fg/bg)256White                                               |
|        8 | (fg/bg)256HighBlack                                           |
|        9 | (fg/bg)256HighRed                                             |
|       10 | (fg/bg)256HighGreen                                           |
|       11 | (fg/bg)256HighYellow                                          |
|       12 | (fg/bg)256HighBlue                                            |
|       13 | (fg/bg)256HighMagenta                                         |
|       14 | (fg/bg)256HighCyan                                            |
|       15 | (fg/bg)256HighWhite                                           |
|  16..231 | (fg/bg)256R**N**G**N**B**N**, where N are numbers from 0 to 5 |
| 232..255 | (fg/bg)256Gray**N**, where N is a number from 0 to 23         |

And you can also use ready-made functions:

- for colors:

  ```dart
  int rgb(int r, int g, int b); // r,g,b: 0..5
  int gray(int level); // level: 0..23
  ```

- for ANSI escape codes:

  ```dart
  String fg256(int color); // color: 0..255
  String bg256(int color);
  String underline256(int color);
  ```

### RGB colors

<https://en.wikipedia.org/wiki/ANSI_escape_code#24-bit>

A template for using a RGB color:

```dart
print('$fgRgbOpen$r;$g;$b$fgRgbClose');
print('$bgRgbOpen$r;$g;$b$bgRgbClose');
print('$underlineRgbOpen$r;$g;$b$underlineRgbClose');
```

Where `r`, `g` and `b` are numbers from 0 to 255.

You can also use ready-made functions:

```dart
String fgRgb(int r, int g, int b); // r,g,b: 0..255
String bgRgb(int r, int g, int b);
String underlineRgb(int r, int g, int b);
```

## Control sequences

| Description    | Usage |
|:---------------|:------|
| cursor up      | `'$cursorUpOpen$n$cursorUpClose'` or `cursorUp` for 1 line or `cursorUpN(int n)` |
| cursor down    | `'$cursorDownOpen$n$cursorDownClose'` or `cursorDown`for 1 line  or `cursorDownN(int n)` for 1 line |
| cursor forward | `'$cursorForwardOpen$n$cursorForwardClose'` or `cursorForward` for 1 column or `cursorForwardN(int n)` |
| cursor back    | `'$cursorBackOpen$n$cursorBackClose'` or `cursorBack` for 1 column or `cursorBackN(int n)` |
