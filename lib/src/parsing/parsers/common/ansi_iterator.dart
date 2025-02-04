part of '../parsers.dart';

final class AnsiIterator<S extends AnsiState<S>>
    implements Iterator<AnsiMatch<S>> {
  final AnsiMatches<S> _parent;
  final List<AnsiMatch<S>> _readyMatches = [];
  final Iterator<RegExpMatch> _regExpIterator;
  RegExpMatch? _next;
  int _pos = 0;
  AnsiMatch<S>? _current;
  final S _defaultState;
  S _currentState;

  AnsiIterator(this._parent, this._defaultState)
      : _regExpIterator = escapeCodesRe.allMatches(_parent._input).iterator,
        _currentState = _defaultState;

  @override
  AnsiMatch<S> get current =>
      _current ?? (throw StateError('Use moveNext first'));

  @override
  bool moveNext() {
    final string = _parent._input;
    final pos = _pos;

    // End of string.
    if (pos == string.length) {
      _parent._parsingResult ??= AnsiMatchesResult<S>._(
        matches: _readyMatches,
        endState: _currentState,
      );

      return false;
    }

    // There's the next escape code.
    final next = _next;
    if (next != null) {
      final entity = AnsiEscapeCode._parse(next);
      final match = AnsiMatch<S>._(
        state: _currentState,
        entity: entity,
        start: next.start,
        end: next.end,
      );
      _readyMatches.add(match);
      _current = match;
      _next = null;
      _pos = next.end;
      _updateState(entity);

      return true;
    }

    // There is nothing further to move, so we return the rest of the string.
    if (!_regExpIterator.moveNext()) {
      final entity = AnsiPlainText._(string.substring(pos));
      final match = AnsiMatch<S>._(
        state: _currentState,
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
      final entity = AnsiPlainText._(string.substring(pos, m.start));
      final match = AnsiMatch<S>._(
        state: _currentState,
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
    final entity = AnsiEscapeCode._parse(m);
    final match = AnsiMatch<S>._(
      state: _currentState,
      entity: entity,
      start: m.start,
      end: m.end,
    );
    _readyMatches.add(match);
    _current = match;
    _pos = m.end;
    _updateState(entity);

    return true;
  }

  void _updateState(AnsiEscapeCode entity) {
    final state = _currentState;

    _currentState = switch (entity) {
      AnsiReset() => _currentState = _defaultState,
      AnsiForegroundColor() => _currentState =
          state.copyWith(foregroundColor: entity),
      AnsiBackgroundColor() => _currentState =
          state.copyWith(backgroundColor: entity),
      AnsiUnderlineColor() => _currentState =
          state.copyWith(underlineColor: entity),
      AnsiIntensityStyle() => _currentState =
          state.copyWith(intensityStyle: entity),
      AnsiItalicStyle() => _currentState = state.copyWith(italicStyle: entity),
      AnsiUnderlineStyle() => _currentState =
          state.copyWith(underlineStyle: entity),
      AnsiBlinkStyle() => _currentState = state.copyWith(blinkStyle: entity),
      AnsiReverseStyle() => _currentState =
          state.copyWith(reverseStyle: entity),
      AnsiConcealStyle() => _currentState =
          state.copyWith(concealStyle: entity),
      AnsiCrossedOutStyle() => _currentState =
          state.copyWith(crossedOutStyle: entity),
      AnsiFramedStyle() => _currentState = state.copyWith(framedStyle: entity),
      AnsiOverlinedStyle() => _currentState =
          state.copyWith(overlinedStyle: entity),
      AnsiSuperAndSubsriptStyle() => _currentState =
          state.copyWith(superAndSubscriptStyle: entity),
      _ => _currentState,
    };
  }
}
