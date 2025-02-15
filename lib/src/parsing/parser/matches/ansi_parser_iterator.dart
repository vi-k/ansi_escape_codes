part of '../ansi_parser.dart';

final class AnsiParserIterator<S extends SgrState<S>>
    implements Iterator<Match<S>> {
  final Matches<S> _parent;
  final List<Match<S>> _readyMatches = [];
  final Iterator<RegExpMatch> _regExpIterator;
  RegExpMatch? _next;
  int _pos = 0;
  Match<S>? _current;
  final S _initialState;

  AnsiParserIterator._(this._parent, this._initialState)
      : _regExpIterator = escapeCodesRe.allMatches(_parent._input).iterator;

  /// Current match.
  @override
  Match<S> get current => _current ?? (throw StateError('Use moveNext first'));

  /// Current state.
  S get currentState => _current?.state ?? _initialState;

  @override
  bool moveNext() {
    final string = _parent._input;
    final pos = _pos;

    // End of string.
    if (pos == string.length) {
      _parent._parsingResult ??= MatchesResult<S>._(
        matches: _readyMatches,
        finalState: currentState,
      );

      return false;
    }

    // There's the next escape code.
    final next = _next;
    if (next != null) {
      final matchingState = MatchingState(next, currentState);
      final entity = EscapeCode._parse(matchingState);
      final match = Match<S>._(
        state: matchingState.sgrState,
        entity: entity,
        start: next.start,
        end: next.end,
      );
      _readyMatches.add(match);
      _current = match;
      _next = null;
      _pos = next.end;

      return true;
    }

    // There is nothing further to move, so we return the rest of the string.
    if (!_regExpIterator.moveNext()) {
      final entity = Text._(string.substring(pos));
      final match = Match<S>._(
        state: currentState,
        entity: entity,
        start: pos,
        end: string.length,
      );
      _readyMatches.add(match);
      _current = match;
      _pos = string.length;

      return true;
    }

    final m = _regExpIterator.current;

    // There is plain text before the escape code.
    if (pos != m.start) {
      final entity = Text._(string.substring(pos, m.start));
      final match = Match<S>._(
        state: currentState,
        entity: entity,
        start: pos,
        end: m.start,
      );
      _readyMatches.add(match);
      _current = match;
      _pos = m.start;
      _next = m;

      return true;
    }

    // Escape code.
    final matchingState = MatchingState(m, currentState);
    final entity = EscapeCode._parse(matchingState);
    final match = Match<S>._(
      state: matchingState.sgrState,
      entity: entity,
      start: m.start,
      end: m.end,
    );
    _readyMatches.add(match);
    _current = match;
    _pos = m.end;

    return true;
  }
}
