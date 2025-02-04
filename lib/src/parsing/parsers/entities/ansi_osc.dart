part of '../parsers.dart';

sealed class AnsiOsc extends AnsiEscapeCode {
  factory AnsiOsc._parse(RegExpMatch match) {
    final string = match.namedGroup('all')!;
    final params = match.namedGroup('osc_parameters')!.split(splitterRe);
    final firstParam = int.tryParse(params[0]);

    return switch (firstParam) {
      8 when params.length == 3 => AnsiLink._(string, params[2]),
      _ => AnsiOscUnknown._(string),
    };
  }

  const AnsiOsc._(super.string) : super._();

  @override
  String toString() => '$AnsiOsc("${toStringAsEscapeSquences()}")';
}

final class AnsiOscUnknown extends AnsiOsc with AnsiUnrecognized {
  const AnsiOscUnknown._(super.string) : super._();

  @override
  String get id => 'unknown_osc:${super.id}';

  @override
  String toString() => '$AnsiOsc("${toStringAsEscapeSquences()}")';
}

final class AnsiLink extends AnsiOsc {
  final String url;

  const AnsiLink(this.url) : super._(reset);

  const AnsiLink._(super.string, this.url) : super._();

  @override
  String get id => url.isEmpty ? 'linkClose' : 'link($url)';

  @override
  String toString() => '$AnsiReset()';
}
