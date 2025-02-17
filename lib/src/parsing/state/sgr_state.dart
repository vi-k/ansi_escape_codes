import 'package:meta/meta.dart';

import '../../controls/c1.dart';
import '../../controls/csi.dart';
import '../../controls/sgr.dart';
import '../../predefined_values/sgr/sgr.dart';
import '../colors/color.dart';

part 'sgr_plain_state.dart';
part 'sgr_stacked_state.dart';

@immutable
sealed class SgrState<S extends SgrState<S>> {
  const SgrState();

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

  Color? get foreground;

  Color? get background;

  ExtendedColor? get underlineColor;

  S resetAll();

  S setBold();

  S setFaint();

  S resetBoldAndFaint();

  S setItalicized();

  S resetItalicized();

  S setSinglyUnderlined();

  S setDoublyUnderlined();

  S resetUnderlined();

  S setSlowlyBlinking();

  S setRapidlyBlinking();

  S resetBlinking();

  S setNegative();

  S resetNegative();

  S setConcealed();

  S resetConcealed();

  S setCrossedOut();

  S resetCrossedOut();

  S setFramed();

  S setEncircled();

  S resetFramedAndEncircled();

  S setOverlined();

  S resetOverlined();

  S setSuperscripted();

  S setSubscripted();

  S resetSuperscriptedAndSubscripted();

  S setForeground(Color color);

  S resetForeground();

  S setBackground(Color color);

  S resetBackground();

  S setUnderlineColor(ExtendedColor color);

  S resetUnderlineColor();

  String transitTo(
    SgrState<void> other, {
    bool skipSet = false,
    bool skipReset = false,
  }) {
    if ((this as SgrState<void>) != SgrPlainState.defaults &&
        other == SgrPlainState.defaults) {
      return skipReset ? '' : reset;
    }

    final otherForeground = other.foreground;
    final otherBackground = other.background;
    final otherUnderlineColor = other.underlineColor;
    final otherUnderlinedStyle = other.underlinedStyle;
    final otherBlinkingStyle = other.blinkingStyle;
    final otherFramedStyle = other.framedStyle;
    final otherScriptedStyle = other.scriptedStyle;

    final resetParams = skipReset
        ? const <int>[]
        : <int>[
            // Colors.
            if (foreground != otherForeground && otherForeground == null)
              _colorIndex(30, 90, null),
            if (background != otherBackground && otherBackground == null)
              _colorIndex(40, 100, null),
            if (underlineColor != otherUnderlineColor &&
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
            if (foreground != otherForeground &&
                otherForeground is ExtendedColor)
              _color(30, 90, otherForeground),
            if (background != otherBackground &&
                otherBackground is ExtendedColor)
              _color(40, 100, otherBackground),
            if (underlineColor != otherUnderlineColor &&
                otherUnderlineColor != null)
              _color(50, 0, otherUnderlineColor),
          ].join();

    final setParams = skipSet
        ? const <int>[]
        : <int>[
            // Colors.
            if (foreground != otherForeground && otherForeground is Color16)
              _colorIndex(30, 90, otherForeground),
            if (background != otherBackground && otherBackground is Color16)
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

  SgrPlainState changeDefaultsTo(SgrState other) => SgrPlainState(
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
        foreground: foreground ?? other.foreground,
        background: background ?? other.background,
        underlineColor: underlineColor ?? other.underlineColor,
      );

  SgrPlainState toPlainState();

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
        foreground,
        background,
        underlineColor,
      );

  @override
  bool operator ==(Object other) =>
      other is SgrState &&
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
      foreground == other.foreground &&
      background == other.background &&
      underlineColor == other.underlineColor;

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
      if (foreground != null) 'foreground: $foreground',
      if (background != null) 'background: $background',
      if (underlineColor != null) 'underlineColor: $underlineColor',
    ];

    return values.join(', ');
  }

  @override
  String toString() => '$_objectTypeName(${toShortString()})';
}
