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

  @override
  String get id => url.isEmpty ? 'linkClose' : 'link($url)';

  @override
  String toString() => '$Link($url)';
}
