part of '../parser.dart';

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

final class EscCommon extends Esc {
  final ControlFunctionsEscFs function;

  const EscCommon._(super.string, this.function) : super._();

  @override
  String get id => '${ControlFunctionsC0.ESC.name} ${function.name}';

  @override
  String toString() => '$Esc(${function.name})';
}

final class EscUnknown extends Esc with UnrecognizedEscapeCode {
  const EscUnknown._(super.string) : super._();

  @override
  String toString() => '$Esc("${toStringAsEscapeSequences()}")';
}

final class SaveCursor extends Esc {
  const SaveCursor() : super._('${ESC}7');

  const SaveCursor._(super.string) : super._();

  @override
  String get id => 'saveCursor';

  @override
  String toString() => '$SaveCursor()';
}

final class RestoreCursor extends Esc {
  const RestoreCursor() : super._('${ESC}8');

  const RestoreCursor._(super.string) : super._();

  @override
  String get id => 'restoreCursor';

  @override
  String toString() => '$RestoreCursor()';
}
