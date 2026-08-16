// Most of this file is the table of the sixteen colours, where the name is
// the documentation.
// ignore_for_file: public_member_api_docs

part of 'color.dart';

/// One of the sixteen colours a terminal names itself, set by `CSI 30`
/// through `CSI 37` and their high-intensity pairs.
///
/// What they look like is the terminal's business: this is the colour the
/// user chose in its settings, not a colour this package can point at.
final class Color16 extends Color {
  /// Which of the sixteen it is.
  final Colors color;

  const Color16._(this.color, [super._target]);

  @internal
  @override
  Color16 on(ColorTarget target) =>
      _target == target ? this : Color16._(color, target);

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

  /// The SGR parameter this colour is set by, counted from [offset] for the
  /// first eight and from [highOffset] for the high-intensity eight.
  ///
  /// The foreground counts from 30 and 90, the background from 40 and 100.
  int index(int offset, int highOffset) {
    final index = color.index;
    return index < 8 ? offset + index : highOffset + index - 8;
  }

  @override
  int get hashCode => Object.hash(Color16, color);

  @override
  bool operator ==(Object other) => other is Color16 && color == other.color;

  @override
  String get id => '${_target?.prefix ?? '?'}${color.name.capitalize()}';

  @override
  String toString() => '$Color16.${color.name}';
}
