part of '../parser.dart';

final class Sgr extends Csi {
  final List<CsiParam> params;
  final List<SgrFunction> functions;

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
  ) {
    final parsingState = _SgrParsingState(params, state.state);

    while (!parsingState.end) {
      switch (parsingState.currentParam) {
        case CsiParamDefault():
          parsingState
            ..state = parsingState.state.reset
            ..commitFunction(const SgrDefaultFunction());

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
              if (!_parseSimpleFunction(
                parsingState,
                _underlineFunctionFromValues(values),
              )) {
                parsingState.commitFunction(
                  SgrUnknownParamsFunction(values),
                );
              }

            default:
              if (!_parseSimpleFunction(parsingState, firstValue)) {
                parsingState.commitFunction(
                  SgrUnknownParamsFunction(values),
                );
              }
          }
      }
    }

    state.state = parsingState.state;

    return Sgr._(state.string, params, parsingState.functions);
  }

  /// The function `4:n` stands for.
  ///
  /// The kinds this package does not tell apart — curly, dotted and dashed —
  /// are read as a plain underline.
  static int _underlineFunctionFromValues(List<int> values) =>
      switch (values.length > 1 ? values[1] : 1) {
        0 => NOT_UNDERLINE,
        2 => DOUBLY_UNDERLINE,
        _ => UNDERLINE,
      };

  static bool _parseSimpleFunction<S extends State<S>>(
    _SgrParsingState<S> parsingState,
    int functionIndex,
  ) {
    final code = ControlFunctionsSGR.byIndex(functionIndex);
    if (code == null) {
      return false;
    }

    final state = parsingState.state;

    parsingState
      ..state = switch (functionIndex) {
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
        DOUBLY_UNDERLINE => state.doublyUnderline,
        NOT_BOLD_NOT_DIM => state.resetBoldAndDim,
        NOT_ITALIC => state.resetItalic,
        NOT_UNDERLINE => state.resetUnderline,
        NOT_BLINK => state.resetBlink,
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
        // 38 - FOREGROUND
        FG_DEFAULT => state.resetForeground,
        BG_BLACK => state.background(Color16.black),
        BG_RED => state.background(Color16.red),
        BG_GREEN => state.background(Color16.green),
        BG_YELLOW => state.background(Color16.yellow),
        BG_BLUE => state.background(Color16.blue),
        BG_MAGENTA => state.background(Color16.magenta),
        BG_CYAN => state.background(Color16.cyan),
        BG_WHITE => state.background(Color16.white),
        // 48 - BACKGROUND
        BG_DEFAULT => state.resetBackground,
        FRAME => state.frame,
        ENCIRCLE => state.encircle,
        OVERLINE => state.overline,
        NOT_FRAME_NOT_ENCIRCLE => state.resetFrameAndEncircle,
        NOT_OVERLINE => state.resetOverline,
        // 58 - UNDERLINE_COLOR
        UNDERLINE_COLOR_DEFAULT => state.resetUnderlineColor,
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
      }
      ..commitFunction(SgrSimpleFunction(code));

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
        if (kind.value == COLOR_256 && parsingState.availableParamsCount >= 1) {
          final index = parsingState.nextParam;

          if (index is CsiParamNumber) {
            final colorCode = Colors.byIndex(index.value);
            if (colorCode != null) {
              color = Color256(colorCode);
            }
          }
        } else if (kind.value == COLOR_RGB &&
            parsingState.availableParamsCount >= 3) {
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
      parsingState
        ..state = switch (code) {
          ControlFunctionsSGR.fg => parsingState.state.foreground(color),
          ControlFunctionsSGR.bg => parsingState.state.background(color),
          ControlFunctionsSGR.underlineColor =>
            parsingState.state.underlineColor(color),
          _ => parsingState.state,
        }
        ..commitFunction(SgrColorFunction(code, color));
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
      parsingState
        ..state = switch (code) {
          ControlFunctionsSGR.fg => parsingState.state.foreground(color),
          ControlFunctionsSGR.bg => parsingState.state.background(color),
          ControlFunctionsSGR.underlineColor =>
            parsingState.state.underlineColor(color),
          _ => parsingState.state,
        }
        ..commitFunction(SgrColorFunction(code, color));
    }
  }

  @override
  String get id => functions.join(';');

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
  // final List<AnsiCsiParam> params;
  // final List<AnsiSgrFunction> functions;
}

final class _SgrParsingState<S extends State<S>> {
  final List<CsiParam> _params;
  final List<SgrFunction> functions = [];

  int _index;
  int? _savedIndex;

  S state;

  _SgrParsingState(this._params, this.state) : _index = 0;

  bool get end => _index >= _params.length;

  CsiParam get currentParam => _params[_index];

  CsiParam get nextParam => _params[++_index];

  int get availableParamsCount => _params.length - _index - 1;

  void commitFunction(SgrFunction function) {
    functions.add(function);
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
  const SgrDefaultFunction() : super(ControlFunctionsSGR.reset);

  @override
  String toString() => code.id;
}

/// A function that is its code and nothing else: the `1` of `CSI 1 m`, bold.
final class SgrSimpleFunction extends SgrFunctionWithCode {
  const SgrSimpleFunction(super.code);

  @override
  String toString() => code.id;
}

/// A function setting one of the three colours: the foreground, the
/// background or the underline.
final class SgrColorFunction extends SgrFunctionWithCode {
  /// The colour set, under the name of the code that sets it.
  final ExtendedColor color;

  SgrColorFunction(super.code, ExtendedColor color)
      : color = color.withPrefix(code.id);

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

  const SgrUnknownParamFunction(this.number);

  @override
  String toString() => '$number';
}

/// Sub-parameters naming no function this package knows: the `99:1` of
/// `CSI 99:1 m`.
final class SgrUnknownParamsFunction extends SgrFunction {
  /// The numbers written, in the order they were written in.
  final List<int> numbers;

  SgrUnknownParamsFunction(List<int> numbers)
      : numbers = List.unmodifiable(numbers);

  @override
  String toString() => numbers.join(':');
}
