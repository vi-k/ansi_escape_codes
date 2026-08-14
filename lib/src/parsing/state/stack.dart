part of 'state.dart';

/// One frame of a [Stack]'s history: what was pushed, and everything under it.
///
/// A push is one new frame pointing at the old top, and a pop is the frame
/// under this one, so both cost a single small allocation and every version of
/// a stack shares the whole of its own tail with the versions it came from.
///
/// Lists were the obvious thing and were the wrong thing. A [Stack] is
/// immutable, so a push had to copy the list it grew — twice, once to build it
/// and once to seal it — which made a run of n pushes cost n² words of copying
/// and, because a parse keeps every state it passed, kept n² of them alive at
/// once. A string of 320 kB that switched colour without ever resetting took
/// 15 s and 7.6 GB where a [Style] took 51 ms and nothing.
///
/// Nothing is lost by it: every history is only ever asked
/// whether it is empty and what is on top, and only ever grows and shrinks at
/// that same end.
final class _Frame<T> {
  const _Frame(this.value, this.under);

  /// What this frame holds.
  final T value;

  /// The frame under this one, or null where this is the bottom of the stack.
  final _Frame<T>? under;
}

/// A history handed to [Stack._copyWith].
///
/// A bare `_Frame<T>?` could not be a parameter there: null is what an empty
/// history looks like, and `_copyWith` needs null to mean "leave this one
/// alone". Wrapping it says which of the two is meant.
typedef _Replace<T> = ({_Frame<T>? frames});

/// Represents an active text style that tracks history via a stack.
///
/// Unlike [Style] which keeps only the recently active properties, [Stack]
/// remembers the order in which styles and colors were applied. When applied,
/// items are pushed onto the history stack. When a reset is called, the last
/// value is popped, reverting the property to its previous state.
///
/// A reset of a property that was never applied does nothing: text may come
/// from anywhere and close an attribute it has not opened, so such resets are
/// ignored rather than treated as an error.
///
/// Equality compares the visible surface only — see [State.==]: the
/// history is what a stack does, not what it equals.
final class Stack extends State<Stack> {
  final _Frame<IntensityStyle>? _intensity;
  final int _boldCounter;
  final int _dimCounter;
  final _Frame<FontSelection>? _font;
  final _Frame<FontShape>? _fontShape;
  final _Frame<UnderlineStyle>? _underline;
  final int _proportionalSpacingCounter;
  final _Frame<BlinkStyle>? _blink;
  final int _inverseCounter;
  final int _invisibleCounter;
  final int _strikethroughCounter;
  final _Frame<FrameStyle>? _frame;
  final int _overlineCounter;
  final _Frame<IdeogramStyle>? _ideogram;
  final _Frame<ScriptStyle>? _script;
  final _Frame<Color>? _foreground;
  final _Frame<Color>? _background;
  final _Frame<ExtendedColor>? _underlineColor;

  const Stack._({
    required _Frame<IntensityStyle>? intensity,
    required int boldCounter,
    required int dimCounter,
    required _Frame<FontSelection>? font,
    required _Frame<FontShape>? fontShape,
    required _Frame<UnderlineStyle>? underline,
    required int proportionalSpacingCounter,
    required _Frame<BlinkStyle>? blink,
    required int inverseCounter,
    required int invisibleCounter,
    required int strikethroughCounter,
    required _Frame<FrameStyle>? frame,
    required int overlineCounter,
    required _Frame<IdeogramStyle>? ideogram,
    required _Frame<ScriptStyle>? script,
    required _Frame<Color>? foreground,
    required _Frame<Color>? background,
    required _Frame<ExtendedColor>? underlineColor,
  })  : _intensity = intensity,
        _boldCounter = boldCounter,
        _dimCounter = dimCounter,
        _font = font,
        _fontShape = fontShape,
        _underline = underline,
        _proportionalSpacingCounter = proportionalSpacingCounter,
        _blink = blink,
        _inverseCounter = inverseCounter,
        _invisibleCounter = invisibleCounter,
        _strikethroughCounter = strikethroughCounter,
        _frame = frame,
        _overlineCounter = overlineCounter,
        _ideogram = ideogram,
        _script = script,
        _foreground = foreground,
        _background = background,
        _underlineColor = underlineColor;

  /// The state a terminal is in before anything is written to it: its own
  /// colours, and nothing switched on.
  static const Stack terminalColors = Stack._(
    intensity: null,
    boldCounter: 0,
    dimCounter: 0,
    font: null,
    fontShape: null,
    underline: null,
    proportionalSpacingCounter: 0,
    blink: null,
    inverseCounter: 0,
    invisibleCounter: 0,
    strikethroughCounter: 0,
    frame: null,
    overlineCounter: 0,
    ideogram: null,
    script: null,
    foreground: null,
    background: null,
    underlineColor: null,
  );

