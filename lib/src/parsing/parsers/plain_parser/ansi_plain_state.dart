part of '../parsers.dart';

final class AnsiPlainState extends AnsiState<AnsiPlainState> {
  @override
  final AnsiForegroundColor foregroundColor;

  @override
  final AnsiBackgroundColor backgroundColor;

  @override
  final AnsiUnderlineColor underlineColor;

  @override
  final AnsiIntensityStyle intensityStyle;

  @override
  final AnsiItalicStyle italicStyle;

  @override
  final AnsiUnderlineStyle underlineStyle;

  @override
  final AnsiBlinkStyle blinkStyle;

  @override
  final AnsiReverseStyle reverseStyle;

  @override
  final AnsiConcealStyle concealStyle;

  @override
  final AnsiCrossedOutStyle crossedOutStyle;

  @override
  final AnsiFramedStyle framedStyle;

  @override
  final AnsiOverlinedStyle overlinedStyle;

  @override
  final AnsiSuperAndSubsriptStyle superAndSubscriptStyle;

  const AnsiPlainState({
    this.foregroundColor = const AnsiForegroundDefault(),
    this.backgroundColor = const AnsiBackgroundDefault(),
    this.underlineColor = const AnsiUnderlineDefault(),
    this.intensityStyle = const AnsiNormalIntensity(),
    bool italic = false,
    this.underlineStyle = const AnsiNotUnderlined(),
    this.blinkStyle = const AnsiNotBlinking(),
    bool reverse = false,
    bool conceal = false,
    bool crossedOut = false,
    this.framedStyle = const AnsiNeitherFramedNorEncircled(),
    bool overlined = false,
    this.superAndSubscriptStyle = const AnsiNeitherSuperscriptNorSubscript(),
  })  : italicStyle = italic ? const AnsiItalic() : const AnsiNotItalic(),
        reverseStyle = reverse ? const AnsiReverse() : const AnsiNotReversed(),
        concealStyle = conceal ? const AnsiConceal() : const AnsiReveal(),
        crossedOutStyle =
            crossedOut ? const AnsiCrossedOut() : const AnsiNotCrossedOut(),
        overlinedStyle =
            overlined ? const AnsiOverlined() : const AnsiNotOverlined();

  const AnsiPlainState._({
    required this.foregroundColor,
    required this.backgroundColor,
    required this.underlineColor,
    required this.intensityStyle,
    required this.italicStyle,
    required this.underlineStyle,
    required this.blinkStyle,
    required this.reverseStyle,
    required this.concealStyle,
    required this.crossedOutStyle,
    required this.framedStyle,
    required this.overlinedStyle,
    required this.superAndSubscriptStyle,
  });

  static const AnsiPlainState defaults = AnsiPlainState();

  @override
  bool get foregroundColorIsDefault => foregroundColor is AnsiForegroundDefault;

  @override
  bool get backgroundColorIsDefault => backgroundColor is AnsiBackgroundDefault;

  @override
  bool get underlineColorIsDefault => underlineColor is AnsiUnderlineDefault;

  @override
  bool get isBold => intensityStyle is AnsiBold;

  @override
  bool get isFaint => intensityStyle is AnsiFaint;

  @override
  bool get isNormalIntensity => intensityStyle is AnsiNormalIntensity;

  @override
  bool get isItalic => italicStyle is AnsiItalic;

  @override
  bool get isNotItalic => italicStyle is AnsiNotItalic;

  @override
  bool get isUnderline => underlineStyle is AnsiUnderline;

  @override
  bool get isDoubleUnderlined => underlineStyle is AnsiDoublyUnderlined;

  @override
  bool get isNotUnderlined => underlineStyle is AnsiNotUnderlined;

  @override
  bool get isBlink => blinkStyle is AnsiBlink;

  @override
  bool get isRapidBlink => blinkStyle is AnsiRapidBlink;

  @override
  bool get isNotBlinking => blinkStyle is AnsiNotBlinking;

  @override
  bool get isReversed => reverseStyle is AnsiReverse;

  @override
  bool get isNotReversed => reverseStyle is AnsiNotReversed;

  @override
  bool get isConceal => concealStyle is AnsiConceal;

  @override
  bool get isReveal => concealStyle is AnsiReveal;

