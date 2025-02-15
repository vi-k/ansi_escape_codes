part of '../ansi_parser.dart';

sealed class Osc extends EscapeCode {
  const Osc._(super.string) : super._();

  static Osc _parse<S extends SgrState<S>>(MatchingState<S> state) {
    final params = state['osc_params']!.split(';');
    final firstParam = int.tryParse(params[0]);

    return switch (firstParam) {
      8 when params.length == 3 => Link._(state.string, params[2]),
      _ => OscUnknown._(state.string),
    };
  }

  @override
  String toString() => '$Osc("${toStringAsEscapeSquences()}")';
}

final class OscUnknown extends Osc with UnrecognizedEscapeCode {
  const OscUnknown._(super.string) : super._();

  @override
  String toString() => '$Osc("${toStringAsEscapeSquences()}")';
}

final class Link extends Osc {
  final String url;

  const Link(this.url) : super._(reset);

  const Link._(super.string, this.url) : super._();

  @override
  String get id => url.isEmpty ? 'linkClose' : 'link($url)';

  @override
  String toString() => '$Link()';
}
