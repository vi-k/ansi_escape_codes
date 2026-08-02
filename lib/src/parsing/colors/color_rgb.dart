part of 'color.dart';

/// A 24-bit colour, set by `CSI 38;2;r;g;b` and its background and underline
/// pairs.
///
/// Not every terminal reads these; the ones that do not fall back to the
/// nearest colour they have, or ignore the sequence.
final class ColorRgb extends ExtendedColor {
  final int _value;

  /// The colour with [r] red, [g] green and [b] blue, each a byte.
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

  /// How much red, 0 to 255.
  int get r => _value >> 16;

  /// How much green, 0 to 255.
  int get g => (_value >> 8) & 0xFF;

  /// How much blue, 0 to 255.
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
