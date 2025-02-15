## 2.0.0

- Shift the focus of the package to parsing.
- Add parser.
- Add printer.
- Add their corresponding functions to intercept the `print` function using
  zones: `runZonedAnsiParser`.

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
