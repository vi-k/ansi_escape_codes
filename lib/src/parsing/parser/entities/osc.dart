part of '../parser.dart';

/// An operating system command: `OSC ... ST`, the escape codes that talk to
/// the terminal rather than to the screen.
///
/// The one this package names is [Link]; the rest come back [OscUnknown].
sealed class Osc extends ControlString {
  const Osc._(super.string) : super._();

  /// A `BEL` ends an `OSC` — xterm's terminator, kept because the strings
  /// written with it are everywhere — where it ends no other control string.
  @override
  bool get terminated => string.endsWith(ST) || string.endsWith(BEL);

  static Osc _parse<S extends State<S>>(_MatchingState<S> state) {
    final params = state['osc_params']!.split(';');
    final firstParam = int.tryParse(params[0]);

    return switch (firstParam) {
      // OSC 8 is `8 ; params ; uri`, and the uri may hold semicolons of its
      // own, so everything past the second one belongs to it.
      8 when params.length >= 3 =>
        Link._(state.string, params.sublist(2).join(';')),
      _ => OscUnknown._(state.string),
    };
  }
}

/// An operating system command this package has no name for: setting the
/// window title, asking after a colour, whatever else the terminal answers to.
final class OscUnknown extends Osc with UnrecognizedEscapeCode {
  const OscUnknown._(super.string) : super._();

  @override
  String toString() => '$Osc("${toStringAsEscapeSequences()}")';
}

/// Whether [string] ends where an `OSC` sequence is allowed to end.
///
/// Asked of link codes, which are always an `OSC`; the openings held back go
/// through [_terminatedOpening], which must not ask it. An `OSC` runs until a
/// `ST` or a `BEL`; one that got neither runs on to the next `ESC` or to the
/// end of the text — the parser reads it that way on purpose, see
/// `oscPattern`. Ending that way is ending nowhere: whatever is written
/// straight after is read as more of the sequence.
bool _oscTerminated(String string) =>
    string.endsWith(ST) || string.endsWith(BEL);

/// [codes] with a terminator supplied where it ends in an `OSC` that never
/// got one and [following] is what that `OSC` would otherwise swallow.
///
/// The codes copied out of a string carry the ending they had there, and what
/// ended an unterminated one in the string was the `ESC` of whatever stood
/// behind it. That `ESC` need not be copied with them: an `SGR` is not copied
/// at all but written again as a transition, and a transition that changes
/// nothing writes nothing. Where what follows is text, then, the terminator
/// the sequence lacks is supplied here.
///
/// Where an `ESC` follows anyway, or where nothing follows, the bytes are
/// given back exactly as they came: a string that is copied whole is copied
/// byte for byte.
///
/// [following] is what would be written next, and the callers write it in
/// pieces: the link codes held back, a reopening, a transition, the text.
/// They pass those pieces to [_firstNotEmpty] rather than joining them — see
/// there.
String _terminatedIfTextFollows(String codes, String following) =>
    following.isEmpty ? codes : _terminatedUnlessCodeFollows(codes, following);

/// [codes] with a terminator supplied where they end in an `OSC` that never
/// got one and nothing beginning with an `ESC` follows to end it.
///
/// The rule at the edge of an output, where [_terminatedIfTextFollows] is the
/// rule inside one, and the two differ in what an empty [following] means.
/// Inside a string it means nothing follows the opening at all, so there is
/// nothing to be swallowed and the bytes go out as they came. At the edge of
/// an output that closes — [Parser.substring] or [Parser.optimize] with
/// `close: true`, a printed line — it means the next thing written is
/// whatever the caller prints after, and the terminator is owed for the same
/// reason the hyperlink close is.
String _terminatedUnlessCodeFollows(String codes, String following) =>
    codes.isEmpty || _oscTerminated(codes) || following.startsWith(ESC)
        ? codes
        : '$codes$ST';

