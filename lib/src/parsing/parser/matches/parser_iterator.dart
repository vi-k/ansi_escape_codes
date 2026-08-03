part of '../parser.dart';

final class _ParserIterator<S extends State<S>> implements Iterator<Match<S>> {
  final Matches<S> _parent;
  final S _initialState;

  /// Created once this iterator has to read past what was read before, and
  /// started from there rather than from the beginning of the string.
  Iterator<RegExpMatch>? _regExpIterator;

  RegExpMatch? _next;

  /// How many matches this iterator has handed out.
  int _index = 0;

  int _pos = 0;
  Match<S>? _current;

  /// The state [SaveCursor] put away, for [RestoreCursor] to bring back.
  ///
  /// `ESC 7` saves the rendition along with the cursor, and `ESC 8` restores
  /// both, so a reader that ignored them would report a style the terminal is
  /// no longer showing.
  S? _saved;

  _ParserIterator._(this._parent, this._initialState);

  /// Current match.
  @override
  Match<S> get current => _current ?? (throw StateError('Use moveNext first'));

  /// Current state.
  S get currentState => _current?.state ?? _initialState;

  @override
  bool moveNext() {
    final parsed = _parent._parsed;

    // Already read once, by this iterator or another one over the same
    // string. Reading it again would give the same answer.
    if (_index < parsed.length) {
      final match = parsed[_index];

      // Read before, and read again from the start by another iterator: the
      // state of each match is settled, but what was saved along the way has
      // to be picked up again for the restore that may still be ahead.
      if (match.entity is SaveCursor) {
        _saved = match.state;
      }

      _index++;
      _current = match;
      _pos = match.end;

      // Taking a match from the cache moves the position, and what this
      // iterator had found ahead of the old one belongs to where it was.
      // Reading on starts the search again from here.
      _next = null;
      _regExpIterator = null;

      return true;
    }

    final match = _read();
    if (match == null) {
      _parent._parsingResult ??= _MatchesResult<S>._(
        matches: parsed,
        finalState: currentState,
      );

      return false;
    }

    // Another iterator may have got here first while this one was reading.
    if (_index == parsed.length) {
      parsed.add(match);
    }

    _index++;
    _current = match;

    return true;
  }

  /// Reads the next match of the string, or `null` at the end of it.
  Match<S>? _read() {
    final string = _parent._input;
    final pos = _pos;

    // End of string.
    if (pos == string.length) {
      return null;
    }

    // There's the next escape code.
    final next = _next;
    if (next != null) {
      _next = null;

      return _escapeCode(next);
    }

    final regExpIterator =
        _regExpIterator ??= escapeCodesRe.allMatches(string, pos).iterator;

    // There is nothing further to move, so we return the rest of the string.
    if (!regExpIterator.moveNext()) {
      return _text(pos, string.length);
    }

    final m = regExpIterator.current;

    // There is plain text before the escape code.
    if (pos != m.start) {
      _next = m;

      return _text(pos, m.start);
    }

    return _escapeCode(m);
  }

  Match<S> _text(int start, int end) {
    _pos = end;

    return Match<S>._(
      state: currentState,
      entity: Text._(_parent._input.substring(start, end)),
      start: start,
      end: end,
    );
  }

  Match<S> _escapeCode(RegExpMatch m) {
    final matchingState = _MatchingState(m, currentState);
    final entity = EscapeCode._parse(matchingState);

    switch (entity) {
      case SaveCursor():
        _saved = matchingState.state;
      case RestoreCursor():
        // With nothing saved the terminal goes back to its defaults, which
        // for a parser is the state it was started in.
        matchingState.state = _saved ?? _parent._initialState;
      default:
    }

    _pos = m.end;

    return Match<S>._(
      state: matchingState.state,
      entity: entity,
      start: m.start,
      end: m.end,
    );
  }
}
