part of '../parsers.dart';

sealed class AnsiCsi extends AnsiEscapeCode {
  factory AnsiCsi._parse(RegExpMatch match) {
    final string = match.namedGroup('all')!;
    final code = match.namedGroup('csi_final');
    final params = match.namedGroup('csi_parameters')!.split(splitterRe);

    try {
      return switch (code) {
        cursorUpClose => AnsiCursorUp._(string, _p1(params)),
        cursorDownClose => AnsiCursorDown._(string, _p1(params)),
        cursorForwardClose => AnsiCursorForward._(string, _p1(params)),
        cursorBackClose => AnsiCursorBack._(string, _p1(params)),
        cursorNextLineClose => AnsiCursorNextLine._(string, _p1(params)),
        cursorPrevLineClose => AnsiCursorPrevLine._(string, _p1(params)),
        cursorHPosClose => AnsiCursorHPos._(string, _p1(params)),
        cursorPosClose => AnsiCursorPos._(string, _p2(params)),
        cursorHVPosClose => AnsiCursorHVPos._(string, _p2(params)),
        clearScreenClose => AnsiClearScreenN._parse(string, _p1(params)),
        eraseLineClose => AnsiEraseLineN._parse(string, _p1(params)),
        scrollUpClose => AnsiScrollUp._(string, _p1(params)),
        scrollDownClose => AnsiScrollDown._(string, _p1(params)),
        sgr => AnsiSgr._parse(match),
        _ => AnsiCsiUnknown._(string),
      };
    } on FormatException {
      return AnsiCsiUnknown._(string);
    }
  }

  const AnsiCsi._(super.string) : super._();

  static int? _p1(List<String> params) {
    final param = params[0];
    if (param.isEmpty && params.length == 1) {
      return null;
    }

    return int.parse(param);
  }

  static (int, int)? _p2(List<String> params) {
    final firstParam = params[0];
    if (firstParam.isEmpty && params.length == 1) {
      return null;
    }

    final secondParam = params[1];

    return (int.parse(firstParam), int.parse(secondParam));
  }
}

final class AnsiCsiUnknown extends AnsiCsi with AnsiUnrecognized {
  const AnsiCsiUnknown._(super.string) : super._();

  @override
  String get id => 'unknown_csi:${super.id}';

  @override
  String toString() => '$AnsiCsi(${toStringAsEscapeSquences()})';
}

final class AnsiCursorUp extends AnsiSgr {
  final int? count;

  const AnsiCursorUp({this.count}) : super._(cursorUp);

  const AnsiCursorUp._(
    super.string,
    this.count,
  ) : super._();

  @override
  String get id => count == null ? 'cursorUp' : 'cursorUpN($count)';

  @override
  String toString() => '$AnsiCursorUp()';
}

final class AnsiCursorDown extends AnsiSgr {
  final int? n;

  const AnsiCursorDown({this.n}) : super._(cursorDown);

  const AnsiCursorDown._(
    super.string,
    this.n,
  ) : super._();

  @override
  String get id => n == null ? 'cursorDown' : 'cursorDownN($n)';

  @override
  String toString() => '$AnsiCursorDown()';
}

final class AnsiCursorForward extends AnsiSgr {
  final int? n;

  const AnsiCursorForward({this.n}) : super._(cursorForward);

  const AnsiCursorForward._(
    super.string,
    this.n,
  ) : super._();

  @override
  String get id => n == null ? 'cursorForward' : 'cursorForwardN($n)';

  @override
  String toString() => '$AnsiCursorForward()';
}

final class AnsiCursorBack extends AnsiSgr {
  final int? n;

  const AnsiCursorBack({this.n}) : super._(cursorBack);

  const AnsiCursorBack._(
    super.string,
    this.n,
  ) : super._();

  @override
  String get id => n == null ? 'cursorBack' : 'cursorBackN($n)';

  @override
  String toString() => '$AnsiCursorBack()';
}

final class AnsiCursorNextLine extends AnsiSgr {
  final int? n;

  const AnsiCursorNextLine({this.n}) : super._(cursorNextLine);

  const AnsiCursorNextLine._(
    super.string,
    this.n,
  ) : super._();

  @override
  String get id => n == null ? 'cursorNextLine' : 'cursorNextLineN($n)';

  @override
  String toString() => '$AnsiCursorNextLine()';
}

final class AnsiCursorPrevLine extends AnsiSgr {
  final int? n;

  const AnsiCursorPrevLine({this.n}) : super._(cursorPrevLine);

  const AnsiCursorPrevLine._(
    super.string,
    this.n,
  ) : super._();

  @override
  String get id => n == null ? 'cursorPrevLine' : 'cursorPrevLineN($n)';

  @override
  String toString() => '$AnsiCursorPrevLine()';
}

final class AnsiCursorHPos extends AnsiSgr {
  final int? n;

  const AnsiCursorHPos({this.n}) : super._(cursorHPosToBegin);

  const AnsiCursorHPos._(
    super.string,
    this.n,
  ) : super._();

  @override
  String get id => n == null ? 'cursorHPosToBegin' : 'cursorHPosTo($n)';

  @override
  String toString() => '$AnsiCursorHPos()';
}

final class AnsiCursorPos extends AnsiSgr {
  final (int, int)? pos;

  const AnsiCursorPos({this.pos}) : super._(reset);

  const AnsiCursorPos._(
    super.string,
    this.pos,
  ) : super._();

  @override
  String get id {
    final pos = this.pos;

    return pos == null
        ? 'cursorPosToTopLeft'
        : 'cursorPosTo(${pos.$1},${pos.$2})';
  }