/// [opening] with the terminator it lacks, where what follows would otherwise
/// be swallowed by it.
///
/// Only an opening the parser found unterminated is ever held back, so this
/// does not ask again whether it ended — and it must not ask: a `BEL` ends an
/// [Osc] and no other control string, so an unterminated [Dcs] whose body
/// happens to end in one would be called finished by that question and left
/// open. [_terminatedIfTextFollows] and [_terminatedUnlessCodeFollows] go on
/// asking it, because what they are given is link codes, and those are always
/// an `OSC`.
///
/// [closing] says what an empty [following] means. Inside a string it means
/// nothing follows the opening at all, so there is nothing to be swallowed
/// and the bytes go out as they came. At the edge of an output that closes —
/// [Parser.substring] or [Parser.optimize] with `close: true`, a printed line
/// — it means the next thing written is whatever the caller prints after, and
/// the terminator is owed for the reason the hyperlink close is.
String _terminatedOpening(
  String opening,
  String following, {
  required bool closing,
}) =>
    opening.isEmpty ||
            following.startsWith(ESC) ||
            (following.isEmpty && !closing)
        ? opening
        : '$opening$ST';

/// The first of [first], [second], [third] and [fourth] with anything in it,
/// or the empty string where none of them has.
///
/// The two rules above ask two things of what follows: whether there is any
/// of it, and whether it begins with an `ESC`. Both are answered by the first
/// piece that is not empty — a joined string is empty only where every piece
/// is, and begins where its first non-empty piece begins — so the pieces go
/// over unjoined and the answer is the same to the byte.
///
/// The pieces must be given in the order they are about to be written. Four
/// of them is the longest any caller has: an opening held back by
/// [Parser.substring] is written ahead of the held link codes, the reopening,
/// the transition and the text of the piece.
///
/// This is on the path every piece of a slice, of an optimized string and of
/// a printed line takes, and the string it does not build there is the whole
/// of what is about to be written: joining it cost a link-heavy slicing run
/// some tenth of its time to look at one character.
String _firstNotEmpty(
  String first,
  String second, [
  String third = '',
  String fourth = '',
]) =>
    first.isNotEmpty
        ? first
        : second.isNotEmpty
            ? second
            : third.isNotEmpty
                ? third
                : fourth;

/// A hyperlink, `OSC 8`: the text between an open and a close is what the
/// terminal makes clickable.
///
/// A [url] that is empty closes the link opened before it.
///
/// [url] is where the link points and nothing else. `OSC 8` carries
/// parameters of its own between the introducer and the address — `id=`
/// above all, which is what tells a terminal that two pieces a line break cut
/// apart are one link — and those stay in [string], the bytes the sequence
/// was written with, along with the terminator it was written with. Reading
/// them is reading [string].
///
/// A link opened again elsewhere — by [Parser.substring], by an insertion, by
/// a printer starting a new line — is written from [string] and not built
/// afresh from [url], so the parameters and the form of the terminator travel
/// with it.
final class Link extends Osc {
  /// The address the link points at, empty where the link is being closed.
  ///
  /// The parameters the sequence carried are not here; see the class doc.
  final String url;

  /// The sequence that opens a link on [url], or closes one where [url] is
  /// empty.
  const Link(this.url) : super._('${OSC}8;;$url$ST');

  const Link._(super.string, this.url) : super._();

  /// The bytes that open this link again somewhere else.
  ///
  /// [string] as it was written, save for an opening whose terminator never
  /// came. `OSC 8 ; ; url` with nothing to end it runs to the next `ESC` or
  /// to the end of the text — the parser reads it that way on purpose, see
  /// `oscPattern` — and in the string it was read from one of those two
  /// always followed it. Written again in front of text that did not follow
  /// it there, it would swallow that text into the url, so the terminator it
  /// lacks is supplied.
  ///
  /// [string] itself is left as it stands: a parsed string gives itself back
  /// piece by piece, and mending it here would be mending it everywhere.
  ///
  /// This is what [Parser.substring], the insertions and the printers write
  /// where they open a link the text they are copying was already inside.
  String get _reopening => terminated ? string : '$string$ST';

  @override
  String get id => url.isEmpty ? 'linkClose' : 'link($url)';

  @override
  String toString() => '$Link($url)';
}
