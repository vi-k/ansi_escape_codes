part of '../parsers.dart';

sealed class AnsiSgr extends AnsiCsi {
  factory AnsiSgr._parse(RegExpMatch match) {
    final string = match.namedGroup('all')!;
    final params = match.namedGroup('csi_parameters')!.split(splitterRe);
    final firstParam = int.tryParse(params[0]);

    return switch (firstParam) {
      0 => AnsiReset._(string),
      1 => AnsiBold._(string),
      2 => AnsiFaint._(string),
      3 => AnsiItalic._(string),
      4 => AnsiUnderline._(string),
      5 => AnsiBlink._(string),
      6 => AnsiRapidBlink._(string),
      7 => AnsiReverse._(string),
      8 => AnsiConceal._(string),
      9 => AnsiCrossedOut._(string),
      // 11–19: Alternative font
      21 => AnsiDoublyUnderlined._(string),
      22 => AnsiNormalIntensity._(string),
      23 => AnsiNotItalic._(string),
      24 => AnsiNotUnderlined._(string),
      25 => AnsiNotBlinking._(string),
      // 26: Proportional spacing (not known to be used on terminals)
      27 => AnsiNotReversed._(string),
      28 => AnsiReveal._(string),
      29 => AnsiNotCrossedOut._(string),
      //
      30 => AnsiForegroundBlack._(string),
      31 => AnsiForegroundRed._(string),
      32 => AnsiForegroundGreen._(string),
      33 => AnsiForegroundYellow._(string),
      34 => AnsiForegroundBlue._(string),
      35 => AnsiForegroundMagenta._(string),
      36 => AnsiForegroundCyan._(string),
      37 => AnsiForegroundWhite._(string),
      38 => AnsiForegroundColor._parse(match, params),
      39 => AnsiForegroundDefault._(string),
      //
      40 => AnsiBackgroundBlack._(string),
      41 => AnsiBackgroundRed._(string),
      42 => AnsiBackgroundGreen._(string),
      43 => AnsiBackgroundYellow._(string),
      44 => AnsiBackgroundBlue._(string),
      45 => AnsiBackgroundMagenta._(string),
      46 => AnsiBackgroundCyan._(string),
      47 => AnsiBackgroundWhite._(string),
      48 => AnsiBackgroundColor._parse(match, params),
      49 => AnsiBackgroundDefault._(string),
      // 50: Disable proportional spacing
      51 => AnsiFramed._(string),
      52 => AnsiEncircled._(string),
      53 => AnsiOverlined._(string),
      54 => AnsiNeitherFramedNorEncircled._(string),
      55 => AnsiNotOverlined._(string),
      // 56-57: ?
      58 => AnsiUnderlineColor._parse(match, params),
      59 => AnsiUnderlineDefault._(string),
      // 60-65: Rarely supported
      // 66-72: ?
      73 => AnsiSuperscript._(string),
      74 => AnsiSubscript._(string),
      75 => AnsiNeitherSuperscriptNorSubscript._(string),
      // 76-89: ?
      90 => AnsiForegroundBrightBlack._(string),
      91 => AnsiForegroundBrightRed._(string),
      92 => AnsiForegroundBrightGreen._(string),
      93 => AnsiForegroundBrightYellow._(string),
      94 => AnsiForegroundBrightBlue._(string),
      95 => AnsiForegroundBrightMagenta._(string),
      96 => AnsiForegroundBrightCyan._(string),
      97 => AnsiForegroundBrightWhite._(string),
      // 98-99: ?
      100 => AnsiBackgroundBrightBlack._(string),
      101 => AnsiBackgroundBrightRed._(string),
      102 => AnsiBackgroundBrightGreen._(string),
      103 => AnsiBackgroundBrightYellow._(string),
      104 => AnsiBackgroundBrightBlue._(string),
      105 => AnsiBackgroundBrightMagenta._(string),
      106 => AnsiBackgroundBrightCyan._(string),
      107 => AnsiBackgroundBrightWhite._(string),
      //
      _ => AnsiSgrUnknown._(string),
    };
  }

  const AnsiSgr._(super.string) : super._();
}

final class AnsiSgrUnknown extends AnsiSgr with AnsiUnrecognized {
  const AnsiSgrUnknown._(super.string) : super._();

  @override
  String get id => 'unknown_sgr:${super.id}';

  @override
  String toString() => '$AnsiSgr(${toStringAsEscapeSquences()})';
}

