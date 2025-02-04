part of '../parsers.dart';

final class AnsiStackedParser {
  final String input;

  _AnsiMatchesV2? _matches;

  AnsiStackedParser(this.input);

  @visibleForTesting
  bool get isParsed => _matches?._parsingResult != null;

  AnsiMatches<AnsiStackedState> get matches =>
      _matches ?? _AnsiMatchesV2(input);

  AnsiStackedState get endState => matches._requireParsingResult.endState;

  int get length => matches.fold(
        0,
        (prev, m) =>
            prev +
            switch (m.entity) {
              AnsiPlainText(:final string) => string.length,
              _ => 0,
            },
      );

  /// Has escape codes?
  bool get hasEscapeCodes => escapeCodesRe.hasMatch(input);

  /// Has CSI?
  bool get hasCsi => csiRe.hasMatch(input);

  /// Has SGR?
  bool get hasSgr => sgrRe.hasMatch(input);

  /// Has foreground color?
  bool get hasForegroundColor => foregroundRe.hasMatch(input);

  /// Has background color?
  bool get hasBackgroundColor => backgroundRe.hasMatch(input);

  /// Optional method. Only needed to optimize parsing.
  void parse() {
    matches._requireParsingResult;
  }

  AnsiStackedState stateAtPos(int pos) {
    var end = 0;
    for (final m in matches) {
      if (m.entity case AnsiPlainText(:final string)) {
        end += string.length;
        if (end > pos) {
          return m.state;
        }
      }
    }

    if (end != pos) {
      throw RangeError.range(end, 0, null, 'pos');
    }

    return endState;
  }

  /// Replaces all escape codes with [replace].
  ///
  /// Creates a new string in which the escape codes are replaced by the result
  /// of calling [replace] on the corresponding [AnsiEscapeCode] code.
  ///
  /// ```dart
  /// print(
  ///   AnsiParser('$bold bold $italic italic $reset')
  ///       .replaceAll((code) => '[${code.id}]'),
  /// )
  /// // bold] bold [italic] italic [reset]
  /// ```
  ///
  /// [replacePlainText] allows you to process plain text:
  ///
  /// ```dart
  /// print(
  ///   AnsiParser('$bold bold\n$italic italic\n$reset').replaceAll(
  ///     (code) => '[${code.id}]',
  ///     replacePlainText: (entity) => entity.string.showAnsiControlCodes(),
  ///   ),
  /// );
  /// // [bold] bold\n[italic] italic\n[reset]
  /// ```
  String replaceAll(
    String Function(AnsiEscapeCode code) replace, {
    String Function(AnsiPlainText entity)? replacePlainText,
  }) {
    final buf = StringBuffer();

    for (final m in matches) {
      final entity = m.entity;

      final result = switch (entity) {
        AnsiEscapeCode() => replace(entity),
        AnsiPlainText() => replacePlainText?.call(entity) ?? entity.string,
      };

      buf.write(result);
    }

    return buf.toString();
  }

  /// Remove all escape codes.
  String removeAll() {
    final buf = StringBuffer();

    for (final m in matches) {
      final result = switch (m.entity) {
        AnsiEscapeCode() => '',
        AnsiPlainText(:final string) => string,
      };

      buf.write(result);
    }

    return buf.toString();
  }

  /// The substring of this string from [start], maximum length [maxLength].
  ///
  /// Example:
  ///
  /// ```dart
  /// const string = '$fgRed'
  ///     ' ${bold}BOLD$normalIntensity'
  ///     ' ${italic}ITALIC$notItalic'
  ///     ' $fgDefault';
  /// final substring = AnsiParser(string).substring(3, maxLength: 6);
  /// print(substring);
  /// print(AnsiParser(substring).replaceAll((code) => '[${code.id}]'));
  /// // [fgRed][bold]LD[normalIntensity] [italic]ITA[fgDefault][notItalic]
  /// ```
  ///
  /// By default, the string is closed (`fgDefault` and `nonItalic` at the end
  /// of the string). But if you disable the [close] parameter, the string will
  /// not be closed. This means that when it is printed, it will affect the
  /// next text output:
  ///
  /// ```dart
  /// AnsiParser(string).substring(3, maxLength: 6, close: false);
  /// // [fgRed][bold]LD[normalIntensity] [italic]ITA
  /// ```
  ///
  /// When hitting a text/code boundary, the ending escape codes are not
  /// included in the substring.
  ///
  /// ```dart
  /// AnsiParser(string).substring(0, maxLength: 12, close: false);
  /// // [fgRed] [bold]BOLD[normalIntensity] [italic]ITALIC
  /// ```
  String substring(
    int start, {
    int? maxLength,
    bool close = true,
  }) {
    throw UnimplementedError();
    // if (start < 0) {
    //   throw RangeError.range(start, 0, null, 'start');
    // }

    // final end = maxLength == null ? null : start + maxLength;
    // if (end != null && start > end) {
    //   throw RangeError.range(end, start, null, 'end');
    // }

    // if (start == 0 && (end == null || end == input.length)) {
    //   return input;
    // }

    // final buf = StringBuffer();
    // var pos = 0;
    // AnsiStackedState? currentState;

    // for (final m in matches) {
    //   final entity = m.entity;

    //   switch (entity) {
    //     case AnsiPlainText():
    //       currentState = m.state;
    //       final string = entity.string;
    //       pos += entity.string.length;
    //       if (pos >= start) {
    //         if (buf.isEmpty) {
    //           buf.write(m.state.asStringOnlyNonDefaults);
    //         }
    //         buf.write(
    //           string.substring(
    //             math.max(string.length - (pos - start), 0),
    //             end == null
    //                 ? string.length
    //                 : math.min(string.length - (pos - end), string.length),
    //           ),
    //         );
    //       }

    //     case AnsiEscapeCode():
    //       if (pos >= start) {
    //         if (buf.isEmpty) {
    //           buf.write(m.state.asStringOnlyNonDefaults);
    //         }
    //         buf.write(entity.string);
    //       }
    //   }

    //   if (end != null && pos >= end) {
    //     break;
    //   }
    // }

    // if (start > pos) {
    //   throw RangeError.range(start, 0, pos, 'start');
    // }

    // // if (close && currentState != null) {
    // //   buf.write(currentState._transitTo(AnsiStateV2.defaults));
    // // }

    // return buf.toString();
  }
}
