part of '../parsers.dart';

final class AnsiStackedState extends AnsiState<AnsiStackedState> {
  final List<AnsiForegroundColor> _foregroundStack;
  final List<AnsiBackgroundColor> _backgroundStack;
  final List<AnsiUnderlineColor> _underlineColorStack;
  final List<AnsiIntensityStyle> _intensityStack;
  final int _italicCounter;
  final List<AnsiUnderlineStyle> _underlineStack;
  final List<AnsiBlinkStyle> _blinkStack;
  final int _reverseCounter;
  final int _concealCounter;
  final int _crossedOutCounter;
  final List<AnsiFramedStyle> _framedStack;
  final int _overlinedCounter;
  final List<AnsiSuperAndSubsriptStyle> _superAndSubscriptStack;

  const AnsiStackedState()
      : _foregroundStack = const [],
        _backgroundStack = const [],
        _underlineColorStack = const [],
        _intensityStack = const [],
        _italicCounter = 0,
        _underlineStack = const [],
        _blinkStack = const [],
        _reverseCounter = 0,
        _concealCounter = 0,
        _crossedOutCounter = 0,
        _framedStack = const [],
        _overlinedCounter = 0,
        _superAndSubscriptStack = const [];

  AnsiStackedState._({
    required List<AnsiForegroundColor> foregroundStack,
    required List<AnsiBackgroundColor> backgroundStack,
    required List<AnsiUnderlineColor> underlineColorStack,
    required List<AnsiIntensityStyle> intensityStack,
    required int italicCounter,
    required List<AnsiUnderlineStyle> underlineStack,
    required List<AnsiBlinkStyle> blinkStack,
    required int reverseCounter,
    required int concealCounter,
    required int crossedOutCounter,
    required List<AnsiFramedStyle> framedStack,
    required int overlinedCounter,
    required List<AnsiSuperAndSubsriptStyle> superAndSubscriptStack,
  })  : _foregroundStack = foregroundStack,
        _backgroundStack = backgroundStack,
        _underlineColorStack = underlineColorStack,
        _intensityStack = intensityStack,
        _italicCounter = italicCounter,
        _underlineStack = underlineStack,
        _blinkStack = blinkStack,
        _reverseCounter = reverseCounter,
        _concealCounter = concealCounter,
        _crossedOutCounter = crossedOutCounter,
        _framedStack = framedStack,
        _overlinedCounter = overlinedCounter,
        _superAndSubscriptStack = superAndSubscriptStack;

  static const AnsiStackedState defaults = AnsiStackedState();

  @override
  AnsiForegroundColor get foregroundColor => _foregroundStack.isEmpty
      ? const AnsiForegroundDefault()
      : _foregroundStack.last;

  @override
  bool get foregroundColorIsDefault => _foregroundStack.isEmpty;

  @override
  AnsiBackgroundColor get backgroundColor => _backgroundStack.isEmpty
      ? const AnsiBackgroundDefault()
      : _backgroundStack.last;

  @override
  bool get backgroundColorIsDefault => _backgroundStack.isEmpty;

  @override
  AnsiUnderlineColor get underlineColor => _underlineColorStack.isEmpty
      ? const AnsiUnderlineDefault()
      : _underlineColorStack.last;

  @override
  bool get underlineColorIsDefault => _underlineColorStack.isEmpty;

  @override
  AnsiIntensityStyle get intensityStyle => switch (_intensityStack.isEmpty) {
        true => const AnsiNormalIntensity(),
        false => _intensityStack.last,
      };

  @override
  bool get isBold =>
      _intensityStack.isNotEmpty && _intensityStack.last is AnsiBold;

  @override
  bool get isFaint =>
      _intensityStack.isNotEmpty && _intensityStack.last is AnsiFaint;

  @override
  bool get isNormalIntensity => _intensityStack.isEmpty;

  @override
  AnsiItalicStyle get italicStyle =>
      isItalic ? const AnsiItalic() : const AnsiNotItalic();

  @override
  bool get isItalic => _italicCounter > 0;

  @override
  bool get isNotItalic => _italicCounter == 0;

  @override
  AnsiUnderlineStyle get underlineStyle => switch (_underlineStack.isEmpty) {
        true => const AnsiNotUnderlined(),
        false => _underlineStack.last,
      };

