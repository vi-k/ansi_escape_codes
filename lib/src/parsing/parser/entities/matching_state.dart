part of '../parser.dart';

final class _MatchingState<S extends State<S>> {
  final RegExpMatch match;
  S state;

  _MatchingState(this.match, this.state);

  String get string => match.namedGroup('all')!;

  String? operator [](String namedGroup) => match.namedGroup(namedGroup);
}
