part of 'color.dart';

final class ColorRgb extends ExtendedColor {
  final int _value;

  factory ColorRgb(int r, int g, int b) {
    IndexError.check(r, 256, name: 'r');
    IndexError.check(g, 256, name: 'g');
    IndexError.check(b, 256, name: 'b');

    final value = r << 16 | g << 8 | b;

    return ColorRgb._(value);
  }

  const ColorRgb._(this._value, [super._prefix]);

  @override
  ColorRgb withPrefix(String prefix) => ColorRgb._(_value, prefix);

  int get r => _value >> 16;

  int get g => (_value >> 8) & 0xFF;

  int get b => _value & 0xFF;

  @override
  int get hashCode => _value.hashCode;

  @override
  bool operator ==(Object other) => other is ColorRgb && _value == other._value;

  @override
  String get id => '${_prefix ?? '?'}Rgb($r,$g,$b)';

  @override
  String toString() => '$ColorRgb($r, $g, $b)';
}
