part of '../ansi_parser.dart';

sealed class Esc extends EscapeCode {
  const Esc._(super.string) : super._();

  static Esc _parse<S extends SgrState<S>>(MatchingState<S> state) {
    final code = state['esc_final']!;

    return switch (code) {
      '7' => SaveCursor._(state.string),
      '8' => RestoreCursor._(state.string),
      _ => EscUnknown._(state.string),
    };
  }

  @override
  String toString() => '$Osc("${toStringAsEscapeSquences()}")';
}

final class EscUnknown extends Esc with UnrecognizedEscapeCode {
  const EscUnknown._(super.string) : super._();

  @override
  String toString() => '$Esc("${toStringAsEscapeSquences()}")';
}

final class SaveCursor extends Esc {
  const SaveCursor() : super._(reset);

  const SaveCursor._(super.string) : super._();

  @override
  String get id => 'saveCursor';

  @override
  String toString() => '$SaveCursor()';
}

final class RestoreCursor extends Esc {
  const RestoreCursor() : super._(reset);

  const RestoreCursor._(super.string) : super._();

  @override
  String get id => 'restoreCursor';

  @override
  String toString() => '$RestoreCursor()';
}
