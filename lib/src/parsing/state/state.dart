import 'package:meta/meta.dart';

import '../../ansi/c1.dart';
import '../../ansi/csi.dart';
import '../../ansi/sgr.dart';
import '../../ready_to_use/sgr/sgr.dart' as sgr;
import '../colors/color.dart';
import '../parser/parser.dart';

part 'style.dart';
part 'style_colors.dart';
part 'styles.dart';
part 'stack.dart';

/// The base class for tracking the state of ANSI escape codes.
///
/// This class represents a set of applied text styles and colors. Subclasses
/// like [Style] and [Stack] provide specific mechanisms for how these
/// properties are maintained.
///
/// A state is never changed: every getter and method below that returns an
/// `S` gives back the state with the change made, leaving this one as it was.
/// `style.bold.italic` is three states, and the first two are still there to
/// be used. Where there is nothing to change — a [Stack] asked to close an
/// italic it never opened — the answer is this state itself.
@immutable
sealed class State<S extends State<S>> {
  const State();

  /// Whether the text is bold.
  bool get isBold;

  /// Whether the text is dim.
  bool get isDim;

  /// Which of the ten standard fonts is selected.
  FontSelection get fontSelection;

  /// Which slanted letter shape is active, or null for neither.
  FontShape? get fontShape;

  /// Whether the text is italic.
  bool get isItalic;

  /// Whether the text is fraktur (Gothic).
  bool get isFraktur;

  /// Whether the text has a single, curly, dotted or dashed underline.
  bool get isUnderline;

  /// Whether the text is underlined twice.
  bool get isDoublyUnderline;

  /// Which underline the text carries, or null for none.
  ///
  /// The variants are one property to the terminal: selecting one puts the
  /// previous underline out rather than adding another line beside it.
  UnderlineStyle? get underlineStyle;

  /// Whether the text has a curly underline.
  bool get isCurlyUnderline;

  /// Whether the text has a dotted underline.
  bool get isDottedUnderline;

  /// Whether the text has a dashed underline.
  bool get isDashedUnderline;

  /// Whether proportional spacing is active.
  bool get isProportionalSpacing;

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

  /// Which ideogram rendition the text carries, or null for none.
  IdeogramStyle? get ideogramStyle;

  /// Whether the text is raised.
  bool get isSuperscript;

  /// Whether the text is lowered.
  bool get isSubscript;

  /// Which of the two the text carries, or null for neither.
  ScriptStyle? get scriptStyle;

  /// The colour of the text, or null where the terminal's own is in force.
  ///
  /// {@template ansi_escape_codes.State.slotNamesTheColour}
  /// The colour answers to [Color.id] under the name of the slot it is held
  /// in — `fgRed` here, `bg256Gray5` in [backgroundColor] — whatever it was
  /// set on before it was given. A colour standing on its own has no slot,
  /// and says so with a `?`.
  /// {@endtemplate}
  Color? get foregroundColor;

  /// The colour behind the text, or null where the terminal's own is in
  /// force.
  ///
  /// {@macro ansi_escape_codes.State.slotNamesTheColour}
  Color? get backgroundColor;

  /// The colour of the underline, or null where it takes the colour of the
  /// text.
  ///
  /// {@macro ansi_escape_codes.State.slotNamesTheColour}
  ExtendedColor? get underlineColorValue;

  /// This state with bold added.
  S get bold;

  /// This state with dim added.
  S get dim;

  /// This state with the first alternative font selected.
  S get alternativeFont1;

  /// This state with the second alternative font selected.
  S get alternativeFont2;

  /// This state with the third alternative font selected.
  S get alternativeFont3;

  /// This state with the fourth alternative font selected.
  S get alternativeFont4;

  /// This state with the fifth alternative font selected.
  S get alternativeFont5;

  /// This state with the sixth alternative font selected.
  S get alternativeFont6;

  /// This state with the seventh alternative font selected.
  S get alternativeFont7;