  @override
  bool get isUnderline =>
      _underlineStack.isNotEmpty && _underlineStack.last is AnsiUnderline;

  @override
  bool get isDoubleUnderlined =>
      _underlineStack.isNotEmpty &&
      _underlineStack.last is AnsiDoublyUnderlined;

  @override
  bool get isNotUnderlined => _underlineStack.isEmpty;

  @override
  AnsiBlinkStyle get blinkStyle => switch (_blinkStack.isEmpty) {
        true => const AnsiNotBlinking(),
        false => _blinkStack.last,
      };

  @override
  bool get isBlink => _blinkStack.isNotEmpty && _blinkStack.last is AnsiBlink;

  @override
  bool get isRapidBlink =>
      _blinkStack.isNotEmpty && _blinkStack.last is AnsiRapidBlink;

  @override
  bool get isNotBlinking => _blinkStack.isEmpty;

  @override
  AnsiReverseStyle get reverseStyle =>
      isReversed ? const AnsiReverse() : const AnsiNotReversed();

  @override
  bool get isReversed => _reverseCounter > 0;

  @override
  bool get isNotReversed => _reverseCounter == 0;

  @override
  AnsiConcealStyle get concealStyle =>
      isConceal ? const AnsiConceal() : const AnsiReveal();

  @override
  bool get isConceal => _concealCounter > 0;

  @override
  bool get isReveal => _concealCounter == 0;

  @override
  AnsiCrossedOutStyle get crossedOutStyle =>
      isCrossedOut ? const AnsiCrossedOut() : const AnsiNotCrossedOut();

  @override
  bool get isCrossedOut => _crossedOutCounter > 0;

  @override
  bool get isNotCrossedOut => _crossedOutCounter == 0;

  @override
  AnsiFramedStyle get framedStyle => switch (_framedStack.isEmpty) {
        true => const AnsiNeitherFramedNorEncircled(),
        false => _framedStack.last,
      };

  @override
  bool get isFramed =>
      _framedStack.isNotEmpty && _framedStack.last is AnsiFramed;

  @override
  bool get isEncircled =>
      _framedStack.isNotEmpty && _framedStack.last is AnsiEncircled;

  @override
  bool get isNeitherFramedNorEncircled => _framedStack.isEmpty;

  @override
  AnsiOverlinedStyle get overlinedStyle =>
      isOverlined ? const AnsiOverlined() : const AnsiNotOverlined();

  @override
  bool get isOverlined => _overlinedCounter > 0;

  @override
  bool get isNotOverlined => _overlinedCounter == 0;

  @override
  AnsiSuperAndSubsriptStyle get superAndSubscriptStyle =>
      switch (_superAndSubscriptStack.isEmpty) {
        true => const AnsiNeitherSuperscriptNorSubscript(),
        false => _superAndSubscriptStack.last,
      };

  @override
  bool get isSuperscript =>
      _superAndSubscriptStack.isNotEmpty &&
      _superAndSubscriptStack.last is AnsiSuperscript;

  @override
  bool get isSubscript =>
      _superAndSubscriptStack.isNotEmpty &&
      _superAndSubscriptStack.last is AnsiSubscript;

  @override
  bool get isNeitherSuperscriptNorSubscript => _superAndSubscriptStack.isEmpty;

  @override
  String get asString => '${foregroundColor.string}'
      '${backgroundColor.string}'
      '${underlineColor.string}'
      '${intensityStyle.string}'
      '${italicStyle.string}'
      '${underlineStyle.string}'
      '${blinkStyle.string}'
      '${reverseStyle.string}'
      '${concealStyle.string}'
      '${crossedOutStyle.string}'
      '${framedStyle.string}'
      '${overlinedStyle.string}'
      '${superAndSubscriptStyle.string}';

