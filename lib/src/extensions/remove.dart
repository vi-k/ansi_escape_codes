import '../ansi/c0.dart';
import '../internal/sgr_functions.dart';
import '../parsing/control_functions/control_functions_c0.dart';
import '../parsing/patterns/patterns.dart';

/// Taking escape codes back out of a string, all of them or by kind.
extension StringRemoveEscapeCodesExtension on String {
  /// Removes any escape codes in the text.
  ///
  /// The same as `Parser(text).removeAll()` — they read by the same pattern —
  /// and quicker, since nothing is built for what is taken out. A broken
  /// sequence goes with the rest: an `ESC` with nothing after it, or an OSC
  /// string that was never terminated, which runs to the next sequence or to
  /// the end as a terminal waiting for its terminator would.
  ///
  /// A control sequence with no final byte is not a sequence at all: `ESC [`
  /// goes and what followed it stays, so `'a\x1B[31'` leaves `'a31'`. That is
  /// what a terminal is left holding too, and `Parser` reads it the same way.
  ///
  /// What stays is everything that is not an escape code, control codes
  /// included: the tabs, the line feeds and the `DEL`. The eight-bit forms of
  /// the C1 controls stay as well — `0x9B` is no `CSI` in a Dart string, where
  /// it is a character of its own.
  String ansiRemoveEscapeCodes() =>
      contains(ESC) ? replaceAll(escapeCodesRe, '') : this;

  /// Removes the control codes in the text: the C0 set and `DEL`.
  ///
  /// This is what `ansiHasControlCodes` asks about, taken out — the tabs, the
  /// line feeds, the carriage returns and the rest of the bytes below `0x20`,
  /// which is more than an escape code and less than a character.
  ///
  /// [exclude] names the ones to keep, for a text that is to stay in lines or
  /// in columns:
  ///
  /// ```dart
  /// print(text.ansiRemoveControlCodes(exclude: {ControlFunctionsC0.LF}));
  /// ```
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
  String ansiRemoveControlCodes({
    Set<ControlFunctionsC0> exclude = const {},
  }) {
    if (exclude.isEmpty) {
      return replaceAll(controlCodesRe, '');
    }

    final kept = {for (final code in exclude) code.code};

    return replaceAllMapped(
      controlCodesRe,
      (m) => kept.contains(m[0]) ? m[0]! : '',
    );
  }

  /// Removes control sequences (CSI) in the text.
  String ansiRemoveCsi() => contains(ESC) ? replaceAll(csiRe, '') : this;

  /// Removes SGR (Select Graphic Rendition) codes in the text.
  ///
  /// A sequence is read here by its pattern and not by what its parameters
  /// mean, and where the pattern and `Parser` part ways the pattern decides.
  /// A parameter too large to be an integer — anything past
  /// `9223372036854775807` — is one such place: `Parser` cannot read the
  /// sequence at all, hands it back as an unknown control sequence carrying
  /// no style, and passes it on as it was written wherever it passes codes
  /// on. This takes it out regardless, and the colour removals below rewrite
  /// it: the `31` of `CSI 31;9223372036854775808 SGR` goes to
  /// [ansiRemoveForeground] as any other red would. An accepted limit, and
  /// the one the `ansiHas` family answers by as well.
  String ansiRemoveSgr() => contains(ESC) ? replaceAll(sgrRe, '') : this;

  /// Removes foreground colors in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 1;31 SGR` becomes
  /// `CSI 1 SGR`.
  ///
  /// Read by the pattern, not by what `Parser` makes of the sequence: see
  /// [ansiRemoveSgr] for the parameter too large to be an integer.
  String ansiRemoveForeground() =>
      contains(ESC) ? removeSgrFunction(this, isForegroundFunction) : this;

  /// Removes background colors in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 1;41 SGR` becomes
  /// `CSI 1 SGR`.
  ///
  /// Read by the pattern here too — see [ansiRemoveSgr] for the parameter no
  /// integer can hold.
  String ansiRemoveBackground() =>
      contains(ESC) ? removeSgrFunction(this, isBackgroundFunction) : this;

  /// Removes the colors of the underline in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 4;58;5;1 SGR` becomes
  /// `CSI 4 SGR`, leaving the underline itself.
  ///
  /// Read by the pattern as the others are: see [ansiRemoveSgr].
  String ansiRemoveUnderlineColor() =>
      contains(ESC) ? removeSgrFunction(this, isUnderlineColorFunction) : this;

  /// Returns the length of the string without escape codes.
  int get lengthWithoutEscapeCodes => ansiRemoveEscapeCodes().length;
}
