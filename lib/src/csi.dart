import 'common.dart';

/// CSI (Control Sequence Introducer).
const String csi = '$esc[';

/// Opening tag for Cursor Up.
///
/// Template: `{cursorUpOpen}[n]{cursorUpClose}`.
///
/// Moves the cursor up `n` (default `1`) lines.
///
/// See also [cursorUp] and [cursorUpN].
const String cursorUpOpen = csi;

/// Closing tag for Cursor Up.
///
/// Template: `{cursorUpOpen}[n]{cursorUpClose}`.
///
/// Moves the cursor up `n` (default `1`) lines.
///
/// See also [cursorUp] and [cursorUpN].
const String cursorUpClose = 'A';

/// Moves the cursor up `1` line.
///
/// See [cursorUpOpen] and [cursorUpN].
const String cursorUp = '$cursorUpOpen$cursorUpClose';

/// Moves the cursor up `n` lines.
///
/// See [cursorUpOpen] and [cursorUp].
String cursorUpN(int n) => '$cursorUpOpen$n$cursorUpClose';

/// Opening tag for Cursor Down.
///
/// Template: `cursorDow<nOpen[n]{cursorDownClose}`.
///
/// Moves the cursor down `n` (default `1`) lines.
///
/// See also [cursorDown] and [cursorDownN].
const String cursorDownOpen = csi;

/// Closing tag for Cursor Down.
///
/// Template: `{cursorDownOpen}[n]{cursorDownClose}`.
///
/// Moves the cursor down `n` (default `1`) lines.
///
/// See also [cursorDown] and [cursorDownN].
const String cursorDownClose = 'B';

/// Moves the cursor down `1` line.
///
/// See [cursorDownOpen] and [cursorDownN].
const String cursorDown = '$cursorDownOpen$cursorDownClose';

/// Moves the cursor down `n` lines.
///
/// See [cursorDownOpen] and [cursorDown].
String cursorDownN(int n) => '$cursorDownOpen$n$cursorDownClose';

/// Opening tag for Cursor Forward.
///
/// Template: `{cursorForwardOpen}[n]{cursorForwardClose}`.
///
/// Moves the cursor forward `n` (default `1`) cells.
///
/// See also [cursorForward] and [cursorForwardN].
const String cursorForwardOpen = csi;

/// Closing tag for Cursor Forward.
///
/// Template: `{cursorForwardOpen}[n]{cursorForwardClose}`.
///
/// Moves the cursor forward `n` (default `1`) cells.
///
/// See also [cursorForward] and [cursorForwardN].
const String cursorForwardClose = 'C';

/// Moves the cursor forward `1` cell.
///
/// See [cursorForwardOpen] and [cursorForwardN].
const String cursorForward = '$cursorForwardOpen$cursorForwardClose';

/// Moves the cursor forward `n` cells.
///
/// See [cursorForwardOpen] and [cursorForward].
String cursorForwardN(int n) => '$cursorForwardOpen$n$cursorForwardClose';

/// Opening tag for Cursor Back.
///
/// Template: `{cursorBackOpen}[n]{cursorBackClose}`.
///
/// Moves the cursor back `n` (default `1`) cells.
///
/// See also [cursorBack] and [cursorBackN].
const String cursorBackOpen = csi;

/// Closing tag for Cursor Back.
///
/// Template: `{cursorBackOpen}[n]{cursorBackClose}`.
///
/// Moves the cursor back `n` (default `1`) cells.
///
/// See also [cursorBack] and [cursorBackN].
const String cursorBackClose = 'D';

/// Moves the cursor back `1` cell.
///
/// See [cursorBackOpen] and [cursorBackN].
const String cursorBack = '$cursorBackOpen$cursorBackClose';

/// Moves the cursor back `n` cells.
///
/// See [cursorBackOpen] and [cursorBack].
String cursorBackN(int n) => '$cursorBackOpen$n$cursorBackClose';

/// Opening tag for Cursor Next Line.
///
/// Template: `{cursorNextLineOpen}[n]{cursorNextLineClose}`.
///
/// Moves cursor to beginning of the line `n` (default `1`) lines down.
///
/// See also [cursorNextLine] and [cursorNextLineN].
const String cursorNextLineOpen = csi;

/// Closing tag for Cursor Next Line.
///
/// Template: `{cursorNextLineOpen}[n]{cursorNextLineClose}`.
///
/// Moves cursor to beginning of the line `n` (default `1`) lines down.
///
/// See also [cursorNextLine] and [cursorNextLineN].
const String cursorNextLineClose = 'E';

/// Moves cursor to beginning of the line `1` line down.
///
/// See [cursorNextLineOpen] and [cursorNextLineN].
const String cursorNextLine = '$cursorNextLineOpen$cursorNextLineClose';

