part of 'state.dart';

const _bold = 0x0001;
const _dim = 0x0002;
const _italic = 0x0004;
const _underline = 0x0008;
const _doublyUnderline = 0x0010;
const _blink = 0x0020;
const _blinkRapid = 0x0040;
const _inverse = 0x0080;
const _invisible = 0x0100;
const _strikethrough = 0x0200;
const _frame = 0x0400;
const _encircle = 0x0800;
const _overline = 0x1000;
const _superscript = 0x2000;
const _subscript = 0x4000;
const _fraktur = 0x8000;
const _curlyUnderline = 0x10000;
const _dottedUnderline = 0x20000;
const _dashedUnderline = 0x40000;
const _proportionalSpacing = 0x80000;
const _fontShapeMask = _italic | _fraktur;
const _underlineMask = _underline |
    _doublyUnderline |
    _curlyUnderline |
    _dottedUnderline |
    _dashedUnderline;

/// Which of the two intensities was asked for: `CSI 1` for bold, `CSI 2` for
/// dim.
///
/// Both can be on at once — `style.bold.dim` writes `CSI 1;2` — and one code,
/// `CSI 22`, takes both off. That is why a [Stack] keeps the order they were
/// opened in: a reset closes the last one and leaves the other standing.
enum IntensityStyle {
  /// Brighter or heavier, whichever the terminal does.
  bold,

  /// Fainter.
  dim,
}

/// Which of the ten standard fonts is selected.
enum FontSelection {
  /// The primary (default) font.
  primary,

  /// The first alternative font.
  alternative1,

  /// The second alternative font.
  alternative2,

  /// The third alternative font.
  alternative3,

  /// The fourth alternative font.
  alternative4,

  /// The fifth alternative font.
  alternative5,

  /// The sixth alternative font.
  alternative6,

  /// The seventh alternative font.
  alternative7,

  /// The eighth alternative font.
  alternative8,

  /// The ninth alternative font.
  alternative9,
}

/// Which slanted letter shape is active.
enum FontShape {
  /// Italic letters.
  italic,

  /// Fraktur (Gothic) letters.
  fraktur,
}

/// Which underline the text carries; underlining twice puts the single line
/// out rather than adding to it.
enum UnderlineStyle {
  /// One line.
  singly,

  /// Two.
  doubly,

  /// A wavy or curly line.
  curly,

  /// A dotted line.
  dotted,

  /// A dashed line.
  dashed,
}

/// Which ideogram rendition is active.
enum IdeogramStyle {
  /// An underline or a line on the right side.
  underline,

  /// A double underline or double line on the right side.
  doublyUnderline,

  /// An overline or a line on the left side.
  overline,

  /// A double overline or double line on the left side.
  doublyOverline,

  /// Stress marking.
  stress,
}

/// Which blink the text carries.
enum BlinkStyle {
  /// Under 150 a minute, as the standard puts it.
  slow,

  /// Faster, where the terminal blinks at all.
  rapid,
}

/// Which of the two the text is wrapped in.
enum FrameStyle {
  /// A frame.
  frame,

  /// A circle.
  encircle,
}

/// Where the text sits on the line.
enum ScriptStyle {
  /// Raised.
  superscript,

  /// Lowered.
  subscript,
}

/// Represents the currently active text style.
///
/// [Style] contains the current state of ANSI graphic renditions (SGR) without
/// keeping any history. Modifications (e.g., calling [bold] or [foreground])
/// return a new [Style] with up-to-date properties.
///
/// A [Style] can be called as a function (e.g., `style('text')`) to apply
/// itself to the given string.
final class Style extends State<Style> {
  final int _flags;
  final FontSelection _fontSelection;
  final IdeogramStyle? _ideogramStyle;

  final Color? _foreground;
  final Color? _background;
  final ExtendedColor? _underlineColor;

  /// The colour of the text, or null where the terminal's own is in force.
  ///
  /// {@macro ansi_escape_codes.State.slotNamesTheColour}
  @override
  Color? get foregroundColor => _foreground?.on(ColorTarget.foreground);

  /// The colour behind the text, or null where the terminal's own is in
  /// force.
  ///
  /// {@macro ansi_escape_codes.State.slotNamesTheColour}
  @override
  Color? get backgroundColor => _background?.on(ColorTarget.background);

