part of 'color.dart';

final class Color256 extends ExtendedColor {
  final Colors color;

  const Color256(this.color);

  const Color256._(this.color, [super._prefix]);

  @override
  Color256 withPrefix(String prefix) => Color256._(color, prefix);

  int get index => color.index;

  @override
  int get hashCode => color.hashCode;

  @override
  bool operator ==(Object other) => other is Color256 && color == other.color;

  @override
  String get id => '${_prefix ?? '?'}256${color.name.firstToUpperCase()}';

  @override
  String toString() => '$Color256($color)';
}