  /// This state with the eighth alternative font selected.
  S get alternativeFont8;

  /// This state with the ninth alternative font selected.
  S get alternativeFont9;

  /// This state with italic added.
  S get italic;

  /// This state with fraktur (Gothic) added.
  S get fraktur;

  /// This state with a single underline added.
  S get underline;

  /// This state with a double underline added.
  S get doublyUnderline;

  /// This state with a curly underline added.
  S get curlyUnderline;

  /// This state with a dotted underline added.
  S get dottedUnderline;

  /// This state with a dashed underline added.
  S get dashedUnderline;

  /// This state with proportional spacing added.
  S get proportionalSpacing;

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

  /// This state with an ideogram underline or right side line.
  S get ideogramUnderline;

  /// This state with a double ideogram underline or right side line.
  S get ideogramDoublyUnderline;

  /// This state with an ideogram overline or left side line.
  S get ideogramOverline;

  /// This state with a double ideogram overline or left side line.
  S get ideogramDoublyOverline;

  /// This state with an ideogram stress mark.
  S get ideogramStress;

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

  /// This state with the primary font restored.
  S get resetFont;

  /// This state with italic or fraktur taken off.
  S get resetFontShape;

  /// This state with the italic or fraktur taken off.
  ///
  /// This historical name is an alias of [resetFontShape].
  S get resetItalic;

  /// This state with every underline variant taken off.
  S get resetUnderline;

  /// This state with proportional spacing taken off.
  S get resetProportionalSpacing;

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