  @override
  bool get isBold => _boldCounter != 0;

  @override
  bool get isDim => _dimCounter != 0;

  @override
  FontSelection get fontSelection => _font?.value ?? FontSelection.primary;

  @override
  FontShape? get fontShape => _fontShape?.value;

  @override
  bool get isItalic => fontShape == FontShape.italic;

  @override
  bool get isFraktur => fontShape == FontShape.fraktur;

  @override
  bool get isUnderline => switch (underlineStyle) {
        UnderlineStyle.singly ||
        UnderlineStyle.curly ||
        UnderlineStyle.dotted ||
        UnderlineStyle.dashed =>
          true,
        UnderlineStyle.doubly || null => false,
      };

  @override
  bool get isDoublyUnderline => underlineStyle == UnderlineStyle.doubly;

  @override
  bool get isCurlyUnderline => underlineStyle == UnderlineStyle.curly;

  @override
  bool get isDottedUnderline => underlineStyle == UnderlineStyle.dotted;

  @override
  bool get isDashedUnderline => underlineStyle == UnderlineStyle.dashed;

  @override
  UnderlineStyle? get underlineStyle => _underline?.value;

  @override
  bool get isProportionalSpacing => _proportionalSpacingCounter != 0;

  @override
  bool get isBlink => _blink?.value == BlinkStyle.slow;

  @override
  bool get isBlinkRapid => _blink?.value == BlinkStyle.rapid;

  @override
  BlinkStyle? get blinkStyle => isBlink
      ? BlinkStyle.slow
      : isBlinkRapid
          ? BlinkStyle.rapid
          : null;

  @override
  bool get isInverse => _inverseCounter != 0;

  @override
  bool get isInvisible => _invisibleCounter != 0;

  @override
  bool get isStrikethrough => _strikethroughCounter != 0;

  @override
  bool get isFrame => _frame?.value == FrameStyle.frame;

  @override
  bool get isEncircle => _frame?.value == FrameStyle.encircle;

  @override
  FrameStyle? get frameStyle => isFrame
      ? FrameStyle.frame
      : isEncircle
          ? FrameStyle.encircle
          : null;

  @override
  bool get isOverline => _overlineCounter != 0;

  @override
  IdeogramStyle? get ideogramStyle => _ideogram?.value;

  @override
  bool get isSuperscript => _script?.value == ScriptStyle.superscript;

  @override
  bool get isSubscript => _script?.value == ScriptStyle.subscript;

  @override
  ScriptStyle? get scriptStyle => isSuperscript
      ? ScriptStyle.superscript
      : isSubscript
          ? ScriptStyle.subscript
          : null;

  @override
  Color? get foregroundColor => _foreground?.value;

  @override
  Color? get backgroundColor => _background?.value;

  @override
  ExtendedColor? get underlineColorValue => _underlineColor?.value;

  @override
  Stack get bold => _copyWith(
        intensity: (frames: _Frame(IntensityStyle.bold, _intensity)),
        boldCounter: _boldCounter + 1,
      );

  @override
  Stack get dim => _copyWith(
        intensity: (frames: _Frame(IntensityStyle.dim, _intensity)),
        dimCounter: _dimCounter + 1,
      );

  @override
  Stack get alternativeFont1 => _setFont(FontSelection.alternative1);

  @override
  Stack get alternativeFont2 => _setFont(FontSelection.alternative2);

  @override
  Stack get alternativeFont3 => _setFont(FontSelection.alternative3);

  @override
  Stack get alternativeFont4 => _setFont(FontSelection.alternative4);

  @override
  Stack get alternativeFont5 => _setFont(FontSelection.alternative5);

  @override
  Stack get alternativeFont6 => _setFont(FontSelection.alternative6);

  @override
  Stack get alternativeFont7 => _setFont(FontSelection.alternative7);

  @override
  Stack get alternativeFont8 => _setFont(FontSelection.alternative8);

  @override
  Stack get alternativeFont9 => _setFont(FontSelection.alternative9);

  @override
  Stack get italic => _setFontShape(FontShape.italic);

  @override
  Stack get fraktur => _setFontShape(FontShape.fraktur);

  @override
  Stack get underline => _setUnderline(UnderlineStyle.singly);

  @override
  Stack get doublyUnderline => _setUnderline(UnderlineStyle.doubly);

  @override
  Stack get curlyUnderline => _setUnderline(UnderlineStyle.curly);

  @override
  Stack get dottedUnderline => _setUnderline(UnderlineStyle.dotted);

  @override
  Stack get dashedUnderline => _setUnderline(UnderlineStyle.dashed);

