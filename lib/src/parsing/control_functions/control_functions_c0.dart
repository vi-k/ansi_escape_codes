// ignore_for_file: constant_identifier_names

import '../../controls/c0.dart' as c0;

/// Control functions: elements of the C0 set.
///
/// See [c0].
enum ControlFunctionsC0 {
  /// See [c0.NUL].
  NUL(c0.NUL, null, '␀', 'Null'),

  /// See [c0.SOH].
  SOH(c0.SOH, null, '␁', 'Start Of Heading'),

  /// See [c0.STX].
  STX(c0.STX, null, '␂', 'Start Of Text'),

  /// See [c0.ETX].
  ETX(c0.ETX, null, '␃', 'End Of Text'),

  /// See [c0.EOT].
  EOT(c0.EOT, null, '␄', 'End Of Transmission'),

  /// See [c0.ENQ].
  ENQ(c0.ENQ, null, '␅', 'Enquiry'),

  /// See [c0.ACK].
  ACK(c0.ACK, null, '␆', 'Acknowledge'),

  /// See [c0.BEL].
  BEL(c0.BEL, null, '␇', 'Bell'),

  /// See [c0.BS].
  BS(c0.BS, 'b', '␈', 'Backspace'),

  /// See [c0.HT].
  HT(c0.HT, r'\t', '␉', 'Horizontal Tabulation'),

  /// See [c0.LF].
  LF(c0.LF, r'\n', '␊', 'Line Feed'),

  /// See [c0.VT].
  VT(c0.VT, null, '␋', 'Vertical Tabulation'),

  /// See [c0.FF].
  FF(c0.FF, r'\f', '␌', 'Form Feed'),

  /// See [c0.CR].
  CR(c0.CR, r'\r', '␍', 'Carriage Return'),

  /// See [c0.SO].
  SO(c0.SO, null, '␎', 'Shift-Out'),

  /// See [c0.SI].
  SI(c0.SI, null, '␏', 'Shift-In'),

  /// See [c0.DLE].
  DLE(c0.DLE, null, '␐', 'Data Link Escape'),

  /// See [c0.DC1].
  DC1(c0.DC1, null, '␑', 'Device Control One'),

  /// See [c0.DC2].
  DC2(c0.DC2, null, '␒', 'Device Control Two'),

  /// See [c0.DC3].
  DC3(c0.DC3, null, '␓', 'Device Control Three'),

  /// See [c0.DC4].
  DC4(c0.DC4, null, '␔', 'Device Control Four'),

  /// See [c0.NAK].
  NAK(c0.NAK, null, '␕', ''),

  /// See [c0.SYN].
  SYN(c0.SYN, null, '␖', 'Synchronous Idle'),

  /// See [c0.ETB].
  ETB(c0.ETB, null, '␗', 'End Of Transmission Block'),

  /// See [c0.CAN].
  CAN(c0.CAN, null, '␘', 'Cancel'),

  /// See [c0.EM].
  EM(c0.EM, null, '␙', 'End Of Medium'),

  /// See [c0.SUB].
  SUB(c0.SUB, null, '␚', 'Substitute'),

  /// See [c0.ESC].
  ESC(c0.ESC, null, '␛', 'Escape'),

  /// See [c0.FS].
  FS(c0.FS, null, '␜', 'File Separator'),

  /// See [c0.GS].
  GS(c0.GS, null, '␝', 'Group Separator'),

  /// See [c0.RS].
  RS(c0.RS, null, '␞', 'Record Separator'),

  /// See [c0.US].
  US(c0.US, null, '␟', 'Unit Separator');

  const ControlFunctionsC0(
    this.code,
    this.escapeSymbol,
    this.unicodeSymbol,
    this.description,
  );

  final String code;
  final String? escapeSymbol;
  final String unicodeSymbol;
  final String description;

  static ControlFunctionsC0? byCode(String code) {
    if (code.length != 1) {
      return null;
    }

    return byIndex(code.codeUnitAt(0));
  }

  static ControlFunctionsC0? byIndex(int index) =>
      index >= 0 && index < values.length ? values[index] : null;
}