  /// The colour of the underline, or null where it takes the colour of the
  /// text.
  ///
  /// {@macro ansi_escape_codes.State.slotNamesTheColour}
  @override
  ExtendedColor? get underlineColorValue =>
      _underlineColor?.on(ColorTarget.underline);

  /// A style carrying whatever is asked for here, and the terminal's own
  /// where nothing is.
  ///
  /// The families the terminal cannot hold at once — italic/fraktur, the five
  /// underlines, blink and blinkRapid, frame and encircle, superscript and
  /// subscript — assert in debug and keep the first value otherwise.
  const Style({
    bool bold = false,
    bool dim = false,
    FontSelection fontSelection = FontSelection.primary,
    bool italic = false,
    bool fraktur = false,
    bool underline = false,
    bool doublyUnderline = false,
    bool curlyUnderline = false,
    bool dottedUnderline = false,
    bool dashedUnderline = false,
    bool proportionalSpacing = false,
    bool blink = false,
    bool blinkRapid = false,
    bool inverse = false,
    bool invisible = false,
    bool strikethrough = false,
    bool frame = false,
    bool encircle = false,
    bool overline = false,
    IdeogramStyle? ideogramStyle,
    bool superscript = false,
    bool subscript = false,
    Color? foreground,
    Color? background,
    ExtendedColor? underlineColor,
  })  : assert(
          !italic || !fraktur,
          'Either italic or fraktur can be set',
        ),
        assert(
          (underline ? 1 : 0) +
                  (doublyUnderline ? 1 : 0) +
                  (curlyUnderline ? 1 : 0) +
                  (dottedUnderline ? 1 : 0) +
                  (dashedUnderline ? 1 : 0) <=
              1,
          'Only one underline style can be set',
        ),
        assert(
          !blink || !blinkRapid,
          'Either blink or blinkRapid can be set',
        ),
        assert(
          !frame || !encircle,
          'Either frame or encircle can be set',
        ),
        assert(
          !superscript || !subscript,
          'Either superscript or subscript can be set',
        ),
        _flags = (bold ? _bold : 0) |
            (dim ? _dim : 0) |
            (italic ? _italic : 0) |
            (fraktur && !italic ? _fraktur : 0) |
            (underline ? _underline : 0) |
            (doublyUnderline && !underline ? _doublyUnderline : 0) |
            (curlyUnderline && !underline && !doublyUnderline
                ? _curlyUnderline
                : 0) |
            (dottedUnderline &&
                    !underline &&
                    !doublyUnderline &&
                    !curlyUnderline
                ? _dottedUnderline
                : 0) |
            (dashedUnderline &&
                    !underline &&
                    !doublyUnderline &&
                    !curlyUnderline &&
                    !dottedUnderline
                ? _dashedUnderline
                : 0) |
            (proportionalSpacing ? _proportionalSpacing : 0) |
            (blink ? _blink : 0) |
            (blinkRapid && !blink ? _blinkRapid : 0) |
            (inverse ? _inverse : 0) |
            (invisible ? _invisible : 0) |
            (strikethrough ? _strikethrough : 0) |
            (frame ? _frame : 0) |
            (encircle && !frame ? _encircle : 0) |
            (overline ? _overline : 0) |
            (superscript ? _superscript : 0) |
            (subscript && !superscript ? _subscript : 0),
        _fontSelection = fontSelection,
        _ideogramStyle = ideogramStyle,
        _foreground = foreground,
        _background = background,
        _underlineColor = underlineColor;

  const Style._(
    this._flags,
    this._fontSelection,
    this._ideogramStyle,
    this._foreground,
    this._background,
    this._underlineColor,
  );

  /// The state a terminal is in before anything is written to it: its own
  /// colours, and nothing switched on.
  static const Style terminalColors = Style();

