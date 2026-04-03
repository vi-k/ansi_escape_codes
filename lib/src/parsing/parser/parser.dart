import 'dart:async';
import 'dart:math' as math;

import 'package:meta/meta.dart';

import '../../ansi/sgr.dart';
import '../../extensions/remove.dart';
import '../../extensions/show_control_codes.dart';
import '../../extensions/show_escape_codes.dart';
import '../../ready_to_use/sgr/sgr.dart';
import '../colors/color.dart';
import '../control_functions/control_functions_c1.dart';
import '../control_functions/control_sequences.dart';
import '../control_functions/sgr.dart';
import '../patterns/patterns.dart';
import '../state/state.dart';

part 'printer.dart';
part 'entities/csi.dart';
part 'entities/entity.dart';
part 'entities/esc.dart';
part 'entities/matching_state.dart';
part 'entities/osc.dart';
part 'entities/sgr.dart';
part 'matches/parser_iterator.dart';
part 'matches/match.dart';
part 'matches/matches.dart';
part 'matches/matches_result.dart';

@Deprecated('Use Parser instead')
typedef AnsiParser = Parser;

/// A parser that processes strings containing ANSI escape codes and tracks the
/// current [Style].
///
/// [Parser] allows you to perform various operations on strings with ANSI
/// sequences, such as:
/// * Stripping out the escape codes using [removeAll].
/// * Optimizing the string to remove redundant codes using [optimize].
/// * Extracting a substring while preserving the active style using
///   [substring].
/// * Retrieving the computed [Style] at a specific text position using
///   [stateAt] and [finalState].
/// * Analyzing a string using [matches].
///
/// [Parser] allows you to work with a string containing ANSI escape codes as
/// with a regular string without ANSI escape codes:
/// * [length] - string length without ANSI escape codes.
/// * [indexOf] - index of the first occurrence of a pattern in the string
///   without ANSI escape codes.
/// * [lastIndexOf] - index of the last occurrence of a pattern in the string
///   without ANSI escape codes.
/// * [contains] - whether the string contains a pattern in the string without
///   ANSI escape codes.
/// * [startsWith] - whether the string starts with a pattern in the string
///   without ANSI escape codes.
/// * [endsWith] - whether the string ends with a pattern in the string without
///   ANSI escape codes.
final class Parser extends _ParserBase<Style> {
  /// Creates a [Parser] for the given [input] string.
  Parser(String input) : super(input, Style.defaults);
}

/// A parser that processes strings containing ANSI escape codes and tracks
/// the [Stack] of styles.
///
/// Similar to [Parser], but instead of maintaining only the currently active
/// [Style], [StackedParser] tracks the full history of applied styles using a
/// [Stack]. This is useful for complex formatting where styles might be
/// applied and reverted hierarchically.
final class StackedParser extends _ParserBase<Stack> {
  /// Creates a [StackedParser] for the given [input] string.
  StackedParser(String input) : super(input, Stack.defaults);
}

final class _ParserBase<S extends State<S>> {
  final String input;
  final S initialState;

  Matches<S>? _matches;
  String? _plainString;

  _ParserBase(this.input, this.initialState);

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

  @visibleForTesting
  bool get isParsed => _matches?.isParsed ?? false;

  /// The [Matches] of the string.
  Matches<S> get matches => _matches ??= Matches._(input, initialState);

  /// The final [S] after processing the entire string.
  ///
  /// See also [stateAt].
  S get finalState => matches._requireParsingResult.finalState;

  /// String length without ANSI escape codes.
  int get length => _requirePlainString.length;

  /// Whether the string is closed with the default style.
  bool get isClosed => finalState == Style.defaults;

  /// Forcibly collects [matches] and prepares plain string.
  void prepare() {
    matches._requireParsingResult;
    _requirePlainString;
  }

  /// Index of the first occurrence of a pattern in the string without ANSI
  /// escape codes.
  int indexOf(Pattern pattern) => _requirePlainString.indexOf(pattern);

  /// Index of the last occurrence of a pattern in the string without ANSI
  /// escape codes.
  int lastIndexOf(Pattern pattern) => _requirePlainString.lastIndexOf(pattern);

  /// Whether the string contains a pattern in the string without ANSI escape
  /// codes.
  bool contains(Pattern other, [int startIndex = 0]) =>
      _requirePlainString.contains(other, startIndex);

  /// Whether the string starts with a pattern in the string without ANSI
  /// escape codes.
  bool startsWith(Pattern pattern, [int index = 0]) =>
      _requirePlainString.startsWith(pattern, index);

  /// Whether the string ends with a pattern in the string without ANSI
  /// escape codes.
  bool endsWith(String other) => _requirePlainString.endsWith(other);

  @Deprecated('Use stateAt instead')
  S stateAtPos(int pos) => stateAt(pos);

  /// Returns the [S] of the string at the given plain text [pos].
  ///
  /// [pos] is the position in the string without ANSI escape codes.
  ///
  /// See also [finalState].
  S stateAt(int pos) {
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

  /// Replaces all [EscapeCode]s in the string with the result of the [replace]
  /// function.
  ///
  /// [replacePlainText] is an optional function that replaces [Text] entities.
  /// If not provided, [Text] entities are not changed.
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

  /// Returns the string without ANSI escape codes.
  String removeAll() => _requirePlainString;

  /// Returns a string in which all [EscapeCode] are replaced with their
  /// identifiers.
  ///
  /// ```dart
  /// const text = 'Hello ${fgRed}world$reset';
  /// final parser = Parser(text);
  /// print(parser.showControlFunctions());
  /// // Hello [fgRed]world[reset]
  /// ```
  ///
  /// [open] is the string to prepend to each [EscapeCode].
  /// [close] is the string to append to each [EscapeCode].
  String showControlFunctions({
    String open = '[',
    String close = ']',
  }) =>
      replaceAll((e) => '$open${e.id}$close');

  /// Returns a substring of the given [start] position while preserving the
  /// text style.
  ///
  /// [maxLength] is the maximum length of the substring.
  /// [close] is whether to close the substring with the default style.
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
    var currentState = Style.defaults;
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
              currentState = m.state.toStyle();
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
          close ? Style.defaults : lastMatch.state,
          skipSet: true,
        ),
      );
    }

    return buf.toString();
  }

  String padRight(int width, [String padding = ' ']) {
    final needToAdd = width - length;
    if (needToAdd <= 0) {
      return input;
    }

    return input.padRight(input.length + needToAdd, padding);
  }

  String padLeft(int width, [String padding = ' ']) {
    final needToAdd = width - length;
    if (needToAdd <= 0) {
      return input;
    }

    return input.padLeft(input.length + needToAdd, padding);
  }

  /// Optimizes the string by removing consecutive escape codes.
  ///
  /// [close] is whether to close the string with the default style.
  String optimize({bool close = true}) {
    final buf = StringBuffer();
    var currentState = Style.defaults;

    for (final m in matches) {
      final entity = m.entity;
      if (entity is Text) {
        final string = entity.string;
        if (string.isNotEmpty) {
          buf
            ..write(currentState.transitTo(m.state))
            ..write(string);
        }
        currentState = m.state.toStyle();
      }
    }

    final lastMatch = matches.lastOrNull;

    if (close) {
      buf.write(currentState.transitTo(Style.defaults));
    } else if (lastMatch != null) {
      buf.write(currentState.transitTo(lastMatch.state));
    }

    return buf.toString();
  }
}
