part of '../parser.dart';

sealed class Csi extends EscapeCode {
  const Csi._(super.string) : super._();

  static Csi _parse<S extends State<S>>(MatchingState<S> state) {
    final finalBytes = state['csi_final']!;
    final function = ControlSequencesFunctions.byCode(finalBytes);
    if (function == null) {
      return ControlSequencesFunctions.isPrivateCode(finalBytes)
          ? CsiPrivate._(state.string)
          : CsiUnknown._(state.string);
    }

    final paramsString = state['csi_params']!;

    final firstByte =
        paramsString.isNotEmpty ? paramsString.codeUnitAt(0) : null;
    final isPrivate =
        firstByte != null && firstByte >= 0x3C && firstByte <= 0x3F;
    if (isPrivate) {
      return _privateMode(function, paramsString) ?? CsiPrivate._(state.string);
    }

    try {
      final paramsList = paramsString.split(';');
      final params = <CsiParam>[];
      for (final value in paramsList) {
        params.add(CsiParam._parse(value));
      }

      return switch (function) {
        ControlSequencesFunctions.SGR => Sgr._parse(state, params),
        _ => _named(state.string, function, params)
      };
    } on FormatException {
      return CsiUnknown._(state.string);
    }
  }

  /// The private modes that have earned a name: the pair the cursor is shown
  /// and hidden by, and the pair the alternate screen is entered and left by.
  ///
  /// The private area belongs to the terminal, and most of what is written
  /// there stays a [CsiPrivate]. These four are what every terminal in use
  /// means by them, and what this package writes with [showCursor],
  /// [hideCursor], [useAlternateScreen] and [useMainScreen].
  static Csi? _privateMode(
    ControlSequencesFunctions function,
    String params,
  ) =>
      switch ((params, function)) {
        ('?25', ControlSequencesFunctions.SM) => const ShowCursor(),
        ('?25', ControlSequencesFunctions.RM) => const HideCursor(),
        ('?1049', ControlSequencesFunctions.SM) => const UseAlternateScreen(),
        ('?1049', ControlSequencesFunctions.RM) => const UseMainScreen(),
        _ => null,
      };

  /// The sequence under the type that speaks for it, where there is one.
  ///
  /// A type promising `n` needs an `n` to promise: a sequence carrying
  /// anything but what its type says it carries stays a plain [CsiCommon]
  /// rather than being given made-up values.
  static CsiCommon _named(
    String string,
    ControlSequencesFunctions function,
    List<CsiParam> params,
  ) {
    final n = _count(params);
    if (n != null) {
      final named = switch (function) {
        ControlSequencesFunctions.CUU => CursorUp._(string, params, n),
        ControlSequencesFunctions.CUD => CursorDown._(string, params, n),
        ControlSequencesFunctions.CUF => CursorRight._(string, params, n),
        ControlSequencesFunctions.CUB => CursorLeft._(string, params, n),
        ControlSequencesFunctions.CNL => CursorNextLine._(string, params, n),
        ControlSequencesFunctions.CPL => CursorPrevLine._(string, params, n),
        ControlSequencesFunctions.CHA => CursorHPos._(string, params, n),
        ControlSequencesFunctions.SU => ScrollUp._(string, params, n),
        ControlSequencesFunctions.SD => ScrollDown._(string, params, n),
        _ => null,
      };

      if (named != null) {
        return named;
      }
    }

    // The part left out is the one from the cursor onwards, not the first
    // one, so these do not share the default the movements have.
    final part = _count(params, ifLeftOut: 0);
    if (part != null) {
      final erased = ErasePart._byCode(part);
      if (erased != null) {
        final named = switch (function) {
          ControlSequencesFunctions.ED => EraseInPage._(string, params, erased),
          ControlSequencesFunctions.EL => EraseInLine._(string, params, erased),
          _ => null,
        };

        if (named != null) {
          return named;
        }
      }
    }

    final position = _position(params);
    if (position != null) {
      final named = switch (function) {
        ControlSequencesFunctions.CUP =>
          CursorPos._(string, params, position.row, position.col),
        ControlSequencesFunctions.HVP =>
          CursorHVPos._(string, params, position.row, position.col),
        _ => null,
      };

      if (named != null) {
        return named;
      }
    }

    return CsiCommon._(string, function, params);
  }

