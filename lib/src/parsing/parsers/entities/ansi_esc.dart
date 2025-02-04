part of '../parsers.dart';

sealed class AnsiEsc extends AnsiEscapeCode {
  factory AnsiEsc._parse(RegExpMatch match) {
    final string = match.namedGroup('all')!;
    final code = match.namedGroup('esc_final')!;

    return switch (code) {
      '7' => AnsiSaveCursor._(string),
      '8' => AnsiRestoreCursor._(string),
      _ => AnsiEscUnknown._(string),
    };
  }

  const AnsiEsc._(super.string) : super._();

  @override
  String toString() => '$AnsiOsc("${toStringAsEscapeSquences()}")';
}

final class AnsiEscUnknown extends AnsiEsc with AnsiUnrecognized {
  const AnsiEscUnknown._(super.string) : super._();

  @override
  String get id => 'unknown_esc:${super.id}';

  @override
  String toString() => '$AnsiEsc("${toStringAsEscapeSquences()}")';
}

final class AnsiSaveCursor extends AnsiEsc {
  const AnsiSaveCursor() : super._(reset);

  const AnsiSaveCursor._(super.string) : super._();

  @override
  String get id => 'saveCursor';

  @override
  String toString() => '$AnsiSaveCursor()';
}

final class AnsiRestoreCursor extends AnsiEsc {
  const AnsiRestoreCursor() : super._(reset);

  const AnsiRestoreCursor._(super.string) : super._();

  @override
  String get id => 'restoreCursor';

  @override
  String toString() => '$AnsiRestoreCursor()';
}