  @override
  Stack get proportionalSpacing => _copyWith(
        proportionalSpacingCounter: _proportionalSpacingCounter + 1,
      );

  @override
  Stack get blink => _copyWith(
        blink: (frames: _Frame(BlinkStyle.slow, _blink)),
      );

  @override
  Stack get blinkRapid => _copyWith(
        blink: (frames: _Frame(BlinkStyle.rapid, _blink)),
      );

  @override
  Stack get inverse => _copyWith(inverseCounter: _inverseCounter + 1);

  @override
  Stack get invisible => _copyWith(invisibleCounter: _invisibleCounter + 1);

  @override
  Stack get strikethrough =>
      _copyWith(strikethroughCounter: _strikethroughCounter + 1);

  @override
  Stack get frame => _copyWith(
        frame: (frames: _Frame(FrameStyle.frame, _frame)),
      );

  @override
  Stack get encircle => _copyWith(
        frame: (frames: _Frame(FrameStyle.encircle, _frame)),
      );

  @override
  Stack get overline => _copyWith(overlineCounter: _overlineCounter + 1);

  @override
  Stack get ideogramUnderline => _setIdeogram(IdeogramStyle.underline);

  @override
  Stack get ideogramDoublyUnderline =>
      _setIdeogram(IdeogramStyle.doublyUnderline);

  @override
  Stack get ideogramOverline => _setIdeogram(IdeogramStyle.overline);

  @override
  Stack get ideogramDoublyOverline =>
      _setIdeogram(IdeogramStyle.doublyOverline);

  @override
  Stack get ideogramStress => _setIdeogram(IdeogramStyle.stress);

  @override
  Stack get superscript => _copyWith(
        script: (frames: _Frame(ScriptStyle.superscript, _script)),
      );

  @override
  Stack get subscript => _copyWith(
        script: (frames: _Frame(ScriptStyle.subscript, _script)),
      );

  @override
  Stack foreground(Color color) => _copyWith(
        foreground: (
          frames: _Frame(color.on(ColorTarget.foreground), _foreground),
        ),
      );

  @override
  Stack background(Color color) => _copyWith(
        background: (
          frames: _Frame(color.on(ColorTarget.background), _background),
        ),
      );

  @override
  Stack underlineColor(ExtendedColor color) => _copyWith(
        underlineColor: (
          frames: _Frame(color.on(ColorTarget.underline), _underlineColor),
        ),
      );

  Stack _setFont(FontSelection font) => _copyWith(
        font: (frames: _Frame(font, _font)),
      );

  Stack _setFontShape(FontShape shape) => _copyWith(
        fontShape: (frames: _Frame(shape, _fontShape)),
      );

  Stack _setUnderline(UnderlineStyle style) => _copyWith(
        underline: (frames: _Frame(style, _underline)),
      );

  Stack _setIdeogram(IdeogramStyle style) => _copyWith(
        ideogram: (frames: _Frame(style, _ideogram)),
      );

  @override
  Stack get reset => terminalColors;

  @override
  Stack get resetBoldAndDim {
    final top = _intensity;
    if (top == null) {
      return this;
    }

    return _copyWith(
      intensity: (frames: top.under),
      boldCounter:
          top.value == IntensityStyle.bold ? _boldCounter - 1 : _boldCounter,
      dimCounter:
          top.value == IntensityStyle.dim ? _dimCounter - 1 : _dimCounter,
    );
  }

  @override
  Stack get resetFont {
    final top = _font;
    if (top == null) {
      return this;
    }

    return _copyWith(font: (frames: top.under));
  }

  @override
  Stack get resetFontShape {
    final top = _fontShape;
    if (top == null) {
      return this;
    }

    return _copyWith(fontShape: (frames: top.under));
  }

  @override
  Stack get resetItalic => resetFontShape;

  @override
  Stack get resetUnderline {
    final top = _underline;
    if (top == null) {
      return this;
    }

    return _copyWith(underline: (frames: top.under));
  }

  @override
  Stack get resetProportionalSpacing {
    if (_proportionalSpacingCounter == 0) {
      return this;
    }

    return _copyWith(
      proportionalSpacingCounter: _proportionalSpacingCounter - 1,
    );
  }

  @override
  Stack get resetBlink {
    final top = _blink;
    if (top == null) {
      return this;
    }

    return _copyWith(blink: (frames: top.under));
  }

  @override
  Stack get resetInverse {
    if (_inverseCounter == 0) {
      return this;
    }

    return _copyWith(inverseCounter: _inverseCounter - 1);
  }

  @override
  Stack get resetInvisible {
    if (_invisibleCounter == 0) {
      return this;
    }

    return _copyWith(invisibleCounter: _invisibleCounter - 1);
  }

