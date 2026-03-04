import 'package:meta/meta.dart';

import '../../ansi/c1.dart';
import '../../ansi/csi.dart';
import '../../ansi/sgr.dart';
import '../../ready_to_use/sgr/sgr.dart' as sgr;
import '../colors/color.dart';
import '../parser/parser.dart';

part 'style.dart';
part 'stack.dart';

/// The base class for tracking the state of ANSI escape codes.
///
/// This class represents a set of applied text styles and colors. Subclasses
/// like [Style] and [Stack] provide specific mechanisms for how these
/// properties are maintained.
@immutable
sealed class State<S extends State<S>> {
  const State();

  bool get isBold;

  bool get isFaint;

  bool get isItalicized;

  bool get isSinglyUnderlined;

  bool get isDoublyUnderlined;

  UnderlinedStyle? get underlinedStyle;

  bool get isSlowlyBlinking;

  bool get isRapidlyBlinking;

  BlinkingStyle? get blinkingStyle;

  bool get isNegative;

  bool get isConcealed;

  bool get isCrossedOut;

  bool get isFramed;

  bool get isEncircled;

  FramedStyle? get framedStyle;

  bool get isOverlined;

  bool get isSuperscripted;

  bool get isSubscripted;

  ScriptedStyle? get scriptedStyle;

  Color? get colorOfForeground;

  Color? get colorOfBackground;

  ExtendedColor? get colorOfUnderline;

  S get bold;
  S get faint;
  S get italic;
  S get underline;
  S get doublyUnderline;
  S get slowlyBlink;
  S get rapidlyBlink;
  S get negative;
  S get conceal;
  S get crossOut;
  S get frame;
  S get encircle;
  S get overline;
  S get superscript;
  S get subscript;

  S foreground(Color color);
  S background(Color color);
  S underlineColor(ExtendedColor color);

  S get reset;
  S get resetBoldAndFaint;
  S get resetItalicized;
  S get resetUnderlined;
  S get resetBlinking;
  S get resetNegative;
  S get resetConcealed;
  S get resetCrossedOut;
  S get resetFramedAndEncircled;
  S get resetOverlined;
  S get resetSuperscriptedAndSubscripted;
  S get resetForeground;
  S get resetBackground;
  S get resetUnderlineColor;

