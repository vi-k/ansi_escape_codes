import 'csi.dart' as csi;

/// Table of CSI codes.
enum CsiCodes {
  cursorUp(csi.cursorUpClose, 'CURSOR_UP'),
  cursorDown(csi.cursorDownClose, 'CURSOR_DOWN'),
  cursorForward(csi.cursorForwardClose, 'CURSOR_FORWARD'),
  cursorBack(csi.cursorBackClose, 'CURSOR_BACK'),
  cursorNextLine(csi.cursorNextLineClose, 'CURSOR_NEXT_LINE'),
  cursorPrevLine(csi.cursorPrevLineClose, 'CURSOR_PREV_LINE'),
  cursorHPos(csi.cursorHPosClose, 'CURSOR_HPOS'),
  cursorPos(csi.cursorPosClose, 'CURSOR_POS'),
  cursorHVPos(csi.cursorHVPosClose, 'CURSOR_HVPOS'),
  clearScreen(csi.clearScreenClose, 'CLEAR_SCREEN'),
  eraseLine(csi.eraseLineClose, 'ERASE_LINE'),
  scrollUp(csi.scrollUpClose, 'SCROLL_UP'),
  scrollDown(csi.scrollDownClose, 'SCROLL_DOWN'),
  sgr(csi.sgr, 'SGR');

  const CsiCodes(this.code, this.abbr);

  final String code;
  final String abbr;

  static CsiCodes? byCode(String code) {
    for (final v in values) {
      if (v.code == code) {
        return v;
      }
    }

    return null;
  }
}
