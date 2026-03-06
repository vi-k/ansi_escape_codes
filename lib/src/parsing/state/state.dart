import 'package:meta/meta.dart';

import '../../ansi/c1.dart';
import '../../ansi/csi.dart';
import '../../ansi/sgr.dart';
import '../../ready_to_use/sgr/sgr.dart' as sgr;
import '../colors/color.dart';
import '../parser/parser.dart';

part 'style.dart';
part 'stack.dart';

@Deprecated('Use State instead')
typedef SgrState<S extends State<S>> = State<S>;

/// The base class for tracking the state of ANSI escape codes.
///
/// This class represents a set of applied text styles and colors. Subclasses
/// like [Style] and [Stack] provide specific mechanisms for how these
/// properties are maintained.
@immutable
sealed class State<S extends State<S>> {
  const State();

  bool get isBold;

  bool get isDim;

  bool get isItalic;

  bool get isUnderline;

  bool get isDoublyUnderline;

  UnderlineStyle? get underlineStyle;

  bool get isBlink;

  bool get isBlinkRapid;

  BlinkStyle? get blinkStyle;

  bool get isInverse;

  bool get isInvisible;

  bool get isStrikethrough;

  bool get isFrame;

  bool get isEncircle;

  FrameStyle? get frameStyle;

  bool get isOverline;

  bool get isSuperscript;

  bool get isSubscript;

  ScriptStyle? get scriptStyle;

  Color? get foregroundColor;

  Color? get backgroundColor;

  ExtendedColor? get underlineColorValue;

  S get bold;
  S get dim;
  S get italic;
  S get underline;
  S get doublyUnderline;
  S get blink;
  S get blinkRapid;
  S get inverse;
  S get invisible;
  S get strikethrough;
  S get frame;
  S get encircle;
  S get overline;
  S get superscript;
  S get subscript;

  S foreground(Color color);
  S background(Color color);
  S underlineColor(ExtendedColor color);

  S get reset;
  S get resetBoldAndDim;
  S get resetItalic;
  S get resetUnderline;
  S get resetBlink;
  S get resetInverse;
  S get resetInvisible;
  S get resetStrikethrough;
  S get resetFrameAndEncircle;
  S get resetOverline;
  S get resetSuperAndSubscript;
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

    final otherForeground = other.foregroundColor;
    final otherBackground = other.backgroundColor;
    final otherUnderlineColor = other.underlineColorValue;
    final otherUnderlineStyle = other.underlineStyle;
    final otherBlinkStyle = other.blinkStyle;
    final otherFrameStyle = other.frameStyle;
    final otherScriptStyle = other.scriptStyle;

    final resetParams = skipReset
        ? const <int>[]
        : <int>[
            if (foregroundColor != otherForeground && otherForeground == null)
              _colorIndex(30, 90, null),
            if (backgroundColor != otherBackground && otherBackground == null)
              _colorIndex(40, 100, null),
            if (underlineColorValue != otherUnderlineColor &&
                otherUnderlineColor == null)
              59,
            if (isBold && !other.isBold || isDim && !other.isDim) 22,
            if (isItalic && !other.isItalic) 23,
            if (underlineStyle != otherUnderlineStyle &&
                otherUnderlineStyle == null)
              24,
            if (blinkStyle != otherBlinkStyle && otherBlinkStyle == null) 25,
            if (isInverse && !other.isInverse) 27,
            if (isInvisible && !other.isInvisible) 28,
            if (isStrikethrough && !other.isStrikethrough) 29,
            if (frameStyle != otherFrameStyle && otherFrameStyle == null) 54,
            if (isOverline && !other.isOverline) 55,
            if (scriptStyle != otherScriptStyle && otherScriptStyle == null) 75,
          ];

    final extColorsSetParams = skipSet
        ? ''
        : <String>[
            if (foregroundColor != otherForeground &&
                otherForeground is ExtendedColor)
              _color(30, 90, otherForeground),
            if (backgroundColor != otherBackground &&
                otherBackground is ExtendedColor)
              _color(40, 100, otherBackground),
            if (underlineColorValue != otherUnderlineColor &&
                otherUnderlineColor != null)
              _color(50, 0, otherUnderlineColor),
          ].join();