  /// The single number a sequence carries, or null when it carries anything
  /// else.
  static int? _count(List<CsiParam> params, {int ifLeftOut = 1}) =>
      params.length == 1 ? _number(params.first, ifLeftOut: ifLeftOut) : null;

  /// The row and the column a sequence carries, or null when it carries
  /// anything else.
  ///
  /// A column left out is the first one, as a row left out is.
  static ({int row, int col})? _position(List<CsiParam> params) {
    if (params.length > 2) {
      return null;
    }

    final row = _number(params.first);
    final col = params.length == 2 ? _number(params[1]) : 1;

    return row == null || col == null ? null : (row: row, col: col);
  }

  /// The number a parameter carries, [ifLeftOut] when it is left out, or null
  /// when it carries the sub-parameters none of these sequences take.
  static int? _number(CsiParam param, {int ifLeftOut = 1}) => switch (param) {
        CsiParamDefault() => ifLeftOut,
        CsiParamNumber(:final value) => value,
        CsiParamNumbers() => null,
      };
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
      // An empty sub-parameter stands for the default value, as an empty
      // parameter does. `38:2::1:2:3` leaves out the colour space id this way.
      numbers.add(value.isEmpty ? 0 : int.parse(value));
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
  String toString() => '$Csi(${toStringAsEscapeSequences()})';
}

final class CsiPrivate extends Csi with UnrecognizedEscapeCode {
  const CsiPrivate._(super.string) : super._();

  @override
  String toString() => '$Csi(${toStringAsEscapeSequences()})';
}

/// A control sequence the parser knows the name of.
///
/// The ones that carry something worth reading — a number of lines to move
/// by, a row and a column — have a type of their own extending this: see
/// [CursorUp] and the sequences beside it. Matching [CsiCommon] catches them
/// all the same.
base class CsiCommon extends Csi {
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
  String toString() => '$Csi(${toStringAsEscapeSequences()})';
}

/// Moves the cursor up [n] lines. `CSI n A`, [ControlSequencesFunctions.CUU].
final class CursorUp extends CsiCommon {
  /// The number of lines to move by, `1` when the sequence leaves it out.
  final int n;

  CursorUp._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.CUU, params);
}

/// Moves the cursor down [n] lines. `CSI n B`,
/// [ControlSequencesFunctions.CUD].
final class CursorDown extends CsiCommon {
  /// The number of lines to move by, `1` when the sequence leaves it out.
  final int n;

  CursorDown._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.CUD, params);
}

/// Moves the cursor right [n] characters. `CSI n C`,
/// [ControlSequencesFunctions.CUF].
final class CursorRight extends CsiCommon {
  /// The number of characters to move by, `1` when the sequence leaves it out.
  final int n;

  CursorRight._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.CUF, params);
}

/// Moves the cursor left [n] characters. `CSI n D`,
/// [ControlSequencesFunctions.CUB].
final class CursorLeft extends CsiCommon {
  /// The number of characters to move by, `1` when the sequence leaves it out.
  final int n;

  CursorLeft._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.CUB, params);
}

/// Moves the cursor to the beginning of the line [n] lines down. `CSI n E`,
/// [ControlSequencesFunctions.CNL].
final class CursorNextLine extends CsiCommon {
  /// The number of lines to move by, `1` when the sequence leaves it out.
  final int n;

  CursorNextLine._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.CNL, params);
}

/// Moves the cursor to the beginning of the line [n] lines up. `CSI n F`,
/// [ControlSequencesFunctions.CPL].
final class CursorPrevLine extends CsiCommon {
  /// The number of lines to move by, `1` when the sequence leaves it out.
  final int n;

  CursorPrevLine._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.CPL, params);
}

/// Moves the cursor to column [n]. `CSI n G`,
/// [ControlSequencesFunctions.CHA].
final class CursorHPos extends CsiCommon {
  /// The column to move to, the first one when the sequence leaves it out.
  final int n;

  CursorHPos._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.CHA, params);
}

