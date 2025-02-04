part of '../parsers.dart';

sealed class AnsiUnderlineColor extends AnsiSgr {
  factory AnsiUnderlineColor._parse(RegExpMatch match, List<String> params) {
    final string = match.namedGroup('all')!;
    final secondParam = params.length >= 2 ? int.tryParse(params[1]) : null;

    switch (secondParam) {
      case 5:
        final index = params.length >= 3 ? int.tryParse(params[2]) : null;
        if (index != null && index >= 0 && index <= 255) {
          return AnsiUnderline256._(string, index);
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
            return AnsiUnderlineRgb._(string, r, g, b);
          }
        }

      default:
    }

    return AnsiUnderlineUnknown._(string);
  }

  const AnsiUnderlineColor._(super.string) : super._();
}

final class AnsiUnderlineUnknown extends AnsiUnderlineColor
    with AnsiUnrecognized {
  const AnsiUnderlineUnknown._(super.string) : super._();

  @override
  String get id => 'unknown_underline:${super.id}';

  @override
  String toString() => '$AnsiUnderlineColor(${toStringAsEscapeSquences()})';
}

final class AnsiUnderlineDefault extends AnsiUnderlineColor {
  const AnsiUnderlineDefault() : super._(underlineDefault);

  const AnsiUnderlineDefault._(super.string) : super._();

  @override
  String get id => 'underlineDefault';

  @override
  String toString() => '$AnsiUnderlineDefault()';
}

final class AnsiUnderline256 extends AnsiUnderlineColor {
  final int index;

  const AnsiUnderline256(this.index)
      : super._('$underline256Open$index$underline256Close');

  const AnsiUnderline256._(super.string, this.index) : super._();

  @override
  String get id => 'underline256'
      '${color.name.substring(0, 1).toUpperCase()}'
      '${color.name.substring(1)}';

  AnsiColors256 get color => AnsiColors256.byIndex(index);

  @override
  String toString() => '$AnsiUnderline256(color: $color)';
}

final class AnsiUnderlineRgb extends AnsiUnderlineColor {
  final int r;
  final int g;
  final int b;

  const AnsiUnderlineRgb(this.r, this.g, this.b)
      : super._('$underlineRgbOpen$r;$g;$b$underlineRgbClose');

  const AnsiUnderlineRgb._(super.string, this.r, this.g, this.b) : super._();

  @override
  String get id => 'underlineRgb($r,$g,$b)';

  @override
  String toString() => '$AnsiUnderlineRgb(r: $r, g: $g, b: $b)';
}
