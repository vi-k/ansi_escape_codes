part of '../ansi_parser.dart';

final class MatchesResult<S extends SgrState<S>> {
  final List<Match<S>> matches;
  final S finalState;

  MatchesResult._({
    required List<Match<S>> matches,
    required this.finalState,
  }) : matches = List.unmodifiable(matches);

  @override
  String toString() =>
      'MatchesResult(matches: $matches, finalState: $finalState)';
}
