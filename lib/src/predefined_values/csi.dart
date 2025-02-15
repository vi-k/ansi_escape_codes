import '../controls/c1.dart';
import '../controls/csi.dart';

/// Cursor Up: opening tag.
///
/// See [CUU].
///
/// Template: `'$cursorUpOpen[$n]$cursorUpClose'`.
///
/// See also [cursorUp] and [cursorUpN].
const String cursorUpOpen = CSI;

/// Cursor Up: closing tag.
///
/// See [CUU].
///
/// Template: `'$cursorUpOpen[$n]$cursorUpClose'`.
///
/// See also [cursorUp] and [cursorUpN].
const String cursorUpClose = CUU;

/// Cursor Up: moves the cursor up `1` line.
///
/// See [CUU].
///
/// See also [cursorUpOpen], [cursorUpClose] and [cursorUpN].
const String cursorUp = '$cursorUpOpen$cursorUpClose';

/// Cursor Up: moves the cursor up [n] lines.
///
/// See also [cursorUpOpen], [cursorUpClose] and [cursorUp].
String cursorUpN(int n) => '$cursorUpOpen$n$cursorUpClose';

/// Cursor Down: opening tag.
///
/// See [CUD].
///
/// Template: `'$cursorDownOpen[$n]$cursorDownClose'`.
///
/// See also [cursorDown] and [cursorDownN].
const String cursorDownOpen = CSI;

/// Cursor Down: closing tag.
///
/// See [CUD].
///
/// Template: `'$cursorDownOpen[$n]$cursorDownClose'`.
///
/// See also [cursorDown] and [cursorDownN].
const String cursorDownClose = CUB;

/// Cursor Down: moves the cursor up `1` line.
///
/// See [CUD].
///
/// See also [cursorDownOpen], [cursorDownClose] and [cursorDownN].
const String cursorDown = '$cursorDownOpen$cursorDownClose';

/// Cursor Down: moves the cursor up [n] line.
///
/// See [CUD].
///
/// See also [cursorDownOpen], [cursorDownClose] and [cursorDownN].
String cursorDownN(int n) => '$cursorDownOpen$n$cursorDownClose';

/// Cursor Right: opening tag.
///
/// See [CUF].
///
/// Template: `'$cursorRightOpen[$n]$cursorRightClose'`.
///
/// See also [cursorRight] and [cursorRightN].
const String cursorRightOpen = CSI;

/// Cursor Right: closing tag.
///
/// See [CUF].
///
/// Template: `'$cursorRightOpen[$n]$cursorRightClose'`.
///
/// See also [cursorRight] and [cursorRightN].
const String cursorRightClose = CUF;

/// Cursor Right: moves the cursor right `1` line.
///
/// See [CUF].
///
/// See also [cursorRightOpen], [cursorRightClose] and [cursorRightN].
const String cursorRight = '$cursorRightOpen$cursorRightClose';

/// Cursor Right: moves the cursor right [n] line.
///
/// See [CUF].
///
/// See also [cursorRightOpen], [cursorRightClose] and [cursorRightN].
String cursorRightN(int n) => '$cursorRightOpen$n$cursorRightClose';

/// Cursor Left: opening tag.
///
/// See [CUB].
///
/// Template: `'$cursorLeftOpen[$n]$cursorLeftClose'`.
///
/// See also [cursorLeft] and [cursorLeftN].
const String cursorLeftOpen = CSI;

/// Cursor Left: closing tag.
///
/// See [CUB].
///
/// Template: `'$cursorLeftOpen[$n]$cursorLeftClose'`.
///
/// See also [cursorLeft] and [cursorLeftN].
const String cursorLeftClose = CUB;

/// Cursor Left: moves the cursor left `1` line.
///
/// See [CUB].
///
/// See also [cursorLeftOpen], [cursorLeftClose] and [cursorLeftN].
const String cursorLeft = '$cursorLeftOpen$cursorLeftClose';

