## 3.2.0

Added:

- `insertBefore` and `insertAfter` on `Parser` and `StackedParser`, with the
  `ansiInsertBefore` and `ansiInsertAfter` string extensions. Text put into a
  styled string takes the style of the place it lands in and closes whatever
  it opens of its own, leaving the rest of the string as it was.
- The independent control functions, ESC Fs: constants for all ten of them,
  `ControlFunctionsEscFs`, and `resetTerminal` for RIS.
- `useAlternateScreen` and `useMainScreen`, the screen a full-screen program
  draws on.
- Types for the control sequences that carry something worth reading:
  `CursorUp`, `CursorDown`, `CursorRight`, `CursorLeft`, `CursorNextLine`,
  `CursorPrevLine`, `CursorHPos`, `ScrollUp` and `ScrollDown` carry `n`;
  `CursorPos` and `CursorHVPos` carry `row` and `col`; `EraseInPage` and
  `EraseInLine` carry an `ErasePart`; `ShowCursor`, `HideCursor`,
  `UseAlternateScreen` and `UseMainScreen` stand for the four private modes
  this package writes itself.
- `ansiHasUnderlineColor` and `ansiRemoveUnderlineColor`: the extensions knew
  the foreground and the background but not the underline colour.
- `Colors implements Comparable`, so a list of them can be sorted.
- `ansiShowControlFunctions` and `ansiOptimizeControlFunctions`, which used to
  live in the tests though the README and the examples took them for public.
- The control function types the API returns — `ControlFunctionsSGR`,
  `ControlSequencesFunctions` and the rest — are exported from the main entry
  point.

Fixed:

- `cursorDown` moved the cursor left, and the cursor functions built sequences
  out of any number, `-1` included.
- `runZonedStackedPrinter` printed only the first line.
- `currentCursorPos` left the terminal in raw mode, and read the answer as one
  chunk it does not always arrive in.
- `tabs` looped forever on a tab width that never advances, and wrote over the
  line it was called on.
- `Stack` threw where a reset had no style to pop, and took a colour it cannot
  hold in `underlineColor`.
- `faint` stood for `bold` instead of `dim`.
- An ESC sequence was cut after two characters, and one carrying intermediate
  bytes was shown without them: `ESC ( B` and `ESC ) B` came out alike, and a
  string ending in a bare `ESC` threw.
- `optimize` and `substring` dropped every code that was not SGR, and they,
  with `isClosed`, ignored the state the parser started from.
- An empty sub-parameter threw the whole sequence away, an RGB colour cancelled
  the rest of it, a broken colour took the rest with it, and `CSI 4:0 m`
  switched the underline on.
- An OSC string ended at the wrong place, or nowhere; a URL carrying `;` was
  refused.
- `NoStyle` passed for the colours of the terminal.
- A private-use sequence was reported as an unknown one.
- `Color256.rgb` and `Color256.gray` checked their arguments in an assert only,
  which release builds leave out.
- The superscript and subscript pair picked its winner the other way round from
  every other pair.
- `DEL` counted as a control code but was never shown as one.
- Entities and functions described themselves wrongly in `toString`.

Performance:

- What has been read of a string is kept, instead of being read again by every
  question asked of it. Call `prepare` when there are many.
- A control sequence is looked up in a map rather than by walking the list.

Renamed, the old names deprecated beside the new ones:

- `RESERVED` to `RESERVED_5F`, named after its byte rather than claiming a word
  that plain in the namespace this package exports.
- `toStringAsEscapeSquences` to `toStringAsEscapeSequences`.
- The `standart_colors` directory is spelt `standard_colors`.

Breaking changes:

- `Csi`, `Esc` and `EscapeCode` are sealed, and this release adds types under
  them. A `switch` that covers them exhaustively has to name the new ones. `is`
  checks, casts and the identifiers entities are shown by are unchanged.

## 3.1.2

- Add operators <, <=, >, >= for `Colors` enum.

## 3.1.0-3.1.1

- Add `NoStyle`.
- Rename `defaults` to `terminalColors`.

## 3.0.7-3.0.8

- Add string extensions: `ansiHasControlCodes` and `lengthWithoutEscapeCodes`.

## 3.0.6

- Add `open` and `close` to `Style`.

## 3.0.4-3.0.5

- Add `padLeft` and `padRight` to `Parser` and `StackedParser`.

## 3.0.3

- Fix multiline output by `Style`.

## 3.0.0-3.0.2

- [breaking changes] Total renaming:
  - `AnsiPrinter` to `Printer`, `StackedPrinter`, `SinkPrinter` and
    `StackedSinkPrinter`
  - `AnsiParser` to `Parser` and `StackedParser`
  - `SgrState` to `State`
  - `SgrStackState` to `Stack`
  - and etc.
- Add styles.

## 2.2.1

- Fix SDK constraint.
- Add `Color256.rgb` and `Color256.gray`.

## 2.2.0

- Fix README.
- Add predefined colors: `Color256.rgb123`, etc.
- Add `Color256.rgb` and `Color256.gray`.
- Update `example/colors256.dart`.

## 2.1.0

- Add methods `indexOf`, `lastIndexOf`, `contains`, `startsWith`, `endsWith`
  that work with a plain string.

## 2.0.1-2.0.3

- Fix multiline output by AnsiPrinter.
- Minor changes.

## 2.0.0

- Shift package focus to parsing and standardization.
- Add `AnsiParser`.
- Add `AnsiPrinter`.
- Add stacked `AnsiPrinter`.
- Add their corresponding functions to intercept the `print` function using
  zones: `runZonedAnsiParser`.

Breaking changes:
- The names of some constants have changed: `italic` to `italicized`,
  `blinking` to `slowlyBlinking`. All constants of the form `not…` are
  renamed to `reset…`. `(fg/bg/underline)Bright…` ara renamed to
  `(fg/bg/underline)High…`.
- Removed methods: `handle…`, `all…`. Use `AnsiParser` instead.


## 1.4.1

- Add handleEscapeSequences and handlePlainText.

## 1.4.0

- Add analysis escape sequences (showEscapeSequences).
- Add all control codes (0x00-0x1F).

## 1.3.2

- Refactor methods: allSgr, foregroundColors, backgroundColors.
- Add methods: allCsi, removeCsi, removeSgr, removeForegroundColors,
  removeBackgroundColors. Mark the methods as experimental.

## 1.3.0-1.3.1

- Add several functions to the utilities.
- Update example.
- Refactor constant name.

## 1.2.0

- Add dart doc comments.
- Update README.
- Refactor.

## 1.1.0

- Add saveCursor and restoreCursor.
- Add progress_example.dart.
- Refactor.

## 1.0.0

- Initial version.