  String transitTo(
    State<void> other, {
    bool skipSet = false,
    bool skipReset = false,
  }) {
    if (other == Style.defaults) {
      return skipReset || (this as State<void>) == Style.defaults
          ? ''
          : sgr.reset;
    }

    final otherForeground = other.colorOfForeground;
    final otherBackground = other.colorOfBackground;
    final otherUnderlineColor = other.colorOfUnderline;
    final otherUnderlinedStyle = other.underlinedStyle;
    final otherBlinkingStyle = other.blinkingStyle;
    final otherFramedStyle = other.framedStyle;
    final otherScriptedStyle = other.scriptedStyle;

    final resetParams = skipReset
        ? const <int>[]
        : <int>[
            // Colors.
            if (colorOfForeground != otherForeground && otherForeground == null)
              _colorIndex(30, 90, null),
            if (colorOfBackground != otherBackground && otherBackground == null)
              _colorIndex(40, 100, null),
            if (colorOfUnderline != otherUnderlineColor &&
                otherUnderlineColor == null)
              59,
            // Bold and faint.
            if (isBold && !other.isBold || isFaint && !other.isFaint) 22,
            // Italicized.
            if (isItalicized && !other.isItalicized) 23,
            // Underlined.
            if (underlinedStyle != otherUnderlinedStyle &&
                otherUnderlinedStyle == null)
              24,
            // Blinking.
            if (blinkingStyle != otherBlinkingStyle &&
                otherBlinkingStyle == null)
              25,
            // Negative.
            if (isNegative && !other.isNegative) 27,
            // Concealed.
            if (isConcealed && !other.isConcealed) 28,
            // Crossed out.
            if (isCrossedOut && !other.isCrossedOut) 29,
            // Framed and encircled.
            if (framedStyle != otherFramedStyle && otherFramedStyle == null) 54,
            // Overlined.
            if (isOverlined && !other.isOverlined) 55,
            // Superscripted and subscripted.
            if (scriptedStyle != otherScriptedStyle &&
                otherScriptedStyle == null)
              75,
          ];

    final extColorsSetParams = skipSet
        ? ''
        : <String>[
            if (colorOfForeground != otherForeground &&
                otherForeground is ExtendedColor)
              _color(30, 90, otherForeground),
            if (colorOfBackground != otherBackground &&
                otherBackground is ExtendedColor)
              _color(40, 100, otherBackground),
            if (colorOfUnderline != otherUnderlineColor &&
                otherUnderlineColor != null)
              _color(50, 0, otherUnderlineColor),
          ].join();

    final setParams = skipSet
        ? const <int>[]
        : <int>[
            // Colors.
            if (colorOfForeground != otherForeground &&
                otherForeground is Color16)
              _colorIndex(30, 90, otherForeground),
            if (colorOfBackground != otherBackground &&
                otherBackground is Color16)
              _colorIndex(40, 100, otherBackground),
            // Bold and faint.
            if (isBold && !other.isBold || isFaint && !other.isFaint) ...[
              if (other.isBold) 1,
              if (other.isFaint) 2,
            ] else ...[
              if (!isBold && other.isBold) 1,
              if (!isFaint && other.isFaint) 2,
            ],
            // Italicized.
            if (!isItalicized && other.isItalicized) 3,
            // Underlined.
            if (underlinedStyle != otherUnderlinedStyle &&
                otherUnderlinedStyle != null)
              switch (otherUnderlinedStyle) {
                UnderlinedStyle.singly => 4,
                UnderlinedStyle.doubly => 21,
              },
            // Blinking.
            if (blinkingStyle != otherBlinkingStyle &&
                otherBlinkingStyle != null)
              switch (otherBlinkingStyle) {
                BlinkingStyle.slowly => 5,
                BlinkingStyle.rapidly => 6,
              },
            // Negative.
            if (!isNegative && other.isNegative) 7,
            // Concealed.
            if (!isConcealed && other.isConcealed) 8,
            // Crossed out.
            if (!isCrossedOut && other.isCrossedOut) 9,
            // Framed and encircled.
            if (framedStyle != otherFramedStyle && otherFramedStyle != null)
              switch (otherFramedStyle) {
                FramedStyle.framed => 51,
                FramedStyle.encircled => 52,
              },
            // Overlined.
            if (!isOverlined && other.isOverlined) 53,
            // Superscripted and subscripted.
            if (scriptedStyle != otherScriptedStyle &&
                otherScriptedStyle != null)
              switch (otherScriptedStyle) {
                ScriptedStyle.superscripted => 73,
                ScriptedStyle.subscripted => 74,
              },
          ];

    return extColorsSetParams.isEmpty
        ? resetParams.isEmpty && setParams.isEmpty
            ? ''
            : '$CSI${[...resetParams, ...setParams].join(';')}$SGR'
        : '${resetParams.isEmpty ? '' : '$CSI${resetParams.join(';')}$SGR'}'
            '$extColorsSetParams'
            '${setParams.isEmpty ? '' : '$CSI${setParams.join(';')}$SGR'}';
  }

