part of '../parser.dart';

/// An iterable collection of [Match] objects representing the parsed ANSI
/// escape codes and text segments in a string.
///
/// This class is created by the [Parser] and provides access to the
/// individual matches found in the input string.
final class Matches<S extends State<S>> extends Iterable<Match<S>> {
  final S _initialState;
  final String _input;

  /// What has been read of the string so far, shared by every iterator over
  /// it, so that reading part of it and then asking again does not start the
  /// reading over.
  final List<Match<S>> _parsed = [];

  _MatchesResult<S>? _parsingResult;

  Matches._(this._input, this._initialState);

  _MatchesResult<S> get _requireParsingResult {
    final parsingResult = _parsingResult;
    if (parsingResult != null) {
      return parsingResult;
    }

    final iterator = _createIterator();
    while (iterator.moveNext()) {
      // no-op
    }

    // _parsingResult is set by iterator.
    return _parsingResult!;
  }

  @override
  Iterator<Match<S>> get iterator =>
      _parsingResult?.matches.iterator ?? _createIterator();

  /// Whether the whole string has been read, rather than as much of it as the
  /// questions asked so far needed.
  @visibleForTesting
  bool get isParsed => _parsingResult != null;

  _ParserIterator<S> _createIterator() =>
      _ParserIterator<S>._(this, _initialState);
}