/// Cursor Left: moves the cursor left [n] line.
///
/// See [CUB].
///
/// See also [cursorLeftOpen], [cursorLeftClose] and [cursorLeftN].
String cursorLeftN(int n) => '$cursorLeftOpen$n$cursorLeftClose';

/// Cursor Next Line: opening tag.
///
/// See [CNL].
///
/// Template: `'$cursorNextLineOpen[$n]$cursorNextLineClose'`.
///
/// See also [cursorNextLine] and [cursorNextLineN].
const String cursorNextLineOpen = CSI;

/// Cursor Next Line: closing tag.
///
/// See [CNL].
///
/// Template: `'$cursorNextLineOpen[$n]$cursorNextLineClose'`.
///
/// See also [cursorNextLine] and [cursorNextLineN].
const String cursorNextLineClose = CNL;

/// Cursor Next Line: moves cursor to beginning of the line `1` line down.
///
/// See [CNL].
///
/// See also [cursorNextLineOpen], [cursorNextLineClose] and [cursorNextLineN].
const String cursorNextLine = '$cursorNextLineOpen$cursorNextLineClose';

/// Cursor Next Line: moves cursor to beginning of the line [n] line down.
///
/// See [CNL].
///
/// See also [cursorNextLineOpen], [cursorNextLineClose] and [cursorNextLineN].
String cursorNextLineN(int n) => '$cursorNextLineOpen$n$cursorNextLineClose';

/// Cursor Preceding Line: opening tag.
///
/// See [CPL].
///
/// Template: `'$cursorPrevLineOpen[$n]$cursorPrevLineClose'`.
///
/// See also [cursorPrevLine] and [cursorPrevLineN].
const String cursorPrevLineOpen = CSI;

/// Cursor Preceding Line: closing tag.
///
/// See [CPL].
///
/// Template: `'$cursorPrevLineOpen[$n]$cursorPrevLineClose'`.
///
/// See also [cursorPrevLine] and [cursorPrevLineN].
const String cursorPrevLineClose = CPL;

/// Cursor Preceding Line: moves cursor to beginning of the line `1` line up.
///
/// See [CPL].
///
/// See also [cursorPrevLineOpen], [cursorPrevLineClose] and [cursorPrevLineN].
const String cursorPrevLine = '$cursorPrevLineOpen$cursorPrevLineClose';

/// Cursor Preceding Line: moves cursor to beginning of the line [n] line up.
///
/// See [CPL].
///
/// See also [cursorPrevLineOpen], [cursorPrevLineClose] and [cursorPrevLineN].
String cursorPrevLineN(int n) => '$cursorPrevLineOpen$n$cursorPrevLineClose';

/// Cursor Character Absolute: opening tag.
///
/// See [CHA].
///
/// Template: `'$cursorHPosOpen[$n]$cursorHPosClose'`.
///
/// See also [cursorHPosToBegin] and [cursorHPosTo].
const String cursorHPosOpen = CSI;

/// Cursor Character Absolute: closing tag.
///
/// See [CHA].
///
/// Template: `'$cursorHPosOpen[$n]$cursorHPosClose'`.
///
/// See also [cursorHPosToBegin] and [cursorHPosTo].
const String cursorHPosClose = CHA;

/// Cursor Character Absolute: moves the cursor to column `1`.
///
/// See [CHA].
///
/// See also [cursorHPosOpen], [cursorHPosClose] and [cursorHPosTo].
const String cursorHPosToBegin = '$cursorHPosOpen$cursorHPosClose';

/// Cursor Character Absolute: moves the cursor to column [n].
///
/// See [CHA].
///
/// See also [cursorHPosOpen], [cursorHPosClose] and [cursorHPosTo].
String cursorHPosTo(int n) => '$cursorHPosOpen$n$cursorHPosClose';

