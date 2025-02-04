//
// Constants.
//

/// Null.
const String nul = '\x00';

/// Bell.
///
/// Call for attention from an operator.
const String bel = '\x07';

/// Backspace (\b).
///
/// Move one position leftwards. Next character may overprint or replace
/// the character that was there.
const String backspace = '\b';

/// Horizontal tabulation (\t).
///
/// Move right to the next tab stop.
const String ht = '\t';

/// Line feed (\n).
///
/// Move down to the same position on the next line (some devices also moved
/// to the left column).
const String lf = '\n';

/// Form feed (\f).
///
/// Move down to the top of the next page.
const String ff = '\x0C';

/// Carriage return (\r).
///
/// Move to column zero while staying on the same line.
const String cr = '\x0D';

/// Escape.
///
/// Used to introduce an ANSI escape sequence.
const String esc = '\x1B';
