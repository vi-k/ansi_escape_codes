part of 'sgr_state.dart';

final class SgrStackedState extends SgrState<SgrStackedState> {
  final List<IntensityStyle> _intensityStack;
  final int _boldCounter;
  final int _faintCounter;
  final int _italicizedCounter;
  final List<UnderlinedStyle> _underlinedStack;
  final List<BlinkingStyle> _blinkingStack;
  final int _negativeCounter;
  final int _concealedCounter;
  final int _crossedOutCounter;
  final List<FramedStyle> _framedStack;
  final int _overlinedCounter;
  final List<ScriptedStyle> _scriptedStack;
  final List<Color> _foregroundStack;
  final List<Color> _backgroundStack;
  final List<ExtendedColor> _underlineColorStack;

  const SgrStackedState._({
    required List<IntensityStyle> intencityStack,
    required int boldCounter,
    required int faintCounter,
    required int italicizedCounter,
    required List<UnderlinedStyle> underlinedStack,
    required List<BlinkingStyle> blinkingStack,
    required int negativeCounter,
    required int concealedCounter,
    required int crossedOutCounter,
    required List<FramedStyle> framedStack,
    required int overlinedCounter,
    required List<ScriptedStyle> scriptedStack,
    required List<Color> foregroundStack,
    required List<Color> backgroundStack,
    required List<ExtendedColor> underlineColorStack,
  })  : _intensityStack = intencityStack,
        _boldCounter = boldCounter,
        _faintCounter = faintCounter,
        _italicizedCounter = italicizedCounter,
        _underlinedStack = underlinedStack,
        _blinkingStack = blinkingStack,
        _negativeCounter = negativeCounter,
        _concealedCounter = concealedCounter,
        _crossedOutCounter = crossedOutCounter,
        _framedStack = framedStack,
        _overlinedCounter = overlinedCounter,
        _scriptedStack = scriptedStack,
        _foregroundStack = foregroundStack,
        _backgroundStack = backgroundStack,
        _underlineColorStack = underlineColorStack;

  static const SgrStackedState defaults = SgrStackedState._(
    intencityStack: [],
    boldCounter: 0,
    faintCounter: 0,
    italicizedCounter: 0,
    underlinedStack: [],
    blinkingStack: [],
    negativeCounter: 0,
    concealedCounter: 0,
    crossedOutCounter: 0,
    framedStack: [],
    overlinedCounter: 0,
    scriptedStack: [],
    foregroundStack: [],
    backgroundStack: [],
    underlineColorStack: [],
  );

  @override
  bool get isBold => _boldCounter != 0;

  @override
  bool get isFaint => _faintCounter != 0;

  @override
  bool get isItalicized => _italicizedCounter != 0;

  @override
  bool get isSinglyUnderlined =>
      _underlinedStack.isNotEmpty &&
      _underlinedStack.last == UnderlinedStyle.singly;

  @override
  bool get isDoublyUnderlined =>
      _underlinedStack.isNotEmpty &&
      _underlinedStack.last == UnderlinedStyle.doubly;

  @override
  UnderlinedStyle? get underlinedStyle => isSinglyUnderlined
      ? UnderlinedStyle.singly
      : isDoublyUnderlined
          ? UnderlinedStyle.doubly
          : null;

  @override
  bool get isSlowlyBlinking =>
      _blinkingStack.isNotEmpty && _blinkingStack.last == BlinkingStyle.slowly;

  @override
  bool get isRapidlyBlinking =>
      _blinkingStack.isNotEmpty && _blinkingStack.last == BlinkingStyle.rapidly;

  @override
  BlinkingStyle? get blinkingStyle => isSlowlyBlinking
      ? BlinkingStyle.slowly
      : isRapidlyBlinking
          ? BlinkingStyle.rapidly
          : null;

  @override
  bool get isNegative => _negativeCounter != 0;

  @override
  bool get isConcealed => _concealedCounter != 0;

  @override
  bool get isCrossedOut => _crossedOutCounter != 0;

  @override
  bool get isFramed =>
      _framedStack.isNotEmpty && _framedStack.last == FramedStyle.framed;

  @override
  bool get isEncircled =>
      _framedStack.isNotEmpty && _framedStack.last == FramedStyle.encircled;

  @override
  FramedStyle? get framedStyle => isFramed
      ? FramedStyle.framed
      : isEncircled
          ? FramedStyle.encircled
          : null;

  @override
  bool get isOverlined => _overlinedCounter != 0;

  @override
  bool get isSuperscripted =>
      _scriptedStack.isNotEmpty &&
      _scriptedStack.last == ScriptedStyle.superscripted;

  @override
  bool get isSubscripted =>
      _scriptedStack.isNotEmpty &&
      _scriptedStack.last == ScriptedStyle.subscripted;

