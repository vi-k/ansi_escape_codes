part of '../parser.dart';

/// A control string: an opener, a body, and the `ST` that ends it.
///
/// The standard has five — `OSC`, `DCS`, `SOS`, `PM` and `APC` — and what
/// they share is the one thing this parser needs of them: everything written
/// after the opener belongs to the string until its terminator arrives, so a
/// string that never got one swallows whatever is written behind it. That is
/// what [terminated] asks, and the slice, the optimizer, the printers and the
/// insertions all ask it.
sealed class ControlString extends EscapeCode {
  const ControlString._(super.string) : super._();

  /// Whether the string got the terminator that ends it.
  ///
  /// `ST` ends all five. [Osc] takes a `BEL` as well and overrides this to
  /// say so; that terminator is xterm's, not the standard's, and it ends
  /// nothing else.
  bool get terminated => string.endsWith(ST);

  /// The string this opener opens, for the four that are not an [Osc].
  ///
  /// The `]` never arrives here: [EscapeCode._parse] sends it to [Osc._parse]
  /// instead, which has a hyperlink to look for.
  static ControlString _parse<S extends State<S>>(_MatchingState<S> state) {
    final string = state.string;

    return switch (string.codeUnitAt(1)) {
      0x50 => Dcs._(string), // P
      0x58 => Sos._(string), // X
      0x5E => Pm._(string), // ^
      _ => Apc._(string), // _
    };
  }
}

/// A device control string, `DCS ... ST`: what a terminal reads as
/// instructions for a device rather than for the screen — a sixel image, a
/// `DECRQSS` query, a termcap answer.
///
/// The package carries the bytes and does not read them.
final class Dcs extends ControlString with UnrecognizedEscapeCode {
  const Dcs._(super.string) : super._();

  @override
  String toString() => '$Dcs("${toStringAsEscapeSequences()}")';
}

/// A string opened by `SOS`, which the standard leaves for the application to
/// interpret.
///
/// The standard lets its body hold any bytes but `SOS` and `ST`, so by the
/// letter an `ESC` inside it ends nothing. This package ends it at the next
/// `ESC` all the same, the way the terminals' own state machines do and the
/// way it already reads an `OSC`: a string somebody forgot to close then eats
/// what it can reach rather than the whole of the rest of the input. The
/// divergence is deliberate — see
/// `docs/records/2026-08-11[4]-c1-control-strings-design.md`.
final class Sos extends ControlString with UnrecognizedEscapeCode {
  const Sos._(super.string) : super._();

  @override
  String toString() => '$Sos("${toStringAsEscapeSequences()}")';
}

/// A privacy message, `PM ... ST`.
///
/// The package carries the bytes and does not read them.
final class Pm extends ControlString with UnrecognizedEscapeCode {
  const Pm._(super.string) : super._();

  @override
  String toString() => '$Pm("${toStringAsEscapeSequences()}")';
}

/// An application program command, `APC ... ST`.
///
/// The package carries the bytes and does not read them.
final class Apc extends ControlString with UnrecognizedEscapeCode {
  const Apc._(super.string) : super._();

  @override
  String toString() => '$Apc("${toStringAsEscapeSequences()}")';
}
