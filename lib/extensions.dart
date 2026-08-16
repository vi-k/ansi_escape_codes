/// The same operations as methods on `String`.
///
/// `'…'.ansiRemoveEscapeCodes()`, `.lengthWithoutEscapeCodes`,
/// `.ansiHasSgr` and the rest, with the two enums their signatures name and
/// the exception the insertions throw. Each call parses the string afresh,
/// which is what makes them convenient and what makes a `Parser` worth
/// keeping where the same string is asked more than one question.
library;

export 'src/extensions/has.dart';
export 'src/extensions/parsing.dart';
export 'src/extensions/remove.dart';
export 'src/extensions/show_control_codes.dart';
export 'src/extensions/show_escape_codes.dart';
export 'src/parsing/control_functions/control_functions_c0.dart';
export 'src/parsing/parser/unfinished_sequence_exception.dart';
