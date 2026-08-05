/// The one place the shape of an extended colour lives.
///
/// `38`, `48` and `58` open a colour whose arguments follow as parameters
/// of their own. The introducer and the kind are consumed together, and
/// the kind's arguments only when all of them are there: anything short —
/// a kind with no arguments left to take, an RGB cut off mid-colour —
/// leaves the introducer and the kind consumed alone, and the rest
/// belongs to the sequence as usual. This is the parser's rule;
/// `splitSgrFunctions` reads it from here, the parser reads its
/// argument counts from here, and the fuzzed agreement test holds the
/// rest of the two readings to one answer.
library;

import '../ansi/sgr.dart';

/// Whether [value] introduces an extended colour: the colour of the text,
/// of what is behind it, or of the underline.
bool isExtendedColorIntroducer(int value) =>
    value == FOREGROUND || value == BACKGROUND || value == UNDERLINE_COLOR;

/// How many arguments the kind of an extended colour takes: one for the
/// 256-colour table, three for RGB, none for a kind this package does
/// not know.
int extendedColorArgCount(int kind) => switch (kind) {
      COLOR_256 => 1,
      COLOR_RGB => 3,
      _ => 0,
    };