/// Cursor Position: opening tag.
///
/// See [CUP].
///
/// Template: `'$cursorPosOpen[$n]$cursorPosClose'`.
///
/// See also [cursorPosToTopLeft] and [cursorPosTo].
const String cursorPosOpen = CSI;

/// Cursor Position: closing tag.
///
/// See [CUP].
///
/// Template: `'$cursorPosOpen[$n]$cursorPosClose'`.
///
/// See also [cursorPosToTopLeft] and [cursorPosTo].
const String cursorPosClose = CUP;

/// Cursor Position: moves the cursor to top left corner.
///
/// See [CUP].
///
/// See also [cursorPosOpen], [cursorPosClose] and [cursorPosTo].
const String cursorPosToTopLeft = '$cursorPosOpen$cursorPosClose';

/// Cursor Position: moves the cursor to to [row] and [col].
///
/// See [CUP].
///
/// See also [cursorPosOpen], [cursorPosClose] and [cursorPosTo].
String cursorPosTo(int row, int col) =>
    '$cursorPosOpen$row;$col$cursorPosClose';

/// Character And Line Position: opening tag.
///
/// See [HVP].
///
/// Template: `'$cursorHVPosOpen[$n]$cursorHVPosClose'`.
///
/// See also [cursorHVPosToTopLeft] and [cursorHVPosTo].
const String cursorHVPosOpen = CSI;

/// Character And Line Position: closing tag.
///
/// See [HVP].
///
/// Template: `'$cursorHVPosOpen[$n]$cursorHVPosClose'`.
///
/// See also [cursorHVPosToTopLeft] and [cursorHVPosTo].
const String cursorHVPosClose = HVP;

/// Character And Line Position: moves the cursor to top left corner.
///
/// See [HVP].
///
/// See also [cursorHVPosOpen], [cursorHVPosClose] and [cursorHVPosTo].
const String cursorHVPosToTopLeft = '$cursorHVPosOpen$cursorHVPosClose';

/// Character And Line Position: moves the cursor to [row] and [col].
///
/// See [HVP].
///
/// See also [cursorHVPosOpen], [cursorHVPosClose] and [cursorHVPosTo].
String cursorHVPosTo(int row, int col) =>
    '$cursorHVPosOpen$row;$col$cursorHVPosClose';

/// Erase In Page: opening tag.
///
/// See [ED].
///
/// Template: `'$eraseInPageOpen[$s]$eraseInPageClose'`.
///
/// Erases part of the page:
/// - If `s` is `0` (or missing), erase from cursor to end of page. See
///   [eraseInPageToEnd].
/// - If `s` is `1`, erase from cursor to beginning of the page. See
///   [eraseInPageToBegin].
/// - If `s` is `2`, erase entire page. See [erasePage].
const String eraseInPageOpen = CSI;

/// Erase In Page: closing tag.
///
/// See [ED].
///
/// Template: `'$eraseInPageOpen[$s]$eraseInPageClose'`.
///
/// See also [eraseInPageToEnd], [eraseInPageToBegin] and [erasePage].
const String eraseInPageClose = ED;

/// Erase In Page: erases from cursor to end of page.
///
/// See [ED].
///
/// See also [eraseInPageOpen], [eraseInPageClose], [eraseInPageToBegin] and
/// [erasePage].
const String eraseInPageToEnd = '$eraseInPageOpen$eraseInPageClose';

/// Erase In Page: erases from cursor to beginning of the
/// page.
///
/// See [ED].
///
/// See also [eraseInPageOpen], [eraseInPageClose], [eraseInPageToEnd] and
/// [erasePage].
const String eraseInPageToBegin = '${eraseInPageOpen}1$eraseInPageClose';

/// Erase In Page: erases entire page and moves cursor to
/// upper left.
///
/// See [ED].
///
/// See also [eraseInPageOpen], [eraseInPageClose], [eraseInPageToEnd] and
/// [eraseInPageToBegin].
const String erasePage = '${eraseInPageOpen}2$eraseInPageClose';

