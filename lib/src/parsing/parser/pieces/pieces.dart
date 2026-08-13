part of '../parser.dart';

/// An iterable collection of [Piece] objects representing the parsed ANSI
/// escape codes and text segments in a string.
///
/// This class is created by the [Parser] and provides access to the
/// individual pieces found in the input string.
final class Pieces<S extends State<S>> extends Iterable<Piece<S>> {
  final S _initialState;

  /// The link the string is read as starting inside, where there is one.
  final Link? _initialLink;

  final String _input;

  /// What has been read of the string so far, shared by every iterator over
  /// it, so that reading part of it and then asking again does not start the
  /// reading over.
  final List<Piece<S>> _parsed = [];

  _PiecesResult<S>? _parsingResult;

  Pieces._(this._input, this._initialState, {Link? initialLink})
      : _initialLink = initialLink;

  _PiecesResult<S> get _requireParsingResult {
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
  Iterator<Piece<S>> get iterator =>
      _parsingResult?.pieces.iterator ?? _createIterator();

  /// Whether the whole string has been read, rather than as much of it as the
  /// questions asked so far needed.
  @visibleForTesting
  bool get isParsed => _parsingResult != null;

  _ParserIterator<S> _createIterator() =>
      _ParserIterator<S>._(this, _initialState, _initialLink);
}
