part of '../parser.dart';

/// A Select Graphic Rendition sequence, `CSI ... m`: the one that says how
/// the text after it is to look.
///
/// One sequence carries any number of functions — `CSI 1;31 m` is bold and a
/// red foreground — and [functions] holds them in the order they were
/// written in.
final class Sgr extends Csi {
  /// The parameters as they were written; see [CsiParam].
  ///
  /// [functions] is the same thing read: reach for this only to see how the
  /// sequence was put together.
  final List<CsiParam> params;

  /// What the sequence does, in the order it was written in.
  final List<SgrFunction> functions;

  // Compact copies, not views: a view would keep the growable builder
  // lists alive — with the slack capacity of their backing arrays — for
  // as long as the Sgr lives, and parsed entities live long.
  Sgr._(
    super.string,
    List<CsiParam> params,
    List<SgrFunction> functions,
  )   : params = List.unmodifiable(params),
        functions = List.unmodifiable(functions),
        super._();

  static Sgr _parse<S extends State<S>>(
    _MatchingState<S> state,
    List<CsiParam> params,
    List<String> rawParams,
  ) {
    final parsingState = _SgrParsingState(
      params,
      rawParams,
      state.state,
      state.residual,
    );

    while (!parsingState.end) {
      parsingState.beginOperation();
      switch (parsingState.currentParam) {
        case CsiParamDefault():
          parsingState.commitFunction(const SgrDefaultFunction());

        case CsiParamNumber(:final value):
          switch (value) {
            case FOREGROUND:
              _parseColorFunctionFromParams(
                parsingState,
                ControlFunctionsSGR.fg,
              );

            case BACKGROUND:
              _parseColorFunctionFromParams(
                parsingState,
                ControlFunctionsSGR.bg,
              );

            case UNDERLINE_COLOR:
              _parseColorFunctionFromParams(
                parsingState,
                ControlFunctionsSGR.underlineColor,
              );

            default:
              if (!_parseSimpleFunction(parsingState, value)) {
                parsingState.commitFunction(
                  SgrUnknownParamFunction(value),
                );
              }
          }

        case CsiParamNumbers(:final values):
          final firstValue = values[0];
          switch (firstValue) {
            case FOREGROUND:
              _parseColorFunctionFromValues(
                parsingState,
                values,
                ControlFunctionsSGR.fg,
              );

            case BACKGROUND:
              _parseColorFunctionFromValues(
                parsingState,
                values,
                ControlFunctionsSGR.bg,
              );

            case UNDERLINE_COLOR:
              _parseColorFunctionFromValues(
                parsingState,
                values,
                ControlFunctionsSGR.underlineColor,
              );

            case UNDERLINE:
              _parseUnderlineFunctionFromValues(parsingState, values);

            default:
              if (!_parseSimpleFunction(parsingState, firstValue)) {
                parsingState.commitFunction(
                  SgrUnknownParamsFunction(values),
                );
              }
          }
      }
    }

    state
      ..state = parsingState.state
      ..residual = parsingState.residual;

    return Sgr._(state.string, params, parsingState.functions);
  }

  static const _unknownUnderline = Object();

  static void _parseUnderlineFunctionFromValues<S extends State<S>>(
    _SgrParsingState<S> parsingState,
    List<int> values,
  ) {
    final parsedStyle = switch (values.length > 1 ? values[1] : 1) {
      0 => null,
      1 => UnderlineStyle.singly,
      2 => UnderlineStyle.doubly,
      3 => UnderlineStyle.curly,
      4 => UnderlineStyle.dotted,
      5 => UnderlineStyle.dashed,
      _ => _unknownUnderline,
    };

    if (identical(parsedStyle, _unknownUnderline)) {
      parsingState.commitFunction(SgrUnknownParamsFunction(values));
      return;
    }

    parsingState.commitFunction(
      SgrUnderlineFunction(parsedStyle as UnderlineStyle?),
    );
  }

  static bool _parseSimpleFunction<S extends State<S>>(
    _SgrParsingState<S> parsingState,
    int functionIndex,
  ) {
    final code = ControlFunctionsSGR.byIndex(functionIndex);
    if (code == null) {
      return false;
    }

    parsingState.commitFunction(SgrSimpleFunction._of(code));

    return true;
  }