/// Erase In Line: opening tag.
///
/// See [EL].
///
/// Template: `'$eraseLineOpen[$s]$eraseLineClose'`.
///
/// Erase part of the screen:
/// - If n is 0 (or missing), clear from cursor to the end of the line. See
///   [eraseInLineToEnd].
/// - If n is 1, clear from cursor to beginning of the line. See
///   [eraseInLineToBegin].
/// - If n is 2, clear entire line. See [eraseLine].
const String eraseInLineOpen = CSI;

/// Erase In Line: closing tag.
///
/// See [EL].
///
/// Template: `'$eraseLineOpen[$s]$eraseLineClose'`.
///
/// See also [eraseInLineToEnd], [eraseInLineToBegin] and [eraseLine].
const String eraseInLineClose = EL;

/// Erase In Line: erases from cursor to the end of the line.
///
/// See [ED].
///
/// See also [eraseInLineOpen], [eraseInLineClose], [eraseInLineToBegin] and
/// [eraseLine].
const String eraseInLineToEnd = '$eraseInLineOpen$eraseInLineClose';

/// Erase In Line: erases from cursor to beginning of the line.
///
/// See [ED].
///
/// See also [eraseInLineOpen], [eraseInLineClose], [eraseInLineToEnd] and
/// [eraseLine].
const String eraseInLineToBegin = '${eraseInLineOpen}1$eraseInLineClose';

/// Erase In Line: erases entire line.
///
/// See [ED].
///
/// See also [eraseInLineOpen], [eraseInLineClose], [eraseInLineToEnd] and
/// [eraseInLineToBegin].
const String eraseLine = '${eraseInLineOpen}2$eraseInLineClose';

/// Scroll Up: opening tag.
///
/// See [SU].
///
/// Template: `'$scrollUpOpen[$n]$scrollUpClose'`.
///
/// See also [scrollUp] and [scrollUpN].
const String scrollUpOpen = CSI;

/// Scroll Up: closing tag.
///
/// See [SU].
///
/// Template: `'$scrollUpOpen[$n]$scrollUpClose'`.
///
/// See also [scrollUp] and [scrollUpN].
const String scrollUpClose = SU;

/// Scroll Up: scroll the page up by `1` line.
///
/// See [SU].
///
/// See also [scrollUpOpen], [scrollUpClose] and [scrollUpN].
const String scrollUp = '$scrollUpOpen$scrollUpClose';

/// Scroll Up: scroll the page up by [n] line.
///
/// See [SU].
///
/// See also [scrollUpOpen], [scrollUpClose] and [scrollUpN].
String scrollUpN(int n) => '$scrollUpOpen$n$scrollUpClose';

/// Scroll Down: opening tag.
///
/// See [SD].
///
/// Template: `'$scrollDownOpen[$n]$scrollDownClose'`.
///
/// See also [scrollDown] and [scrollDownN].
const String scrollDownOpen = CSI;

/// Scroll Down: closing tag.
///
/// See [SD].
///
/// Template: `'$scrollDownOpen[$n]$scrollDownClose'`.
///
/// See also [scrollDown] and [scrollDownN].
const String scrollDownClose = SD;

/// Scroll Down: scroll the page down by `1` line.
///
/// See [SD].
///
/// See also [scrollDownOpen], [scrollDownClose] and [scrollDownN].
const String scrollDown = '$scrollDownOpen$scrollDownClose';

/// Scroll Down: scroll the page down by [n] line.
///
/// See [SD].
///
/// See also [scrollDownOpen], [scrollDownClose] and [scrollDownN].
String scrollDownN(int n) => '$scrollDownOpen$n$scrollDownClose';

/// Shows the cursor.
const String showCursor = '$CSI?25h';

/// Hides the cursor.
const String hideCursor = '$CSI?25l';
