part of '../ansi_parser.dart';

final class Match<S extends SgrState<S>> {
  final Entity entity;

  final S state;

  final int start;

  final int end;

  Match._({
    required this.state,
    required this.entity,
    required this.start,
    required this.end,
  });

  @override
  String toString() => 'Match('
      'start: $start'
      ', end: $end'
      ', entity: $entity'
      ', state: $state'
      ')';
}