  Style changeDefaultsTo(State other) => Style(
        bold: isBold || other.isBold,
        faint: isFaint || other.isFaint,
        italicized: isItalicized || other.isItalicized,
        singlyUnderlined: underlinedStyle == UnderlinedStyle.singly ||
            underlinedStyle == null &&
                other.underlinedStyle == UnderlinedStyle.singly,
        doublyUnderlined: underlinedStyle == UnderlinedStyle.doubly ||
            underlinedStyle == null &&
                other.underlinedStyle == UnderlinedStyle.doubly,
        slowlyBlinking: blinkingStyle == BlinkingStyle.slowly ||
            blinkingStyle == null &&
                other.blinkingStyle == BlinkingStyle.slowly,
        rapidlyBlinking: blinkingStyle == BlinkingStyle.rapidly ||
            blinkingStyle == null &&
                other.blinkingStyle == BlinkingStyle.rapidly,
        negative: isNegative || other.isNegative,
        concealed: isConcealed || other.isConcealed,
        crossedOut: isCrossedOut || other.isCrossedOut,
        framed: framedStyle == FramedStyle.framed ||
            framedStyle == null && other.framedStyle == FramedStyle.framed,
        encircled: framedStyle == FramedStyle.encircled ||
            framedStyle == null && other.framedStyle == FramedStyle.encircled,
        overlined: isOverlined || other.isOverlined,
        superscripted: scriptedStyle == ScriptedStyle.superscripted ||
            scriptedStyle == null &&
                other.scriptedStyle == ScriptedStyle.superscripted,
        subscripted: scriptedStyle == ScriptedStyle.subscripted ||
            scriptedStyle == null &&
                other.scriptedStyle == ScriptedStyle.subscripted,
        foreground: colorOfForeground ?? other.colorOfForeground,
        background: colorOfBackground ?? other.colorOfBackground,
        underlineColor: colorOfUnderline ?? other.colorOfUnderline,
      );

  Style toStyle();

  int _colorIndex(int offset, int highOffset, Color16? color) =>
      switch (color) {
        Color16() => color.index(offset, highOffset),
        null => offset + 9,
      };

  String _color(int offset, int highOffset, ExtendedColor color) =>
      switch (color) {
        Color256(:final index) => '$CSI${offset + 8};$COLOR_256;$index$SGR',
        ColorRgb(:final r, :final g, :final b) =>
          '$CSI${offset + 8};$COLOR_RGB;$r;$g;$b$SGR',
      };

  @override
  int get hashCode => Object.hash(
        isBold,
        isFaint,
        isItalicized,
        isSinglyUnderlined,
        isDoublyUnderlined,
        isSlowlyBlinking,
        isRapidlyBlinking,
        isNegative,
        isConcealed,
        isCrossedOut,
        isFramed,
        isEncircled,
        isOverlined,
        isSuperscripted,
        isSubscripted,
        colorOfForeground,
        colorOfBackground,
        colorOfUnderline,
      );

  @override
  bool operator ==(Object other) =>
      other is State<void> &&
      isBold == other.isBold &&
      isFaint == other.isFaint &&
      isItalicized == other.isItalicized &&
      isSinglyUnderlined == other.isSinglyUnderlined &&
      isDoublyUnderlined == other.isDoublyUnderlined &&
      isSlowlyBlinking == other.isSlowlyBlinking &&
      isRapidlyBlinking == other.isRapidlyBlinking &&
      isNegative == other.isNegative &&
      isConcealed == other.isConcealed &&
      isCrossedOut == other.isCrossedOut &&
      isFramed == other.isFramed &&
      isEncircled == other.isEncircled &&
      isOverlined == other.isOverlined &&
      isSuperscripted == other.isSuperscripted &&
      isSubscripted == other.isSubscripted &&
      colorOfForeground == other.colorOfForeground &&
      colorOfBackground == other.colorOfBackground &&
      colorOfUnderline == other.colorOfUnderline;

  String get _objectTypeName;

  String toShortString() {
    final values = [
      if (isBold) 'bold',
      if (isFaint) 'faint',
      if (isItalicized) 'italicized',
      if (isSinglyUnderlined) 'singlyUnderlined',
      if (isDoublyUnderlined) 'doublyUnderlined',
      if (isSlowlyBlinking) 'slowlyBlinking',
      if (isRapidlyBlinking) 'rapidlyBlinking',
      if (isNegative) 'negative',
      if (isConcealed) 'concealed',
      if (isCrossedOut) 'crossedOut',
      if (isFramed) 'framed',
      if (isEncircled) 'encircled',
      if (isOverlined) 'overlined',
      if (isSuperscripted) 'superscripted',
      if (isSubscripted) 'subscripted',
      if (colorOfForeground != null) 'foreground: $colorOfForeground',
      if (colorOfBackground != null) 'background: $colorOfBackground',
      if (colorOfUnderline != null) 'underlineColor: $colorOfUnderline',
    ];

    return values.join(', ');
  }

  @override
  String toString() => '$_objectTypeName(${toShortString()})';
}
