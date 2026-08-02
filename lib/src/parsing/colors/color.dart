import 'package:meta/meta.dart';

import '../../internal/strings.dart';
import '../control_functions/sgr.dart';

part 'color_16.dart';
part 'color_256.dart';
part 'color_indexes.dart';
part 'color_rgb.dart';

/// What a colour is being set on.
///
/// A colour is a colour until it is used; this says which of the three the
/// terminal is being asked to paint, and gives [Color.id] the name to answer
/// with.
enum ColorTarget {
  /// The text itself, `CSI 38`.
  foreground(ControlFunctionsSGR.fg),

  /// What is behind the text, `CSI 48`.
  background(ControlFunctionsSGR.bg),

  /// The line under the text, `CSI 58`.
  underline(ControlFunctionsSGR.underlineColor);

  /// The SGR function that sets a colour there.
  final ControlFunctionsSGR code;

  const ColorTarget(this.code);

  /// The name the constants for this target begin with: `fg`, `bg`,
  /// `underline`.
  ///
  /// Taken from [code], so that the constants and the identifiers cannot
  /// drift apart.
  String get prefix => code.id;

  /// The target [code] sets a colour on, or null where it sets none.
  static ColorTarget? of(ControlFunctionsSGR code) => switch (code) {
        ControlFunctionsSGR.fg => foreground,
        ControlFunctionsSGR.bg => background,
        ControlFunctionsSGR.underlineColor => underline,
        _ => null,
      };
}

/// A colour a terminal can be asked for: one of the sixteen it names itself
/// ([Color16]), one of the 256 in the table ([Color256]), or any of the
/// sixteen million ([ColorRgb]).
@immutable
sealed class Color {
  final ColorTarget? _target;

  const Color([this._target]);

  /// What this colour is called, as `Parser.showControlFunctions` writes it:
  /// `fgRed`, `bg256Gray5`, `underlineRgb(1,2,3)`.
  ///
  /// A colour that has not been set on anything yet has no such name, and
  /// answers with a `?` where the target would be.
  String get id;

  /// The same colour, set on [target] — which is what [id] then names it by.
  Color on(ColorTarget target);
}

/// A colour that only the extended sequences can set: the 256-colour table
/// and 24-bit RGB, which `CSI 38`, `CSI 48` and `CSI 58` reach.
///
/// The underline takes nothing else: the standard gives it no sixteen-colour
/// form.
sealed class ExtendedColor extends Color {
  const ExtendedColor([super._target]);

  @override
  ExtendedColor on(ColorTarget target);
}
