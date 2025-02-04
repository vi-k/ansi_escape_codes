part of '../parsers.dart';

sealed class AnsiState<T extends AnsiState<T>> {
  const AnsiState();

  AnsiForegroundColor get foregroundColor;

  bool get foregroundColorIsDefault;

  AnsiBackgroundColor get backgroundColor;

  bool get backgroundColorIsDefault;

  AnsiUnderlineColor get underlineColor;

  bool get underlineColorIsDefault;

  AnsiIntensityStyle get intensityStyle;

  bool get isBold;

  bool get isFaint;

  bool get isNormalIntensity;

  AnsiItalicStyle get italicStyle;

  bool get isItalic;

  bool get isNotItalic;

  AnsiUnderlineStyle get underlineStyle;

  bool get isUnderline;

  bool get isDoubleUnderlined;

  bool get isNotUnderlined;

  AnsiBlinkStyle get blinkStyle;

  bool get isBlink;

  bool get isRapidBlink;

  bool get isNotBlinking;

  AnsiReverseStyle get reverseStyle;

  bool get isReversed;

  bool get isNotReversed;

  AnsiConcealStyle get concealStyle;

  bool get isConceal;

  bool get isReveal;

  AnsiCrossedOutStyle get crossedOutStyle;

  bool get isCrossedOut;

  bool get isNotCrossedOut;

  AnsiFramedStyle get framedStyle;

  bool get isFramed;

  bool get isEncircled;

  bool get isNeitherFramedNorEncircled;

  AnsiOverlinedStyle get overlinedStyle;

  bool get isOverlined;

  bool get isNotOverlined;

  AnsiSuperAndSubsriptStyle get superAndSubscriptStyle;

  bool get isSuperscript;

  bool get isSubscript;

  bool get isNeitherSuperscriptNorSubscript;

  String get asString;

  AnsiPlainState changeDefaultsTo(AnsiState other) => AnsiPlainState._(
        foregroundColor: foregroundColor is AnsiForegroundDefault
            ? other.foregroundColor
            : foregroundColor,
        backgroundColor: backgroundColor is AnsiBackgroundDefault
            ? other.backgroundColor
            : backgroundColor,
        underlineColor: underlineColor is AnsiUnderlineDefault
            ? other.underlineColor
            : underlineColor,
        intensityStyle: intensityStyle is AnsiNormalIntensity
            ? other.intensityStyle
            : intensityStyle,
        italicStyle:
            italicStyle is AnsiNotItalic ? other.italicStyle : italicStyle,
        underlineStyle: underlineStyle is AnsiNotUnderlined
            ? other.underlineStyle
            : underlineStyle,
        blinkStyle:
            blinkStyle is AnsiNotBlinking ? other.blinkStyle : blinkStyle,
        reverseStyle:
            reverseStyle is AnsiNotReversed ? other.reverseStyle : reverseStyle,
        concealStyle:
            concealStyle is AnsiReveal ? other.concealStyle : concealStyle,
        crossedOutStyle: crossedOutStyle is AnsiNotCrossedOut
            ? other.crossedOutStyle
            : crossedOutStyle,
        framedStyle: framedStyle is AnsiNeitherFramedNorEncircled
            ? other.framedStyle
            : framedStyle,
        overlinedStyle: overlinedStyle is AnsiNotOverlined
            ? other.overlinedStyle
            : overlinedStyle,
        superAndSubscriptStyle:
            superAndSubscriptStyle is AnsiNeitherSuperscriptNorSubscript
                ? other.superAndSubscriptStyle
                : superAndSubscriptStyle,
      );

  String transitTo(AnsiState other) {
    final list = <AnsiSgr>[
      if (foregroundColor != other.foregroundColor) other.foregroundColor,
      if (backgroundColor != other.backgroundColor) other.backgroundColor,
      if (underlineColor != other.underlineColor) other.underlineColor,
      if (intensityStyle != other.intensityStyle) other.intensityStyle,
      if (italicStyle != other.italicStyle) other.italicStyle,
      if (underlineStyle != other.underlineStyle) other.underlineStyle,
      if (blinkStyle != other.blinkStyle) other.blinkStyle,
      if (reverseStyle != other.reverseStyle) other.reverseStyle,
      if (concealStyle != other.concealStyle) other.concealStyle,
      if (crossedOutStyle != other.crossedOutStyle) other.crossedOutStyle,
      if (framedStyle != other.framedStyle) other.framedStyle,
      if (overlinedStyle != other.overlinedStyle) other.overlinedStyle,
      if (superAndSubscriptStyle != other.superAndSubscriptStyle)
        other.superAndSubscriptStyle,
    ];

    return list.map((e) => e.string).join();
  }

  T copyWith({
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
  });

  String get _objectTypeName;

  @override
  String toString() => '$_objectTypeName('
      'foreground: $foregroundColor'
      ', background: $backgroundColor'
      ', underline: $underlineColor'
      ', intensityStyle: $intensityStyle'
      ', italicStyle: $italicStyle'
      ', underlineStyle: $underlineStyle'
      ', blinkStyle: $blinkStyle'
      ', reverseStyle: $reverseStyle'
      ', concealStyle: $concealStyle'
      ', crossedOutStyle: $crossedOutStyle'
      ', framedStyle: $framedStyle'
      ', overlinedStyle: $overlinedStyle'
      ', superAndSubscriptStyle: $superAndSubscriptStyle'
      ')';
}
