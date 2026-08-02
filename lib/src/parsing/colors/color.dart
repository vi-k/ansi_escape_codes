import 'package:meta/meta.dart';

import '../../internal/strings.dart';

part 'color_16.dart';
part 'color_256.dart';
part 'color_indexes.dart';
part 'color_rgb.dart';

/// A colour a terminal can be asked for: one of the sixteen it names itself
/// ([Color16]), one of the 256 in the table ([Color256]), or any of the
/// sixteen million ([ColorRgb]).
@immutable
sealed class Color {
  final String? _prefix;

  const Color([this._prefix]);

  /// What this colour is called, as `Parser.showControlFunctions` writes it:
  /// `fgRed`, `bg256Gray5`, `underlineRgb010203`.
  String get id;

  /// The same colour under a name that says what it is being set on —
  /// `fg`, `bg`, `underline` — which is what [id] reads out.
  Color withPrefix(String prefix);
}

/// A colour that only the extended sequences can set: the 256-colour table
/// and 24-bit RGB, which `CSI 38`, `CSI 48` and `CSI 58` reach.
///
/// The underline takes nothing else: the standard gives it no sixteen-colour
/// form.
sealed class ExtendedColor extends Color {
  const ExtendedColor([super._prefix]);

  @override
  ExtendedColor withPrefix(String prefix);
}