    final setParams = skipSet
        ? const <int>[]
        : <int>[
            if (foregroundColor != otherForeground &&
                otherForeground is Color16)
              _colorIndex(30, 90, otherForeground),
            if (backgroundColor != otherBackground &&
                otherBackground is Color16)
              _colorIndex(40, 100, otherBackground),
            if (isBold && !other.isBold || isDim && !other.isDim) ...[
              if (other.isBold) 1,
              if (other.isDim) 2,
            ] else ...[
              if (!isBold && other.isBold) 1,
              if (!isDim && other.isDim) 2,
            ],
            if (!isItalic && other.isItalic) 3,
            if (underlineStyle != otherUnderlineStyle &&
                otherUnderlineStyle != null)
              switch (otherUnderlineStyle) {
                UnderlineStyle.singly => 4,
                UnderlineStyle.doubly => 21,
              },
            if (blinkStyle != otherBlinkStyle && otherBlinkStyle != null)
              switch (otherBlinkStyle) {
                BlinkStyle.slow => 5,
                BlinkStyle.rapid => 6,
              },
            if (!isInverse && other.isInverse) 7,
            if (!isInvisible && other.isInvisible) 8,
            if (!isStrikethrough && other.isStrikethrough) 9,
            if (frameStyle != otherFrameStyle && otherFrameStyle != null)
              switch (otherFrameStyle) {
                FrameStyle.frame => 51,
                FrameStyle.encircle => 52,
              },
            if (!isOverline && other.isOverline) 53,
            if (scriptStyle != otherScriptStyle && otherScriptStyle != null)
              switch (otherScriptStyle) {
                ScriptStyle.superscript => 73,
                ScriptStyle.subscript => 74,
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
        dim: isDim || other.isDim,
        italic: isItalic || other.isItalic,
        underline: underlineStyle == UnderlineStyle.singly ||
            underlineStyle == null &&
                other.underlineStyle == UnderlineStyle.singly,
        doublyUnderline: underlineStyle == UnderlineStyle.doubly ||
            underlineStyle == null &&
                other.underlineStyle == UnderlineStyle.doubly,
        blink: blinkStyle == BlinkStyle.slow ||
            blinkStyle == null && other.blinkStyle == BlinkStyle.slow,
        blinkRapid: blinkStyle == BlinkStyle.rapid ||
            blinkStyle == null && other.blinkStyle == BlinkStyle.rapid,
        inverse: isInverse || other.isInverse,
        invisible: isInvisible || other.isInvisible,
        strikethrough: isStrikethrough || other.isStrikethrough,
        frame: frameStyle == FrameStyle.frame ||
            frameStyle == null && other.frameStyle == FrameStyle.frame,
        encircle: frameStyle == FrameStyle.encircle ||
            frameStyle == null && other.frameStyle == FrameStyle.encircle,
        overline: isOverline || other.isOverline,
        superscript: scriptStyle == ScriptStyle.superscript ||
            scriptStyle == null && other.scriptStyle == ScriptStyle.superscript,
        subscript: scriptStyle == ScriptStyle.subscript ||
            scriptStyle == null && other.scriptStyle == ScriptStyle.subscript,
        foreground: foregroundColor ?? other.foregroundColor,
        background: backgroundColor ?? other.backgroundColor,
        underlineColor: underlineColorValue ?? other.underlineColorValue,
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
        isDim,
        isItalic,
        isUnderline,
        isDoublyUnderline,
        isBlink,
        isBlinkRapid,
        isInverse,
        isInvisible,
        isStrikethrough,
        isFrame,
        isEncircle,
        isOverline,
        isSuperscript,
        isSubscript,
        foregroundColor,
        backgroundColor,
        underlineColorValue,
      );

  @override
  bool operator ==(Object other) =>
      other is State<void> &&
      isBold == other.isBold &&
      isDim == other.isDim &&
      isItalic == other.isItalic &&
      isUnderline == other.isUnderline &&
      isDoublyUnderline == other.isDoublyUnderline &&
      isBlink == other.isBlink &&
      isBlinkRapid == other.isBlinkRapid &&
      isInverse == other.isInverse &&
      isInvisible == other.isInvisible &&
      isStrikethrough == other.isStrikethrough &&
      isFrame == other.isFrame &&
      isEncircle == other.isEncircle &&
      isOverline == other.isOverline &&
      isSuperscript == other.isSuperscript &&
      isSubscript == other.isSubscript &&
      foregroundColor == other.foregroundColor &&
      backgroundColor == other.backgroundColor &&
      underlineColorValue == other.underlineColorValue;

  String get _objectTypeName;

  String toShortString() {
    final values = [
      if (isBold) 'bold',
      if (isDim) 'dim',
      if (isItalic) 'italic',
      if (isUnderline) 'underline',
      if (isDoublyUnderline) 'doublyUnderline',
      if (isBlink) 'blink',
      if (isBlinkRapid) 'blinkRapid',
      if (isInverse) 'inverse',
      if (isInvisible) 'invisible',
      if (isStrikethrough) 'strikethrough',
      if (isFrame) 'frame',
      if (isEncircle) 'encircle',
      if (isOverline) 'overline',
      if (isSuperscript) 'superscript',
      if (isSubscript) 'subscript',
      if (foregroundColor != null) 'foreground: $foregroundColor',
      if (backgroundColor != null) 'background: $backgroundColor',
      if (underlineColorValue != null) 'underlineColor: $underlineColorValue',
    ];

    return values.join(', ');
  }

  @override
  String toString() => '$_objectTypeName(${toShortString()})';
}
