part of '../parser.dart';

final class _ParserIterator<S extends State<S>> implements Iterator<Piece<S>> {
  final Pieces<S> _parent;
  final S _initialState;
  final Link? _initialLink;

  RegExpMatch? _next;

  /// How many pieces this iterator has handed out.
  int _index = 0;

  int _pos = 0;
  Piece<S>? _current;

  /// The state and the link [SaveCursor] put away, for [RestoreCursor] to
  /// bring back.
  ///
  /// `ESC 7` saves the rendition along with the cursor, and `ESC 8` restores
  /// both, so a reader that ignored them would report a style the terminal is
  /// no longer showing. The link travels in the same bundle: a terminal keeps
  /// the hyperlink among the attributes it saves, so what is restored is
  /// clickable again exactly where it was.
  ({S state, Link? link})? _saved;

  _ParserIterator._(this._parent, this._initialState, this._initialLink);

  /// Current piece.
  @override
  Piece<S> get current => _current ?? (throw StateError('Use moveNext first'));

  /// Current state.
  S get currentState => _current?.state ?? _initialState;

  /// The link open at this point, the way [currentState] is the state.
  ///
  /// Told apart by the piece, not by the link: a closed link is a `null` of
  /// its own, and falling back to the seed would raise it from the dead.
  Link? get currentLink {
    final current = _current;

    return current == null ? _initialLink : current.link;
  }

  @override
  bool moveNext() {
    final parsed = _parent._parsed;

    // Already read once, by this iterator or another one over the same
    // string. Reading it again would give the same answer.
    if (_index < parsed.length) {
      final piece = parsed[_index];

      // Read before, and read again from the start by another iterator: the
      // state and the link of each piece are settled and travel in the piece
      // itself, but what was saved along the way has to be picked up again
      // for the restore that may still be ahead — the whole bundle of it, or
      // the second walk would answer where the first one did not.
      if (piece.entity is SaveCursor) {
        _saved = (state: piece.state, link: piece.link);
      }

      _index++;
      _current = piece;
      _pos = piece.end;

      // Taking a piece from the cache moves the position, and what this
      // iterator had found ahead of the old one belongs to where it was.
      _next = null;

      return true;
    }

    final piece = _read();
    if (piece == null) {
      // Wrap at end-of-input; the list is complete and will not grow.
      _parent._parsingResult ??= _PiecesResult<S>._(
        pieces: parsed,
        finalState: currentState,
        finalLink: currentLink,
      );

      return false;
    }

    // Another iterator may have got here first while this one was reading.
    if (_index == parsed.length) {
      parsed.add(piece);
    }

    _index++;
    _current = piece;

    return true;
  }

  /// Reads the next piece of the string, or `null` at the end of it.
  Piece<S>? _read() {
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

    // Between escape codes the string is scanned by indexOf, which walks
    // bytes two orders of magnitude faster than the regex engine would:
    // every alternative of [escapeCodesRe] begins with ESC, so ESC is the
    // only place a match can start.
    var searchFrom = pos;
    while (true) {
      final escIndex = string.indexOf('\x1B', searchFrom);

      // No escape at all: the rest of the string is plain text.
      if (escIndex < 0) {
        return _text(pos, string.length);
      }

      final m = escapeCodesRe.matchAsPrefix(string, escIndex) as RegExpMatch?;

      // The patterns as they stand match any ESC, so this is for a pattern
      // grown narrower than its scanner: an ESC none of them took stays in
      // the text, exactly as allMatches would have left it.
      if (m == null) {
        searchFrom = escIndex + 1;
        continue;
      }

      // There is plain text before the escape code.
      if (pos != m.start) {
        _next = m;

        return _text(pos, m.start);
      }

      return _escapeCode(m);
    }
  }

  Piece<S> _text(int start, int end) {
    _pos = end;

    return Piece<S>._(
      state: currentState,
      link: currentLink,
      entity: Text._(_parent._input, start, end),
      start: start,
      end: end,
    );
  }

  Piece<S> _escapeCode(RegExpMatch m) {
    final matchingState = _MatchingState(m, currentState);
    final entity = EscapeCode._parse(matchingState);

    // A link does not nest and carries no style, so it rides beside the
    // state: an opening supersedes whatever was open, a close — an opening
    // on an empty url — leaves nothing open, and every other code leaves the
    // link as it found it.
    var link = switch (entity) {
      Link(:final url) => url.isEmpty ? null : entity,
      _ => currentLink,
    };

    switch (entity) {
      case SaveCursor():
        _saved = (state: matchingState.state, link: link);
      case RestoreCursor():
        // With nothing saved the terminal goes back to its defaults, which
        // for a parser is the state and the link it was started in.
        //
        // Told apart by the record and not by what is in it. A save made
        // where no link was open put a link of `null` away, and that is not
        // the same `null` as having saved nothing at all — reaching for the
        // seed there would raise the seeded link from the dead behind a
        // close, which is the very pair [currentLink] is written to keep
        // apart. The state escapes the question only because `S` is not
        // nullable and cannot say the second `null`.
        final saved = _saved;
        if (saved == null) {
          matchingState.state = _initialState;
          link = _initialLink;
        } else {
          matchingState.state = saved.state;
          link = saved.link;
        }
      default:
    }

    _pos = m.end;

    return Piece<S>._(
      state: matchingState.state,
      link: link,
      entity: entity,
      start: m.start,
      end: m.end,
    );
  }
}
