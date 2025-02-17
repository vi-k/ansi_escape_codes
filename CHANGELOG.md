## 2.0.1

- Minor updates.

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
  renamed to `reset…`.
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
