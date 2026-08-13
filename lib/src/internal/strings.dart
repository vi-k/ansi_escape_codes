/// String helpers for the package's own use; nothing here is exported.
extension StringExt on String {
  /// The string with its first character in upper case.
  String capitalize() =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';
}

/// Whether [codeUnit] is a byte the body of a control string cannot carry.
///
/// A C0 control or `DEL`. Written into an `OSC 8`, an `ESC` ends the sequence
/// where it stands and a `BEL` ends it where the older form is used, so
/// whatever was meant as the rest of the address reaches the terminal as
/// codes of its own.
///
/// C1 is left out on purpose. A byte of it is one code unit in a Dart string
/// and two in the UTF-8 that goes to the terminal, so the single-byte escape
/// this file writes would name the wrong byte; and this package does not read
/// eight-bit C1 as control codes at all, so none of them ends a sequence
/// here. See `docs/records/2026-08-12[1]`.
bool isControlByte(int codeUnit) => codeUnit < 0x20 || codeUnit == 0x7F;

/// [string] with every control byte written as its percent-escape.
///
/// Only the bytes [isControlByte] names, and nothing else: the address is
/// otherwise given to the terminal exactly as it came. A `%` is one of the
/// bytes left alone, so a url that arrives percent-encoded — which is the
/// ordinary way one arrives — comes out as it was, and encoding twice is
/// encoding once.
///
/// `Uri.encodeFull` is what the `OSC 8` note asks for and is not what this
/// does: it escapes the `%` as well, so `a%20b` becomes `a%2520b` and an
/// already-encoded address is quietly corrupted.
///
/// Returns [string] itself where there is nothing to encode.
String encodeControlBytes(String string) {
  StringBuffer? buf;
  var from = 0;

  for (var i = 0; i < string.length; i++) {
    final unit = string.codeUnitAt(i);
    if (!isControlByte(unit)) {
      continue;
    }

    (buf ??= StringBuffer())
      ..write(string.substring(from, i))
      ..write('%')
      ..write(unit.toRadixString(16).toUpperCase().padLeft(2, '0'));
    from = i + 1;
  }

  return buf == null ? string : (buf..write(string.substring(from))).toString();
}
