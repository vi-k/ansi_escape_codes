part of '../parsers.dart';

sealed class AnsiMatches<S extends AnsiState<S>>
    extends Iterable<AnsiMatch<S>> {
  final String _input;

  AnsiMatchesResult<S>? _parsingResult;

  AnsiMatches._(this._input);

  AnsiMatchesResult<S> get _requireParsingResult {
    final parsingResult = _parsingResult;
    if (parsingResult != null) {
      return parsingResult;
    }

    final iterator = _createIterator();
    while (iterator.moveNext()) {
      // no-op
    }

    return _parsingResult!;
  }

  @override
  Iterator<AnsiMatch<S>> get iterator =>
      _parsingResult?.matches.iterator ?? _createIterator();

  AnsiIterator<S> _createIterator();
}
