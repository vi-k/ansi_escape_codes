/// The styles, the state and the parser, without the tables of constants.
///
/// A program that reads escape codes rather than writing them has no use for
/// the several hundred ready-to-use strings the main import also brings, and
/// this is the same surface without them. The styles and the parser live in
/// one library, so both come together: writing a style and reading one back
/// are two halves of the same thing.
library;

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