  /// This state with every ideogram rendition taken off.
  S get resetIdeogram;

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
  /// Where the standard has no code for the difference, what it does have is
  /// written instead: bold and dim are taken off together by `CSI 22`, so
  /// going from both to bold alone is `CSI 22;1` — the pair off, then the
  /// bold back on.
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
      // A NoStyle never wrote anything, so there is nothing to take
      // off: its surface is the terminal's own, however the == terms
      // differ.
      return skipReset ||
              this is NoStyle ||
              (this as State<void>) == Style.terminalColors
          ? ''
          : sgr.reset;
    }

    final otherForeground = other.foregroundColor;
    final otherBackground = other.backgroundColor;
    final otherUnderlineColor = other.underlineColorValue;
    final otherFontSelection = other.fontSelection;
    final otherFontShape = other.fontShape;
    final otherUnderlineStyle = other.underlineStyle;
    final otherIdeogramStyle = other.ideogramStyle;
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
            if (fontSelection != otherFontSelection &&
                otherFontSelection == FontSelection.primary)
              10,
            if (fontShape != otherFontShape && otherFontShape == null) 23,
            if (underlineStyle != otherUnderlineStyle &&
                otherUnderlineStyle == null)
              24,
            if (isProportionalSpacing && !other.isProportionalSpacing) 50,
            if (blinkStyle != otherBlinkStyle && otherBlinkStyle == null) 25,
            if (isInverse && !other.isInverse) 27,
            if (isInvisible && !other.isInvisible) 28,
            if (isStrikethrough && !other.isStrikethrough) 29,
            if (frameStyle != otherFrameStyle && otherFrameStyle == null) 54,
            if (isOverline && !other.isOverline) 55,
            if (ideogramStyle != otherIdeogramStyle &&
                otherIdeogramStyle == null)
              65,
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

    // `CSI 22` takes bold and dim off together, so where one of the pair goes
    // off the other has to be put back behind it. Those two parameters belong
    // to the reset rather than being a set of their own, and [skipSet] leaves
    // them standing: with them gone, half of a joint reset would go out and
    // carry off the half of the pair that was meant to survive it.
    final jointIntensityReset =
        isBold && !other.isBold || isDim && !other.isDim;

    final setParams = <String>[
      if (!skipSet) ...[
        if (foregroundColor != otherForeground && otherForeground is Color16)
          '${_colorIndex(30, 90, otherForeground)}',
        if (backgroundColor != otherBackground && otherBackground is Color16)
          '${_colorIndex(40, 100, otherBackground)}',
      ],
      if (jointIntensityReset) ...[
        if (other.isBold) '1',
        if (other.isDim) '2',
      ] else if (!skipSet) ...[
        if (!isBold && other.isBold) '1',
        if (!isDim && other.isDim) '2',
      ],
      if (!skipSet) ...[
        if (fontSelection != otherFontSelection &&
            otherFontSelection != FontSelection.primary)
          switch (otherFontSelection) {
            FontSelection.primary => throw StateError('unreachable'),
            FontSelection.alternative1 => '11',
            FontSelection.alternative2 => '12',
            FontSelection.alternative3 => '13',
            FontSelection.alternative4 => '14',
            FontSelection.alternative5 => '15',
            FontSelection.alternative6 => '16',
            FontSelection.alternative7 => '17',
            FontSelection.alternative8 => '18',
            FontSelection.alternative9 => '19',
          },
        if (fontShape != otherFontShape && otherFontShape != null)
          switch (otherFontShape) {
            FontShape.italic => '3',
            FontShape.fraktur => '20',
          },
        if (underlineStyle != otherUnderlineStyle &&
            otherUnderlineStyle != null)
          switch (otherUnderlineStyle) {
            UnderlineStyle.singly => '4',
            UnderlineStyle.doubly => '21',
            UnderlineStyle.curly => '4:3',
            UnderlineStyle.dotted => '4:4',
            UnderlineStyle.dashed => '4:5',
          },
        if (!isProportionalSpacing && other.isProportionalSpacing) '26',
        if (blinkStyle != otherBlinkStyle && otherBlinkStyle != null)
          switch (otherBlinkStyle) {
            BlinkStyle.slow => '5',
            BlinkStyle.rapid => '6',
          },
        if (!isInverse && other.isInverse) '7',
        if (!isInvisible && other.isInvisible) '8',
        if (!isStrikethrough && other.isStrikethrough) '9',
        if (frameStyle != otherFrameStyle && otherFrameStyle != null)
          switch (otherFrameStyle) {
            FrameStyle.frame => '51',
            FrameStyle.encircle => '52',
          },
        if (!isOverline && other.isOverline) '53',
        if (ideogramStyle != otherIdeogramStyle && otherIdeogramStyle != null)
          switch (otherIdeogramStyle) {
            IdeogramStyle.underline => '60',
            IdeogramStyle.doublyUnderline => '61',
            IdeogramStyle.overline => '62',
            IdeogramStyle.doublyOverline => '63',
            IdeogramStyle.stress => '64',
          },
        if (scriptStyle != otherScriptStyle && otherScriptStyle != null)
          switch (otherScriptStyle) {
            ScriptStyle.superscript => '73',
            ScriptStyle.subscript => '74',
          },
      ],
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
        fontSelection: fontSelection == FontSelection.primary
            ? other.fontSelection
            : fontSelection,
        italic: (fontShape ?? other.fontShape) == FontShape.italic,
        fraktur: (fontShape ?? other.fontShape) == FontShape.fraktur,
        underline: underlineStyle == UnderlineStyle.singly ||
            underlineStyle == null &&
                other.underlineStyle == UnderlineStyle.singly,
        doublyUnderline: underlineStyle == UnderlineStyle.doubly ||
            underlineStyle == null &&
                other.underlineStyle == UnderlineStyle.doubly,
        curlyUnderline: underlineStyle == UnderlineStyle.curly ||
            underlineStyle == null &&
                other.underlineStyle == UnderlineStyle.curly,
        dottedUnderline: underlineStyle == UnderlineStyle.dotted ||
            underlineStyle == null &&
                other.underlineStyle == UnderlineStyle.dotted,
        dashedUnderline: underlineStyle == UnderlineStyle.dashed ||
            underlineStyle == null &&
                other.underlineStyle == UnderlineStyle.dashed,
        proportionalSpacing:
            isProportionalSpacing || other.isProportionalSpacing,
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
        ideogramStyle: ideogramStyle ?? other.ideogramStyle,
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
  ///
  /// Plain is said of the history, not of what the style writes: a [NoStyle]
  /// is a [Style] already and answers with itself, so a state that writes
  /// nothing gives back one that writes nothing.
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
  int get hashCode => Object.hashAll([
        // A state that prints nothing is not the same as one that leaves the
        // terminal to its own colours, however alike their properties look.
        this is NoStyle,
        isBold,
        isDim,
        fontSelection,
        fontShape,
        underlineStyle,
        isProportionalSpacing,
        blinkStyle,
        isInverse,
        isInvisible,
        isStrikethrough,
        frameStyle,
        isOverline,
        ideogramStyle,
        scriptStyle,
        foregroundColor,
        backgroundColor,
        underlineColorValue,
      ]);

  /// Equality is the visible surface: the properties and colours this
  /// state answers with, and whether it is a [NoStyle] — nothing else.
  ///
  /// What a [Stack] remembers of how it got here is not compared: two
  /// equal stacks may answer one and the same reset differently when
  /// their histories differ. `underline.doublyUnderline` equals
  /// `doublyUnderline`, and after one `resetUnderline` each, the first
  /// keeps an underline the second never had. Equal is how it looks,
  /// not how it unwinds.
  ///
  /// The surface is all of it: a [Stack] and a plain [Style] that look the
  /// same are equal, and as keys of a `Set` or `Map` equal states collapse
  /// into one, however they were built.
  @override
  bool operator ==(Object other) =>
      other is State<void> &&
      (this is NoStyle) == (other is NoStyle) &&
      isBold == other.isBold &&
      isDim == other.isDim &&
      fontSelection == other.fontSelection &&
      fontShape == other.fontShape &&
      underlineStyle == other.underlineStyle &&
      isProportionalSpacing == other.isProportionalSpacing &&
      blinkStyle == other.blinkStyle &&
      isInverse == other.isInverse &&
      isInvisible == other.isInvisible &&
      isStrikethrough == other.isStrikethrough &&
      frameStyle == other.frameStyle &&
      isOverline == other.isOverline &&
      ideogramStyle == other.ideogramStyle &&
      scriptStyle == other.scriptStyle &&
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
      if (fontSelection != FontSelection.primary)
        'alternativeFont${fontSelection.index}',
      if (fontShape != null) fontShape!.name,
      if (underlineStyle != null)
        switch (underlineStyle!) {
          UnderlineStyle.singly => 'underline',
          UnderlineStyle.doubly => 'doublyUnderline',
          UnderlineStyle.curly => 'curlyUnderline',
          UnderlineStyle.dotted => 'dottedUnderline',
          UnderlineStyle.dashed => 'dashedUnderline',
        },
      if (isProportionalSpacing) 'proportionalSpacing',
      if (isBlink) 'blink',
      if (isBlinkRapid) 'blinkRapid',
      if (isInverse) 'inverse',
      if (isInvisible) 'invisible',
      if (isStrikethrough) 'strikethrough',
      if (isFrame) 'frame',
      if (isEncircle) 'encircle',
      if (isOverline) 'overline',
      if (ideogramStyle != null) 'ideogram${_capitalized(ideogramStyle!.name)}',
      if (isSuperscript) 'superscript',
      if (isSubscript) 'subscript',
      if (foregroundColor != null) 'foreground: $foregroundColor',
      if (backgroundColor != null) 'background: $backgroundColor',
      if (underlineColorValue != null) 'underlineColor: $underlineColorValue',
    ];

    return values.join(', ');
  }

  String _capitalized(String value) =>
      '${value.substring(0, 1).toUpperCase()}${value.substring(1)}';

  @override
  String toString() => '$_objectTypeName(${toShortString()})';
}
