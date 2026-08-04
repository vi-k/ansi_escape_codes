part of '../parser.dart';

final class _MatchesResult<S extends State<S>> {
  final List<Match<S>> matches;
  final S finalState;

  _MatchesResult._({
    required List<Match<S>> matches,
    required this.finalState,
  }) : matches = UnmodifiableListView(matches);

  @override
  String toString() =>
      '_MatchesResult(matches: $matches, finalState: $finalState)';
}