  @override
  ScriptedStyle? get scriptedStyle => isSuperscripted
      ? ScriptedStyle.superscripted
      : isSubscripted
          ? ScriptedStyle.subscripted
          : null;

  @override
  Color? get foreground =>
      _foregroundStack.isEmpty ? null : _foregroundStack.last;

  @override
  Color? get background =>
      _backgroundStack.isEmpty ? null : _backgroundStack.last;

  @override
  ExtendedColor? get underlineColor =>
      _underlineColorStack.isEmpty ? null : _underlineColorStack.last;

  SgrStackedState _copyWith({
    List<IntensityStyle>? intencityStack,
    int? boldCounter,
    int? faintCounter,
    int? italicizedCounter,
    List<UnderlinedStyle>? underlinedStack,
    List<BlinkingStyle>? blinkingStack,
    int? negativeCounter,
    int? concealedCounter,
    int? crossedOutCounter,
    List<FramedStyle>? framedStack,
    int? overlinedCounter,
    List<ScriptedStyle>? scriptedStack,
    List<Color>? foregroundStack,
    List<Color>? backgroundStack,
    List<Color>? underlineColorStack,
  }) =>
      SgrStackedState._(
        intencityStack: intencityStack == null
            ? _intensityStack
            : List.unmodifiable(intencityStack),
        boldCounter: boldCounter ?? _boldCounter,
        faintCounter: faintCounter ?? _faintCounter,
        italicizedCounter: italicizedCounter ?? _italicizedCounter,
        underlinedStack: underlinedStack == null
            ? _underlinedStack
            : List.unmodifiable(underlinedStack),
        blinkingStack: blinkingStack == null
            ? _blinkingStack
            : List.unmodifiable(blinkingStack),
        negativeCounter: negativeCounter ?? _negativeCounter,
        concealedCounter: concealedCounter ?? _concealedCounter,
        crossedOutCounter: crossedOutCounter ?? _crossedOutCounter,
        framedStack:
            framedStack == null ? _framedStack : List.unmodifiable(framedStack),
        overlinedCounter: overlinedCounter ?? _overlinedCounter,
        scriptedStack: scriptedStack == null
            ? _scriptedStack
            : List.unmodifiable(scriptedStack),
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
  SgrStackedState resetAll() => defaults;

  @override
  SgrStackedState setBold() => _copyWith(
        intencityStack: List.of(_intensityStack)..add(IntensityStyle.bold),
        boldCounter: _boldCounter + 1,
      );

  @override
  SgrStackedState setFaint() => _copyWith(
        intencityStack: List.of(_intensityStack)..add(IntensityStyle.faint),
        faintCounter: _faintCounter + 1,
      );

  @override
  SgrStackedState resetBoldAndFaint() {
    if (_intensityStack.isEmpty) {
      throw StateError('Intensity stack is empty');
    }

    final list = List.of(_intensityStack);
    final last = list.removeLast();

    return _copyWith(
      intencityStack: list,
      boldCounter:
          last == IntensityStyle.bold ? _boldCounter - 1 : _boldCounter,
      faintCounter:
          last == IntensityStyle.faint ? _faintCounter - 1 : _faintCounter,
    );
  }

  @override
  SgrStackedState setItalicized() =>
      _copyWith(italicizedCounter: _italicizedCounter + 1);

  @override
  SgrStackedState resetItalicized() {
    if (_italicizedCounter == 0) {
      throw StateError('Italicized stack is empty');
    }

    return _copyWith(italicizedCounter: _italicizedCounter - 1);
  }

  @override
  SgrStackedState setSinglyUnderlined() => _copyWith(
        underlinedStack: List.of(_underlinedStack)..add(UnderlinedStyle.singly),
      );

  @override
  SgrStackedState setDoublyUnderlined() => _copyWith(
        underlinedStack: List.of(_underlinedStack)..add(UnderlinedStyle.doubly),
      );

  @override
  SgrStackedState resetUnderlined() {
    if (_underlinedStack.isEmpty) {
      throw StateError('Underlined stack is empty');
    }

    return _copyWith(underlinedStack: List.of(_underlinedStack)..removeLast());
  }

  @override
  SgrStackedState setSlowlyBlinking() => _copyWith(
        blinkingStack: List.of(_blinkingStack)..add(BlinkingStyle.slowly),
      );

  @override
  SgrStackedState setRapidlyBlinking() => _copyWith(
        blinkingStack: List.of(_blinkingStack)..add(BlinkingStyle.rapidly),
      );

  @override
  SgrStackedState resetBlinking() {
    if (_blinkingStack.isEmpty) {
      throw StateError('Blinking stack is empty');
    }

    return _copyWith(blinkingStack: List.of(_blinkingStack)..removeLast());
  }

  @override
  SgrStackedState setNegative() =>
      _copyWith(negativeCounter: _negativeCounter + 1);

  @override
  SgrStackedState resetNegative() {
    if (_negativeCounter == 0) {
      throw StateError('Negative stack is empty');
    }

    return _copyWith(negativeCounter: _negativeCounter - 1);
  }

  @override
  SgrStackedState setConcealed() =>
      _copyWith(concealedCounter: _concealedCounter + 1);

  @override
  SgrStackedState resetConcealed() {
    if (_concealedCounter == 0) {
      throw StateError('Concealed stack is empty');
    }

    return _copyWith(concealedCounter: _concealedCounter - 1);
  }

  @override
  SgrStackedState setCrossedOut() =>
      _copyWith(crossedOutCounter: _crossedOutCounter + 1);

  @override
  SgrStackedState resetCrossedOut() {
    if (_crossedOutCounter == 0) {
      throw StateError('Crossed-out stack is empty');
    }

    return _copyWith(crossedOutCounter: _crossedOutCounter - 1);
  }

  @override
  SgrStackedState setFramed() => _copyWith(
        framedStack: List.of(_framedStack)..add(FramedStyle.framed),
      );

  @override
  SgrStackedState setEncircled() => _copyWith(
        framedStack: List.of(_framedStack)..add(FramedStyle.encircled),
      );

  @override
  SgrStackedState resetFramedAndEncircled() {
    if (_framedStack.isEmpty) {
      throw StateError('Framed stack is empty');
    }

    return _copyWith(
      framedStack: List.of(_framedStack)..removeLast(),
    );
  }

  @override
  SgrStackedState setOverlined() =>
      _copyWith(overlinedCounter: _overlinedCounter + 1);

  @override
  SgrStackedState resetOverlined() {
    if (_overlinedCounter == 0) {
      throw StateError('Overlined stack is empty');
    }

    return _copyWith(overlinedCounter: _overlinedCounter - 1);
  }

  @override
  SgrStackedState setSuperscripted() => _copyWith(
        scriptedStack: List.of(_scriptedStack)
          ..add(ScriptedStyle.superscripted),
      );

  @override
  SgrStackedState setSubscripted() => _copyWith(
        scriptedStack: List.of(_scriptedStack)..add(ScriptedStyle.subscripted),
      );

  @override
  SgrStackedState resetSuperscriptedAndSubscripted() {
    if (_scriptedStack.isEmpty) {
      throw StateError('Scripted stack is empty');
    }

    return _copyWith(
      scriptedStack: List.of(_scriptedStack)..removeLast(),
    );
  }

  @override
  SgrStackedState setForeground(Color color) =>
      _copyWith(foregroundStack: List.of(_foregroundStack)..add(color));

  @override
  SgrStackedState resetForeground() {
    if (_foregroundStack.isEmpty) {
      throw StateError('Foreground color stack is empty');
    }

    return _copyWith(
      foregroundStack: List.of(_foregroundStack)..removeLast(),
    );
  }

  @override
  SgrStackedState setBackground(Color color) =>
      _copyWith(backgroundStack: List.of(_backgroundStack)..add(color));

  @override
  SgrStackedState resetBackground() {
    if (_backgroundStack.isEmpty) {
      throw StateError('Foreground color stack is empty');
    }

    return _copyWith(
      backgroundStack: List.of(_backgroundStack)..removeLast(),
    );
  }

  @override
  SgrStackedState setUnderlineColor(Color color) =>
      _copyWith(underlineColorStack: List.of(_underlineColorStack)..add(color));

  @override
  SgrStackedState resetUnderlineColor() {
    if (_foregroundStack.isEmpty) {
      throw StateError('Foreground color stack is empty');
    }

    return _copyWith(
      underlineColorStack: List.of(_underlineColorStack)..removeLast(),
    );
  }

  @override
  SgrPlainState toPlainState() => SgrPlainState(
        bold: isBold,
        faint: isFaint,
        italicized: isItalicized,
        singlyUnderlined: isSinglyUnderlined,
        doublyUnderlined: isDoublyUnderlined,
        slowlyBlinking: isSlowlyBlinking,
        rapidlyBlinking: isRapidlyBlinking,
        negative: isNegative,
        concealed: isConcealed,
        crossedOut: isCrossedOut,
        framed: isFramed,
        encircled: isEncircled,
        overlined: isOverlined,
        superscripted: isSuperscripted,
        subscripted: isSubscripted,
        foreground: foreground,
        background: background,
        underlineColor: underlineColor,
      );

  @override
  String get _objectTypeName => '$SgrStackedState';
}
