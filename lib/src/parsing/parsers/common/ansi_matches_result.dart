part of '../parsers.dart';

final class AnsiMatchesResult<S extends AnsiState<S>> {
  final List<AnsiMatch<S>> matches;
  final S endState;

  AnsiMatchesResult._({
    required List<AnsiMatch<S>> matches,
    required this.endState,
  }) : matches = List.unmodifiable(matches);

  @override
  String toString() =>
      '$AnsiMatchesResult(matches: $matches, endState: $endState)';
}
