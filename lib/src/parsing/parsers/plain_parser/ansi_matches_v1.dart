part of '../parsers.dart';

final class _AnsiMatchesV1 extends AnsiMatches<AnsiPlainState> {
  _AnsiMatchesV1(super._input) : super._();

  @override
  AnsiIterator<AnsiPlainState> _createIterator() =>
      AnsiIterator<AnsiPlainState>(this, AnsiPlainState.defaults);
}