/// Moves the cursor to [row] and [col]. `CSI row ; col H`,
/// [ControlSequencesFunctions.CUP].
final class CursorPos extends CsiCommon {
  /// The row to move to, the first one when the sequence leaves it out.
  final int row;

  /// The column to move to, the first one when the sequence leaves it out.
  final int col;

  CursorPos._(String string, List<CsiParam> params, this.row, this.col)
      : super._(string, ControlSequencesFunctions.CUP, params);
}

/// Moves the cursor to [row] and [col]. `CSI row ; col f`,
/// [ControlSequencesFunctions.HVP].
///
/// The same move as [CursorPos], written the other way.
final class CursorHVPos extends CsiCommon {
  /// The row to move to, the first one when the sequence leaves it out.
  final int row;

  /// The column to move to, the first one when the sequence leaves it out.
  final int col;

  CursorHVPos._(String string, List<CsiParam> params, this.row, this.col)
      : super._(string, ControlSequencesFunctions.HVP, params);
}

/// Shows the cursor. `CSI ? 25 h`, the sequence [showCursor] is written with.
final class ShowCursor extends Csi {
  const ShowCursor() : super._(showCursor);

  @override
  String get id => 'showCursor';

  @override
  String toString() => '$ShowCursor()';
}

/// Hides the cursor. `CSI ? 25 l`, the sequence [hideCursor] is written with.
final class HideCursor extends Csi {
  const HideCursor() : super._(hideCursor);

  @override
  String get id => 'hideCursor';

  @override
  String toString() => '$HideCursor()';
}

/// Switches to the alternate screen. `CSI ? 1049 h`, the sequence
/// [useAlternateScreen] is written with.
final class UseAlternateScreen extends Csi {
  const UseAlternateScreen() : super._(useAlternateScreen);

  @override
  String get id => 'useAlternateScreen';

  @override
  String toString() => '$UseAlternateScreen()';
}

/// Switches back to the main screen. `CSI ? 1049 l`, the sequence
/// [useMainScreen] is written with.
final class UseMainScreen extends Csi {
  const UseMainScreen() : super._(useMainScreen);

  @override
  String get id => 'useMainScreen';

  @override
  String toString() => '$UseMainScreen()';
}

/// The part of the page or of the line an erasing sequence takes out.
enum ErasePart {
  /// From the cursor to the end, the cursor included.
  toEnd(0),

  /// From the beginning to the cursor, the cursor included.
  toBegin(1),

  /// The whole of it.
  all(2);

  /// The parameter standing for this part.
  final int code;

  const ErasePart(this.code);

  static ErasePart? _byCode(int code) => switch (code) {
        0 => toEnd,
        1 => toBegin,
        2 => all,
        _ => null,
      };
}

/// Erases [part] of the page. `CSI n J`, [ControlSequencesFunctions.ED].
final class EraseInPage extends CsiCommon {
  /// The part of the page to erase, [ErasePart.toEnd] when the sequence
  /// leaves it out.
  final ErasePart part;

  EraseInPage._(String string, List<CsiParam> params, this.part)
      : super._(string, ControlSequencesFunctions.ED, params);
}

/// Erases [part] of the line. `CSI n K`, [ControlSequencesFunctions.EL].
final class EraseInLine extends CsiCommon {
  /// The part of the line to erase, [ErasePart.toEnd] when the sequence
  /// leaves it out.
  final ErasePart part;

  EraseInLine._(String string, List<CsiParam> params, this.part)
      : super._(string, ControlSequencesFunctions.EL, params);
}

/// Scrolls the page up by [n] lines. `CSI n S`,
/// [ControlSequencesFunctions.SU].
final class ScrollUp extends CsiCommon {
  /// The number of lines to scroll by, `1` when the sequence leaves it out.
  final int n;

  ScrollUp._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.SU, params);
}

/// Scrolls the page down by [n] lines. `CSI n T`,
/// [ControlSequencesFunctions.SD].
final class ScrollDown extends CsiCommon {
  /// The number of lines to scroll by, `1` when the sequence leaves it out.
  final int n;

  ScrollDown._(String string, List<CsiParam> params, this.n)
      : super._(string, ControlSequencesFunctions.SD, params);
}
