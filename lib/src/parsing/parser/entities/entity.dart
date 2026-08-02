part of '../parser.dart';

/// A piece of a parsed string: either [Text] or an [EscapeCode].
///
/// A string is nothing but these, one after another, and writing them all out
/// in order gives the string back exactly as it came in.
@immutable
sealed class Entity {
  /// The piece of the string this stands for, as it was written.
  final String string;

  const Entity._(this.string);

  @override
  int get hashCode => string.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entity && string == other.string;
}

/// A run of plain text, carrying no escape codes.
///
/// This is what the terminal shows, and what the positions [Parser] is asked
/// about are counted in.
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

/// An escape code: a [Csi] control sequence, an [Osc] string, an [Esc]
/// sequence, or something none of those could be made of.
sealed class EscapeCode extends Entity {
  const EscapeCode._(super.string) : super._();

  /// What this code is called, as [Parser.showControlFunctions] writes it.
  ///
  /// The name of the constant it is written with where there is one —
  /// `fgRed`, `saveCursor`, `hideCursor` — and the sequence read out
  /// otherwise: `CSI 4 CUU`, `ESC (B`.
  String get id;

  static EscapeCode _parse<S extends State<S>>(_MatchingState<S> state) {
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

  /// The sequence with its control codes spelt out by their abbreviations:
  /// `[ESC][` where the bytes are.
  String toStringAsControlCodes() =>
      string.ansiShowControlCodes(preferStyle: ControlCodeStyle.abbr);

  /// The sequence read out as the standard reads it: `[CSI 4 CUU]`.
  String toStringAsEscapeSequences() => string.ansiShowEscapeSequences();
}

/// What a code has in common with the others this package cannot name.
///
/// [EscapeCode.id] falls back to the bytes themselves, so nothing is lost by
/// not being understood. Carried by [UnknownEscapeCode], [CsiUnknown],
/// [CsiPrivate], [EscUnknown] and [OscUnknown]; one check catches them all.
mixin UnrecognizedEscapeCode on EscapeCode {
  @override
  String get id => string.ansiShowEscapeSequences(open: '', close: '');
}

/// What an escape code falls back to when it is none of [Csi], [Osc] or
/// [Esc].
///
/// The patterns as they stand leave nothing for it: whatever they match is one
/// of the three, so nothing in a string being read comes back as this today.
/// It is here so that a pattern grown wider than its reader has somewhere to
/// put what it caught, rather than throwing.
final class UnknownEscapeCode extends EscapeCode with UnrecognizedEscapeCode {
  const UnknownEscapeCode._(super.string) : super._();

  @override
  String toString() => '$EscapeCode(${toStringAsControlCodes()})';
}
