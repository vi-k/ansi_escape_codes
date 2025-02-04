import 'control_codes.dart';
import 'escape_codes.dart';

/// Opening tag for [cursorUp] and [cursorUpN].
///
/// Template: `${cursorUpOpen}[${n}]${cursorUpClose}`.
///
/// Moves the cursor up `n` (default `1`) lines.
const String cursorUpOpen = csi;

/// Closing tag for [cursorUp] and [cursorUpN].
///
/// See [cursorUpOpen].
const String cursorUpClose = 'A';

/// Moves the cursor up `1` line.
///
/// See [cursorUpOpen], [cursorUpClose] and [cursorUpN].
const String cursorUp = '$cursorUpOpen$cursorUpClose';

/// Moves the cursor up [n] lines.
///
/// See [cursorUpOpen], [cursorUpClose] and [cursorUp].
String cursorUpN(int n) => '$cursorUpOpen$n$cursorUpClose';

/// Opening tag for [cursorDown] and [cursorDownN].
///
/// Template: `${cursorDownOpen}[${n}]${cursorDownClose}`.
///
/// Moves the cursor down `n` (default `1`) lines.
const String cursorDownOpen = csi;

/// Closing tag for [cursorDown] and [cursorDownN].
///
/// See [cursorDownOpen].
const String cursorDownClose = 'B';

/// Moves the cursor down `1` line.
///
/// See [cursorDownOpen], [cursorDownClose] and [cursorDownN].
const String cursorDown = '$cursorDownOpen$cursorDownClose';

/// Moves the cursor down [n] lines.
///
/// See [cursorDownOpen], [cursorDownClose] and [cursorDown].
String cursorDownN(int n) => '$cursorDownOpen$n$cursorDownClose';

/// Opening tag for [cursorForward] and [cursorForwardN].
///
/// Template: `${cursorForwardOpen}[${n}]${cursorForwardClose}`.
///
/// Moves the cursor forward `n` (default `1`) cells.
///
/// See also [cursorForward] and [cursorForwardN].
const String cursorForwardOpen = csi;

/// Closing tag for [cursorForward] and [cursorForwardN].
///
/// See [cursorForwardOpen].
const String cursorForwardClose = 'C';

/// Moves the cursor forward `1` cell.
///
/// See [cursorForwardOpen], [cursorForwardClose] and [cursorForwardN].
const String cursorForward = '$cursorForwardOpen$cursorForwardClose';

/// Moves the cursor forward [n] cells.
///
/// See [cursorForwardOpen], [cursorForwardClose] and [cursorForward].
String cursorForwardN(int n) => '$cursorForwardOpen$n$cursorForwardClose';

/// Opening tag for [cursorBack] and [cursorBackN].
///
/// Template: `${cursorBackOpen}[${n}]${cursorBackClose}`.
///
/// Moves the cursor back `n` (default `1`) cells.
const String cursorBackOpen = csi;

/// Closing tag for [cursorBack] and [cursorBackN].
///
/// See cursorBackOpen].
const String cursorBackClose = 'D';

/// Moves the cursor back `1` cell.
///
/// See [cursorBackOpen], [cursorBackClose] and [cursorBackN].
const String cursorBack = '$cursorBackOpen$cursorBackClose';

/// Moves the cursor back [n] cells.
///
/// See [cursorBackOpen], [cursorBackClose] and [cursorBack].
String cursorBackN(int n) => '$cursorBackOpen$n$cursorBackClose';

/// Opening tag for [cursorNextLine] and [cursorNextLineN].
///
/// Template: `${cursorNextLineOpen}[${n}]${cursorNextLineClose}`.
///
/// Moves cursor to beginning of the line `n` (default `1`) lines down.
const String cursorNextLineOpen = csi;

/// Closing tag for [cursorNextLine] and [cursorNextLineN].
///
/// See [cursorNextLineOpen].
const String cursorNextLineClose = 'E';

/// Moves cursor to beginning of the line `1` line down.
///
/// See [cursorNextLineOpen] and [cursorNextLineN].
const String cursorNextLine = '$cursorNextLineOpen$cursorNextLineClose';

/// Moves cursor to beginning of the line [n] lines down.
///
/// See [cursorNextLineOpen] and [cursorNextLine].
String cursorNextLineN(int n) => '$cursorNextLineOpen$n$cursorNextLineClose';

/// Opening tag for [cursorPrevLine] and [cursorPrevLineN].
///
/// Template: `${cursorPrevLineOpen}[${n}]${cursorPrevLineClose}`.
///
/// Moves cursor to beginning of the line `n` (default `1`) lines up.
const String cursorPrevLineOpen = csi;

