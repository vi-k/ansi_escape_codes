/// A toolkit for ANSI escape codes: writing them, and reading strings that
/// carry them.
///
/// One import for all the string work — the ready-to-use strings (`fgRed`,
/// `cursorUp`), the styles, the parser and the state it tracks, the control
/// function tables, and the same operations as `String` extensions.
///
/// Two things stand outside it. `package:ansi_escape_codes/ansi.dart` carries
/// the raw byte tables of the standard, which the ready-to-use strings are
/// built from and which neither import brings the other of. And
/// `package:ansi_escape_codes/utils.dart` carries the two functions that talk
/// to a terminal in person: they reach `dart:io`, and nothing here does, so
/// this import runs wherever Dart does.
library;

export 'src/extensions/has.dart';
export 'src/extensions/parsing.dart';
export 'src/extensions/remove.dart';
export 'src/extensions/show_control_codes.dart';
export 'src/extensions/show_escape_codes.dart';
export 'src/parsing/colors/color.dart';
export 'src/parsing/control_functions/control_functions_c0.dart';
export 'src/parsing/control_functions/control_functions_c1.dart';
export 'src/parsing/control_functions/control_functions_esc_fs.dart';
export 'src/parsing/control_functions/control_sequences.dart';
export 'src/parsing/control_functions/sgr.dart';
export 'src/parsing/parser/parser.dart';
export 'src/parsing/parser/unfinished_sequence_exception.dart';
// IntensityStyle is an internal Stack history element. Nothing public takes
// or returns it: bold and dim coexist, so no single enum value describes it.
export 'src/parsing/state/state.dart' hide IntensityStyle;
export 'src/ready_to_use/csi.dart';
export 'src/ready_to_use/esc.dart';
export 'src/ready_to_use/osc.dart';
export 'src/ready_to_use/sgr/colors256/bg256.dart';
export 'src/ready_to_use/sgr/colors256/fg256.dart';
export 'src/ready_to_use/sgr/colors256/underline256.dart';
export 'src/ready_to_use/sgr/colors256/utils.dart';
export 'src/ready_to_use/sgr/rgb/bg_rgb.dart';
export 'src/ready_to_use/sgr/rgb/fg_rgb.dart';
export 'src/ready_to_use/sgr/rgb/underline_rgb.dart';
export 'src/ready_to_use/sgr/sgr.dart';
export 'src/ready_to_use/sgr/standard_colors/standard_colors.dart';
