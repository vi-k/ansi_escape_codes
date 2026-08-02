part of '../parser.dart';

@immutable
sealed class Entity {
  final String string;

  const Entity._(this.string);

  @override
  int get hashCode => string.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entity && string == other.string;
}

final class Text extends Entity {
  const Text._(super.string) : super._();

  @override
  String toString() {
    // The escaping goes first: showing the control codes writes backslashes
    // of its own, and those must not be escaped again.
    final escapedText = string
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'")
        .ansiShowControlCodes();

    return "$Text('$escapedText')";
  }
}

sealed class EscapeCode extends Entity {
  const EscapeCode._(super.string) : super._();

  String get id;

  static EscapeCode _parse<S extends State<S>>(MatchingState<S> state) {
    final csi = state['csi'];
    if (csi != null) {
      return Csi._parse(state);
    }

    final osc = state['osc'];
    if (osc != null) {
      return Osc._parse(state);
    }

    final esc = state['esc'];
    if (esc != null) {
      return Esc._parse(state);
    }

    return UnknownEscapeCode._(state.string);
  }

  String toStringAsControlCodes() =>
      string.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr);

  String toStringAsEscapeSequences() => string.ansiShowEscapeSequences();

  @Deprecated('Use toStringAsEscapeSequences instead')
  String toStringAsEscapeSquences() => toStringAsEscapeSequences();
}

mixin UnrecognizedEscapeCode on EscapeCode {
  @override
  String get id => string.ansiShowEscapeSequences(open: '', close: '');
}

final class UnknownEscapeCode extends EscapeCode with UnrecognizedEscapeCode {
  const UnknownEscapeCode._(super.string) : super._();

  @override
  String toString() => '$EscapeCode(${toStringAsControlCodes()})';
}
