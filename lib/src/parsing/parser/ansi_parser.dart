import 'dart:async';
import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../controls/sgr.dart';
import '../../extensions/remove.dart';
import '../../extensions/show_control_codes.dart';
import '../../extensions/show_escape_codes.dart';
import '../../predefined_values/sgr/sgr.dart';
import '../colors/color.dart';
import '../control_functions/control_functions_c1.dart';
import '../control_functions/control_sequences.dart';
import '../control_functions/sgr.dart';
import '../patterns/patterns.dart';
import '../state/sgr_state.dart';

part 'ansi_printer.dart';
part 'entities/csi.dart';
part 'entities/entity.dart';
part 'entities/esc.dart';
part 'entities/matching_state.dart';
part 'entities/osc.dart';
part 'entities/sgr.dart';
part 'matches/ansi_parser_iterator.dart';
part 'matches/match.dart';
part 'matches/matches.dart';
part 'matches/matches_result.dart';

/// Parser for analyzing strings containing codes.
sealed class AnsiParser {
  factory AnsiParser(
    String input, {
    @experimental bool stacked = false,
  }) =>
      !stacked
          ? _ParserBase._(input, SgrPlainState.defaults)
          : _ParserBase._(input, SgrStackedState.defaults);

  AnsiParser._();

  @visibleForTesting
  bool get isParsed;

  /// List of matches.
  Iterable<Match<SgrState<void>>> get matches;

  /// Final state of the string.
  SgrState get finalState;

  /// String length without escape codes.
  int get length;

  /// Whether the string is closed.
  bool get isClosed;

  /// Optional method. Only needed to optimize parsing only.
  void prepare();

  /// Return state at [pos].
  ///
  /// [pos] can point to the end of the string, i.e. be in the range from 0 to
  /// [length] inclusive.
  SgrState stateAtPos(int pos);

  /// Replaces all escape codes with [replace].
  ///
  /// Creates a new string in which the escape codes are replaced by the result
  /// of calling [replace] on the corresponding [EscapeCode] code.
  ///
  /// ```dart
  /// print(
  ///   AnsiParser('$bold bold $italicized italicized $reset')
  ///       .replaceAll((code) => '[${code.id}]'),
  /// )
  /// // bold] bold [italicized] italicized [reset]
  /// ```
  ///
  /// [replacePlainText] allows you to process plain text:
  ///
  /// ```dart
  /// print(
  ///   AnsiParser('$bold bold\n$italicized italicized\n$reset').replaceAll(
  ///     (code) => '[${code.id}]',
  ///     replacePlainText: (entity) => entity.string.showAnsiControlCodes(),
  ///   ),
  /// );
  /// // [bold] bold\n[italicized] italicized\n[reset]
  /// ```
  String replaceAll(
    String Function(EscapeCode code) replace, {
    String Function(Text entity)? replacePlainText,
  });

  /// Remove all escape codes.
  ///
  /// Returns plain string without escape codes.
  String removeAll();

  /// Show all control functions at the string.
  String showControlFunctions({
    String open = '[',
    String close = ']',
  });

  /// The substring of this string from [start], maximum length [maxLength].
  ///
  /// Example:
  ///
  /// ```dart
  /// const string = '$fgRed'
  ///     ' $underlined${bold}bold$resetBoldAndFaint'
  ///     ' ${italicized}italic$resetItalicized$resetUnderlined'
  ///     ' $resetFg';
  /// final substring = AnsiParser(string).substring(3, maxLength: 6);
  /// print(AnsiParser(substring).showControlFunctions());
  /// // [fgRed;bold;underlined]ld[resetBoldAndFaint] [italicized]ita[reset]
  /// ```
  ///
  /// By default, the string will be closed ('[reset]' at the end of the
  /// string). If you disable the [close] parameter, the string will not be
  /// closed. This means that when it is printed, it will affect the next text
  /// output:
  ///
  /// ```dart
  /// final substring =
  ///     AnsiParser(string).substring(3, maxLength: 6, close: false);
  /// print(AnsiParser(substring).showControlFunctions());
  /// // [fgRed;bold;underlined]ld[resetBoldAndFaint] [italicized]ita
  /// ```
  ///
  /// The escape codes are not copied into the string directly, but are
  /// inserted in an optimized form:
  ///
  /// ```dart
  /// const string = '$bold$bold$italicized$resetItalicized${underlined}text'
  ///     '$resetBoldAndFaint$resetUnderlined';
  /// final substring = AnsiParser(string).substring(0, maxLength: 4);
  /// print(AnsiParser(substring).showControlFunctions());
  /// // [bold;underlined]text[reset]
  /// ```
  String substring(
    int start, {
    int? maxLength,
    bool close = true,
  });

