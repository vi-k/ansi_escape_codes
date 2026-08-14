part of '../parser.dart';

final class _PiecesResult<S extends State<S>> {
  final List<Piece<S>> pieces;
  final S finalState;
  final _SgrResidual? finalResidual;
  final _CursorSave<S>? finalCursorSave;

  /// The link the string leaves open, or `null` where it leaves none.
  ///
  /// Read off the walk at the end of it, the way [finalState] is: a link
  /// closed on the last line is closed, and a string that touched no link at
  /// all ends in the one it was seeded with.
  final Link? finalLink;

  _PiecesResult._({
    required List<Piece<S>> pieces,
    required this.finalState,
    required this.finalResidual,
    required this.finalLink,
    required this.finalCursorSave,
  }) : pieces = UnmodifiableListView(pieces); // The list is complete once this
  // result exists: every iterator reaching the end sets `_parsingResult`, and
  // any later iterator can only append when its index equals the parsed length.
  // A view rather than a copy costs nothing here, unlike in `Sgr`: this is one
  // list per parse, and the parser holds the list behind it either way.

  @override
  String toString() => '_PiecesResult('
      'pieces: $pieces'
      ', finalState: $finalState'
      ', finalLink: $finalLink'
      ', finalCursorSave: $finalCursorSave'
      ')';
}