  static void _parseColorFunctionFromParams<S extends State<S>>(
    _SgrParsingState<S> parsingState,
    ControlFunctionsSGR code,
  ) {
    ExtendedColor? color;

    parsingState.savePosition();

    // The introducer is followed by the kind of colour, and the kind says how
    // many parameters it takes. Nothing else is read until the kind is known,
    // so that a broken colour gives up itself alone.
    if (parsingState.availableParamsCount >= 1) {
      final kind = parsingState.nextParam;

      if (kind is CsiParamNumber) {
        // How many arguments the kind takes is sgr_rules' knowledge,
        // shared with splitSgrFunctions.
        final args = extendedColorArgCount(kind.value);

        if (kind.value == COLOR_256 &&
            parsingState.availableParamsCount >= args) {
          final index = parsingState.nextParam;

          if (index is CsiParamNumber) {
            final colorCode = Colors.byIndex(index.value);
            if (colorCode != null) {
              color = Color256(colorCode);
            }
          }
        } else if (kind.value == COLOR_RGB &&
            parsingState.availableParamsCount >= args) {
          final r = parsingState.nextParam;
          final g = parsingState.nextParam;
          final b = parsingState.nextParam;

          if (r is CsiParamNumber &&
              g is CsiParamNumber &&
              b is CsiParamNumber) {
            try {
              // `38;2` takes three parameters, the way xterm reads it, and
              // whatever follows them belongs to the sequence as usual.
              color = ColorRgb(r.value, g.value, b.value);

              // ignore: avoid_catching_errors
            } on IndexError {
              // no-op
            }
          }
        }
      }
    }

    if (color == null) {
      parsingState.commitFunction(
        SgrUnknownColorFunctionFromParams(code, parsingState.consumedParams()),
      );
    } else {
      parsingState.commitFunction(SgrColorFunction(code, color));
    }
  }

  static void _parseColorFunctionFromValues<S extends State<S>>(
    _SgrParsingState<S> parsingState,
    List<int> values,
    ControlFunctionsSGR code,
  ) {
    ExtendedColor? color;

    if (values.length >= 3) {
      final param2 = values[1];
      final param3 = values[2];

      if (param2 == COLOR_256) {
        final colorCode = Colors.byIndex(param3);
        if (colorCode != null) {
          color = Color256(colorCode);
        }
      } else if (param2 == COLOR_RGB && values.length >= 5) {
        final threeParams = values.length == 5;
        final r = threeParams ? param3 : values[3];
        final g = threeParams ? values[3] : values[4];
        final b = threeParams ? values[4] : values[5];

        try {
          color = ColorRgb(r, g, b);

          // ignore: avoid_catching_errors
        } on IndexError {
          // no-op
        }
      }
    }

    if (color == null) {
      parsingState.commitFunction(
        SgrUnknownColorFunctionFromValues(code, values.skip(1)),
      );
    } else {
      parsingState.commitFunction(SgrColorFunction(code, color));
    }
  }

  @override
  String get id => functions.join(';');

  /// Whether the sequence carries the function [code] stands for.
  ///
  /// ```dart
  /// final sgr = Parser('$bold').pieces.first.entity as Sgr;
  /// print(sgr.contains(ControlFunctionsSGR.bold)); // true
  /// ```
  bool contains(ControlFunctionsSGR code) {
    for (final function in functions) {
      if (function is SgrFunctionWithCode && function.code == code) {
        return true;
      }
    }

    return false;
  }

  @override
  String toString() => '$Sgr(${functions.join(',')})';
}

final class _SgrParsingState<S extends State<S>> {
  final List<CsiParam> _params;
  final List<String> _rawParams;
  final List<SgrFunction> functions = [];

  int _index;
  int? _savedIndex;
  int _operationStart = 0;
  late Style _operationBefore;

  S state;
  _SgrResidual? residual;

  _SgrParsingState(
    this._params,
    this._rawParams,
    this.state,
    this.residual,
  ) : _index = 0;

  bool get end => _index >= _params.length;

  CsiParam get currentParam => _params[_index];

  CsiParam get nextParam => _params[++_index];

  int get availableParamsCount => _params.length - _index - 1;

  void beginOperation() {
    _operationStart = _index;
    _operationBefore = state.toStyle();
  }