  AnsiPlainState toPlainState() => AnsiPlainState._(
        foregroundColor: foregroundColor,
        backgroundColor: backgroundColor,
        underlineColor: underlineColor,
        intensityStyle: intensityStyle,
        italicStyle: italicStyle,
        underlineStyle: underlineStyle,
        blinkStyle: blinkStyle,
        reverseStyle: reverseStyle,
        concealStyle: concealStyle,
        crossedOutStyle: crossedOutStyle,
        framedStyle: framedStyle,
        overlinedStyle: overlinedStyle,
        superAndSubscriptStyle: superAndSubscriptStyle,
      );
  // @override
  // String get asStringOnlyNonDefaults {
  //   final list = <AnsiSgr>[
  //     if (_foregroundStack.isNotEmpty) _foregroundStack.last,
  //     if (_backgroundStack.isNotEmpty) _backgroundStack.last,
  //     if (_underlineColorStack.isNotEmpty) _underlineColorStack.last,
  //     if (_intensityStack.isNotEmpty) _intensityStack.last,
  //     if (_italicCounter > 0) const AnsiItalic(),
  //     if (_underlineStack.isNotEmpty) _underlineStack.last,
  //     if (_blinkStack.isNotEmpty) _blinkStack.last,
  //     if (_reverseCounter > 0) const AnsiReverse(),
  //     if (_concealCounter > 0) const AnsiConceal(),
  //     if (_crossedOutCounter > 0) const AnsiCrossedOut(),
  //     if (_framedStack.isNotEmpty) _framedStack.last,
  //     if (_overlinedCounter > 0) const AnsiOverlined(),
  //     if (_superAndSubscriptStack.isNotEmpty) _superAndSubscriptStack.last,
  //   ];

  //   return list.map((e) => e.string).join();
  // }

  List<T> _restack<T extends AnsiSgr>(T? ansi, bool isDefault, List<T> stack) {
    if (ansi == null) {
      return stack;
    }

    final clone = List.of(stack);

    if (isDefault) {
      clone.removeLast();
    } else {
      clone.add(ansi);
    }

    return List.unmodifiable(clone);
  }

  @override
  AnsiStackedState copyWith({
    AnsiForegroundColor? foregroundColor,
    AnsiBackgroundColor? backgroundColor,
    AnsiUnderlineColor? underlineColor,
    AnsiIntensityStyle? intensityStyle,
    AnsiItalicStyle? italicStyle,
    AnsiUnderlineStyle? underlineStyle,
    AnsiBlinkStyle? blinkStyle,
    AnsiReverseStyle? reverseStyle,
    AnsiConcealStyle? concealStyle,
    AnsiCrossedOutStyle? crossedOutStyle,
    AnsiFramedStyle? framedStyle,
    AnsiOverlinedStyle? overlinedStyle,
    AnsiSuperAndSubsriptStyle? superAndSubscriptStyle,
  }) =>
      AnsiStackedState._(
        foregroundStack: _restack(
          foregroundColor,
          foregroundColor is AnsiForegroundDefault,
          _foregroundStack,
        ),
        backgroundStack: _restack(
          backgroundColor,
          backgroundColor is AnsiBackgroundDefault,
          _backgroundStack,
        ),
        underlineColorStack: _restack(
          underlineColor,
          underlineColor is AnsiUnderlineDefault,
          _underlineColorStack,
        ),
        intensityStack: _restack(
          intensityStyle,
          intensityStyle is AnsiNormalIntensity,
          _intensityStack,
        ),
        italicCounter:
            italicStyle is AnsiItalic ? _italicCounter + 1 : _italicCounter - 1,
        underlineStack: _restack(
          underlineStyle,
          underlineStyle is AnsiNotUnderlined,
          _underlineStack,
        ),
        blinkStack: _restack(
          blinkStyle,
          blinkStyle is AnsiNotBlinking,
          _blinkStack,
        ),
        reverseCounter: reverseStyle is AnsiReverse
            ? _reverseCounter + 1
            : _reverseCounter - 1,
        concealCounter: concealStyle is AnsiConceal
            ? _concealCounter + 1
            : _concealCounter - 1,
        crossedOutCounter: crossedOutStyle is AnsiCrossedOut
            ? _crossedOutCounter + 1
            : _crossedOutCounter - 1,
        framedStack: _restack(
          framedStyle,
          framedStyle is AnsiNeitherFramedNorEncircled,
          _framedStack,
        ),
        overlinedCounter: overlinedStyle is AnsiOverlined
            ? _overlinedCounter + 1
            : _overlinedCounter - 1,
        superAndSubscriptStack: _restack(
          superAndSubscriptStyle,
          superAndSubscriptStyle is AnsiNeitherSuperscriptNorSubscript,
          _superAndSubscriptStack,
        ),
      );

  @override
  String get _objectTypeName => '$AnsiStackedState';
}
