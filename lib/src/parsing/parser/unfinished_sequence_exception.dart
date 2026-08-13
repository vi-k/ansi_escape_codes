/// Thrown where an insertion would land inside a control sequence the parser
/// could not finish.
///
/// The string ends, or runs on to a byte that cannot finish it, in the middle
/// of a sequence whose last bytes come back as text: a bare `ESC`, a `CSI` with
/// no final byte, an `ESC` left on an intermediate byte. Those bytes belong to
/// the sequence as far as a terminal is concerned, whatever this package calls
/// them, so text put among them would be read as its parameters rather than
/// shown. What the piece of text looks like decides nothing: a truncated `CSI`
/// gives up its parameters, and a byte no sequence can be built from — a `LF`,
/// a `DEL`, a letter outside ASCII — breaks off the pattern of any of the three
/// and leaves the code in front of it waiting just the same.
///
/// An insertion aimed at the seam in front of the sequence is placed there and
/// nothing is thrown. This is for the positions past that seam, where no answer
/// is right: putting the text in front of the sequence would move it before
/// characters the caller counted before it, and leaving it where it was asked
/// for would make it part of the sequence.
///
/// The seam is refused where it is one of those positions itself. Unfinished
/// codes come in runs and the seam belongs in front of a whole run, so a run
/// that begins behind a piece of text begins among bytes the sequence in front
/// of that text is still reading, and the place before it is where that
/// sequence's ending would be written. A code that stands finished between the
/// text and the run gives the run a seam of its own, and that one is served.
///
/// Which of the two insertions asked is not beside the point, because each is
/// refused by the seam it would take and the two take different ones —
/// `insertBefore` the place behind the position, `insertAfter` the place past
/// the codes standing at it. Both are inside the waiting sequence often
/// enough, and then both throw; but a finished code standing between those
/// bytes and what follows them puts a place past the sequence within
/// `insertAfter`'s reach and none within `insertBefore`'s, and there only
/// `insertBefore` is refused. `Parser('aa\x1B[31\x1B(B\x1B[31')` at position 4
/// is such a place.
///
/// A control string that never got its terminator — an `OSC`, a `DCS`, an
/// `SOS`, a `PM` or an `APC` — is unfinished no less, and is never the sequence
/// this names. Its body runs to the next `ESC` or to the end of the text and is
/// part of the sequence rather than text of its own, so no position in the
/// plain text falls among its bytes and it has nothing of its own to refuse. An
/// insertion stands in front of such a string, or in front of the run it stands
/// in.
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
  /// can point at the bytes it is about — the way `Piece.start` does.
  ///
  /// The sequence named is the one whose bytes the text would have joined: the
  /// one still waiting at the refused position. Where the seam in front of a
  /// run is the position refused, that is the sequence standing in front of the
  /// run rather than the code the run begins with — the run's own bytes a
  /// terminal has long since read as something else.
  final int offset;

  @override
  String toString() =>
      'UnfinishedSequenceException: the text at $pos would land inside the '
      'unfinished sequence at $offset';
}
