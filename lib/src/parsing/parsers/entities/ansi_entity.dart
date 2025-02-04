part of '../parsers.dart';

@immutable
sealed class AnsiEntity {
  final String string;

  const AnsiEntity._(this.string);

  @override
  int get hashCode => string.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is AnsiEntity && string == other.string;
}

final class AnsiPlainText extends AnsiEntity {
  const AnsiPlainText._(super.string) : super._();

  @override
  String toString() => '$AnsiPlainText('
      '"${string.showControlCodes().replaceAll('"', r'\"')}"'
      ')';
}

sealed class AnsiEscapeCode extends AnsiEntity {
  factory AnsiEscapeCode._parse(RegExpMatch match) {
    final string = match.namedGroup('all')!;
    final csi = match.namedGroup('csi');
    if (csi != null) {
      return AnsiCsi._parse(match);
    }

    final osc = match.namedGroup('osc');
    if (osc != null) {
      return AnsiOsc._parse(match);
    }

    final esc = match.namedGroup('esc');
    if (esc != null) {
      return AnsiEsc._parse(match);
    }

    return AnsiUnknown._(string);
  }

  const AnsiEscapeCode._(super.string) : super._();

  String get id;

  String toStringAsControlCodes() =>
      string.showControlCodes(preferStyle: AnsiControlCodeStyle.abbr);

  String toStringAsEscapeSquences() => string.showEscapeCodes();
}

mixin AnsiUnrecognized on AnsiEscapeCode {
  @override
  String get id => string.showEscapeCodes(open: '', close: '');
}

final class AnsiUnknown extends AnsiEscapeCode with AnsiUnrecognized {
  const AnsiUnknown._(super.string) : super._();

  @override
  String toString() => '$AnsiEscapeCode(${toStringAsControlCodes()})';
}