  /// The text under this style, opened before it and closed after it.
  ///
  /// ```dart
  /// print(red.bold('Careful'));
  /// ```
  ///
  /// Each line is opened and closed on its own, so the style survives being
  /// cut, and a style already in the text is unwound back to this one rather
  /// than left as it was. A hyperlink survives it too: a line closes the one
  /// it opened, the way a printed line does, and the line after opens it
  /// again, so a link a line break falls inside of stays one link.
  ///
  /// Escape codes in [text] keep their terminal meaning. A selective reset
  /// returns that property to the terminal's default, which this style
  /// replaces; it does not reveal an earlier value set inside [text]. Use
  /// [StackedPrinter] when resets are meant to close nested style operations
  /// one level at a time.
  String call(String text) {
    if (text.isEmpty) {
      return '';
    }

    final buf = StringBuffer();
    final printer = Printer(defaultStyle: this);

    for (final (index, line) in text.split('\n').indexed) {
      if (index != 0) {
        buf.write('\n');
      }
      buf.write(printer.prepare(line));
    }

    return buf.toString();
  }

  @override
  bool get isBold => _flags & _bold != 0;

  @override
  bool get isDim => _flags & _dim != 0;

  @override
  FontSelection get fontSelection => _fontSelection;

  @override
  FontShape? get fontShape => isItalic
      ? FontShape.italic
      : isFraktur
          ? FontShape.fraktur
          : null;

  @override
  bool get isItalic => _flags & _italic != 0;

  @override
  bool get isFraktur => _flags & _fraktur != 0;

  @override
  bool get isUnderline =>
      _flags &
          (_underline |
              _curlyUnderline |
              _dottedUnderline |
              _dashedUnderline) !=
      0;

  @override
  bool get isDoublyUnderline => _flags & _doublyUnderline != 0;

  @override
  bool get isCurlyUnderline => _flags & _curlyUnderline != 0;

  @override
  bool get isDottedUnderline => _flags & _dottedUnderline != 0;

  @override
  bool get isDashedUnderline => _flags & _dashedUnderline != 0;

  @override
  UnderlineStyle? get underlineStyle => _flags & _underline != 0
      ? UnderlineStyle.singly
      : isDoublyUnderline
          ? UnderlineStyle.doubly
          : isCurlyUnderline
              ? UnderlineStyle.curly
              : isDottedUnderline
                  ? UnderlineStyle.dotted
                  : isDashedUnderline
                      ? UnderlineStyle.dashed
                      : null;

  @override
  bool get isProportionalSpacing => _flags & _proportionalSpacing != 0;

  @override
  bool get isBlink => _flags & _blink != 0;

  @override
  bool get isBlinkRapid => _flags & _blinkRapid != 0;

  @override
  BlinkStyle? get blinkStyle => isBlink
      ? BlinkStyle.slow
      : isBlinkRapid
          ? BlinkStyle.rapid
          : null;

  @override
  bool get isInverse => _flags & _inverse != 0;

  @override
  bool get isInvisible => _flags & _invisible != 0;

  @override
  bool get isStrikethrough => _flags & _strikethrough != 0;

  @override
  bool get isFrame => _flags & _frame != 0;

  @override
  bool get isEncircle => _flags & _encircle != 0;

  @override
  FrameStyle? get frameStyle => isFrame
      ? FrameStyle.frame
      : isEncircle
          ? FrameStyle.encircle
          : null;

  @override
  bool get isOverline => _flags & _overline != 0;

  @override
  IdeogramStyle? get ideogramStyle => _ideogramStyle;

  @override
  bool get isSuperscript => _flags & _superscript != 0;

  @override
  bool get isSubscript => _flags & _subscript != 0;

  @override
  ScriptStyle? get scriptStyle => isSuperscript
      ? ScriptStyle.superscript
      : isSubscript
          ? ScriptStyle.subscript
          : null;

  @override
  Style get bold => _setFlags(_flags | _bold);

  @override
  Style get dim => _setFlags(_flags | _dim);

  @override
  Style get alternativeFont1 => _setFont(FontSelection.alternative1);

  @override
  Style get alternativeFont2 => _setFont(FontSelection.alternative2);

  @override
  Style get alternativeFont3 => _setFont(FontSelection.alternative3);

  @override
  Style get alternativeFont4 => _setFont(FontSelection.alternative4);

  @override
  Style get alternativeFont5 => _setFont(FontSelection.alternative5);

  @override
  Style get alternativeFont6 => _setFont(FontSelection.alternative6);

