part of '../ansi_parser.dart';

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

  static Sgr _parse<S extends SgrState<S>>(
    MatchingState<S> state,
    List<CsiParam> params,
  ) {
    final parsingState = _SgrParsingState(params, state.sgrState);

    while (!parsingState.end) {
      switch (parsingState.currentParam) {
        case CsiParamDefault():
          parsingState
            ..sgrState = parsingState.sgrState.resetAll()
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

            default:
              if (!_parseSimpleFunction(parsingState, firstValue)) {
                parsingState.commitFunction(
                  SgrUnknownParamsFunction(values),
                );
              }
          }
      }
    }

    state.sgrState = parsingState.sgrState;

    return Sgr._(state.string, params, parsingState.functions);
  }

  static bool _parseSimpleFunction<S extends SgrState<S>>(
    _SgrParsingState<S> parsingState,
    int functionIndex,
  ) {
    final code = ControlFunctionsSGR.byIndex(functionIndex);
    if (code == null) {
      return false;
    }

    final sgrState = parsingState.sgrState;

    parsingState
      ..sgrState = switch (functionIndex) {
        RESET => sgrState.resetAll(),
        BOLD => sgrState.setBold(),
        FAINT => sgrState.setFaint(),
        ITALICIZED => sgrState.setItalicized(),
        UNDERLINED => sgrState.setSinglyUnderlined(),
        SLOWLY_BLINKING => sgrState.setSlowlyBlinking(),
        RAPIDLY_BLINKING => sgrState.setRapidlyBlinking(),
        NEGATIVE => sgrState.setNegative(),
        CONCEALED => sgrState.setConcealed(),
        CROSSEDOUT => sgrState.setCrossedOut(),
        DOUBLY_UNDERLINED => sgrState.setDoublyUnderlined(),
        NOT_BOLD_NOT_FAINT => sgrState.resetBoldAndFaint(),
        NOT_ITALICIZED => sgrState.resetItalicized(),
        NOT_UNDERLINED => sgrState.resetUnderlined(),
        NOT_BLINKING => sgrState.resetBlinking(),
        NOT_NEGATIVE => sgrState.resetNegative(),
        NOT_CONCEALED => sgrState.resetConcealed(),
        NOT_CROSSEDOUT => sgrState.resetCrossedOut(),
        FG_BLACK => sgrState.setForeground(Color16.black),
        FG_RED => sgrState.setForeground(Color16.red),
        FG_GREEN => sgrState.setForeground(Color16.green),
        FG_YELLOW => sgrState.setForeground(Color16.yellow),
        FG_BLUE => sgrState.setForeground(Color16.blue),
        FG_MAGENTA => sgrState.setForeground(Color16.magenta),
        FG_CYAN => sgrState.setForeground(Color16.cyan),
        FG_WHITE => sgrState.setForeground(Color16.white),
        // 38 - FOREGROUND
        FG_DEFAULT => sgrState.resetForeground(),
        BG_BLACK => sgrState.setBackground(Color16.black),
        BG_RED => sgrState.setBackground(Color16.red),
        BG_GREEN => sgrState.setBackground(Color16.green),
        BG_YELLOW => sgrState.setBackground(Color16.yellow),
        BG_BLUE => sgrState.setBackground(Color16.blue),
        BG_MAGENTA => sgrState.setBackground(Color16.magenta),
        BG_CYAN => sgrState.setBackground(Color16.cyan),
        BG_WHITE => sgrState.setBackground(Color16.white),
        // 48 - BACKGROUND
        BG_DEFAULT => sgrState.resetBackground(),
        FRAMED => sgrState.setFramed(),
        ENCIRCLED => sgrState.setEncircled(),
        OVERLINED => sgrState.setOverlined(),
        NOT_FRAMED_NOT_ENCIRCLED => sgrState.resetFramedAndEncircled(),
        NOT_OVERLINED => sgrState.resetOverlined(),
        // 58 - UNDERLINE_COLOR
        UNDERLINE_COLOR_DEFAULT => sgrState.resetUnderlineColor(),
        SUPERSCRIPTED => sgrState.setSuperscripted(),
        SUBSCRIPTED => sgrState.setSubscripted(),
        NOT_SUPER_NOT_SUBSCRIPTED =>
          sgrState.resetSuperscriptedAndSubscripted(),
        FG_HIGH_BLACK => sgrState.setForeground(Color16.highBlack),
        FG_HIGH_RED => sgrState.setForeground(Color16.highRed),
        FG_HIGH_GREEN => sgrState.setForeground(Color16.highGreen),
        FG_HIGH_YELLOW => sgrState.setForeground(Color16.highYellow),
        FG_HIGH_BLUE => sgrState.setForeground(Color16.highBlue),
        FG_HIGH_MAGENTA => sgrState.setForeground(Color16.highMagenta),
        FG_HIGH_CYAN => sgrState.setForeground(Color16.highCyan),
        FG_HIGH_WHITE => sgrState.setForeground(Color16.highWhite),
        BG_HIGH_BLACK => sgrState.setBackground(Color16.highBlack),
        BG_HIGH_RED => sgrState.setBackground(Color16.highRed),
        BG_HIGH_GREEN => sgrState.setBackground(Color16.highGreen),
        BG_HIGH_YELLOW => sgrState.setBackground(Color16.highYellow),
        BG_HIGH_BLUE => sgrState.setBackground(Color16.highBlue),
        BG_HIGH_MAGENTA => sgrState.setBackground(Color16.highMagenta),
        BG_HIGH_CYAN => sgrState.setBackground(Color16.highCyan),
        BG_HIGH_WHITE => sgrState.setBackground(Color16.highWhite),
        _ => sgrState,
      }
      ..commitFunction(SgrSimpleFunction(code));

    return true;
  }

  static void _parseColorFunctionFromParams<S extends SgrState<S>>(
    _SgrParsingState<S> parsingState,
    ControlFunctionsSGR code,
  ) {
    ExtendedColor? color;

    parsingState.savePosition();

    if (parsingState.availableParamsCount >= 2) {
      final param2 = parsingState.nextParam;
      final param3 = parsingState.nextParam;

      if (param2 is CsiParamNumber && param3 is CsiParamNumber) {
        if (param2.value == COLOR_256) {
          final colorCode = Colors.byIndex(param3.value);
          if (colorCode != null) {
            color = Color256(colorCode);
          }
        } else if (param2.value == COLOR_RGB &&
            parsingState.availableParamsCount >= 2) {
          final param4 = parsingState.nextParam;
          final param5 = parsingState.nextParam;

          if (param4 is CsiParamNumber && param5 is CsiParamNumber) {
            try {
              color = ColorRgb(
                param3.value,
                param4.value,
                param5.value,
              );

              // В rgb параметров может быть больше, чем только r, g и b.
              // Трудно понять, как терминалы могут реагировать на это.
              // Поэтому лучшим вариантом вижу считать, что цвет в RGB
              // задаётся всегда отдельным блоком, и дальнейший парсинг нужно
              // отменить.
              parsingState.cancelParsing();

              // ignore: avoid_catching_errors
            } on IndexError {
              // no-op
            }
          }
        }
      }
    }

    if (color == null) {
      final availableParams = parsingState.availableParams();
      parsingState
        ..cancelParsing()
        ..commitFunction(
          SgrUnknownColorFunctionFromParams(code, availableParams),
        );
    } else {
      parsingState
        ..sgrState = switch (code) {
          ControlFunctionsSGR.fg => parsingState.sgrState.setForeground(color),
          ControlFunctionsSGR.bg => parsingState.sgrState.setBackground(color),
          ControlFunctionsSGR.underlineColor =>
            parsingState.sgrState.setUnderlineColor(color),
          _ => parsingState.sgrState,
        }
        ..commitFunction(SgrColorFunction(code, color));
    }
  }

  static void _parseColorFunctionFromValues<S extends SgrState<S>>(
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
        ..sgrState = switch (code) {
          ControlFunctionsSGR.fg => parsingState.sgrState.setForeground(color),
          ControlFunctionsSGR.bg => parsingState.sgrState.setBackground(color),
          ControlFunctionsSGR.underlineColor =>
            parsingState.sgrState.setUnderlineColor(color),
          _ => parsingState.sgrState,
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

final class _SgrParsingState<S extends SgrState<S>> {
  final List<CsiParam> _params;
  final List<SgrFunction> functions = [];

  int _index;
  int? _savedIndex;

  S sgrState;

  _SgrParsingState(this._params, this.sgrState) : _index = 0;

  bool get end => _index >= _params.length;

  CsiParam get currentParam => _params[_index];

  CsiParam get nextParam => _params[++_index];

  int get availableParamsCount => _params.length - _index - 1;

  void commitFunction(SgrFunction function) {
    functions.add(function);
    _index++;
    _savedIndex = null;
  }

  void cancelParsing() {
    _index = _params.length - 1;
  }

  void savePosition() {
    _savedIndex = _index + 1;
  }

  List<CsiParam> availableParams() => _params.sublist(
        _savedIndex ?? (throw Exception('use savePosition first')),
      );
}

sealed class SgrFunction {
  const SgrFunction();
}

sealed class SgrFunctionWithCode extends SgrFunction {
  final ControlFunctionsSGR code;

  const SgrFunctionWithCode(this.code);
}

final class SgrDefaultFunction extends SgrFunctionWithCode {
  const SgrDefaultFunction() : super(ControlFunctionsSGR.reset);

  @override
  String toString() => '';
}

final class SgrSimpleFunction extends SgrFunctionWithCode {
  const SgrSimpleFunction(super.code);

  @override
  String toString() => code.id;
}

final class SgrColorFunction extends SgrFunctionWithCode {
  final ExtendedColor color;

  SgrColorFunction(super.code, ExtendedColor color)
      : color = color.withPrefix(code.id);

  @override
  String toString() => color.id;
}

final class SgrUnknownColorFunctionFromParams extends SgrFunctionWithCode {
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

final class SgrUnknownColorFunctionFromValues extends SgrFunctionWithCode {
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

final class SgrUnknownParamFunction extends SgrFunction {
  final int number;

  const SgrUnknownParamFunction(this.number);

  @override
  String toString() => '$number';
}

final class SgrUnknownParamsFunction extends SgrFunction {
  final List<int> numbers;

  SgrUnknownParamsFunction(List<int> numbers)
      : numbers = List.unmodifiable(numbers);

  @override
  String toString() => numbers.join(':');
}
