/// Table of control codes.
enum ControlCodes {
  /// Null.
  nul('\x00', 0x00, null, '␀', 'NUL'),

  /// Start of heading.
  soh('\x01', 0x01, null, '␁', 'SOH'),

  /// Start of text.
  stx('\x02', 0x02, null, '␂', 'STX'),

  /// End of text.
  etx('\x03', 0x03, null, '␃', 'ETX'),

  /// End of transmission.
  eot('\x04', 0x04, null, '␄', 'EOT'),

  /// Enquiry.
  enq('\x05', 0x05, null, '␅', 'ENQ'),

  /// Acknowledge.
  ack('\x06', 0x06, null, '␆', 'ACK'),

  /// Bell.
  bel('\x07', 0x07, null, '␇', 'BEL'),

  /// Backspace.
  backspace('\b', 0x08, 'b', '␈', 'BS'),

  /// Horizontal tabulation.
  ht('\t', 0x09, r'\t', '␉', 'HT'),

  /// Line feed.
  lf('\n', 0x0A, r'\n', '␊', 'LF'),

  /// Vertical tabulation.
  vt('\x0B', 0x0B, null, null, 'VT'),

  /// Form feed.
  ff('\f', 0x0C, r'\f', '␌', 'FF'),

  /// Carriage return.
  cr('\r', 0x0D, r'\r', '␍', 'CR'),

  /// Shift out.
  so('\x0E', 0x0E, null, '␎', 'SO'),

  /// Shift in.
  si('\x0F', 0x0F, null, '␏', 'SI'),

  /// Data link escape.
  dle('\x10', 0x10, null, '␐', 'DLE'),

  /// Device control one.
  dc1('\x11', 0x11, null, '␑', 'DC1'),

  /// Device control two.
  dc2('\x12', 0x12, null, '␒', 'DC2'),

  /// Device control three.
  dc3('\x13', 0x13, null, '␓', 'DC3'),

  /// Device control four.
  dc4('\x14', 0x14, null, '␔', 'DC4'),

  /// Negative acknowledge.
  nak('\x15', 0x15, null, '␕', 'NAK'),

  /// Synchronous idle.
  syn('\x16', 0x16, null, '␖', 'SYN'),

  /// End of transmission block.
  etb('\x17', 0x17, null, '␗', 'ETB'),

  /// Cancel.
  can('\x18', 0x18, null, '␘', 'CAN'),

  /// End of medium.
  em('\x19', 0x19, null, '␙', 'EM'),

  /// Substitute.
  sub('\x1A', 0x1A, null, '␚', 'SUB'),

  /// Escape.
  esc('\x1B', 0x1B, null, '␛', 'ESC'),

  /// File separator.
  fs('\x1C', 0x1C, null, '␜', 'FS'),

  /// Group separator.
  gs('\x1D', 0x1D, null, '␝', 'GS'),

  /// Record separator.
  rs('\x1E', 0x1E, null, '␞', 'RS'),

  /// Unit separator.
  us('\x1F', 0x1F, null, '␟', 'US'),

  /// Space.
  sp(' ', 0x20, ' ', '␠', 'SP'),

  /// Delete.
  del('\x7F', 0x7F, null, '␡', 'DEL');

  const ControlCodes(
    this.char,
    this.charCode,
    this.escape,
    this.emoji,
    this.abbr,
  );

  final String char;
  final int charCode;
  final String? escape;
  final String? emoji;
  final String abbr;

  static const _map = <int, ControlCodes>{
    0x00: nul,
    0x01: soh,
    0x02: stx,
    0x03: etx,
    0x04: eot,
    0x05: enq,
    0x06: ack,
    0x07: bel,
    0x08: backspace,
    0x09: ht,
    0x0A: lf,
    0x0B: vt,
    0x0C: ff,
    0x0D: cr,
    0x0E: so,
    0x0F: si,
    0x10: dle,
    0x11: dc1,
    0x12: dc2,
    0x13: dc3,
    0x14: dc4,
    0x15: nak,
    0x16: syn,
    0x17: etb,
    0x18: can,
    0x19: em,
    0x1A: sub,
    0x1B: esc,
    0x1C: fs,
    0x1D: gs,
    0x1E: rs,
    0x1F: us,
    // 0x20: sp,
    0x7F: del,
  };

  static ControlCodes? byCharCode(int code) => _map[code];
}
