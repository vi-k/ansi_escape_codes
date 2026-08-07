part of '../parser.dart';

/// An operating system command: `OSC ... ST`, the escape codes that talk to
/// the terminal rather than to the screen.
///
/// The one this package names is [Link]; the rest come back [OscUnknown].
sealed class Osc extends EscapeCode {
  const Osc._(super.string) : super._();

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
/// An `OSC` runs until a `ST` or a `BEL`; one that got neither runs on to the
/// next `ESC` or to the end of the text — the parser reads it that way on
/// purpose, see `oscPattern`. Ending that way is ending nowhere: whatever is
/// written straight after is read as more of the sequence.
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
String _terminatedIfTextFollows(String codes, String following) =>
    codes.isEmpty ||
            _oscTerminated(codes) ||
            following.isEmpty ||
            following.startsWith(ESC)
        ? codes
        : '$codes$ST';

/// A hyperlink, `OSC 8`: the text between an open and a close is what the
/// terminal makes clickable.
///
/// A [url] that is empty closes the link opened before it.
final class Link extends Osc {
  /// The address the link points at, empty where the link is being closed.
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
  String get _reopening => _oscTerminated(string) ? string : '$string$ST';

  @override
  String get id => url.isEmpty ? 'linkClose' : 'link($url)';

  @override
  String toString() => '$Link($url)';
}