  void commitFunction(SgrFunction function) {
    state = _applyKnownSgrFunction(state, function);
    functions.add(function);

    // The operation is thrown away for every known function while no
    // residual is open, which is most of what an ordinary string holds. The
    // string it carries costs a sublist, a join and an interpolation, and
    // its state costs a whole Style where the parser is a stacked one, so
    // the question is asked before any of that is built.
    if (_residualKeeps(residual, function)) {
      final rawParameters =
          _rawParams.sublist(_operationStart, _index + 1).join(';');
      residual = _advanceSgrResidual(
        residual,
        _operationBefore,
        _SgrOperation(
          string: '$CSI$rawParameters$SGR',
          function: function,
          state: state.toStyle(),
        ),
      );
    } else {
      residual = null;
    }

    _index++;
    _savedIndex = null;
  }

  void savePosition() {
    _savedIndex = _index + 1;
  }

  /// The parameters read since [savePosition], the current one included.
  List<CsiParam> consumedParams() => _params.sublist(
        _savedIndex ?? (throw StateError('use savePosition first')),
        _index + 1,
      );
}

S _applyKnownSgrFunction<S extends State<S>>(
  S state,
  SgrFunction function,
) =>
    switch (function) {
      SgrDefaultFunction() => state.reset,
      SgrUnderlineFunction(:final style) => switch (style) {
          null => state.resetUnderline,
          UnderlineStyle.singly => state.underline,
          UnderlineStyle.doubly => state.doublyUnderline,
          UnderlineStyle.curly => state.curlyUnderline,
          UnderlineStyle.dotted => state.dottedUnderline,
          UnderlineStyle.dashed => state.dashedUnderline,
        },
      SgrColorFunction(:final code, :final color) => switch (code) {
          ControlFunctionsSGR.fg => state.foreground(color),
          ControlFunctionsSGR.bg => state.background(color),
          ControlFunctionsSGR.underlineColor => state.underlineColor(color),
          _ => state,
        },
      SgrSimpleFunction(:final code) => _applySimpleCode(state, code),
      _ => state,
    };

S _applySimpleCode<S extends State<S>>(
  S state,
  ControlFunctionsSGR code,
) =>
    switch (code.index) {
      RESET => state.reset,
      BOLD => state.bold,
      DIM => state.dim,
      ITALIC => state.italic,
      UNDERLINE => state.underline,
      BLINK => state.blink,
      BLINK_RAPID => state.blinkRapid,
      INVERSE => state.inverse,
      INVISIBLE => state.invisible,
      STRIKETHROUGH => state.strikethrough,
      PRIMARY_FONT => state.resetFont,
      ALT_FONT_1 => state.alternativeFont1,
      ALT_FONT_2 => state.alternativeFont2,
      ALT_FONT_3 => state.alternativeFont3,
      ALT_FONT_4 => state.alternativeFont4,
      ALT_FONT_5 => state.alternativeFont5,
      ALT_FONT_6 => state.alternativeFont6,
      ALT_FONT_7 => state.alternativeFont7,
      ALT_FONT_8 => state.alternativeFont8,
      ALT_FONT_9 => state.alternativeFont9,
      FRAKTUR => state.fraktur,
      DOUBLY_UNDERLINE => state.doublyUnderline,
      NOT_BOLD_NOT_DIM => state.resetBoldAndDim,
      NOT_ITALIC => state.resetFontShape,
      NOT_UNDERLINE => state.resetUnderline,
      NOT_BLINK => state.resetBlink,
      PROPORTIONAL_SPACING => state.proportionalSpacing,
      NOT_INVERSE => state.resetInverse,
      NOT_INVISIBLE => state.resetInvisible,
      NOT_STRIKETHROUGH => state.resetStrikethrough,
      FG_BLACK => state.foreground(Color16.black),
      FG_RED => state.foreground(Color16.red),
      FG_GREEN => state.foreground(Color16.green),
      FG_YELLOW => state.foreground(Color16.yellow),
      FG_BLUE => state.foreground(Color16.blue),
      FG_MAGENTA => state.foreground(Color16.magenta),
      FG_CYAN => state.foreground(Color16.cyan),
      FG_WHITE => state.foreground(Color16.white),
      FG_DEFAULT => state.resetForeground,
      BG_BLACK => state.background(Color16.black),
      BG_RED => state.background(Color16.red),
      BG_GREEN => state.background(Color16.green),
      BG_YELLOW => state.background(Color16.yellow),
      BG_BLUE => state.background(Color16.blue),
      BG_MAGENTA => state.background(Color16.magenta),
      BG_CYAN => state.background(Color16.cyan),
      BG_WHITE => state.background(Color16.white),
      BG_DEFAULT => state.resetBackground,
      NOT_PROPORTIONAL_SPACING => state.resetProportionalSpacing,
      FRAME => state.frame,
      ENCIRCLE => state.encircle,
      OVERLINE => state.overline,
      NOT_FRAME_NOT_ENCIRCLE => state.resetFrameAndEncircle,
      NOT_OVERLINE => state.resetOverline,
      UNDERLINE_COLOR_DEFAULT => state.resetUnderlineColor,
      IDEOGRAM_UNDERLINE => state.ideogramUnderline,
      IDEOGRAM_DOUBLY_UNDERLINE => state.ideogramDoublyUnderline,
      IDEOGRAM_OVERLINE => state.ideogramOverline,
      IDEOGRAM_DOUBLY_OVERLINE => state.ideogramDoublyOverline,
      IDEOGRAM_STRESS => state.ideogramStress,
      NOT_IDEOGRAM => state.resetIdeogram,
      SUPERSCRIPT => state.superscript,
      SUBSCRIPT => state.subscript,
      NOT_SUPER_NOT_SUBSCRIPT => state.resetSuperAndSubscript,
      FG_HIGH_BLACK => state.foreground(Color16.highBlack),
      FG_HIGH_RED => state.foreground(Color16.highRed),
      FG_HIGH_GREEN => state.foreground(Color16.highGreen),
      FG_HIGH_YELLOW => state.foreground(Color16.highYellow),
      FG_HIGH_BLUE => state.foreground(Color16.highBlue),
      FG_HIGH_MAGENTA => state.foreground(Color16.highMagenta),
      FG_HIGH_CYAN => state.foreground(Color16.highCyan),
      FG_HIGH_WHITE => state.foreground(Color16.highWhite),
      BG_HIGH_BLACK => state.background(Color16.highBlack),
      BG_HIGH_RED => state.background(Color16.highRed),
      BG_HIGH_GREEN => state.background(Color16.highGreen),
      BG_HIGH_YELLOW => state.background(Color16.highYellow),
      BG_HIGH_BLUE => state.background(Color16.highBlue),
      BG_HIGH_MAGENTA => state.background(Color16.highMagenta),
      BG_HIGH_CYAN => state.background(Color16.highCyan),
      BG_HIGH_WHITE => state.background(Color16.highWhite),
      _ => state,
    };

