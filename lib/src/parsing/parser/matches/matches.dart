part of '../ansi_parser.dart';

final class Matches<S extends SgrState<S>> extends Iterable<Match<S>> {
  final S _initialState;
  final String _input;

  MatchesResult<S>? _parsingResult;

  Matches._(this._input, this._initialState);

  MatchesResult<S> get _requireParsingResult {
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
  Iterator<Match<S>> get iterator =>
      _parsingResult?.matches.iterator ?? _createIterator();

  @visibleForTesting
  bool get isParsed => _parsingResult != null;

  AnsiParserIterator<S> _createIterator() =>
      AnsiParserIterator<S>._(this, _initialState);
}