/// Closing tag for [cursorPrevLine] and [cursorPrevLineN].
///
/// See [cursorPrevLineOpen].
const String cursorPrevLineClose = 'F';

/// Moves cursor to beginning of the line `1` line up.
///
/// See [cursorPrevLineOpen], [cursorPrevLineClose] and [cursorPrevLineN].
const String cursorPrevLine = '$cursorPrevLineOpen$cursorPrevLineClose';

/// Moves cursor to beginning of the line [n] line up.
///
/// See [cursorPrevLineOpen], [cursorPrevLineClose] and [cursorPrevLine].
String cursorPrevLineN(int n) => '$cursorPrevLineOpen$n$cursorPrevLineClose';

/// Opening tag for [cursorHPosToBegin] and [cursorHPosTo].
///
/// Template: `${cursorHPosOpen}[${n}]${cursorHPosClose}`.
///
/// Moves the cursor to column `n` (default `1`).
const String cursorHPosOpen = csi;

/// Closing tag for Cursor Horizontal Absolute.
///
/// See [cursorHPosOpen].
const String cursorHPosClose = 'G';

/// Moves the cursor to column `1`.
///
/// See [cursorHPosOpen], [cursorHPosClose] and [cursorHPosTo].
const String cursorHPosToBegin = '$cursorHPosOpen$cursorHPosClose';

/// Moves the cursor to column [n].
///
/// See [cursorHPosOpen], [cursorHPosClose] and [cursorHPosToBegin].
String cursorHPosTo(int n) => '$cursorHPosOpen$n$cursorHPosClose';

/// Opening tag for [cursorPosToTopLeft] and [cursorPosTo].
///
/// Template: `${cursorPosOpen}[${row};${col}]${cursorPosClose}`.
///
/// Moves the cursor to `row` and `col`. The values are 1-based, and default
/// to `1` (top left corner) if omitted.
const String cursorPosOpen = csi;

/// Closing tag for Cursor Position.
///
/// See [cursorPosOpen].
const String cursorPosClose = 'H';

/// Moves the cursor to top left corner.
///
/// See [cursorPosOpen], [cursorPosClose] and [cursorPosTo].
const String cursorPosToTopLeft = '$cursorPosOpen$cursorPosClose';

/// Moves the cursor to [row] and [col].
///
/// See [cursorPosOpen], [cursorPosClose] and [cursorPosToTopLeft].
String cursorPosTo(int row, int col) =>
    '$cursorPosOpen$row;$col$cursorPosClose';

/// Opening tag for [cursorHVPosToTopLeft] and [cursorHVPosTo].
///
/// Template: `${cursorHVPosOpen}[${row};${col}]${cursorHVPosClose}`.
///
/// Same as [cursorPosOpen]/[cursorPosClose], but counts as a format effector
/// function (like [cr] or [lf]) rather than an editor function (like
/// [cursorUp] or [cursorNextLine]. This can lead to different handling in
/// certain terminal modes.
///
/// See also [cursorHVPosToTopLeft] and [cursorHVPosTo].
const String cursorHVPosOpen = csi;

/// Closing tag for [cursorHVPosToTopLeft] and [cursorHVPosTo].
///
/// See [cursorHVPosOpen].
const String cursorHVPosClose = 'f';

/// Moves the cursor to top left corner.
///
/// See [cursorHVPosOpen], [cursorHVPosClose] and [cursorHVPosTo].
const String cursorHVPosToTopLeft = '$cursorHVPosOpen$cursorHVPosClose';

/// Moves the cursor to [row] and [col].
///
/// See [cursorHVPosOpen]cursorHVPosClose and [cursorHVPosToTopLeft].
String cursorHVPosTo(int row, int col) =>
    '$cursorHVPosOpen$row;$col$cursorHVPosClose';

/// Opening tag for [clearScreenToEnd], [clearScreenToBegin], [clearScreen] and
/// [clearScreenWithBuf].
///
/// Template: `${clearScreenOpen}[${n}]${clearScreenClose}`.
///
/// Clears part of the screen:
/// - If `n` is `0` (or missing), clear from cursor to end of screen. See
///   [clearScreenToEnd].
/// - If `n` is `1`, clear from cursor to beginning of the screen. See
///   [clearScreenToBegin].
/// - If `n` is `2`, clear entire screen and moves cursor to upper left. See
///   [clearScreen].
/// - If `n` is `3`, clear entire screen and delete all lines saved in the
///   scrollback buffer. See [clearScreenWithBuf].
const String clearScreenOpen = csi;