/// One of the functions an [Sgr] sequence carries.
///
/// `CSI 1;31 m` carries two of them, and [Sgr.functions] holds them in the
/// order they were written in. Which kind each one is says how much of it the
/// parser could make out: a [SgrSimpleFunction] where the code is one it
/// names, a [SgrColorFunction] where that code sets a colour, and one of the
/// `SgrUnknown…` kinds where the numbers are none it knows.
///
/// Nothing is thrown away by not being understood: the unknown kinds keep
/// what was written, and the sequence is written back out as it came in.
sealed class SgrFunction {
  const SgrFunction();
}

/// A function whose code this package has a name for.
sealed class SgrFunctionWithCode extends SgrFunction {
  /// The SGR code this function stands for.
  final ControlFunctionsSGR code;

  const SgrFunctionWithCode(this.code);
}

/// A parameter left out, which stands for the reset: `CSI m` takes every
/// style off, as `CSI 0 m` does.
///
/// The `0` written out comes through as a [SgrSimpleFunction] carrying the
/// same code.
final class SgrDefaultFunction extends SgrFunctionWithCode {
  /// The function a parameter left out stands for.
  const SgrDefaultFunction() : super(ControlFunctionsSGR.reset);

  @override
  String toString() => code.id;
}

/// A function that is its code and nothing else: the `1` of `CSI 1 m`, bold.
final class SgrSimpleFunction extends SgrFunctionWithCode {
  /// The function [code] stands for.
  const SgrSimpleFunction(super.code);

  /// The cached instance for [code]: one function per code, not one per
  /// time the code is read.
  static SgrSimpleFunction _of(ControlFunctionsSGR code) => _cache[code.index];

  static final List<SgrSimpleFunction> _cache = List.unmodifiable([
    for (final code in ControlFunctionsSGR.values) SgrSimpleFunction(code),
  ]);

  @override
  String toString() => code.id;
}

