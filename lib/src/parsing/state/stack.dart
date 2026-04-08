part of 'state.dart';

@Deprecated('Use Stack instead')
typedef SgrStackedState = Stack;

/// Represents an active text style that tracks history via a stack.
///
/// Unlike [Style] which keeps only the recently active properties, [Stack]
/// remembers the order in which styles and colors were applied. When applied,
/// items are pushed onto the history stack. When a reset is called, the last
/// value is popped, reverting the property to its previous state.
final class Stack extends State<Stack> {
  final List<IntensityStyle> _intensityStack;
  final int _boldCounter;
  final int _dimCounter;
  final int _italicCounter;
  final List<UnderlineStyle> _underlineStack;
  final List<BlinkStyle> _blinkStack;
  final int _inverseCounter;
  final int _invisibleCounter;
  final int _strikethroughCounter;
  final List<FrameStyle> _frameStack;
  final int _overlineCounter;
  final List<ScriptStyle> _scriptStack;
  final List<Color> _foregroundStack;
  final List<Color> _backgroundStack;
  final List<ExtendedColor> _underlineColorStack;

  const Stack._({
    required List<IntensityStyle> intencityStack,
    required int boldCounter,
    required int dimCounter,
    required int italicCounter,
    required List<UnderlineStyle> underlineStack,
    required List<BlinkStyle> blinkStack,
    required int inverseCounter,
    required int invisibleCounter,
    required int strikethroughCounter,
    required List<FrameStyle> frameStack,
    required int overlineCounter,
    required List<ScriptStyle> scriptStack,
    required List<Color> foregroundStack,
    required List<Color> backgroundStack,
    required List<ExtendedColor> underlineColorStack,
  })  : _intensityStack = intencityStack,
        _boldCounter = boldCounter,
        _dimCounter = dimCounter,
        _italicCounter = italicCounter,
        _underlineStack = underlineStack,
        _blinkStack = blinkStack,
        _inverseCounter = inverseCounter,
        _invisibleCounter = invisibleCounter,
        _strikethroughCounter = strikethroughCounter,
        _frameStack = frameStack,
        _overlineCounter = overlineCounter,
        _scriptStack = scriptStack,
        _foregroundStack = foregroundStack,
        _backgroundStack = backgroundStack,
        _underlineColorStack = underlineColorStack;

  static const Stack terminalColors = Stack._(
    intencityStack: [],
    boldCounter: 0,
    dimCounter: 0,
    italicCounter: 0,
    underlineStack: [],
    blinkStack: [],
    inverseCounter: 0,
    invisibleCounter: 0,
    strikethroughCounter: 0,
    frameStack: [],
    overlineCounter: 0,
    scriptStack: [],
    foregroundStack: [],
    backgroundStack: [],
    underlineColorStack: [],
  );

  @Deprecated('Use `terminalColors` instead')
  static const Stack defaults = terminalColors;

  @override
  bool get isBold => _boldCounter != 0;

  @override
  bool get isDim => _dimCounter != 0;

  @override
  bool get isItalic => _italicCounter != 0;

  @override
  bool get isUnderline =>
      _underlineStack.isNotEmpty &&
      _underlineStack.last == UnderlineStyle.singly;

  @override
  bool get isDoublyUnderline =>
      _underlineStack.isNotEmpty &&
      _underlineStack.last == UnderlineStyle.doubly;

  @override
  UnderlineStyle? get underlineStyle => isUnderline
      ? UnderlineStyle.singly
      : isDoublyUnderline
          ? UnderlineStyle.doubly
          : null;

  @override
  bool get isBlink =>
      _blinkStack.isNotEmpty && _blinkStack.last == BlinkStyle.slow;

  @override
  bool get isBlinkRapid =>
      _blinkStack.isNotEmpty && _blinkStack.last == BlinkStyle.rapid;

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
  bool get isFrame =>
      _frameStack.isNotEmpty && _frameStack.last == FrameStyle.frame;

  @override
  bool get isEncircle =>
      _frameStack.isNotEmpty && _frameStack.last == FrameStyle.encircle;

  @override
  FrameStyle? get frameStyle => isFrame
      ? FrameStyle.frame
      : isEncircle
          ? FrameStyle.encircle
          : null;

  @override
  bool get isOverline => _overlineCounter != 0;

  @override
  bool get isSuperscript =>
      _scriptStack.isNotEmpty && _scriptStack.last == ScriptStyle.superscript;

