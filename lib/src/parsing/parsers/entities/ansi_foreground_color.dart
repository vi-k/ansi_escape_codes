part of '../parsers.dart';

sealed class AnsiForegroundColor extends AnsiSgr {
  factory AnsiForegroundColor._parse(RegExpMatch match, List<String> params) {
    final string = match.namedGroup('all')!;
    final secondParam = params.length >= 2 ? int.tryParse(params[1]) : null;

    switch (secondParam) {
      case 5:
        final index = params.length >= 3 ? int.tryParse(params[2]) : null;
        if (index != null && index >= 0 && index <= 255) {
          return AnsiForeground256._(string, index);
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
            return AnsiForegroundRgb._(string, r, g, b);
          }
        }

      default:
    }

    return AnsiForegroundUnknown._(string);
  }

  const AnsiForegroundColor._(super.string) : super._();
}

final class AnsiForegroundUnknown extends AnsiForegroundColor
    with AnsiUnrecognized {
  const AnsiForegroundUnknown._(super.string) : super._();

  @override
  String get id => 'unknown_foreground:${super.id}';

  @override
  String toString() => '$AnsiForegroundColor(${toStringAsEscapeSquences()})';
}

final class AnsiForegroundDefault extends AnsiForegroundColor {
  const AnsiForegroundDefault() : super._(fgDefault);

  const AnsiForegroundDefault._(super.string) : super._();

  @override
  String get id => 'fgDefault';

  @override
  String toString() => '$AnsiForegroundDefault()';
}

sealed class AnsiForegroundStandart extends AnsiForegroundColor {
  const AnsiForegroundStandart._(super.string) : super._();
}

final class AnsiForegroundBlack extends AnsiForegroundStandart {
  const AnsiForegroundBlack() : super._(fgBlack);

  const AnsiForegroundBlack._(super.string) : super._();

  @override
  String get id => 'fgBlack';

  @override
  String toString() => '$AnsiForegroundBlack()';
}

final class AnsiForegroundRed extends AnsiForegroundStandart {
  const AnsiForegroundRed() : super._(fgRed);

  const AnsiForegroundRed._(super.string) : super._();

  @override
  String get id => 'fgRed';

  @override
  String toString() => '$AnsiForegroundRed()';
}

final class AnsiForegroundGreen extends AnsiForegroundStandart {
  const AnsiForegroundGreen() : super._(fgGreen);

  const AnsiForegroundGreen._(super.string) : super._();

  @override
  String get id => 'fgGreen';

  @override
  String toString() => '$AnsiForegroundGreen()';
}

final class AnsiForegroundYellow extends AnsiForegroundStandart {
  const AnsiForegroundYellow() : super._(fgYellow);

  const AnsiForegroundYellow._(super.string) : super._();

  @override
  String get id => 'fgYellow';

  @override
  String toString() => '$AnsiForegroundYellow()';
}

final class AnsiForegroundBlue extends AnsiForegroundStandart {
  const AnsiForegroundBlue() : super._(fgBlue);

  const AnsiForegroundBlue._(super.string) : super._();

  @override
  String get id => 'fgBlue';

  @override
  String toString() => '$AnsiForegroundBlue()';
}

final class AnsiForegroundMagenta extends AnsiForegroundStandart {
  const AnsiForegroundMagenta() : super._(fgMagenta);

  const AnsiForegroundMagenta._(super.string) : super._();

  @override
  String get id => 'fgMagenta';

  @override
  String toString() => '$AnsiForegroundMagenta()';
}

final class AnsiForegroundCyan extends AnsiForegroundStandart {
  const AnsiForegroundCyan() : super._(fgCyan);

  const AnsiForegroundCyan._(super.string) : super._();

  @override
  String get id => 'fgCyan';

  @override
  String toString() => '$AnsiForegroundCyan()';
}

final class AnsiForegroundWhite extends AnsiForegroundStandart {
  const AnsiForegroundWhite() : super._(fgWhite);

  const AnsiForegroundWhite._(super.string) : super._();

