import 'package:meta/meta.dart';

import '../../ansi/c1.dart';
import '../../ansi/csi.dart';
import '../../ansi/sgr.dart';
import '../../ready_to_use/sgr/sgr.dart' as sgr;
import '../colors/color.dart';
import '../parser/parser.dart';

part 'style.dart';
part 'style_colors.dart';
part 'stack.dart';

/// The base class for tracking the state of ANSI escape codes.
///
/// This class represents a set of applied text styles and colors. Subclasses
/// like [Style] and [Stack] provide specific mechanisms for how these
/// properties are maintained.
///
/// A state is never changed: every getter and method below that returns an
/// `S` gives back a new state with the change made, leaving this one as it
/// was. `style.bold.italic` is three states, and the first two are still
/// there to be used.
@immutable
sealed class State<S extends State<S>> {
  const State();

  /// Whether the text is bold.
  bool get isBold;

  /// Whether the text is dim.
  bool get isDim;

  /// Whether the text is italic.
  bool get isItalic;

  /// Whether the text is underlined once.
  bool get isUnderline;

  /// Whether the text is underlined twice.
  bool get isDoublyUnderline;

  /// Which underline the text carries, or null for none.
  ///
  /// The two are one property to the terminal: underlining twice puts the
  /// single underline out, not another line beside it.
  UnderlineStyle? get underlineStyle;

  /// Whether the text blinks slowly.
  bool get isBlink;

  /// Whether the text blinks rapidly.
  bool get isBlinkRapid;

  /// Which blink the text carries, or null for none.
  BlinkStyle? get blinkStyle;

  /// Whether the foreground and the background are swapped.
  bool get isInverse;

  /// Whether the text is there but not shown.
  bool get isInvisible;

  /// Whether the text is struck through.
  bool get isStrikethrough;

  /// Whether the text is framed.
  bool get isFrame;

  /// Whether the text is encircled.
  bool get isEncircle;

  /// Which of the two the text carries, or null for neither.
  FrameStyle? get frameStyle;

  /// Whether the text is overlined.
  bool get isOverline;

  /// Whether the text is raised.
  bool get isSuperscript;

  /// Whether the text is lowered.
  bool get isSubscript;

  /// Which of the two the text carries, or null for neither.
  ScriptStyle? get scriptStyle;

  /// The colour of the text, or null where the terminal's own is in force.
  Color? get foregroundColor;

  /// The colour behind the text, or null where the terminal's own is in
  /// force.
  Color? get backgroundColor;

  /// The colour of the underline, or null where it takes the colour of the
  /// text.
  ExtendedColor? get underlineColorValue;

  /// This state with bold added.
  S get bold;

  /// This state with dim added.
  S get dim;

  /// This state with italic added.
  S get italic;

  /// This state with a single underline added.
  S get underline;

  /// This state with a double underline added.
  S get doublyUnderline;

  /// This state with a slow blink added.
  S get blink;

  /// This state with a rapid blink added.
  S get blinkRapid;

  /// This state with the foreground and the background swapped.
  S get inverse;

  /// This state with the text hidden.
  S get invisible;

  /// This state with a line through the text.
  S get strikethrough;

  /// This state with a frame around the text.
  S get frame;

  /// This state with a circle around the text.
  S get encircle;

  /// This state with a line above the text.
  S get overline;

  /// This state with the text raised.
  S get superscript;

  /// This state with the text lowered.
  S get subscript;

  /// This state with [color] as the colour of the text.
  S foreground(Color color);

  /// This state with [color] as the colour behind the text.
  S background(Color color);

  /// This state with [color] as the colour of the underline.
  S underlineColor(ExtendedColor color);

  /// This state with everything taken off at once.
  S get reset;

  /// This state with neither bold nor dim, which the terminal takes off
  /// together.
  S get resetBoldAndDim;

  /// This state with the italic taken off.
  S get resetItalic;

  /// This state with the underline taken off, single or double.
  S get resetUnderline;

  /// This state with the blink taken off, slow or rapid.
  S get resetBlink;

  /// This state with the foreground and the background the right way round.
  S get resetInverse;

  /// This state with the text shown again.
  S get resetInvisible;

  /// This state with the line through the text taken off.
  S get resetStrikethrough;

  /// This state with the frame and the circle taken off, which the terminal
  /// takes off together.
  S get resetFrameAndEncircle;

  /// This state with the line above the text taken off.
  S get resetOverline;

  /// This state with the text back on the line, raised or lowered.
  S get resetSuperAndSubscript;

  /// This state with the colour of the text left to the terminal.
  S get resetForeground;

  /// This state with the colour behind the text left to the terminal.
  S get resetBackground;

  /// This state with the underline back to the colour of the text.
  S get resetUnderlineColor;

  /// The codes that take a terminal from this state to [other].
  ///
  /// Only the difference is written: going from bold red to bold green is one
  /// colour code, not a reset and two. The result is empty where the two
  /// states are the same, and where [other] is a [NoStyle], which is the
  /// state that writes nothing by definition.
  ///
  /// [skipReset] leaves out the codes that take properties off and
  /// [skipSet] the ones that put them on — each of use where the far end is
  /// known to need only the other half.
  String transitTo(
    State<void> other, {
    bool skipSet = false,
    bool skipReset = false,
  }) {
    if (other is NoStyle) {
      return '';
    }

    if (other == Style.terminalColors) {
      return skipReset || (this as State<void>) == Style.terminalColors
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

  /// This state laid over [other]: what it sets itself it keeps, and what it
  /// leaves alone it takes from there.
  ///
  /// This is how [Printer] gives text a default style — the text keeps every
  /// property it asks for, and the gaps are filled by the default rather than
  /// by the terminal.
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

  /// This state as a plain [Style], without whatever a [Stack] remembers of
  /// how it got here.
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
        // A state that prints nothing is not the same as one that leaves the
        // terminal to its own colours, however alike their properties look.
        this is NoStyle,
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
      (this is NoStyle) == (other is NoStyle) &&
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

  /// What this state carries, listed without the name of the class around it:
  /// `bold, foreground: fgRed`.
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
