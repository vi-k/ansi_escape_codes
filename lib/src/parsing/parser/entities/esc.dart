part of '../parser.dart';

sealed class Esc extends EscapeCode {
  const Esc._(super.string) : super._();

  static Esc _parse<S extends State<S>>(MatchingState<S> state) {
    final intermediate = state['esc_inter'] ?? '';
    final code = state['esc_final'];

    return switch (code) {
      '7' when intermediate.isEmpty => SaveCursor._(state.string),
      '8' when intermediate.isEmpty => RestoreCursor._(state.string),
      _ => EscUnknown._(state.string),
    };
  }

  @override
  String toString() => '$Esc("${toStringAsEscapeSequences()}")';
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
