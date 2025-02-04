part of '../parsers.dart';

final class _AnsiMatchesV2 extends AnsiMatches<AnsiStackedState> {
  _AnsiMatchesV2(super._input) : super._();

  @override
  AnsiIterator<AnsiStackedState> _createIterator() =>
      AnsiIterator<AnsiStackedState>(this, AnsiStackedState.defaults);
}
