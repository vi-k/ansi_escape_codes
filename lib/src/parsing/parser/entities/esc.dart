part of '../parser.dart';

/// An escape sequence that is `ESC` and what follows it, without the `[` a
/// [Csi] would have.
///
/// The independent control functions come back [EscCommon], the cursor pair
/// comes back [SaveCursor] and [RestoreCursor], and the rest [EscUnknown].
sealed class Esc extends EscapeCode {
  const Esc._(super.string) : super._();

  static Esc _parse<S extends State<S>>(_MatchingState<S> state) {
    final intermediate = state['esc_inter'] ?? '';
    final code = state['esc_final'];

    // The independent control functions are the whole sequence, so a
    // sequence carrying intermediate bytes is none of them.
    final function = ControlFunctionsEscFs.byCode(state.string);
    if (function != null) {
      return EscCommon._(state.string, function);
    }

    return switch (code) {
      '7' when intermediate.isEmpty => SaveCursor._(state.string),
      '8' when intermediate.isEmpty => RestoreCursor._(state.string),
      _ => EscUnknown._(state.string),
    };
  }

  @override
  String toString() => '$Esc("${toStringAsEscapeSequences()}")';
}

/// One of the independent control functions, ESC Fs: `RIS`, `LS2`, `DMI` and
/// the seven others the standard allots.
final class EscCommon extends Esc {
  /// The function this sequence stands for.
  final ControlFunctionsEscFs function;

  const EscCommon._(super.string, this.function) : super._();

  @override
  String get id => '${ControlFunctionsC0.ESC.name} ${function.name}';

  @override
  String toString() => '$Esc(${function.name})';
}

/// An escape sequence this package has no name for: a byte the standard
/// keeps in reserve, or a sequence carrying intermediate bytes, such as the
/// `ESC ( B` that designates a character set.
final class EscUnknown extends Esc with UnrecognizedEscapeCode {
  const EscUnknown._(super.string) : super._();

  @override
  String toString() => '$Esc("${toStringAsEscapeSequences()}")';
}

/// `ESC 7`, which puts the cursor position and the style away for
/// [RestoreCursor] to bring back.
final class SaveCursor extends Esc {
  /// The sequence itself, the same one [saveCursor] is written with.
  const SaveCursor() : super._('${ESC}7');

  const SaveCursor._(super.string) : super._();

  @override
  String get id => 'saveCursor';

  @override
  String toString() => '$SaveCursor()';
}

/// `ESC 8`, which brings back what [SaveCursor] put away, or the defaults
/// where nothing was saved.
final class RestoreCursor extends Esc {
  /// The sequence itself, the same one [restoreCursor] is written with.
  const RestoreCursor() : super._('${ESC}8');

  const RestoreCursor._(super.string) : super._();

  @override
  String get id => 'restoreCursor';

  @override
  String toString() => '$RestoreCursor()';
}
