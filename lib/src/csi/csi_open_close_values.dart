import 'csi.dart' as ansi;
import 'sgr/sgr_rgb_colors.dart' as ansi;

/// Predefined open/close CSI values.
enum CsiOpenCloseValues {
  /// Moves the cursor up n lines.
  cursorUpN(ansi.cursorUpOpen, ansi.cursorUpClose),

  /// Moves the cursor down n lines.
  cursorDownN(ansi.cursorDownOpen, ansi.cursorDownClose),

  /// Moves the cursor forward n cells.
  cursorForwardN(ansi.cursorForwardOpen, ansi.cursorForwardClose),

  /// Moves the cursor back n cells.
  cursorBackN(ansi.cursorBackOpen, ansi.cursorBackClose),

  /// Moves cursor to beginning of the line n lines down.
  cursorNextLineN(ansi.cursorNextLineOpen, ansi.cursorNextLineClose),

  /// Moves cursor to beginning of the line n line up.
  cursorPrevLineN(ansi.cursorPrevLineOpen, ansi.cursorPrevLineClose),

  /// Moves the cursor to column n.
  cursorHPosN(ansi.cursorHPosOpen, ansi.cursorHPosClose),

  /// Moves the cursor to row and col.
  cursorPosTo(ansi.cursorPosOpen, ansi.cursorPosClose),

  /// Moves the cursor to row and col.
  cursorHVPosTo(ansi.cursorHVPosOpen, ansi.cursorHVPosClose),

  /// Clears part of the screen.
  clearScreen(ansi.clearScreenOpen, ansi.clearScreenClose),

  /// Erase part of the screen.
  eraseLine(ansi.eraseLineOpen, ansi.eraseLineClose),

  /// Scroll whole page up by n lines.
  scrollUpN(ansi.scrollUpOpen, ansi.scrollUpClose),

  /// Scroll whole page down by n lines.
  scrollDownN(ansi.scrollDownOpen, ansi.scrollDownClose),

  /// Set color to foreground by RGB.
  fgRgb(ansi.fgRgbOpen, ansi.fgRgbClose),

  /// Set color to background by RGB.
  bgRgb(ansi.bgRgbOpen, ansi.bgRgbClose),

  /// Set color to underline by RGB.
  underlineRgb(ansi.underlineRgbOpen, ansi.underlineRgbClose);

  const CsiOpenCloseValues(this.open, this.close);

  final String open;
  final String close;

  static (CsiOpenCloseValues, String)? byCode(String code) {
    for (final v in values) {
      if (code.startsWith(v.open) && code.endsWith(v.close)) {
        return (v, code.substring(v.open.length, code.length - v.close.length));
      }
    }

    return null;
  }
}
