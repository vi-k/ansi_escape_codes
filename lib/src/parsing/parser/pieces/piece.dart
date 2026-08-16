part of '../parser.dart';

/// One piece of a parsed string, and where and in what state it was found.
///
/// This is what [Pieces] hands out, and what a `for` over `parser.pieces`
/// walks through.
final class Piece<S extends State<S>> {
  /// The piece itself: [Text] or one of the [EscapeCode] kinds.
  final Entity entity;

  /// The state in force at this piece.
  ///
  /// For [Text] it is the style the text is shown in; for an escape code, the
  /// state that code leaves behind it.
  final S state;

  /// The link in force at this piece, or `null` where none is open.
  ///
  /// For [Text] it is the link the text sits inside; for an escape code, the
  /// link that code leaves behind it — the same way [state] is read. A link
  /// does not nest: an opening supersedes the one before it, and a close ends
  /// whatever was open.
  final OscLink? link;

  final _SgrResidual? _residual;

  /// Where the piece starts in the original string, escape codes counted.
  final int start;

  /// Where it ends: the position just past its last character.
  final int end;

  Piece._({
    required this.state,
    required this.link,
    required _SgrResidual? residual,
    required this.entity,
    required this.start,
    required this.end,
  }) : _residual = residual;

  @override
  String toString() => '${Piece<S>}('
      'start: $start'
      ', end: $end'
      ', entity: $entity'
      ', state: $state'
      ', link: $link'
      ')';
}
