import 'package:meta/meta.dart';

import '../../internal/strings.dart';

part 'color_16.dart';
part 'color_256.dart';
part 'color_indexes.dart';
part 'color_rgb.dart';

@immutable
sealed class Color {
  final String? _prefix;

  const Color([this._prefix]);

  String get id;

  Color withPrefix(String prefix);
}

sealed class ExtendedColor extends Color {
  const ExtendedColor([super._prefix]);

  @override
  ExtendedColor withPrefix(String prefix);
}
