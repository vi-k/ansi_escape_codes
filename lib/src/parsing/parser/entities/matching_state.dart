part of '../parser.dart';

final class _MatchingState<S extends State<S>> {
  final RegExpMatch match;
  S state;

  _MatchingState(this.match, this.state);

  /// The whole matched text.
  ///
  /// A field, not a getter: every parse reads it more than once — the byte
  /// dispatch in [EscapeCode._parse] and then the entity it hands the match
  /// to — and asking the match for a named group is not free.
  late final String string = match.namedGroup('all')!;

  String? operator [](String namedGroup) => match.namedGroup(namedGroup);
}