  @override
  Stack get resetStrikethrough {
    if (_strikethroughCounter == 0) {
      return this;
    }

    return _copyWith(strikethroughCounter: _strikethroughCounter - 1);
  }

  @override
  Stack get resetFrameAndEncircle {
    final top = _frame;
    if (top == null) {
      return this;
    }

    return _copyWith(frame: (frames: top.under));
  }

  @override
  Stack get resetOverline {
    if (_overlineCounter == 0) {
      return this;
    }

    return _copyWith(overlineCounter: _overlineCounter - 1);
  }

  @override
  Stack get resetIdeogram {
    final top = _ideogram;
    if (top == null) {
      return this;
    }

    return _copyWith(ideogram: (frames: top.under));
  }

  @override
  Stack get resetSuperAndSubscript {
    final top = _script;
    if (top == null) {
      return this;
    }

    return _copyWith(script: (frames: top.under));
  }

  @override
  Stack get resetForeground {
    final top = _foreground;
    if (top == null) {
      return this;
    }

    return _copyWith(foreground: (frames: top.under));
  }

  @override
  Stack get resetBackground {
    final top = _background;
    if (top == null) {
      return this;
    }

    return _copyWith(background: (frames: top.under));
  }

  @override
  Stack get resetUnderlineColor {
    final top = _underlineColor;
    if (top == null) {
      return this;
    }

    return _copyWith(underlineColor: (frames: top.under));
  }

  /// This stack with the named parts replaced and the rest carried over.
  ///
  /// A history left out is passed on as it stands rather than copied: frames
  /// are immutable and share their tails, so handing the same top to the new
  /// stack hands it the whole history behind it and costs nothing. The
  /// histories are wrapped in a [_Replace] because an empty one is null and
  /// "leave this alone" has to be told apart from it.
  Stack _copyWith({
    _Replace<IntensityStyle>? intensity,
    int? boldCounter,
    int? dimCounter,
    _Replace<FontSelection>? font,
    _Replace<FontShape>? fontShape,
    _Replace<UnderlineStyle>? underline,
    int? proportionalSpacingCounter,
    _Replace<BlinkStyle>? blink,
    int? inverseCounter,
    int? invisibleCounter,
    int? strikethroughCounter,
    _Replace<FrameStyle>? frame,
    int? overlineCounter,
    _Replace<IdeogramStyle>? ideogram,
    _Replace<ScriptStyle>? script,
    _Replace<Color>? foreground,
    _Replace<Color>? background,
    _Replace<ExtendedColor>? underlineColor,
  }) =>
      Stack._(
        intensity: intensity == null ? _intensity : intensity.frames,
        boldCounter: boldCounter ?? _boldCounter,
        dimCounter: dimCounter ?? _dimCounter,
        font: font == null ? _font : font.frames,
        fontShape: fontShape == null ? _fontShape : fontShape.frames,
        underline: underline == null ? _underline : underline.frames,
        proportionalSpacingCounter:
            proportionalSpacingCounter ?? _proportionalSpacingCounter,
        blink: blink == null ? _blink : blink.frames,
        inverseCounter: inverseCounter ?? _inverseCounter,
        invisibleCounter: invisibleCounter ?? _invisibleCounter,
        strikethroughCounter: strikethroughCounter ?? _strikethroughCounter,
        frame: frame == null ? _frame : frame.frames,
        overlineCounter: overlineCounter ?? _overlineCounter,
        ideogram: ideogram == null ? _ideogram : ideogram.frames,
        script: script == null ? _script : script.frames,
        foreground: foreground == null ? _foreground : foreground.frames,
        background: background == null ? _background : background.frames,
        underlineColor:
            underlineColor == null ? _underlineColor : underlineColor.frames,
      );

  @override
  Style toStyle() => Style(
        bold: isBold,
        dim: isDim,
        fontSelection: fontSelection,
        italic: isItalic,
        fraktur: isFraktur,
        underline: underlineStyle == UnderlineStyle.singly,
        doublyUnderline: isDoublyUnderline,
        curlyUnderline: isCurlyUnderline,
        dottedUnderline: isDottedUnderline,
        dashedUnderline: isDashedUnderline,
        proportionalSpacing: isProportionalSpacing,
        blink: isBlink,
        blinkRapid: isBlinkRapid,
        inverse: isInverse,
        invisible: isInvisible,
        strikethrough: isStrikethrough,
        frame: isFrame,
        encircle: isEncircle,
        overline: isOverline,
        ideogramStyle: ideogramStyle,
        superscript: isSuperscript,
        subscript: isSubscript,
        foreground: foregroundColor,
        background: backgroundColor,
        underlineColor: underlineColorValue,
      );

  @override
  String get _objectTypeName => '$Stack';
}
