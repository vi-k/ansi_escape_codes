part of '../parser.dart';

/// A piece of a parsed string: either [Text] or an [EscapeCode].
///
/// A string is nothing but these, one after another, and writing them all out
/// in order gives the string back exactly as it came in.
@immutable
sealed class Entity {
  /// The piece of the string this stands for, as it was written.
  String get string;

  const Entity._();

  @override
  int get hashCode => string.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is Entity && string == other.string;
}

/// A run of text, carrying no escape codes.
///
/// This is everything the escape codes are not, and what the positions
/// [Parser] is asked about are counted in. Control codes are part of it: a
/// tab, a line feed and a `BEL` are text to this parser, so a string of them
/// is one [Text] and every byte counts towards the length, however many
/// columns the terminal then puts them in.
final class Text extends Entity {
  final String _input;
  final int _start;
  final int _end;

  /// The piece of the string this stands for, cut out on first use: a piece
  /// nobody reads keeps no copy of itself.
  @override
  late final String string = _input.substring(_start, _end);

  Text._(this._input, this._start, this._end) : super._();

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
  @override
  final String string;

  const EscapeCode._(this.string) : super._();

  /// What this code is called, as [Parser.showControlFunctions] writes it.
  ///
  /// The name of the constant it is written with where there is one —
  /// `fgRed`, `saveCursor`, `hideCursor` — and the sequence read out
  /// otherwise: `CSI 4 CUU`, `ESC (B`.
  String get id;

  static EscapeCode _parse<S extends State<S>>(_MatchingState<S> state) {
    final string = state.string;

    // Every match begins with ESC; the byte after it says which of the
    // three kinds this is, without asking the regex for its groups — save
    // for one case the byte alone cannot settle: `ESC[` with nothing after
    // it that could complete a CSI (cut short, or followed by a byte a CSI
    // could never end on) is not a [csiPattern] match but an [escPattern]
    // one, the `[` swept up as its optional final byte. The `csi` group
    // tells the two apart; asking it costs nothing where the byte already
    // rules CSI out.
    if (string.length > 1) {
      switch (string.codeUnitAt(1)) {
        case 0x5B when state['csi'] != null: // [
          return Csi._parse(state);
        case 0x5D: // ]
          return Osc._parse(state);
      }
    }

    return Esc._parse(state);
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
  String toString() => '$UnknownEscapeCode(${toStringAsControlCodes()})';
}
