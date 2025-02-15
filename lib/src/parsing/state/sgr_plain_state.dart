part of 'sgr_state.dart';

const _bold = 0x0001;
const _faint = 0x0002;
const _italicized = 0x0004;
const _singlyUnderlined = 0x0008;
const _doublyUnderlined = 0x0010;
const _slowlyBlinking = 0x0020;
const _rapidlyBlinking = 0x0040;
const _negative = 0x0080;
const _concealed = 0x0100;
const _crossedOut = 0x0200;
const _framed = 0x0400;
const _encircled = 0x0800;
const _overlined = 0x1000;
const _superscripted = 0x2000;
const _subscripted = 0x4000;

final class SgrPlainState extends SgrState<SgrPlainState> {
  final int _flags;

  @override
  final Color? foreground;

  @override
  final Color? background;

  @override
  final ExtendedColor? underlineColor;

  const SgrPlainState({
    bool bold = false,
    bool faint = false,
    bool italicized = false,
    bool singlyUnderlined = false,
    bool doublyUnderlined = false,
    bool slowlyBlinking = false,
    bool rapidlyBlinking = false,
    bool negative = false,
    bool concealed = false,
    bool crossedOut = false,
    bool framed = false,
    bool encircled = false,
    bool overlined = false,
    bool superscripted = false,
    bool subscripted = false,
    this.foreground,
    this.background,
    this.underlineColor,
  })  : assert(
          !singlyUnderlined || !doublyUnderlined,
          'Either singlyUnderlined or doublyUnderlined can be set',
        ),
        assert(
          !slowlyBlinking || !rapidlyBlinking,
          'Either slowlyBlinking or rapidlyBlinking can be set',
        ),
        assert(
          !framed || !encircled,
          'Either framed or encircled can be set',
        ),
        assert(
          !superscripted || !subscripted,
          'Either superscripted or subscripted can be set',
        ),
        _flags = (bold ? _bold : 0) |
            (faint ? _faint : 0) |
            (italicized ? _italicized : 0) |
            (singlyUnderlined ? _singlyUnderlined : 0) |
            (doublyUnderlined && !singlyUnderlined ? _doublyUnderlined : 0) |
            (slowlyBlinking ? _slowlyBlinking : 0) |
            (rapidlyBlinking && !slowlyBlinking ? _rapidlyBlinking : 0) |
            (negative ? _negative : 0) |
            (concealed ? _concealed : 0) |
            (crossedOut ? _crossedOut : 0) |
            (framed ? _framed : 0) |
            (encircled && !framed ? _encircled : 0) |
            (overlined ? _overlined : 0) |
            (superscripted && !subscripted ? _superscripted : 0) |
            (subscripted ? _subscripted : 0);

  const SgrPlainState._(
    this._flags,
    this.foreground,
    this.background,
    this.underlineColor,
  );

  static const SgrPlainState defaults = SgrPlainState._(0, null, null, null);

  @override
  bool get isBold => _flags & _bold != 0;

  @override
  bool get isFaint => _flags & _faint != 0;

  @override
  bool get isItalicized => _flags & _italicized != 0;

  @override
  bool get isSinglyUnderlined => _flags & _singlyUnderlined != 0;

  @override
  bool get isDoublyUnderlined => _flags & _doublyUnderlined != 0;

  @override
  UnderlinedStyle? get underlinedStyle => isSinglyUnderlined
      ? UnderlinedStyle.singly
      : isDoublyUnderlined
          ? UnderlinedStyle.doubly
          : null;

  @override
  bool get isSlowlyBlinking => _flags & _slowlyBlinking != 0;

  @override
  bool get isRapidlyBlinking => _flags & _rapidlyBlinking != 0;

  @override
  BlinkingStyle? get blinkingStyle => isSlowlyBlinking
      ? BlinkingStyle.slowly
      : isRapidlyBlinking
          ? BlinkingStyle.rapidly
          : null;

  @override
  bool get isNegative => _flags & _negative != 0;

  @override
  bool get isConcealed => _flags & _concealed != 0;

  @override
  bool get isCrossedOut => _flags & _crossedOut != 0;

  @override
  bool get isFramed => _flags & _framed != 0;

  @override
  bool get isEncircled => _flags & _encircled != 0;

  @override
  FramedStyle? get framedStyle => isFramed
      ? FramedStyle.framed
      : isEncircled
          ? FramedStyle.encircled
          : null;

  @override
  bool get isOverlined => _flags & _overlined != 0;

  @override
  bool get isSuperscripted => _flags & _superscripted != 0;

