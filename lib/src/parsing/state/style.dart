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

/// Which of the two intensities the text carries; the terminal has room for
/// one at a time, and one code takes both off.
enum IntensityStyle {
  /// Brighter or heavier, whichever the terminal does.
  bold,

  /// Fainter.
  dim,
}

/// Which underline the text carries; underlining twice puts the single line
/// out rather than adding to it.
enum UnderlineStyle {
  /// One line.
  singly,

  /// Two.
  doubly,
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

  @override
  final Color? foregroundColor;

  @override
  final Color? backgroundColor;

  @override
  final ExtendedColor? underlineColorValue;

  /// A style carrying whatever is asked for here, and the terminal's own
  /// where nothing is.
  ///
  /// The pairs the terminal cannot hold at once — underline and
  /// doublyUnderline, blink and blinkRapid, frame and encircle, superscript
  /// and subscript — assert in debug and keep the first of the two otherwise.
  const Style({
    bool bold = false,
    bool dim = false,
    bool italic = false,
    bool underline = false,
    bool doublyUnderline = false,
    bool blink = false,
    bool blinkRapid = false,
    bool inverse = false,
    bool invisible = false,
    bool strikethrough = false,
    bool frame = false,
    bool encircle = false,
    bool overline = false,
    bool superscript = false,
    bool subscript = false,
    Color? foreground,
    Color? background,
    ExtendedColor? underlineColor,
  })  : assert(
          !underline || !doublyUnderline,
          'Either underline or doublyUnderline can be set',
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
            (underline ? _underline : 0) |
            (doublyUnderline && !underline ? _doublyUnderline : 0) |
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
        foregroundColor = foreground,
        backgroundColor = background,
        underlineColorValue = underlineColor;

  const Style._(
    this._flags,
    this.foregroundColor,
    this.backgroundColor,
    this.underlineColorValue,
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
  /// than left as it was.
  String call(String text) {
    if (text.isEmpty) {
      return '';
    }

    final buf = StringBuffer();
    final printer = StackedPrinter(defaultStyle: this);

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
  bool get isItalic => _flags & _italic != 0;

  @override
  bool get isUnderline => _flags & _underline != 0;

  @override
  bool get isDoublyUnderline => _flags & _doublyUnderline != 0;

  @override
  UnderlineStyle? get underlineStyle => isUnderline
      ? UnderlineStyle.singly
      : isDoublyUnderline
          ? UnderlineStyle.doubly
          : null;

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
  Style get italic => _setFlags(_flags | _italic);

  @override
  Style get underline => _setFlags(_flags & ~_doublyUnderline | _underline);

  @override
  Style get doublyUnderline =>
      _setFlags(_flags & ~_underline | _doublyUnderline);

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
  Style get superscript => _setFlags(_flags & ~_subscript | _superscript);

  @override
  Style get subscript => _setFlags(_flags & ~_superscript | _subscript);

  @override
  Style foreground(Color color) => Style._(
        _flags,
        color.withPrefix('fg'),
        backgroundColor,
        underlineColorValue,
      );

  @override
  Style background(Color color) => Style._(
        _flags,
        foregroundColor,
        color.withPrefix('bg'),
        underlineColorValue,
      );

  @override
  Style underlineColor(ExtendedColor color) => Style._(
        _flags,
        foregroundColor,
        backgroundColor,
        color.withPrefix('underline'),
      );

  @override
  Style get reset => terminalColors;

  @override
  Style get resetBoldAndDim => _setFlags(_flags & ~(_bold | _dim));

  @override
  Style get resetItalic => _setFlags(_flags & ~_italic);

  @override
  Style get resetUnderline =>
      _setFlags(_flags & ~(_underline | _doublyUnderline));

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
  Style get resetSuperAndSubscript => _setFlags(
        _flags & ~(_superscript | _subscript),
      );
  @override
  Style get resetForeground =>
      Style._(_flags, null, backgroundColor, underlineColorValue);

  @override
  Style get resetBackground =>
      Style._(_flags, foregroundColor, null, underlineColorValue);

  @override
  Style get resetUnderlineColor =>
      Style._(_flags, foregroundColor, backgroundColor, null);

  /// The codes that take a terminal from its own colours to this style.
  ///
  /// Nothing is taken off first: this only puts on what the style carries.
  String get open => Style.terminalColors.transitTo(this, skipReset: true);

  /// The code that takes everything off again, which is the reset.
  String get close => sgr.reset;

  Style _setFlags(int flags) => Style._(
        flags,
        foregroundColor,
        backgroundColor,
        underlineColorValue,
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
