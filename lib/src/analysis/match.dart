import 'package:ansi_escape_codes/src/analysis/show_escape_sequences.dart';
import 'package:meta/meta.dart';

import 'patterns.dart';

/// Returns all escape sequences in [text].
@experimental
List<Match> allEscapeSequences(String text) =>
    escRe.allMatches(text).map((e) => Match._(e[0]!, e.start, e.end)).toList();

/// Returns all CSI in [text].
@experimental
List<Match> allCsi(String text) =>
    csiRe.allMatches(text).map((e) => Match._(e[0]!, e.start, e.end)).toList();

/// Returns all SGR in [text].
@experimental
List<Match> allSgr(String text) =>
    sgrRe.allMatches(text).map((e) => Match._(e[0]!, e.start, e.end)).toList();

/// Returns all foreground colors in [text].
@experimental
List<Match> foregroundColors(String text) => foregroundRe
    .allMatches(text)
    .map((e) => Match._(e[0]!, e.start, e.end))
    .toList();

/// Returns all background colors in [text].
@experimental
List<Match> backgroundColors(String text) => backgroundRe
    .allMatches(text)
    .map((e) => Match._(e[0]!, e.start, e.end))
    .toList();

/// A regular expression match for escape sequencess.
@experimental
final class Match {
  const Match._(this.code, this.start, this.end);

  final String code;
  final int start;
  final int end;

  @override
  String toString() => '$Match('
      'code: ${showEscapeSequences(code)}'
      ', recognize: ${showEscapeSequences(code, recognizeSequences: true)}'
      ', start: $start'
      ', end: $end)';
}