  @override
  Style get alternativeFont7 => _setFont(FontSelection.alternative7);

  @override
  Style get alternativeFont8 => _setFont(FontSelection.alternative8);

  @override
  Style get alternativeFont9 => _setFont(FontSelection.alternative9);

  @override
  Style get italic => _setFontShape(FontShape.italic);

  @override
  Style get fraktur => _setFontShape(FontShape.fraktur);

  @override
  Style get underline => _setUnderline(UnderlineStyle.singly);

  @override
  Style get doublyUnderline => _setUnderline(UnderlineStyle.doubly);

  @override
  Style get curlyUnderline => _setUnderline(UnderlineStyle.curly);

  @override
  Style get dottedUnderline => _setUnderline(UnderlineStyle.dotted);

  @override
  Style get dashedUnderline => _setUnderline(UnderlineStyle.dashed);

  @override
  Style get proportionalSpacing => _setFlags(_flags | _proportionalSpacing);

  @override
  Style get blink => _setFlags(_flags & ~_blinkRapid | _blink);

  @override
  Style get blinkRapid => _setFlags(_flags & ~_blink | _blinkRapid);

  @override
  Style get inverse => _setFlags(_flags | _inverse);

  @override
  Style get invisible => _setFlags(_flags | _invisible);

  @override
  Style get strikethrough => _setFlags(_flags | _strikethrough);

  @override
  Style get frame => _setFlags(_flags & ~_encircle | _frame);

  @override
  Style get encircle => _setFlags(_flags & ~_frame | _encircle);

  @override
  Style get overline => _setFlags(_flags | _overline);

  @override
  Style get ideogramUnderline => _setIdeogram(IdeogramStyle.underline);

  @override
  Style get ideogramDoublyUnderline =>
      _setIdeogram(IdeogramStyle.doublyUnderline);

  @override
  Style get ideogramOverline => _setIdeogram(IdeogramStyle.overline);

  @override
  Style get ideogramDoublyOverline =>
      _setIdeogram(IdeogramStyle.doublyOverline);

  @override
  Style get ideogramStress => _setIdeogram(IdeogramStyle.stress);

  @override
  Style get superscript => _setFlags(_flags & ~_subscript | _superscript);

  @override
  Style get subscript => _setFlags(_flags & ~_superscript | _subscript);

  // The slot is put on the colour on the way out (see foregroundColor) and
  // Color.== ignores it, so comparing what is held against what is asked for
  // is enough — here and in the two below.
  @override
  Style foreground(Color color) => _foreground == color
      ? this
      : Style._(
          _flags,
          _fontSelection,
          _ideogramStyle,
          color.on(ColorTarget.foreground),
          _background,
          _underlineColor,
        );

  @override
  Style background(Color color) => _background == color
      ? this
      : Style._(
          _flags,
          _fontSelection,
          _ideogramStyle,
          _foreground,
          color.on(ColorTarget.background),
          _underlineColor,
        );

  @override
  Style underlineColor(ExtendedColor color) => _underlineColor == color
      ? this
      : Style._(
          _flags,
          _fontSelection,
          _ideogramStyle,
          _foreground,
          _background,
          color.on(ColorTarget.underline),
        );

  @override
  Style get reset => terminalColors;

  @override
  Style get resetBoldAndDim => _setFlags(_flags & ~(_bold | _dim));

  @override
  Style get resetFont => _setFont(FontSelection.primary);

  @override
  Style get resetFontShape => _setFontShape(null);

  @override
  Style get resetItalic => resetFontShape;

  @override
  Style get resetUnderline => _setUnderline(null);

  @override
  Style get resetProportionalSpacing =>
      _setFlags(_flags & ~_proportionalSpacing);

  @override
  Style get resetBlink => _setFlags(_flags & ~(_blink | _blinkRapid));

  @override
  Style get resetInverse => _setFlags(_flags & ~_inverse);

  @override
  Style get resetInvisible => _setFlags(_flags & ~_invisible);

  @override
  Style get resetStrikethrough => _setFlags(_flags & ~_strikethrough);

  @override
  Style get resetFrameAndEncircle => _setFlags(_flags & ~(_frame | _encircle));