  @override
  bool get isSubscript =>
      _scriptStack.isNotEmpty && _scriptStack.last == ScriptStyle.subscript;

  @override
  ScriptStyle? get scriptStyle => isSuperscript
      ? ScriptStyle.superscript
      : isSubscript
          ? ScriptStyle.subscript
          : null;

  @override
  Color? get foregroundColor =>
      _foregroundStack.isEmpty ? null : _foregroundStack.last;

  @override
  Color? get backgroundColor =>
      _backgroundStack.isEmpty ? null : _backgroundStack.last;

  @override
  ExtendedColor? get underlineColorValue =>
      _underlineColorStack.isEmpty ? null : _underlineColorStack.last;

  @override
  Stack get bold => _copyWith(
        intencityStack: List.of(_intensityStack)..add(IntensityStyle.bold),
        boldCounter: _boldCounter + 1,
      );

  @override
  Stack get dim => _copyWith(
        intencityStack: List.of(_intensityStack)..add(IntensityStyle.dim),
        dimCounter: _dimCounter + 1,
      );

  @override
  Stack get italic => _copyWith(italicCounter: _italicCounter + 1);

  @override
  Stack get underline => _copyWith(
        underlineStack: List.of(_underlineStack)..add(UnderlineStyle.singly),
      );

  @override
  Stack get doublyUnderline => _copyWith(
        underlineStack: List.of(_underlineStack)..add(UnderlineStyle.doubly),
      );

  @override
  Stack get blink => _copyWith(
        blinkStack: List.of(_blinkStack)..add(BlinkStyle.slow),
      );

  @override
  Stack get blinkRapid => _copyWith(
        blinkStack: List.of(_blinkStack)..add(BlinkStyle.rapid),
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
        frameStack: List.of(_frameStack)..add(FrameStyle.frame),
      );

  @override
  Stack get encircle => _copyWith(
        frameStack: List.of(_frameStack)..add(FrameStyle.encircle),
      );

  @override
  Stack get overline => _copyWith(overlineCounter: _overlineCounter + 1);

  @override
  Stack get superscript => _copyWith(
        scripStack: List.of(_scriptStack)..add(ScriptStyle.superscript),
      );

  @override
  Stack get subscript => _copyWith(
        scripStack: List.of(_scriptStack)..add(ScriptStyle.subscript),
      );

  @override
  Stack foreground(Color color) =>
      _copyWith(foregroundStack: List.of(_foregroundStack)..add(color));

  @override
  Stack background(Color color) =>
      _copyWith(backgroundStack: List.of(_backgroundStack)..add(color));

  @override
  Stack underlineColor(Color color) =>
      _copyWith(underlineColorStack: List.of(_underlineColorStack)..add(color));

  @override
  Stack get reset => terminalColors;

  @override
  Stack get resetBoldAndDim {
    if (_intensityStack.isEmpty) {
      throw StateError('Intensity stack is empty');
    }

    final list = List.of(_intensityStack);
    final last = list.removeLast();

    return _copyWith(
      intencityStack: list,
      boldCounter:
          last == IntensityStyle.bold ? _boldCounter - 1 : _boldCounter,
      dimCounter: last == IntensityStyle.dim ? _dimCounter - 1 : _dimCounter,
    );
  }

  @override
  Stack get resetItalic {
    if (_italicCounter == 0) {
      throw StateError('Italic stack is empty');
    }

    return _copyWith(italicCounter: _italicCounter - 1);
  }

  @override
  Stack get resetUnderline {
    if (_underlineStack.isEmpty) {
      throw StateError('Underline stack is empty');
    }

    return _copyWith(underlineStack: List.of(_underlineStack)..removeLast());
  }

  @override
  Stack get resetBlink {
    if (_blinkStack.isEmpty) {
      throw StateError('Blink stack is empty');
    }

    return _copyWith(blinkStack: List.of(_blinkStack)..removeLast());
  }

  @override
  Stack get resetInverse {
    if (_inverseCounter == 0) {
      throw StateError('Inverse stack is empty');
    }

    return _copyWith(inverseCounter: _inverseCounter - 1);
  }

  @override
  Stack get resetInvisible {
    if (_invisibleCounter == 0) {
      throw StateError('Invisible stack is empty');
    }

    return _copyWith(invisibleCounter: _invisibleCounter - 1);
  }