  /// Optimizes codes by removing redundant codes and merging the remaining
  /// ones.
  String optimize({
    bool close = true,
  });
}

final class _ParserBase<S extends SgrState<S>> extends AnsiParser {
  final String input;
  final S initialState;

  Matches<S>? _matches;
  String? _plainString;

  _ParserBase._(this.input, this.initialState) : super._();

  String get _requirePlainString => _plainString ??= () {
        final buf = StringBuffer();
        for (final m in matches) {
          final entity = m.entity;
          if (entity is Text) {
            buf.write(entity.string);
          }
        }

        return buf.toString();
      }();

  @override
  @visibleForTesting
  bool get isParsed => _matches?.isParsed ?? false;

  @override
  Matches<S> get matches => _matches ??= Matches._(input, initialState);

  @override
  S get finalState => matches._requireParsingResult.finalState;

  @override
  int get length => _requirePlainString.length;

  @override
  bool get isClosed => finalState == SgrPlainState.defaults;

  @override
  void prepare() {
    matches._requireParsingResult;
    _requirePlainString;
  }

  int indexOf(Pattern pattern) => _requirePlainString.indexOf(pattern);

  int lastIndexOf(Pattern pattern) => _requirePlainString.lastIndexOf(pattern);

  bool contains(Pattern other, [int startIndex = 0]) =>
      _requirePlainString.contains(other, startIndex);

  bool startsWith(Pattern pattern, [int index = 0]) =>
      _requirePlainString.startsWith(pattern, index);

  bool endsWith(String other) => _requirePlainString.endsWith(other);

  @override
  S stateAtPos(int pos) {
    RangeError.checkNotNegative(pos, 'pos');

    var end = 0;
    for (final m in matches) {
      if (m.entity case Text(:final string)) {
        end += string.length;
        if (end > pos) {
          return m.state;
        }
      }
    }

    RangeError.checkValidIndex(pos, null, 'pos', end + 1);

    return finalState;
  }

  @override
  String replaceAll(
    String Function(EscapeCode code) replace, {
    String Function(Text entity)? replacePlainText,
  }) {
    final buf = StringBuffer();

    for (final m in matches) {
      final entity = m.entity;

      final result = switch (entity) {
        EscapeCode() => replace(entity),
        Text() => replacePlainText?.call(entity) ?? entity.string,
      };

      buf.write(result);
    }

    return buf.toString();
  }

  @override
  String removeAll() => _requirePlainString;

  @override
  String showControlFunctions({
    String open = '[',
    String close = ']',
  }) =>
      replaceAll((e) => '$open${e.id}$close');

  @override
  String substring(
    int start, {
    int? maxLength,
    bool close = true,
  }) {
    if (start < 0) {
      throw RangeError.range(start, 0, null, 'start');
    }

    final end = maxLength == null ? null : start + maxLength;
    if (end != null && start > end) {
      throw RangeError.range(end, start, null, 'end');
    }

    final buf = StringBuffer();
    var pos = 0;
    var currentState = SgrPlainState.defaults;
    Match<S>? lastMatch;

    for (final m in matches) {
      final entity = m.entity;

      switch (entity) {
        case Text():
          final string = entity.string;
          pos += string.length;
          if (pos >= start) {
            final substring = string.substring(
              math.max(string.length - (pos - start), 0),
              end == null
                  ? string.length
                  : math.min(string.length - (pos - end), string.length),
            );
            if (substring.isNotEmpty) {
              buf
                ..write(currentState.transitTo(m.state))
                ..write(substring);
              currentState = m.state.toPlainState();
              lastMatch = m;
            }
          }

        case EscapeCode():
          lastMatch = m;
      }

      if (end != null && pos > end) {
        break;
      }
    }

    if (start > pos) {
      throw RangeError.range(start, 0, pos, 'start');
    }

    if (lastMatch != null) {
      buf.write(
        currentState.transitTo(
          close ? SgrPlainState.defaults : lastMatch.state,
          skipSet: true,
        ),
      );
    }

    return buf.toString();
  }

  @override
  String optimize({bool close = true}) {
    final buf = StringBuffer();
    var currentState = SgrPlainState.defaults;

    for (final m in matches) {
      final entity = m.entity;
      if (entity is Text) {
        final string = entity.string;
        if (string.isNotEmpty) {
          buf
            ..write(currentState.transitTo(m.state))
            ..write(string);
        }
        currentState = m.state.toPlainState();
      }
    }

    final lastMatch = matches.lastOrNull;

    if (close) {
      buf.write(currentState.transitTo(SgrPlainState.defaults));
    } else if (lastMatch != null) {
      buf.write(currentState.transitTo(lastMatch.state));
    }

    return buf.toString();
  }
}
