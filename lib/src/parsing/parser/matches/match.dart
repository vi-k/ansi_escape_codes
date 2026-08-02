part of '../parser.dart';

/// One piece of a parsed string, and where and in what state it was found.
///
/// This is what [Matches] hands out, and what a `for` over `parser.matches`
/// walks through.
final class Match<S extends State<S>> {
  /// The piece itself: [Text] or one of the [EscapeCode] kinds.
  final Entity entity;

  /// The state in force at this piece.
  ///
  /// For [Text] it is the style the text is shown in; for an escape code, the
  /// state that code leaves behind it.
  final S state;

  /// Where the piece starts in the original string, escape codes counted.
  final int start;

  /// Where it ends: the position just past its last character.
  final int end;

  Match._({
    required this.state,
    required this.entity,
    required this.start,
    required this.end,
  });

  @override
  String toString() => '${Match<S>}('
      'start: $start'
      ', end: $end'
      ', entity: $entity'
      ', state: $state'
      ')';
}
