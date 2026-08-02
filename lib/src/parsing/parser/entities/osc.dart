part of '../parser.dart';

sealed class Osc extends EscapeCode {
  const Osc._(super.string) : super._();

  static Osc _parse<S extends State<S>>(MatchingState<S> state) {
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

  @override
  String toString() => '$Osc("${toStringAsEscapeSequences()}")';
}

final class OscUnknown extends Osc with UnrecognizedEscapeCode {
  const OscUnknown._(super.string) : super._();

  @override
  String toString() => '$Osc("${toStringAsEscapeSequences()}")';
}

final class Link extends Osc {
  final String url;

  const Link(this.url) : super._('${OSC}8;;$url$ST');

  const Link._(super.string, this.url) : super._();

  @override
  String get id => url.isEmpty ? 'linkClose' : 'link($url)';

  @override
  String toString() => '$Link($url)';
}
