part of '../parser.dart';

final class _MatchesResult<S extends State<S>> {
  final List<Match<S>> matches;
  final S finalState;

  _MatchesResult._({
    required List<Match<S>> matches,
    required this.finalState,
  }) : matches =
            UnmodifiableListView(matches); // The list is complete once this
  // result exists: every iterator reaching the end sets `_parsingResult`, and
  // any later iterator can only append when its index equals the parsed length.

  @override
  String toString() =>
      '_MatchesResult(matches: $matches, finalState: $finalState)';
}