  @override
  bool get isCrossedOut => crossedOutStyle is AnsiCrossedOut;

  @override
  bool get isNotCrossedOut => crossedOutStyle is AnsiNotCrossedOut;

  @override
  bool get isFramed => framedStyle is AnsiFramed;

  @override
  bool get isEncircled => framedStyle is AnsiEncircled;

  @override
  bool get isNeitherFramedNorEncircled =>
      framedStyle is AnsiNeitherFramedNorEncircled;

  @override
  bool get isOverlined => overlinedStyle is AnsiOverlined;

  @override
  bool get isNotOverlined => overlinedStyle is AnsiNotOverlined;

  @override
  bool get isSuperscript => superAndSubscriptStyle is AnsiSuperscript;

  @override
  bool get isSubscript => superAndSubscriptStyle is AnsiSubscript;

  @override
  bool get isNeitherSuperscriptNorSubscript =>
      superAndSubscriptStyle is AnsiNeitherSuperscriptNorSubscript;

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

  // @override
  // String get asStringOnlyNonDefaults {
  //   final list = <AnsiSgr>[
  //     if (!foregroundIsDefault) foreground,
  //     if (!backgroundIsDefault) background,
  //     if (!underlineColorIsDefault) underlineColor,
  //     if (!isNormalIntensity) intensityStyle,
  //     if (!isNotItalic) italicStyle,
  //     if (!isNotUnderlined) underlineStyle,
  //     if (!isNotBlinking) blinkStyle,
  //     if (!isNotReversed) reverseStyle,
  //     if (!isReveal) concealStyle,
  //     if (!isNotCrossedOut) crossedOutStyle,
  //     if (!isNeitherFramedNorEncircled) framedStyle,
  //     if (!isNotOverlined) overlinedStyle,
  //     if (!isNeitherSuperscriptNorSubscript) superAndSubscriptStyle,
  //   ];

  //   return list.map((e) => e.string).join();
  // }

  // String get asStringToDefaults {
  //   final list = <AnsiSgr>[
  //     if (!foregroundIsDefault) const AnsiForegroundDefault(),
  //     if (!backgroundIsDefault) const AnsiBackgroundDefault(),
  //     if (!underlineColorIsDefault) const AnsiUnderlineDefault(),
  //     if (!isNormalIntensity) const AnsiNormalIntensity(),
  //     if (!isNotItalic) const AnsiNotItalic(),
  //     if (!isNotUnderlined) const AnsiNotUnderlined(),
  //     if (!isNotBlinking) const AnsiNotBlinking(),
  //     if (!isNotReversed) const AnsiNotReversed(),
  //     if (!isReveal) const AnsiReveal(),
  //     if (!isNotCrossedOut) const AnsiNotCrossedOut(),
  //     if (!isNeitherFramedNorEncircled) const AnsiNeitherFramedNorEncircled(),
  //     if (!isNotOverlined) const AnsiNotOverlined(),
  //     if (!isNeitherSuperscriptNorSubscript)
  //       const AnsiNeitherSuperscriptNorSubscript(),
  //   ];

  //   return list.map((e) => e.string).join();
  // }

  @override
  AnsiPlainState copyWith({
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
      AnsiPlainState._(
        foregroundColor: foregroundColor ?? this.foregroundColor,
        backgroundColor: backgroundColor ?? this.backgroundColor,
        underlineColor: underlineColor ?? this.underlineColor,
        intensityStyle: intensityStyle ?? this.intensityStyle,
        italicStyle: italicStyle ?? this.italicStyle,
        underlineStyle: underlineStyle ?? this.underlineStyle,
        blinkStyle: blinkStyle ?? this.blinkStyle,
        reverseStyle: reverseStyle ?? this.reverseStyle,
        concealStyle: concealStyle ?? this.concealStyle,
        crossedOutStyle: crossedOutStyle ?? this.crossedOutStyle,
        framedStyle: framedStyle ?? this.framedStyle,
        overlinedStyle: overlinedStyle ?? this.overlinedStyle,
        superAndSubscriptStyle:
            superAndSubscriptStyle ?? this.superAndSubscriptStyle,
      );

  @override
  String get _objectTypeName => '$AnsiPlainState';
}