final class AnsiReset extends AnsiSgr {
  const AnsiReset() : super._(reset);

  const AnsiReset._(super.string) : super._();

  @override
  String get id => 'reset';

  @override
  String toString() => '$AnsiReset()';
}

sealed class AnsiIntensityStyle extends AnsiSgr {
  const AnsiIntensityStyle._(super.string) : super._();
}

final class AnsiBold extends AnsiIntensityStyle {
  const AnsiBold() : super._(bold);

  const AnsiBold._(super.string) : super._();

  @override
  String get id => 'bold';

  @override
  String toString() => '$AnsiBold()';
}

final class AnsiFaint extends AnsiIntensityStyle {
  const AnsiFaint() : super._(faint);

  const AnsiFaint._(super.string) : super._();

  @override
  String get id => 'faint';

  @override
  String toString() => '$AnsiFaint()';
}

final class AnsiNormalIntensity extends AnsiIntensityStyle {
  const AnsiNormalIntensity() : super._(neitherBoldNorFaint);

  const AnsiNormalIntensity._(super.string) : super._();

  @override
  String get id => 'normalIntensity';

  @override
  String toString() => '$AnsiNormalIntensity()';
}

sealed class AnsiItalicStyle extends AnsiSgr {
  const AnsiItalicStyle._(super.string) : super._();
}

final class AnsiItalic extends AnsiItalicStyle {
  const AnsiItalic() : super._(italic);

  const AnsiItalic._(super.string) : super._();

  @override
  String get id => 'italic';

  @override
  String toString() => '$AnsiItalic()';
}

final class AnsiNotItalic extends AnsiItalicStyle {
  const AnsiNotItalic() : super._(notItalic);

  const AnsiNotItalic._(super.string) : super._();

  @override
  String get id => 'notItalic';

  @override
  String toString() => '$AnsiNotItalic()';
}

sealed class AnsiUnderlineStyle extends AnsiSgr {
  const AnsiUnderlineStyle._(super.string) : super._();
}

final class AnsiUnderline extends AnsiUnderlineStyle {
  const AnsiUnderline() : super._(underline);

  const AnsiUnderline._(super.string) : super._();

  @override
  String get id => 'underline';

  @override
  String toString() => '$AnsiUnderline()';
}

final class AnsiDoublyUnderlined extends AnsiUnderline {
  const AnsiDoublyUnderlined() : super._(doublyUnderlined);

  const AnsiDoublyUnderlined._(super.string) : super._();

  @override
  String get id => 'doublyUnderlined';

  @override
  String toString() => '$AnsiDoublyUnderlined()';
}

final class AnsiNotUnderlined extends AnsiUnderline {
  const AnsiNotUnderlined() : super._(notUnderlined);

  const AnsiNotUnderlined._(super.string) : super._();

  @override
  String get id => 'notUnderlined';

  @override
  String toString() => '$AnsiNotUnderlined()';
}

sealed class AnsiBlinkStyle extends AnsiSgr {
  const AnsiBlinkStyle._(super.string) : super._();
}

final class AnsiBlink extends AnsiBlinkStyle {
  const AnsiBlink() : super._(blink);

  const AnsiBlink._(super.string) : super._();

  @override
  String get id => 'blink';

  @override
  String toString() => '$AnsiBlink()';
}

final class AnsiRapidBlink extends AnsiBlinkStyle {
  const AnsiRapidBlink() : super._(rapidBlink);

  const AnsiRapidBlink._(super.string) : super._();

  @override
  String get id => 'rapidBlink';

  @override
  String toString() => '$AnsiRapidBlink()';
}

final class AnsiNotBlinking extends AnsiBlinkStyle {
  const AnsiNotBlinking() : super._(notBlinking);

  const AnsiNotBlinking._(super.string) : super._();

  @override
  String get id => 'notBlinking';

  @override
  String toString() => '$AnsiNotBlinking()';
}

sealed class AnsiReverseStyle extends AnsiSgr {
  const AnsiReverseStyle._(super.string) : super._();
}

final class AnsiReverse extends AnsiReverseStyle {
  const AnsiReverse() : super._(reverse);

  const AnsiReverse._(super.string) : super._();

  @override
  String get id => 'reverse';

  @override
  String toString() => '$AnsiReverse()';
}

final class AnsiNotReversed extends AnsiReverseStyle {
  const AnsiNotReversed() : super._(notReversed);

  const AnsiNotReversed._(super.string) : super._();

  @override
  String get id => 'notReversed';