  @override
  String toString() => '$AnsiCursorPos()';
}

final class AnsiCursorHVPos extends AnsiSgr {
  final (int, int)? pos;

  const AnsiCursorHVPos({this.pos}) : super._(reset);

  const AnsiCursorHVPos._(
    super.string,
    this.pos,
  ) : super._();

  @override
  String get id {
    final pos = this.pos;

    return pos == null
        ? 'cursorHVPosToTopLeft'
        : 'cursorHVPosTo(${pos.$1},${pos.$2})';
  }

  @override
  String toString() => '$AnsiCursorPos()';
}

sealed class AnsiClearScreenN extends AnsiSgr {
  factory AnsiClearScreenN._parse(String string, int? n) => switch (n) {
        0 || null => AnsiClearScreenToEnd._(string),
        1 => AnsiClearScreenToBegin._(string),
        2 => AnsiClearScreen._(string),
        3 => AnsiClearScreenWithBuf._(string),
        _ => AnsiClearScreenUnknown._(string, n),
      };

  const AnsiClearScreenN._(super.string) : super._();
}

final class AnsiClearScreenUnknown extends AnsiClearScreenN
    with AnsiUnrecognized {
  final int n;

  const AnsiClearScreenUnknown._(super.string, this.n) : super._();

  @override
  String get id => 'clearScreenN($n)';

  @override
  String toString() => '$AnsiClearScreenN(${toStringAsEscapeSquences()})';
}

final class AnsiClearScreenToEnd extends AnsiClearScreenN {
  const AnsiClearScreenToEnd() : super._(clearScreenToEnd);

  const AnsiClearScreenToEnd._(super.string) : super._();

  @override
  String get id => 'clearScreenToEnd';

  @override
  String toString() => '$AnsiClearScreenToEnd()';
}

final class AnsiClearScreenToBegin extends AnsiClearScreenN {
  const AnsiClearScreenToBegin() : super._(clearScreenToBegin);

  const AnsiClearScreenToBegin._(super.string) : super._();

  @override
  String get id => 'clearScreenToBegin';

  @override
  String toString() => '$AnsiClearScreenToBegin()';
}

final class AnsiClearScreen extends AnsiClearScreenN {
  const AnsiClearScreen() : super._(clearScreen);

  const AnsiClearScreen._(super.string) : super._();

  @override
  String get id => 'clearScreen';

  @override
  String toString() => '$AnsiClearScreen()';
}

final class AnsiClearScreenWithBuf extends AnsiClearScreenN {
  const AnsiClearScreenWithBuf() : super._(clearScreenWithBuf);

  const AnsiClearScreenWithBuf._(super.string) : super._();

  @override
  String get id => 'clearScreenWithBuf';

  @override
  String toString() => '$AnsiClearScreenWithBuf()';
}

sealed class AnsiEraseLineN extends AnsiSgr {
  factory AnsiEraseLineN._parse(String string, int? n) => switch (n) {
        0 || null => AnsiEraseLineToEnd._(string),
        1 => AnsiEraseLineToBegin._(string),
        2 => AnsiEraseLine._(string),
        _ => AnsiEraseLineUnknown._(string, n),
      };

  const AnsiEraseLineN._(super.string) : super._();
}

final class AnsiEraseLineUnknown extends AnsiEraseLineN with AnsiUnrecognized {
  final int n;

  const AnsiEraseLineUnknown._(super.string, this.n) : super._();

  @override
  String get id => 'eraseLineN($n)';

  @override
  String toString() => '$AnsiClearScreenN(${toStringAsEscapeSquences()})';
}

final class AnsiEraseLineToEnd extends AnsiEraseLineN {
  const AnsiEraseLineToEnd() : super._(eraseLineToEnd);

  const AnsiEraseLineToEnd._(super.string) : super._();

  @override
  String get id => 'eraseLineToEnd';

  @override
  String toString() => '$AnsiEraseLineToEnd()';
}

final class AnsiEraseLineToBegin extends AnsiEraseLineN {
  const AnsiEraseLineToBegin() : super._(eraseLineToBegin);

  const AnsiEraseLineToBegin._(super.string) : super._();

  @override
  String get id => 'eraseLineToBegin';

  @override
  String toString() => '$AnsiEraseLineToBegin()';
}

final class AnsiEraseLine extends AnsiEraseLineN {
  const AnsiEraseLine() : super._(eraseLine);

  const AnsiEraseLine._(super.string) : super._();

  @override
  String get id => 'eraseLine';

  @override
  String toString() => '$AnsiEraseLine()';
}

final class AnsiScrollUp extends AnsiSgr {
  final int? count;

  const AnsiScrollUp({this.count}) : super._(reset);

  const AnsiScrollUp._(
    super.string,
    this.count,
  ) : super._();

  @override
  String get id => count == null ? 'scrollUp' : 'scrollUpN($count)';

  @override
  String toString() => '$AnsiScrollUp()';
}

final class AnsiScrollDown extends AnsiSgr {
  final int? count;

  const AnsiScrollDown({this.count}) : super._(reset);

  const AnsiScrollDown._(
    super.string,
    this.count,
  ) : super._();

  @override
  String get id => count == null ? 'scrollDown' : 'scrollDownN($count)';

  @override
  String toString() => '$AnsiScrollDown()';
}

// /// Shows the cursor.
// const String showCursor = '$csi?25h';

// /// Hides the cursor.
// const String hideCursor = '$csi?25l';
