part of '../parser.dart';

final class MatchingState<S extends State<S>> {
  final RegExpMatch match;
  S state;

  MatchingState(this.match, this.state);

  String get string => match.namedGroup('all')!;

  String? operator [](String namedGroup) => match.namedGroup(namedGroup);
}