/// Closing tag for [clearScreenToEnd], [clearScreenToBegin], [clearScreen] and
/// [clearScreenWithBuf].
///
/// See [clearScreenOpen].
const String clearScreenClose = 'J';

/// Clears from cursor to end of screen.
///
/// See [clearScreenOpen], [clearScreenClose], [clearScreenToBegin],
/// [clearScreen] and [clearScreenWithBuf].
const String clearScreenToEnd = '$clearScreenOpen$clearScreenClose';

/// Clears from cursor to beginning of the screen.
///
/// See [clearScreenOpen], [clearScreenClose], [clearScreenToEnd],
/// [clearScreen] and [clearScreenWithBuf].
const String clearScreenToBegin = '${clearScreenOpen}1$clearScreenClose';

/// Clears entire screen and moves cursor to upper left.
///
/// See [clearScreenOpen], [clearScreenClose], [clearScreenToEnd],
/// [clearScreenToBegin] and [clearScreenWithBuf].
const String clearScreen = '${clearScreenOpen}2$clearScreenClose';

/// Clears entire screen and delete all lines saved in the scrollback buffer.
///
/// See [clearScreenOpen], [clearScreenClose], [clearScreenToEnd],
/// [clearScreenToBegin] and [clearScreen].
const String clearScreenWithBuf = '${clearScreenOpen}3$clearScreenClose';

/// Opening tag for [eraseLineToEnd], [eraseLineToBegin] and [eraseLine].
///
/// Template: `${eraseLineOpen}[${n}]${eraseLineClose}`.
///
/// Erase part of the screen:
/// - If n is 0 (or missing), clear from cursor to the end of the line. See
///   [eraseLineToEnd].
/// - If n is 1, clear from cursor to beginning of the line. See
///   [eraseLineToBegin].
/// - If n is 2, clear entire line. See [eraseLine].
const String eraseLineOpen = csi;

/// Closing tag for [eraseLineToEnd], [eraseLineToBegin] and [eraseLine].
///
/// See [eraseLineOpen].
const String eraseLineClose = 'K';

/// Clears from cursor to the end of the line.
///
/// See [eraseLineOpen], [eraseLineClose], [eraseLineToBegin] and [eraseLine].
const String eraseLineToEnd = '$eraseLineOpen$eraseLineClose';

/// Clears from cursor to beginning of the line.
///
/// See [eraseLineOpen], [eraseLineClose], [eraseLineToEnd] and [eraseLine].
const String eraseLineToBegin = '${eraseLineOpen}1$eraseLineClose';

/// Clears entire line.
///
/// See [eraseLineOpen], [eraseLineClose], [eraseLineToEnd] and
/// [eraseLineToBegin].
const String eraseLine = '${eraseLineOpen}2$eraseLineClose';

/// Opening tag for [scrollUp] and [scrollUpN].
///
/// Template: `${scrollUpOpen}[${n}]${scrollUpClose}`.
///
/// Scroll whole page up by `n` (default `1`) lines. New lines are added at the
/// bottom.
const String scrollUpOpen = csi;

/// Closing tag for [scrollUp] and [scrollUpN].
///
/// See [scrollUpOpen].
const String scrollUpClose = 'S';

/// Scroll whole page up by `1` line.
///
/// See [scrollUpOpen], [scrollUpClose] and [scrollUpN].
const String scrollUp = '$scrollUpOpen$scrollUpClose';

/// Scroll whole page up by [n] lines.
///
/// See [scrollUpOpen], [scrollUpClose] and [scrollUp].
String scrollUpN(int n) => '$scrollUpOpen$n$scrollUpClose';

/// Opening tag for [scrollDown] and [scrollDownN].
///
/// Template: `{scrollDownOpen}[${n}]{scrollDownClose}`.
///
/// Scroll whole page down by `n` (default `1`) lines. New lines are added at
/// the top.
const String scrollDownOpen = csi;

/// Closing tag for [scrollDown] and [scrollDownN].
///
/// See [scrollDownOpen].
const String scrollDownClose = 'T';

/// Scroll whole page down by `1` line.
///
/// See [scrollDownOpen], [scrollDownClose] and [scrollDownN].
const String scrollDown = '$scrollDownOpen$scrollDownClose';

/// Scroll whole page down by [n] lines.
///
/// See [scrollDownOpen], [scrollDownClose] and [scrollDown].
String scrollDownN(int n) => '$scrollDownOpen$n$scrollDownClose';

/// SGR (Select Graphic Rendition): `$csi{n}m`.
const String sgr = 'm';

/// Shows the cursor.
const String showCursor = '$csi?25h';

/// Hides the cursor.
const String hideCursor = '$csi?25l';
