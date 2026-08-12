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
  /// sequence goes with the rest: an `ESC` with nothing after it, or a control
  /// string that never got its terminator — an `OSC`, a `DCS`, an `SOS`, a `PM`
  /// or an `APC` — running to the next sequence or to the end as a terminal
  /// waiting for its terminator would, and taking the text it ran over with it.
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

  /// Removes the control codes in the text: the C0 set, `DEL` and the
  /// eight-bit C1.
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
  /// The eight-bit forms of the C1 controls go with the rest. They open no
  /// escape sequence in this package and are read as text, but Unicode files
  /// them under its control category and a terminal handed one prints
  /// rubbish, so a text cleaned for display is not clean while they are in
  /// it. [exclude] cannot spare them: it names members of
  /// [ControlFunctionsC0], and the set ends at `0x1F`.
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
  /// A parameter too large for the parser to read as a number is one such
  /// place: `Parser` cannot read the sequence at all, hands it back as an
  /// unknown control sequence carrying no style, and passes it on as it was
  /// written wherever it passes codes on. This takes it out regardless, and
  /// the colour removals rewrite it: the `31` of
  /// `CSI 31;9223372036854775808 SGR` goes to [ansiRemoveForeground] as any
  /// other red would. How large is too large is the platform's to say — on
  /// the VM, where an `int` is 64 bits, that number is already past it; on
  /// the web, where an `int` is a double, it parses and the sequence is read
  /// like any other. An accepted limit either way, and the one the `ansiHas`
  /// family answers by as well.
  String ansiRemoveSgr() => contains(ESC) ? replaceAll(sgrRe, '') : this;

  /// Removes foreground colors in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 1;31 SGR` becomes
  /// `CSI 1 SGR`.
  ///
  /// Read by the pattern, not by what `Parser` makes of the sequence: see
  /// [ansiRemoveSgr] for the parameter too large for the parser to read.
  String ansiRemoveForeground() =>
      contains(ESC) ? removeSgrFunction(this, isForegroundFunction) : this;

  /// Removes background colors in the text.
  ///
  /// The other functions of a sequence are kept: `CSI 1;41 SGR` becomes
  /// `CSI 1 SGR`.
  ///
  /// Read by the pattern here too — see [ansiRemoveSgr] for the number that
  /// outgrows the parser's `int`.
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
  ///
  /// The cleaned string is never built: the codes are found by the pattern
  /// [ansiRemoveEscapeCodes] takes them out by, and what they take up is
  /// counted off the length — the answer [ansiRemoveEscapeCodes] would have
  /// given, arrived at without a second copy of the string being made. The
  /// walk over the matches is the same one either way, so what a page of
  /// megabytes saves here is the copy and not the time.
  int get lengthWithoutEscapeCodes {
    if (!contains(ESC)) {
      return length;
    }

    var removed = 0;
    for (final m in escapeCodesRe.allMatches(this)) {
      removed += m.end - m.start;
    }

    return length - removed;
  }
}
