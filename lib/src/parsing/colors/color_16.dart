part of 'color.dart';

final class Color16 extends Color {
  final Colors color;

  const Color16._(this.color, [super._prefix]);

  @override
  Color16 withPrefix(String prefix) => Color16._(color, prefix);

  static const Color16 black = Color16._(Colors.black);

  static const Color16 red = Color16._(Colors.red);

  static const Color16 green = Color16._(Colors.green);

  static const Color16 yellow = Color16._(Colors.yellow);

  static const Color16 blue = Color16._(Colors.blue);

  static const Color16 magenta = Color16._(Colors.magenta);

  static const Color16 cyan = Color16._(Colors.cyan);

  static const Color16 white = Color16._(Colors.white);

  static const Color16 highBlack = Color16._(Colors.highBlack);

  static const Color16 highRed = Color16._(Colors.highRed);

  static const Color16 highGreen = Color16._(Colors.highGreen);

  static const Color16 highYellow = Color16._(Colors.highYellow);

  static const Color16 highBlue = Color16._(Colors.highBlue);

  static const Color16 highMagenta = Color16._(Colors.highMagenta);

  static const Color16 highCyan = Color16._(Colors.highCyan);

  static const Color16 highWhite = Color16._(Colors.highWhite);

  int index(int offset, int highOffset) {
    final index = color.index;
    return index < 8 ? offset + index : highOffset + index - 8;
  }

  @override
  int get hashCode => color.hashCode;

  @override
  bool operator ==(Object other) => other is Color16 && color == other.color;

  @override
  String get id => '${_prefix ?? '?'}${color.name.firstToUpperCase()}';

  @override
  String toString() => '$Color16($color)';
}