/// Moves cursor to beginning of the line `n` lines down.
///
/// See [cursorNextLineOpen] and [cursorNextLine].
String cursorNextLineN(int n) => '$cursorNextLineOpen$n$cursorNextLineClose';

/// Opening tag for Cursor Previous Line.
///
/// Template: `{cursorPrevLineOpen}[n]{cursorPrevLineClose}`.
///
/// Moves cursor to beginning of the line `n` (default `1`) lines up.
///
/// See also [cursorPrevLine] and [cursorPrevLineN].
const String cursorPrevLineOpen = csi;

/// Closing tag for Cursor Previous Line.
///
/// Template: `{cursorPrevLineOpen}[n]{cursorPrevLineClose}`.
///
/// Moves cursor to beginning of the line `n` (default `1`) lines up.
///
/// See also [cursorPrevLine] and [cursorPrevLineN].
const String cursorPrevLineClose = 'F';

/// Moves cursor to beginning of the line `1` line up.
///
/// See [cursorPrevLineOpen] and [cursorPrevLineN].
const String cursorPrevLine = '$cursorPrevLineOpen$cursorPrevLineClose';

/// Moves cursor to beginning of the line `n` line up.
///
/// See [cursorPrevLineOpen] and [cursorPrevLine].
String cursorPrevLineN(int n) => '$cursorPrevLineOpen$n$cursorPrevLineClose';

/// Opening tag for Cursor Horizontal Absolute.
///
/// Template: `{cursorHPosOpen}[n]{cursorHPosClose}`.
///
/// Moves the cursor to column `n` (default `1`).
///
/// See also [cursorHPos] and [cursorHPosN].
const String cursorHPosOpen = csi;

/// Closing tag for Cursor Horizontal Absolute.
///
/// Template: `{cursorHPosOpen}[n]{cursorHPosClose}`.
///
/// Moves the cursor to column `n` (default `1`).
///
/// See also [cursorHPos] and [cursorHPosN].
const String cursorHPosClose = 'G';

/// Moves the cursor to column `1`.
///
/// See [cursorHPosOpen] and [cursorHPosN].
const String cursorHPos = '$cursorHPosOpen$cursorHPosClose';

/// Moves the cursor to column `n`.
///
/// See [cursorHPosOpen] and [cursorHPos].
String cursorHPosN(int n) => '$cursorHPosOpen$n$cursorHPosClose';

/// Opening tag for Cursor Position.
///
/// Template: `{cursorPosOpen}[n]{cursorPosClose}`.
///
/// Moves the cursor to `row` and `column`. The values are 1-based, and default
/// to `1` (top left corner) if omitted.
///
/// See also [cursorPosToTopLeft] and [cursorPosTo].
const String cursorPosOpen = csi;

/// Closing tag for Cursor Position.
///
/// Template: `{cursorPosOpen}[n]{cursorPosClose}`.
///
/// Moves the cursor to `row` and `column`. The values are 1-based, and default
/// to `1` (top left corner) if omitted.
///
/// See also [cursorPosToTopLeft] and [cursorPosTo].
const String cursorPosClose = 'H';

/// Moves the cursor to top left corner.
///
/// See [cursorPosOpen] and [cursorPosTo].
const String cursorPosToTopLeft = '$cursorPosOpen$cursorPosClose';

/// Moves the cursor to `row` and `column`.
///
/// See [cursorPosOpen] and [cursorPosToTopLeft].
String cursorPosTo(int row, int col) =>
    '$cursorPosOpen$row;$col$cursorPosClose';

/// Opening tag for Horizontal Vertical Position.
///
/// Template: `{cursorHVPosOpen}[n]{cursorHVPosClose}`.
///
/// Same as Cursor Position, but counts as a format effector function (like
/// [cr] or [lf]) rather than an editor function (like Cursor Up or
/// Cursor Next Line). This can lead to different handling in certain terminal
/// modes.
///
/// See also [cursorHVPosToTopLeft] and [cursorHVPosTo].
const String cursorHVPosOpen = csi;

/// Closing tag for Horizontal Vertical Position.
///
/// Template: `{cursorHVPosOpen}[n]{cursorHVPosClose}`.
///
/// Same as Cursor Position, but counts as a format effector function (like
/// [cr] or [lf]) rather than an editor function (like Cursor Up or
/// Cursor Next Line). This can lead to different handling in certain terminal
/// modes.
///
/// See also [cursorHVPosToTopLeft] and [cursorHVPosTo].
const String cursorHVPosClose = 'f';

/// Moves the cursor to top left corner.
///
/// See [cursorHVPosOpen] and [cursorHVPosTo].
const String cursorHVPosToTopLeft = '$cursorHVPosOpen$cursorHVPosClose';

/// Moves the cursor to `row` and `column`.
///
/// See [cursorHVPosOpen] and [cursorHVPosToTopLeft].
String cursorHVPosTo(int row, int col) =>
    '$cursorHVPosOpen$row;$col$cursorHVPosClose';