/// An underline function written with sub-parameters: `CSI 4:n m`.
///
/// Unlike [SgrSimpleFunction], this keeps the exact decorated underline kind
/// carried by the second sub-parameter.
final class SgrUnderlineFunction extends SgrFunctionWithCode {
  /// The underline kind, or null when `4:0` resets the underline.
  final UnderlineStyle? style;

  /// The underline [style] carried by a `4:n` function.
  SgrUnderlineFunction(this.style)
      : super(
          switch (style) {
            null => ControlFunctionsSGR.resetUnderline,
            UnderlineStyle.doubly => ControlFunctionsSGR.doublyUnderline,
            _ => ControlFunctionsSGR.underline,
          },
        );

  @override
  String toString() => switch (style) {
        null => 'resetUnderline',
        UnderlineStyle.singly => 'underline',
        UnderlineStyle.doubly => 'doublyUnderline',
        UnderlineStyle.curly => 'curlyUnderline',
        UnderlineStyle.dotted => 'dottedUnderline',
        UnderlineStyle.dashed => 'dashedUnderline',
      };
}

/// A function setting one of the three colours: the foreground, the
/// background or the underline.
final class SgrColorFunction extends SgrFunctionWithCode {
  /// The colour set, under the name of the code that sets it.
  final ExtendedColor color;

  /// The [color] that [code] sets, named after where the code sets it.
  SgrColorFunction(super.code, ExtendedColor color)
      : color = switch (ColorTarget.of(code)) {
          final target? => color.on(target),
          // Only the three that set a colour reach this, and each of them has
          // a target; a code that has none leaves the colour as it came.
          null => color,
        };

  @override
  String toString() => color.id;
}

/// A colour whose parameters name no colour space this package reads: the
/// `7` of `CSI 38;7;1 m`, where a `5` or a `2` was expected.
///
/// Only the colour is given up on. The `1` after it is still read, and still
/// bold.
final class SgrUnknownColorFunctionFromParams extends SgrFunctionWithCode {
  /// The parameters as they were written, the colour space id included.
  final List<CsiParam> params;

  /// The colour [code] was setting, kept as the [params] it was written with.
  SgrUnknownColorFunctionFromParams(super.code, List<CsiParam> params)
      : params = List.unmodifiable(params);

  @override
  String toString() {
    final firstParam = params.isEmpty ? null : params[0];
    final firstNum = firstParam is CsiParamNumber ? firstParam.value : null;

    final (tag, remainder) = switch (firstNum) {
      COLOR_256 => ('256', params.skip(1)),
      COLOR_RGB => ('Rgb', params.skip(1)),
      _ => ('', params),
    };

    return '${code.id}$tag?${remainder.join(';')}';
  }
}

/// What [SgrUnknownColorFunctionFromParams] is, for a colour written with
/// sub-parameters: the `38:7:1` of `CSI 38:7:1 m`.
final class SgrUnknownColorFunctionFromValues extends SgrFunctionWithCode {
  /// The sub-parameters as they were written, the colour space id included.
  final List<int> values;

  /// The colour [code] was setting, kept as the [values] it was written with.
  SgrUnknownColorFunctionFromValues(super.code, Iterable<int> values)
      : values = List.unmodifiable(values);

  @override
  String toString() {
    final firstValue = values.isEmpty ? null : values[0];

    final (tag, remainder) = switch (firstValue) {
      COLOR_256 => ('256', values.skip(1)),
      COLOR_RGB => ('Rgb', values.skip(1)),
      _ => ('', values),
    };

    return '${code.id}$tag?${remainder.join(':')}';
  }
}

/// A parameter naming no function this package knows: the `99` of
/// `CSI 99 m`.
final class SgrUnknownParamFunction extends SgrFunction {
  /// The number written.
  final int number;

  /// The [number] that named nothing.
  const SgrUnknownParamFunction(this.number);

  @override
  String toString() => '$number';
}

/// Sub-parameters naming no function this package knows: the `99:1` of
/// `CSI 99:1 m`.
final class SgrUnknownParamsFunction extends SgrFunction {
  /// The numbers written, in the order they were written in.
  final List<int> numbers;

  /// The [numbers] that named nothing.
  SgrUnknownParamsFunction(List<int> numbers)
      : numbers = List.unmodifiable(numbers);

  @override
  String toString() => numbers.join(':');
}
