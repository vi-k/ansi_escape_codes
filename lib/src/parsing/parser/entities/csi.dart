part of '../ansi_parser.dart';

sealed class Csi extends EscapeCode {
  const Csi._(super.string) : super._();

  static Csi _parse<S extends SgrState<S>>(MatchingState<S> state) {
    final finalBytes = state['csi_final']!;
    final function = ControlSequencesFunctions.byCode(finalBytes);
    if (function == null) {
      return CsiUnknown._(state.string);
    }

    final paramsString = state['csi_params']!;

    final firstByte =
        paramsString.isNotEmpty ? paramsString.codeUnitAt(0) : null;
    final isPrivate =
        firstByte != null && firstByte >= 0x3C && firstByte <= 0x3F;
    if (isPrivate) {
      return CsiPrivate._(state.string);
    }

    try {
      final paramsList = paramsString.split(';');
      final params = <CsiParam>[];
      for (final value in paramsList) {
        params.add(CsiParam._parse(value));
      }

      return switch (function) {
        ControlSequencesFunctions.SGR => Sgr._parse(state, params),
        _ => CsiCommon._(state.string, function, params)
      };
    } on FormatException {
      return CsiUnknown._(state.string);
    }
  }
}

sealed class CsiParam {
  factory CsiParam._parse(String param) {
    final list = param.split(':');

    if (list.length == 1) {
      return param.isEmpty
          ? const CsiParamDefault._()
          : CsiParamNumber._(int.parse(param));
    }

    final numbers = <int>[];
    for (final value in list) {
      numbers.add(int.parse(value));
    }

    return CsiParamNumbers._(numbers);
  }

  const CsiParam._();
}

final class CsiParamDefault extends CsiParam {
  const CsiParamDefault._() : super._();

  @override
  String toString() => '';
}

final class CsiParamNumber extends CsiParam {
  final int value;

  const CsiParamNumber._(this.value) : super._();

  @override
  String toString() => '$value';
}

final class CsiParamNumbers extends CsiParam {
  final List<int> values;

  CsiParamNumbers._(List<int> values)
      : values = List.unmodifiable(values),
        super._();

  @override
  String toString() => values.join(':');
}

final class CsiUnknown extends Csi with UnrecognizedEscapeCode {
  const CsiUnknown._(super.string) : super._();

  @override
  String toString() => '$Csi(${toStringAsEscapeSquences()})';
}

final class CsiPrivate extends Csi with UnrecognizedEscapeCode {
  const CsiPrivate._(super.string) : super._();

  @override
  String toString() => '$Csi(${toStringAsEscapeSquences()})';
}

final class CsiCommon extends Csi {
  final ControlSequencesFunctions controlSequence;
  final List<CsiParam> params;

  CsiCommon._(
    super.string,
    this.controlSequence,
    List<CsiParam> params,
  )   : params = List.unmodifiable(params),
        super._();

  @override
  String get id {
    final paramsStr = params.join(';');

    return '${ControlFunctionsC1.CSI.name}'
        '${paramsStr.isEmpty ? '' : ' $paramsStr'}'
        ' ${controlSequence.name}';
  }

  @override
  String toString() => '$Csi(${toStringAsEscapeSquences()})';
}
