part of '../parsers.dart';

sealed class AnsiBackgroundColor extends AnsiSgr {
  factory AnsiBackgroundColor._parse(RegExpMatch match, List<String> params) {
    final string = match.namedGroup('all')!;
    final secondParam = params.length >= 2 ? int.tryParse(params[1]) : null;

    switch (secondParam) {
      case 5:
        final index = params.length >= 3 ? int.tryParse(params[2]) : null;
        if (index != null && index >= 0 && index <= 255) {
          return AnsiBackground256._(string, index);
        }

      case 2:
        if (params.length >= 5) {
          final r = int.tryParse(params[2]);
          final g = int.tryParse(params[3]);
          final b = int.tryParse(params[4]);
          if (r != null &&
              r >= 0 &&
              r <= 255 &&
              g != null &&
              g >= 0 &&
              g <= 255 &&
              b != null &&
              b >= 0 &&
              b <= 255) {
            return AnsiBackgroundRgb._(string, r, g, b);
          }
        }

      default:
    }

    return AnsiBackgroundUnknown._(string);
  }

  const AnsiBackgroundColor._(super.string) : super._();
}

final class AnsiBackgroundUnknown extends AnsiBackgroundColor
    with AnsiUnrecognized {
  const AnsiBackgroundUnknown._(super.string) : super._();

  @override
  String get id => 'unknown_background:${super.id}';

  @override
  String toString() => '$AnsiBackgroundColor(${toStringAsEscapeSquences()})';
}

final class AnsiBackgroundDefault extends AnsiBackgroundColor {
  const AnsiBackgroundDefault() : super._(bgDefault);

  const AnsiBackgroundDefault._(super.string) : super._();

  @override
  String get id => 'bgDefault';

  @override
  String toString() => '$AnsiBackgroundDefault()';
}

sealed class AnsiBackgroundStandart extends AnsiBackgroundColor {
  const AnsiBackgroundStandart._(super.string) : super._();
}

final class AnsiBackgroundBlack extends AnsiBackgroundStandart {
  const AnsiBackgroundBlack() : super._(bgBlack);

  const AnsiBackgroundBlack._(super.string) : super._();

  @override
  String get id => 'bgBlack';

  @override
  String toString() => '$AnsiBackgroundBlack()';
}

final class AnsiBackgroundRed extends AnsiBackgroundStandart {
  const AnsiBackgroundRed() : super._(bgRed);

  const AnsiBackgroundRed._(super.string) : super._();

  @override
  String get id => 'bgRed';

  @override
  String toString() => '$AnsiBackgroundRed()';
}

final class AnsiBackgroundGreen extends AnsiBackgroundStandart {
  const AnsiBackgroundGreen() : super._(bgGreen);

  const AnsiBackgroundGreen._(super.string) : super._();

  @override
  String get id => 'bgGreen';

  @override
  String toString() => '$AnsiBackgroundGreen()';
}

final class AnsiBackgroundYellow extends AnsiBackgroundStandart {
  const AnsiBackgroundYellow() : super._(bgYellow);

  const AnsiBackgroundYellow._(super.string) : super._();

  @override
  String get id => 'bgYellow';

  @override
  String toString() => '$AnsiBackgroundYellow()';
}

final class AnsiBackgroundBlue extends AnsiBackgroundStandart {
  const AnsiBackgroundBlue() : super._(bgBlue);

  const AnsiBackgroundBlue._(super.string) : super._();

  @override
  String get id => 'bgBlue';

  @override
  String toString() => '$AnsiBackgroundBlue()';
}

final class AnsiBackgroundMagenta extends AnsiBackgroundStandart {
  const AnsiBackgroundMagenta() : super._(bgMagenta);

  const AnsiBackgroundMagenta._(super.string) : super._();

  @override
  String get id => 'bgMagenta';

  @override
  String toString() => '$AnsiBackgroundMagenta()';
}

final class AnsiBackgroundCyan extends AnsiBackgroundStandart {
  const AnsiBackgroundCyan() : super._(bgCyan);

  const AnsiBackgroundCyan._(super.string) : super._();

  @override
  String get id => 'bgCyan';

  @override
  String toString() => '$AnsiBackgroundCyan()';
}