  @override
  Style get resetOverline => _setFlags(_flags & ~_overline);

  @override
  Style get resetIdeogram => _setIdeogram(null);

  @override
  Style get resetSuperAndSubscript => _setFlags(
        _flags & ~(_superscript | _subscript),
      );
  @override
  Style get resetForeground => _foreground == null
      ? this
      : Style._(
          _flags,
          _fontSelection,
          _ideogramStyle,
          null,
          _background,
          _underlineColor,
        );

  @override
  Style get resetBackground => _background == null
      ? this
      : Style._(
          _flags,
          _fontSelection,
          _ideogramStyle,
          _foreground,
          null,
          _underlineColor,
        );

  @override
  Style get resetUnderlineColor => _underlineColor == null
      ? this
      : Style._(
          _flags,
          _fontSelection,
          _ideogramStyle,
          _foreground,
          _background,
          null,
        );

  /// The codes that take a terminal from its own colours to this style.
  ///
  /// Nothing is taken off first: this only puts on what the style carries.
  String get open => Style.terminalColors.transitToPart(this, skipReset: true);

  /// The code that takes everything off again, which is the reset.
  String get close => sgr.reset;

  // Nothing to change answers itself — the promise State makes — and a
  // NoStyle asked for nothing stays a NoStyle.
  Style _setFlags(int flags) => flags == _flags
      ? this
      : Style._(
          flags,
          _fontSelection,
          _ideogramStyle,
          _foreground,
          _background,
          _underlineColor,
        );

  Style _setFont(FontSelection font) => font == _fontSelection
      ? this
      : Style._(
          _flags,
          font,
          _ideogramStyle,
          _foreground,
          _background,
          _underlineColor,
        );

  Style _setFontShape(FontShape? shape) => _setFlags(
        _flags & ~_fontShapeMask |
            switch (shape) {
              FontShape.italic => _italic,
              FontShape.fraktur => _fraktur,
              null => 0,
            },
      );

  Style _setUnderline(UnderlineStyle? style) => _setFlags(
        _flags & ~_underlineMask |
            switch (style) {
              UnderlineStyle.singly => _underline,
              UnderlineStyle.doubly => _doublyUnderline,
              UnderlineStyle.curly => _curlyUnderline,
              UnderlineStyle.dotted => _dottedUnderline,
              UnderlineStyle.dashed => _dashedUnderline,
              null => 0,
            },
      );

  Style _setIdeogram(IdeogramStyle? style) => style == _ideogramStyle
      ? this
      : Style._(
          _flags,
          _fontSelection,
          style,
          _foreground,
          _background,
          _underlineColor,
        );

  @override
  Style toStyle() => this;

  @override
  String get _objectTypeName => '$Style';
}

/// A style that adds nothing to the text.
///
/// Every other style writes something. `Style.terminalColors('text')` comes
/// back with a reset in front of it, because a style that means "the terminal's
/// own" still has to say so. This one is asked and answers with the text
/// itself: [open] and [close] are empty, and `transitTo` gives an empty string
/// wherever this is the destination.
///
/// It is for the places that take a style and must be told to do nothing.
/// Passing it to a [Printer] stops the printer from imposing a style of its
/// own; the codes already in the text still go through, and taking those out
/// is what `ansiCodesEnabled: false` is for.
///
/// Nothing leads back into it. Setting anything — [bold], [foreground], any
/// of them — answers with an ordinary [Style] that writes, and no operation
/// on that one comes back here, so `const NoStyle()` is the only way to have
/// this style. The narrower resets leave it where it is: they have nothing
/// to take off and answer with this style itself, the way any state answers
/// itself when it has nothing to change.
///
/// [reset] is the one operation that leaves this style behind without
/// changing anything it shows. It answers with [Style.terminalColors] — the
/// same properties and the same colours, but a style that says "the
/// terminal's own" out loud where this one says nothing at all. The two are
/// not equal all the same: being a [NoStyle] is part of what equality
/// compares.
final class NoStyle extends Style {
  /// The style that writes nothing.
  const NoStyle();

  @override
  String call(String text) => text;

  /// Nothing was opened, so there is nothing to close.
  @override
  String get close => '';

  @override
  String get _objectTypeName => '$NoStyle';
}
