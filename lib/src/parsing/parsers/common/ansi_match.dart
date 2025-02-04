part of '../parsers.dart';

final class AnsiMatch<S extends AnsiState<S>> {
  final AnsiEntity entity;

  final S state;

  final int start;

  final int end;

  AnsiMatch._({
    required this.state,
    required this.entity,
    required this.start,
    required this.end,
  });

  @override
  String toString() => '$AnsiMatch('
      'state: $state'
      ', entity: $entity'
      ', start: $start'
      ', end: $end'
      ')';
}
