import 'common.dart';

// CSI (Control Sequence Introducer)
const String csi = '$esc[';

const String cursorUp = '$cursorUpOpen$cursorUpClose';
const String cursorUpOpen = csi;
const String cursorUpClose = 'A';

const String cursorDown = '$cursorDownOpen$cursorDownClose';
const String cursorDownOpen = csi;
const String cursorDownClose = 'B';

const String cursorForward = '$cursorForwardOpen$cursorForwardClose';
const String cursorForwardOpen = csi;
const String cursorForwardClose = 'C';

const String cursorBack = '$cursorBackOpen$cursorBackClose';
const String cursorBackOpen = csi;
const String cursorBackClose = 'D';

const String cursorNextLine = '$cursorNextLineOpen$cursorNextLineClose';
const String cursorNextLineOpen = csi;
const String cursorNextLineClose = 'E';

const String cursorPrevLine = '$cursorPrevLineOpen$cursorPrevLineClose';
const String cursorPrevLineOpen = csi;
const String cursorPrevLineClose = 'F';

const String cursorHVPos = '$cursorHVPosOpen$cursorHVPosClose';
const String cursorHVPosOpen = csi;
const String cursorHVPosClose = 'f';

const String cursorHPos = '$cursorHPosOpen$cursorHPosClose';
const String cursorHPosOpen = csi;
const String cursorHPosClose = 'G';

const String cursorPos = '$cursorPosOpen$cursorPosClose';
const String cursorPosOpen = csi;
const String cursorPosClose = 'H';

// If n is 0 (or missing), clear from cursor to end of screen.
// If n is 1, clear from cursor to beginning of the screen.
// If n is 2, clear entire screen.
// If n is 3, clear entire screen (?) and delete all lines saved in the
//   scrollback buffer.
const String clearOpen = csi;
const String clearClose = 'J';
const String clearToEnd = '$clearOpen$clearClose';
const String clearToBegin = '${clearOpen}1$clearClose';
const String clear = '${clearOpen}2$clearClose';
const String clearBuf = '${clearOpen}3$clearClose';

// If n is 0 (or missing), clear from cursor to the end of the line.
// If n is 1, clear from cursor to beginning of the line.
// If n is 2, clear entire line.
const String eraseLineOpen = csi;
const String eraseLineClose = 'K';
const String eraseLineToEnd = '$eraseLineOpen$eraseLineClose';
const String eraseLineToBegin = '${eraseLineOpen}1$eraseLineClose';
const String eraseLine = '${eraseLineOpen}2$eraseLineClose';

const String scrollUp = '$scrollUpOpen$scrollUpClose';
const String scrollUpOpen = csi;
const String scrollUpClose = 'S';

const String scrollDown = '$scrollDownOpen$scrollDownClose';
const String scrollDownOpen = csi;
const String scrollDownClose = 'T';

const String hideCursor = '$csi?25l';
const String showCursor = '$csi?25h';