  @override
  String get id => 'fgWhite';

  @override
  String toString() => '$AnsiForegroundWhite()';
}

final class AnsiForegroundBrightBlack extends AnsiForegroundStandart {
  const AnsiForegroundBrightBlack() : super._(fgBrightBlack);

  const AnsiForegroundBrightBlack._(super.string) : super._();

  @override
  String get id => 'fgBrightBlack';

  @override
  String toString() => '$AnsiForegroundBrightBlack()';
}

final class AnsiForegroundBrightRed extends AnsiForegroundStandart {
  const AnsiForegroundBrightRed() : super._(fgBrightRed);

  const AnsiForegroundBrightRed._(super.string) : super._();

  @override
  String get id => 'fgBrightRed';

  @override
  String toString() => '$AnsiForegroundBrightRed()';
}

final class AnsiForegroundBrightGreen extends AnsiForegroundStandart {
  const AnsiForegroundBrightGreen() : super._(fgBrightGreen);

  const AnsiForegroundBrightGreen._(super.string) : super._();

  @override
  String get id => 'fgBrightGreen';

  @override
  String toString() => '$AnsiForegroundBrightGreen()';
}

final class AnsiForegroundBrightYellow extends AnsiForegroundStandart {
  const AnsiForegroundBrightYellow() : super._(fgBrightYellow);

  const AnsiForegroundBrightYellow._(super.string) : super._();

  @override
  String get id => 'fgBrightYellow';

  @override
  String toString() => '$AnsiForegroundBrightYellow()';
}

final class AnsiForegroundBrightBlue extends AnsiForegroundStandart {
  const AnsiForegroundBrightBlue() : super._(fgBrightBlue);

  const AnsiForegroundBrightBlue._(super.string) : super._();

  @override
  String get id => 'fgBrightBlue';

  @override
  String toString() => '$AnsiForegroundBrightBlue()';
}

final class AnsiForegroundBrightMagenta extends AnsiForegroundStandart {
  const AnsiForegroundBrightMagenta() : super._(fgBrightMagenta);

  const AnsiForegroundBrightMagenta._(super.string) : super._();

  @override
  String get id => 'fgBrightMagent';

  @override
  String toString() => '$AnsiForegroundBrightMagenta()';
}

final class AnsiForegroundBrightCyan extends AnsiForegroundStandart {
  const AnsiForegroundBrightCyan() : super._(fgBrightCyan);

  const AnsiForegroundBrightCyan._(super.string) : super._();

  @override
  String get id => 'fgBrightCyan';

  @override
  String toString() => '$AnsiForegroundBrightCyan()';
}

final class AnsiForegroundBrightWhite extends AnsiForegroundStandart {
  const AnsiForegroundBrightWhite() : super._(fgBrightWhite);

  const AnsiForegroundBrightWhite._(super.string) : super._();

  @override
  String get id => 'fgBrightWhite';

  @override
  String toString() => '$AnsiForegroundBrightWhite()';
}

final class AnsiForeground256 extends AnsiForegroundColor {
  final int index;

  const AnsiForeground256(this.index) : super._('$fg256Open$index$fg256Close');

  const AnsiForeground256._(super.string, this.index) : super._();

  @override
  String get id => 'fg256'
      '${color.name.substring(0, 1).toUpperCase()}'
      '${color.name.substring(1)}';

  AnsiColors256 get color => AnsiColors256.byIndex(index);

  @override
  String toString() => '$AnsiForeground256(color: $color)';
}

final class AnsiForegroundRgb extends AnsiForegroundColor {
  final int r;
  final int g;
  final int b;

  const AnsiForegroundRgb(this.r, this.g, this.b)
      : super._('$fgRgbOpen$r;$g;$b$fgRgbClose');

  const AnsiForegroundRgb._(super.string, this.r, this.g, this.b) : super._();

  @override
  String get id => 'fgRgb($r,$g,$b)';

  @override
  String toString() => '$AnsiForegroundRgb(r: $r, g: $g, b: $b)';
}
