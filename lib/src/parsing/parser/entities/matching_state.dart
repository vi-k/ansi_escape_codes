part of '../ansi_parser.dart';

final class MatchingState<S extends SgrState<S>> {
  final RegExpMatch match;
  S sgrState;

  MatchingState(this.match, this.sgrState);

  String get string => match.namedGroup('all')!;

  String? operator [](String namedGroup) => match.namedGroup(namedGroup);
}