  @override
  bool get isSubscripted => _flags & _subscripted != 0;

  @override
  ScriptedStyle? get scriptedStyle => isSuperscripted
      ? ScriptedStyle.superscripted
      : isSubscripted
          ? ScriptedStyle.subscripted
          : null;

  SgrPlainState _setFlags(int flags) => SgrPlainState._(
        flags,
        foreground,
        background,
        underlineColor,
      );

  @override
  SgrPlainState resetAll() => defaults;

  @override
  SgrPlainState setBold() => _setFlags(_flags | _bold);

  @override
  SgrPlainState setFaint() => _setFlags(_flags | _faint);

  @override
  SgrPlainState resetBoldAndFaint() => _setFlags(_flags & ~(_bold | _faint));

  @override
  SgrPlainState setItalicized() => _setFlags(_flags | _italicized);

  @override
  SgrPlainState resetItalicized() => _setFlags(_flags & ~_italicized);

  @override
  SgrPlainState setSinglyUnderlined() =>
      _setFlags(_flags & ~_doublyUnderlined | _singlyUnderlined);

  @override
  SgrPlainState setDoublyUnderlined() =>
      _setFlags(_flags & ~_singlyUnderlined | _doublyUnderlined);

  @override
  SgrPlainState resetUnderlined() =>
      _setFlags(_flags & ~(_singlyUnderlined | _doublyUnderlined));

  @override
  SgrPlainState setSlowlyBlinking() =>
      _setFlags(_flags & ~_rapidlyBlinking | _slowlyBlinking);

  @override
  SgrPlainState setRapidlyBlinking() =>
      _setFlags(_flags & ~_slowlyBlinking | _rapidlyBlinking);

  @override
  SgrPlainState resetBlinking() =>
      _setFlags(_flags & ~(_slowlyBlinking | _rapidlyBlinking));

  @override
  SgrPlainState setNegative() => _setFlags(_flags | _negative);

  @override
  SgrPlainState resetNegative() => _setFlags(_flags & ~_negative);

  @override
  SgrPlainState setConcealed() => _setFlags(_flags | _concealed);

  @override
  SgrPlainState resetConcealed() => _setFlags(_flags & ~_concealed);

  @override
  SgrPlainState setCrossedOut() => _setFlags(_flags | _crossedOut);

  @override
  SgrPlainState resetCrossedOut() => _setFlags(_flags & ~_crossedOut);

  @override
  SgrPlainState setFramed() => _setFlags(_flags & ~_encircled | _framed);

  @override
  SgrPlainState setEncircled() => _setFlags(_flags & ~_framed | _encircled);

  @override
  SgrPlainState resetFramedAndEncircled() =>
      _setFlags(_flags & ~(_framed | _encircled));

  @override
  SgrPlainState setOverlined() => _setFlags(_flags | _overlined);

  @override
  SgrPlainState resetOverlined() => _setFlags(_flags & ~_overlined);

  @override
  SgrPlainState setSuperscripted() =>
      _setFlags(_flags & ~_subscripted | _superscripted);

  @override
  SgrPlainState setSubscripted() =>
      _setFlags(_flags & ~_superscripted | _subscripted);

  @override
  SgrPlainState resetSuperscriptedAndSubscripted() => _setFlags(
        _flags & ~(_superscripted | _subscripted),
      );

  @override
  SgrPlainState setForeground(Color color) => SgrPlainState._(
        _flags,
        color.withPrefix('fg'),
        background,
        underlineColor,
      );

  @override
  SgrPlainState resetForeground() =>
      SgrPlainState._(_flags, null, background, underlineColor);

  @override
  SgrPlainState setBackground(Color color) => SgrPlainState._(
        _flags,
        foreground,
        color.withPrefix('bg'),
        underlineColor,
      );

  @override
  SgrPlainState resetBackground() =>
      SgrPlainState._(_flags, foreground, null, underlineColor);

  @override
  SgrPlainState setUnderlineColor(ExtendedColor color) => SgrPlainState._(
        _flags,
        foreground,
        background,
        color.withPrefix('underlineColor'),
      );

  @override
  SgrPlainState resetUnderlineColor() =>
      SgrPlainState._(_flags, foreground, background, null);

  @override
  SgrPlainState toPlainState() => this;

  @override
  String get _objectTypeName => 'SgrState';
}

enum IntensityStyle { bold, faint }

enum UnderlinedStyle { singly, doubly }

enum BlinkingStyle { slowly, rapidly }

enum FramedStyle { framed, encircled }

enum ScriptedStyle { superscripted, subscripted }
