# Examples

Eight programs, each meant to be run at a terminal — the point of most of them
is what the terminal does with what they write, which a captured log cannot
show.

```bash
dart run example/ansi_escape_codes_example.dart
```

The smallest thing this package does:

```dart
import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  // Writing: by a style, or by constants that cost nothing at run time.
  print('${Styles.red.bold('ERROR')} the roof is on fire');
  print('${fgCyan}the same in cyan$reset');

  // Reading: what a string says, and how long it is without the codes.
  const line = '${fgRed}ERROR$reset: the roof is on fire';
  final parser = Parser(line);

  print(parser.removeAll()); // ERROR: the roof is on fire
  print(parser.length); // 26
  print(parser.stateAt(3).foregroundColor?.id); // fgRed
}
```

## What each one shows

| Program | What it shows |
|:---|:---|
| [`ansi_escape_codes_example.dart`](ansi_escape_codes_example.dart) | the tour: colouring, styles, the parser, slices, insertions, hyperlinks, tab stops |
| [`styles.dart`](styles.dart) | building a style and nesting one inside another, so the inner one hands the outer one back |
| [`colors256.dart`](colors256.dart) | the 256-colour table, every entry beside the name that writes it |
| [`rgb.dart`](rgb.dart) | truecolour, and how a terminal that has none of it falls back |
| [`links.dart`](links.dart) | `OSC 8` hyperlinks, and the bytes they are made of |
| [`control.dart`](control.dart) | moving and erasing: the seven ways to move the cursor, erase in page and in line, scrolling, and asking the terminal where the cursor is |
| [`progress_indicator.dart`](progress_indicator.dart) | four ways to redraw a line in place, from a carriage return to a saved cursor |
| [`check_compatibility.dart`](check_compatibility.dart) | what *your* terminal actually does with each rendition — bold, dim, the underline variants, the colour forms |

`utils.dart` beside them is not a program: it is the titles the others print,
and it has no `main` to run.

## The two that need a terminal in person

`control.dart` asks the terminal where the cursor is, and
`ansi_escape_codes_example.dart` sets tab stops. Both go through
`package:ansi_escape_codes/utils.dart`, the one entry point that reaches
`dart:io`. Run from a pipe or a redirect, they find no terminal and say so
rather than writing a request nothing will answer.