  @override
  Stack get resetStrikethrough {
    if (_strikethroughCounter == 0) {
      throw StateError('Strikethrough stack is empty');
    }

    return _copyWith(strikethroughCounter: _strikethroughCounter - 1);
  }

  @override
  Stack get resetFrameAndEncircle {
    if (_frameStack.isEmpty) {
      throw StateError('Frame stack is empty');
    }

    return _copyWith(
      frameStack: List.of(_frameStack)..removeLast(),
    );
  }

  @override
  Stack get resetOverline {
    if (_overlineCounter == 0) {
      throw StateError('Overline stack is empty');
    }

    return _copyWith(overlineCounter: _overlineCounter - 1);
  }

  @override
  Stack get resetSuperAndSubscript {
    if (_scriptStack.isEmpty) {
      throw StateError('Script stack is empty');
    }

    return _copyWith(
      scripStack: List.of(_scriptStack)..removeLast(),
    );
  }

  @override
  Stack get resetForeground {
    if (_foregroundStack.isEmpty) {
      throw StateError('Foreground color stack is empty');
    }

    return _copyWith(
      foregroundStack: List.of(_foregroundStack)..removeLast(),
    );
  }

  @override
  Stack get resetBackground {
    if (_backgroundStack.isEmpty) {
      throw StateError('Foreground color stack is empty');
    }

    return _copyWith(
      backgroundStack: List.of(_backgroundStack)..removeLast(),
    );
  }

  @override
  Stack get resetUnderlineColor {
    if (_foregroundStack.isEmpty) {
      throw StateError('Foreground color stack is empty');
    }

    return _copyWith(
      underlineColorStack: List.of(_underlineColorStack)..removeLast(),
    );
  }

  Stack _copyWith({
    List<IntensityStyle>? intencityStack,
    int? boldCounter,
    int? dimCounter,
    int? italicCounter,
    List<UnderlineStyle>? underlineStack,
    List<BlinkStyle>? blinkStack,
    int? inverseCounter,
    int? invisibleCounter,
    int? strikethroughCounter,
    List<FrameStyle>? frameStack,
    int? overlineCounter,
    List<ScriptStyle>? scripStack,
    List<Color>? foregroundStack,
    List<Color>? backgroundStack,
    List<Color>? underlineColorStack,
  }) =>
      Stack._(
        intencityStack: intencityStack == null
            ? _intensityStack
            : List.unmodifiable(intencityStack),
        boldCounter: boldCounter ?? _boldCounter,
        dimCounter: dimCounter ?? _dimCounter,
        italicCounter: italicCounter ?? _italicCounter,
        underlineStack: underlineStack == null
            ? _underlineStack
            : List.unmodifiable(underlineStack),
        blinkStack:
            blinkStack == null ? _blinkStack : List.unmodifiable(blinkStack),
        inverseCounter: inverseCounter ?? _inverseCounter,
        invisibleCounter: invisibleCounter ?? _invisibleCounter,
        strikethroughCounter: strikethroughCounter ?? _strikethroughCounter,
        frameStack:
            frameStack == null ? _frameStack : List.unmodifiable(frameStack),
        overlineCounter: overlineCounter ?? _overlineCounter,
        scriptStack:
            scripStack == null ? _scriptStack : List.unmodifiable(scripStack),
        foregroundStack: foregroundStack == null
            ? _foregroundStack
            : List.unmodifiable(foregroundStack),
        backgroundStack: backgroundStack == null
            ? _backgroundStack
            : List.unmodifiable(backgroundStack),
        underlineColorStack: underlineColorStack == null
            ? _underlineColorStack
            : List.unmodifiable(underlineColorStack),
      );

  @override
  Style toStyle() => Style(
        bold: isBold,
        dim: isDim,
        italic: isItalic,
        underline: isUnderline,
        doublyUnderline: isDoublyUnderline,
        blink: isBlink,
        blinkRapid: isBlinkRapid,
        inverse: isInverse,
        invisible: isInvisible,
        strikethrough: isStrikethrough,
        frame: isFrame,
        encircle: isEncircle,
        overline: isOverline,
        superscript: isSuperscript,
        subscript: isSubscript,
        foreground: foregroundColor,
        background: backgroundColor,
        underlineColor: underlineColorValue,
      );

  @override
  String get _objectTypeName => '$Stack';
}