  @override
  String toString() => '$AnsiNotReversed()';
}

sealed class AnsiConcealStyle extends AnsiSgr {
  const AnsiConcealStyle._(super.string) : super._();
}

final class AnsiConceal extends AnsiConcealStyle {
  const AnsiConceal() : super._(conceal);

  const AnsiConceal._(super.string) : super._();

  @override
  String get id => 'conceal';

  @override
  String toString() => '$AnsiConceal()';
}

final class AnsiReveal extends AnsiConcealStyle {
  const AnsiReveal() : super._(reveal);

  const AnsiReveal._(super.string) : super._();

  @override
  String get id => 'reveal';

  @override
  String toString() => '$AnsiReveal()';
}

sealed class AnsiCrossedOutStyle extends AnsiSgr {
  const AnsiCrossedOutStyle._(super.string) : super._();
}

final class AnsiCrossedOut extends AnsiCrossedOutStyle {
  const AnsiCrossedOut() : super._(crossedOut);

  const AnsiCrossedOut._(super.string) : super._();

  @override
  String get id => 'crossedOut';

  @override
  String toString() => '$AnsiCrossedOut()';
}

final class AnsiNotCrossedOut extends AnsiCrossedOutStyle {
  const AnsiNotCrossedOut() : super._(notCrossedOut);

  const AnsiNotCrossedOut._(super.string) : super._();

  @override
  String get id => 'notCrossedOut';

  @override
  String toString() => '$AnsiNotCrossedOut()';
}

sealed class AnsiFramedStyle extends AnsiSgr {
  const AnsiFramedStyle._(super.string) : super._();
}

final class AnsiFramed extends AnsiFramedStyle {
  const AnsiFramed() : super._(framed);

  const AnsiFramed._(super.string) : super._();

  @override
  String get id => 'framed';

  @override
  String toString() => '$AnsiFramed()';
}

final class AnsiEncircled extends AnsiFramedStyle {
  const AnsiEncircled() : super._(encircled);

  const AnsiEncircled._(super.string) : super._();

  @override
  String get id => 'encircled';

  @override
  String toString() => '$AnsiEncircled()';
}

final class AnsiNeitherFramedNorEncircled extends AnsiFramedStyle {
  const AnsiNeitherFramedNorEncircled() : super._(neitherFramedNorEncircled);

  const AnsiNeitherFramedNorEncircled._(super.string) : super._();

  @override
  String get id => 'neitherFramedNorEncircled';

  @override
  String toString() => '$AnsiNeitherFramedNorEncircled()';
}

sealed class AnsiOverlinedStyle extends AnsiSgr {
  const AnsiOverlinedStyle._(super.string) : super._();
}

final class AnsiOverlined extends AnsiOverlinedStyle {
  const AnsiOverlined() : super._(overlined);

  const AnsiOverlined._(super.string) : super._();

  @override
  String get id => 'overlined';

  @override
  String toString() => '$AnsiOverlined()';
}

final class AnsiNotOverlined extends AnsiOverlinedStyle {
  const AnsiNotOverlined() : super._(notOverlined);

  const AnsiNotOverlined._(super.string) : super._();

  @override
  String get id => 'notOverlined';

  @override
  String toString() => '$AnsiNotOverlined()';
}

sealed class AnsiSuperAndSubsriptStyle extends AnsiSgr {
  const AnsiSuperAndSubsriptStyle._(super.string) : super._();
}

final class AnsiSuperscript extends AnsiSuperAndSubsriptStyle {
  const AnsiSuperscript() : super._(superscript);

  const AnsiSuperscript._(super.string) : super._();

  @override
  String get id => 'superscript';

  @override
  String toString() => '$AnsiSuperscript()';
}

final class AnsiSubscript extends AnsiSuperAndSubsriptStyle {
  const AnsiSubscript() : super._(subscript);

  const AnsiSubscript._(super.string) : super._();

  @override
  String get id => 'subscript';

  @override
  String toString() => '$AnsiSubscript()';
}

final class AnsiNeitherSuperscriptNorSubscript
    extends AnsiSuperAndSubsriptStyle {
  const AnsiNeitherSuperscriptNorSubscript()
      : super._(netherSuperscriptedNorSubscripted);

  const AnsiNeitherSuperscriptNorSubscript._(super.string) : super._();

  @override
  String get id => 'netherSuperscriptedNorSubscripted';

  @override
  String toString() => '$AnsiNeitherSuperscriptNorSubscript()';
}
