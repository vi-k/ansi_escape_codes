/// Thrown where an insertion would land inside a control sequence the parser
/// could not finish.
///
/// The string ends, or runs on to a byte that cannot finish it, in the middle
/// of a sequence whose last bytes come back as text: a bare `ESC`, a `CSI` with
/// no final byte, an `ESC` left on an intermediate byte. Those bytes belong to
/// the sequence as far as a terminal is concerned, whatever this package calls
/// them, so text put among them would be read as its parameters rather than
/// shown.
///
/// An insertion aimed at the seam in front of the sequence is placed there and
/// nothing is thrown. This is for the positions past that seam, where no answer
/// is right: putting the text in front of the sequence would move it before
/// characters the caller counted before it, and leaving it where it was asked
/// for would make it part of the sequence.
///
/// A control string that never got its terminator — an `OSC`, a `DCS`, an
/// `SOS`, a `PM` or an `APC` — is unfinished no less, and never throws this.
/// Its body runs to the next `ESC` or to the end of the text and is part of the
/// sequence rather than text of its own, so no position in the plain text falls
/// among its bytes and there is nothing to refuse. An insertion stands in front
/// of such a string instead; `insertBefore` says what that leaves uncovered.
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
