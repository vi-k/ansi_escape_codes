/// Thrown where an insertion would land inside a control sequence the parser
/// could not finish.
///
/// The string ends — or runs on to the next `ESC` — in the middle of a
/// sequence: an `OSC` that never got its terminator, a bare `ESC`, a `CSI`
/// with no final byte, an `ESC` left on an intermediate byte. The bytes that
/// follow such a sequence belong to it as far as a terminal is concerned,
/// whatever this package calls them, so text put among them would be read as
/// its parameters rather than shown.
///
/// An insertion aimed at the seam in front of the sequence is placed there
/// and nothing is thrown. This is for the positions past that seam, where no
/// answer is right: putting the text in front of the sequence would move it
/// before characters the caller counted before it, and leaving it where it
/// was asked for would make it part of the sequence.
///
/// It is an [Exception] and not an [Error] on purpose. The position is within
/// the plain text, it is the input that is cut short, and the caller has no
/// way of knowing it in advance. A position outside the plain text is a
/// different matter and still throws a [RangeError].
final class UnfinishedSequenceException implements Exception {
  /// Creates an exception for the insertion at [pos] refused by the sequence
  /// beginning at [offset].
  const UnfinishedSequenceException({required this.pos, required this.offset});

  /// The position in the plain text the insertion was aimed at.
  final int pos;

  /// Where the sequence begins in the string being read, so that a complaint
  /// can point at the bytes it is about — the way `Match.start` does.
  final int offset;

  @override
  String toString() =>
      'UnfinishedSequenceException: the text at $pos would land inside the '
      'unfinished sequence at $offset';
}
