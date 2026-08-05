import '../ansi/c1.dart';
import '../ansi/csi.dart';
import '../ansi/sgr.dart';
import '../parsing/patterns/patterns.dart';
import 'sgr_rules.dart';

/// Splits the parameters of an SGR sequence into separate functions.
///
/// A colour introduced by `38`, `48` or `58` takes its arguments as parameters
/// of its own (`38;5;196`), so it is kept together with them. In the colon
/// form (`38:5:196`) the whole colour is already a single parameter.
List<String> splitSgrFunctions(String params) {
  if (params.isEmpty) {
    return const [];
  }

  final parts = params.split(';');
  final functions = <String>[];

  for (var i = 0; i < parts.length;) {
    var length = 1;

    // A parameter that is a whole number can open an extended colour;
    // the colon form carries its arguments inside one parameter and
    // stays whole on its own. Numbers are read as numbers: ECMA-48
    // allows leading zeroes, and `038` is `38`.
    final head = int.tryParse(parts[i]);

    if (head != null &&
        isExtendedColorIntroducer(head) &&
        i + 1 < parts.length) {
      // The introducer and the kind go together, the kind's arguments
      // only when all of them are there — the rule lives in sgr_rules.
      length = 2;
      final kind = int.tryParse(parts[i + 1]);
      if (kind != null) {
        final args = extendedColorArgCount(kind);
        if (i + 2 + args <= parts.length) {
          length = 2 + args;
        }
      }
    }

    functions.add(parts.sublist(i, i + length).join(';'));
    i += length;
  }

  return functions;
}

/// Whether the function sets the foreground color.
bool isForegroundFunction(String function) =>
    _isColorFunction(function, FG_BLACK, FG_HIGH_BLACK, FOREGROUND);

/// Whether the function sets the background color.
bool isBackgroundFunction(String function) =>
    _isColorFunction(function, BG_BLACK, BG_HIGH_BLACK, BACKGROUND);

/// Whether the function sets the color of the underline.
///
/// This one has no sixteen-colour forms — only the palette, RGB, and back to
/// the default.
bool isUnderlineColorFunction(String function) {
  final value = int.tryParse(_head(function));

  return value == UNDERLINE_COLOR || value == UNDERLINE_COLOR_DEFAULT;
}

/// Whether any SGR sequence in the text contains a function [test] accepts.
bool hasSgrFunction(String text, bool Function(String function) test) {
  for (final match in sgrRe.allMatches(text)) {
    if (splitSgrFunctions(match.namedGroup('params') ?? '').any(test)) {
      return true;
    }
  }

  return false;
}

/// Drops every function [test] accepts, keeping the rest of each sequence.
///
/// A sequence left without functions is dropped as a whole; a sequence nothing
/// was dropped from is kept as it was written.
String removeSgrFunction(String text, bool Function(String function) test) =>
    text.replaceAllMapped(sgrRe, (match) {
      final params = (match as RegExpMatch).namedGroup('params') ?? '';
      final functions = splitSgrFunctions(params);
      final kept = functions.where((f) => !test(f)).toList();

      if (kept.length == functions.length) {
        return match[0]!;
      }

      return kept.isEmpty ? '' : '$CSI${kept.join(';')}$SGR';
    });

bool _isColorFunction(String function, int base, int high, int extended) {
  final value = int.tryParse(_head(function));

  return value != null &&
      (value == extended ||
          value >= base && value <= base + 7 ||
          value == base + 9 ||
          value >= high && value <= high + 7);
}

/// The part of the function before its arguments.
String _head(String function) {
  for (var i = 0; i < function.length; i++) {
    final char = function[i];
    if (char == ';' || char == ':') {
      return function.substring(0, i);
    }
  }

  return function;
}
