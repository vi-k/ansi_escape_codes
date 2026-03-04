part of '../parser.dart';

final class Match<S extends State<S>> {
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
  String toString() => '${Match<S>}('
      'start: $start'
      ', end: $end'
      ', entity: $entity'
      ', state: $state'
      ')';
}
