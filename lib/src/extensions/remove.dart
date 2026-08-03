import '../internal/sgr_functions.dart';
import '../parsing/patterns/patterns.dart';

/// Taking escape codes back out of a string, all of them or by kind.
extension StringRemoveEscapeCodesExtension on String {
  /// Removes any escape codes in the text.
  ///
  /// The same as `Parser(text).removeAll()` — they read by the same pattern —
  /// and quicker, since nothing is built for what is taken out. A broken
  /// sequence goes with the rest: an `ESC` with nothing after it, a control
  /// sequence with no final byte, an OSC string that was never terminated,
  /// which runs to the next sequence or to the end as a terminal waiting for
  /// its terminator would.
  ///
  /// What stays is everything that is not an escape code, control codes
  /// included: the tabs, the line feeds and the `DEL`. The eight-bit forms of
  /// the C1 controls stay as well — `0x9B` is no `CSI` in a Dart string, where
  /// it is a character of its own.
  String ansiRemoveEscapeCodes() => replaceAll(escapeCodesRe, '');

  /// Removes the control codes in the text: the C0 set and `DEL`.
  ///
  /// This is what `ansiHasControlCodes` asks about, taken out — the tabs, the
  /// line feeds, the carriage returns and the rest of the bytes below `0x20`,
  /// which is more than an escape code and less than a character. A text meant
  /// to stay in lines should be split into them first.
  ///
  /// `ESC` is a control code itself, so on a string that carries escape codes
  /// this leaves their bodies behind as text: `${fgRed}x` becomes `[31mx`.
  /// Take those out first:
  ///
  /// ```dart
  /// print(text.ansiRemoveEscapeCodes().ansiRemoveControlCodes());
  /// ```
  ///
  /// The eight-bit forms of the C1 controls are not touched: `0x9B` is above
  /// `DEL`, and in a Dart string it is a character of its own.
  String ansiRemoveControlCodes() => replaceAll(controlCodesRe, '');

  /// Removes control sequences (CSI) in the text.
  String ansiRemoveCsi() => replaceAll(csiRe, '');

  /// Removes SGR (Select Graphic Rendition) codes in the text.
  String ansiRemoveSgr() => replaceAll(sgrRe, '');

  /// Removes foreground colors in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 1;31 SGR` becomes
  /// `CSI 1 SGR`.
  String ansiRemoveForeground() =>
      removeSgrFunction(this, isForegroundFunction);

  /// Removes background colors in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 1;41 SGR` becomes
  /// `CSI 1 SGR`.
  String ansiRemoveBackground() =>
      removeSgrFunction(this, isBackgroundFunction);

  /// Removes the colors of the underline in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 4;58;5;1 SGR` becomes
  /// `CSI 4 SGR`, leaving the underline itself.
  String ansiRemoveUnderlineColor() =>
      removeSgrFunction(this, isUnderlineColorFunction);

  /// Returns the length of the string without escape codes.
  int get lengthWithoutEscapeCodes => ansiRemoveEscapeCodes().length;
}