final class AnsiBackgroundWhite extends AnsiBackgroundStandart {
  const AnsiBackgroundWhite() : super._(bgWhite);

  const AnsiBackgroundWhite._(super.string) : super._();

  @override
  String get id => 'bgWhite';

  @override
  String toString() => '$AnsiBackgroundWhite()';
}

final class AnsiBackgroundBrightBlack extends AnsiBackgroundStandart {
  const AnsiBackgroundBrightBlack() : super._(bgBrightBlack);

  const AnsiBackgroundBrightBlack._(super.string) : super._();

  @override
  String get id => 'bgBrightBlack';

  @override
  String toString() => '$AnsiBackgroundBrightBlack()';
}

final class AnsiBackgroundBrightRed extends AnsiBackgroundStandart {
  const AnsiBackgroundBrightRed() : super._(bgBrightRed);

  const AnsiBackgroundBrightRed._(super.string) : super._();

  @override
  String get id => 'bgBrightRed';

  @override
  String toString() => '$AnsiBackgroundBrightRed()';
}

final class AnsiBackgroundBrightGreen extends AnsiBackgroundStandart {
  const AnsiBackgroundBrightGreen() : super._(bgBrightGreen);

  const AnsiBackgroundBrightGreen._(super.string) : super._();

  @override
  String get id => 'bgBrightGreen';

  @override
  String toString() => '$AnsiBackgroundBrightGreen()';
}

final class AnsiBackgroundBrightYellow extends AnsiBackgroundStandart {
  const AnsiBackgroundBrightYellow() : super._(bgBrightYellow);

  const AnsiBackgroundBrightYellow._(super.string) : super._();

  @override
  String get id => 'bgBrightYellow';

  @override
  String toString() => '$AnsiBackgroundBrightYellow()';
}

final class AnsiBackgroundBrightBlue extends AnsiBackgroundStandart {
  const AnsiBackgroundBrightBlue() : super._(bgBrightBlue);

  const AnsiBackgroundBrightBlue._(super.string) : super._();

  @override
  String get id => 'bgBrightBlue';

  @override
  String toString() => '$AnsiBackgroundBrightBlue()';
}

final class AnsiBackgroundBrightMagenta extends AnsiBackgroundStandart {
  const AnsiBackgroundBrightMagenta() : super._(bgBrightMagenta);

  const AnsiBackgroundBrightMagenta._(super.string) : super._();

  @override
  String get id => 'bgBrightMagenta';

  @override
  String toString() => '$AnsiBackgroundBrightMagenta()';
}

final class AnsiBackgroundBrightCyan extends AnsiBackgroundStandart {
  const AnsiBackgroundBrightCyan() : super._(bgBrightCyan);

  const AnsiBackgroundBrightCyan._(super.string) : super._();

  @override
  String get id => 'bgBrightCyan';

  @override
  String toString() => '$AnsiBackgroundBrightCyan()';
}

final class AnsiBackgroundBrightWhite extends AnsiBackgroundStandart {
  const AnsiBackgroundBrightWhite() : super._(bgBrightWhite);

  const AnsiBackgroundBrightWhite._(super.string) : super._();

  @override
  String get id => 'bgBrightWhite';

  @override
  String toString() => '$AnsiBackgroundBrightWhite()';
}

final class AnsiBackground256 extends AnsiBackgroundColor {
  final int index;

  const AnsiBackground256(this.index) : super._('$bg256Open$index$bg256Close');

  const AnsiBackground256._(super.string, this.index) : super._();

  @override
  String get id => 'bg256'
      '${color.name.substring(0, 1).toUpperCase()}'
      '${color.name.substring(1)}';

  AnsiColors256 get color => AnsiColors256.byIndex(index);

  @override
  String toString() => '$AnsiBackground256(color: $color)';
}

final class AnsiBackgroundRgb extends AnsiBackgroundColor {
  final int r;
  final int g;
  final int b;

  const AnsiBackgroundRgb(this.r, this.g, this.b)
      : super._('$bgRgbOpen$r;$g;$b$bgRgbClose');

  const AnsiBackgroundRgb._(super.string, this.r, this.g, this.b) : super._();

  @override
  String get id => 'bgRgb($r,$g,$b)';

  @override
  String toString() => '$AnsiBackgroundRgb(r: $r, g: $g, b: $b)';
}