/// Opening tag for Erase in Display (Clear Screen).
///
/// Template: `{clearScreenOpen}[n]{clearScreenClose}`.
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

/// Closing tag for Erase in Display (Clear Screen).
///
/// Template: `{clearScreenOpen}[n]{clearScreenClose}`.
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
const String clearScreenClose = 'J';

/// Clears from cursor to end of screen.
///
/// See [clearScreenOpen], [clearScreenToBegin], [clearScreen] and
/// [clearScreenWithBuf].
const String clearScreenToEnd = '$clearScreenOpen$clearScreenClose';

/// Clears from cursor to beginning of the screen.
///
/// See [clearScreenOpen], [clearScreenToEnd], [clearScreen] and
/// [clearScreenWithBuf].
const String clearScreenToBegin = '${clearScreenOpen}1$clearScreenClose';

/// Clears entire screen and moves cursor to upper left.
///
/// See [clearScreenOpen], [clearScreenToEnd], [clearScreenToBegin] and
/// [clearScreenWithBuf].
const String clearScreen = '${clearScreenOpen}2$clearScreenClose';

/// Clears entire screen and delete all lines saved in the scrollback buffer.
///
/// See [clearScreenOpen], [clearScreenToEnd], [clearScreenToBegin] and
/// [clearScreen].
const String clearScreenWithBuf = '${clearScreenOpen}3$clearScreenClose';

/// Opening tag for Erase in Line (Erase Line).
///
/// Template: `{eraseLineOpen}[n]{eraseLineClose}`.
///
/// Erase part of the screen:
/// - If n is 0 (or missing), clear from cursor to the end of the line. See
///   [eraseLineToEnd].
/// - If n is 1, clear from cursor to beginning of the line. See
///   [eraseLineToBegin].
/// - If n is 2, clear entire line. See [eraseLine].
const String eraseLineOpen = csi;

/// Closing tag for Erase in Line (Erase Line).
///
/// Template: `{eraseLineOpen}[n]{eraseLineClose}`.
///
/// Erase part of the screen:
/// - If n is 0 (or missing), clear from cursor to the end of the line. See
///   [eraseLineToEnd].
/// - If n is 1, clear from cursor to beginning of the line. See
///   [eraseLineToBegin].
/// - If n is 2, clear entire line. See [eraseLine].
const String eraseLineClose = 'K';

/// Clears from cursor to the end of the line.
///
/// See [eraseLineOpen], [eraseLineToBegin] and [eraseLine].
const String eraseLineToEnd = '$eraseLineOpen$eraseLineClose';

/// Clears from cursor to beginning of the line.
///
/// See [eraseLineOpen], [eraseLineToEnd] and [eraseLine].
const String eraseLineToBegin = '${eraseLineOpen}1$eraseLineClose';

/// Clears entire line.
///
/// See [eraseLineOpen], [eraseLineToEnd] and [eraseLineToBegin].
const String eraseLine = '${eraseLineOpen}2$eraseLineClose';

/// Opening tag for Scroll Up.
///
/// Template: `{scrollUpOpen}[n]{scrollUpClose}`.
///
/// Scroll whole page up by `n` (default `1`) lines. New lines are added at the
/// bottom.
const String scrollUpOpen = csi;

/// Closing tag for Scroll Up.
///
/// Template: `{scrollUpOpen}[n]{scrollUpClose}`.
///
/// Scroll whole page up by `n` (default `1`) lines. New lines are added at the
/// bottom.
const String scrollUpClose = 'S';

/// Scroll whole page up by `1` line.
///
/// See [scrollUpOpen] and [scrollUpN].
const String scrollUp = '$scrollUpOpen$scrollUpClose';

/// Scroll whole page up by `n` lines.
///
/// See [scrollUpOpen] and [scrollUp].
String scrollUpN(int n) => '$scrollUpOpen$n$scrollUpClose';

/// Opening tag for Scroll Down.
///
/// Template: `{scrollDownOpen}[n]{scrollDownClose}`.
///
/// Scroll whole page down by `n` (default `1`) lines. New lines are added at
/// the top.
const String scrollDownOpen = csi;

/// Closing tag for `scrollDown`.
///
/// Template: `{scrollDownOpen}[n]{scrollDownClose}`.
///
/// Scroll whole page down by `n` (default `1`) lines. New lines are added at
/// the top.
const String scrollDownClose = 'T';

/// Scroll whole page down by `1` line.
///
/// See [scrollDownOpen] and [scrollDownN].
const String scrollDown = '$scrollDownOpen$scrollDownClose';

/// Scroll whole page down by `n` lines.
///
/// See [scrollDownOpen] and [scrollDown].
String scrollDownN(int n) => '$scrollDownOpen$n$scrollDownClose';

/// Shows the cursor.
const String showCursor = '$csi?25h';

/// Hides the cursor.
const String hideCursor = '$csi?25l';
