part of '../ansi_parser.dart';

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
    final escapedText = string
        .showControlCodes()
        .replaceAll(r'\', r'\\')
        .replaceAll("'", r"\'");

    return "$Text('$escapedText')";
  }
}

sealed class EscapeCode extends Entity {
  const EscapeCode._(super.string) : super._();

  String get id;

  static EscapeCode _parse<S extends SgrState<S>>(MatchingState<S> state) {
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
      string.showControlCodes(preferStyle: ControlCodeStyle.abbr);

  String toStringAsEscapeSquences() => string.showEscapeCodes();
}

mixin UnrecognizedEscapeCode on EscapeCode {
  @override
  String get id => string.showEscapeCodes(open: '', close: '');
}

final class UnknownEscapeCode extends EscapeCode with UnrecognizedEscapeCode {
  const UnknownEscapeCode._(super.string) : super._();

  @override
  String toString() => '$EscapeCode(${toStringAsControlCodes()})';
}
