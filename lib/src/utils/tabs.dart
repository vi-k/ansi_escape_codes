import 'dart:io' as io;

import '../ansi/c1.dart';
import '../ansi/csi.dart';
import '../ready_to_use/csi.dart';

/// Sets the tabulation stops of the terminal.
///
/// The stops that were set before are always cleared first, so calling this
/// without [defaultTab] and without [tabs] leaves the terminal with no stops
/// at all — it does not bring back the ones the terminal started with.
///
/// [tabs] sets a stop after each of the given distances; [defaultTab] then
/// keeps setting one every that many columns until the width of the terminal
/// is reached.
///
/// The numbers are distances rather than column numbers, and the run starts
/// at the left edge: `tabs: [8, 4, 4]` sets its stops in columns 9, 13 and 17.
/// [defaultTab] sets one in the first column as well, which [tabs] does not —
/// a run laid out from the left begins at the left. Forward tabulation never
/// sees that difference, `HT` going to the first stop right of the cursor;
/// a backward one does.
///
/// Every stop advances the cursor, so [defaultTab] and each element of [tabs]
/// must be greater than `0`, otherwise a [RangeError] is thrown and nothing is
/// written. A distance reaching past the width sets no stop and ends the run
/// there, however far past it reaches: what follows it has no room either.
///
/// Nothing is written when [stdout] is not a terminal: there are no stops to
/// set and no width to fit them into.
void tabs({
  int? defaultTab,
  List<int>? tabs,
  io.Stdout? stdout,
}) {
  if (defaultTab != null && defaultTab < 1) {
    throw RangeError.value(defaultTab, 'defaultTab', 'Must be greater than 0');
  }

  if (tabs != null) {
    for (final tab in tabs) {
      if (tab < 1) {
        throw RangeError.value(tab, 'tabs', 'Must be greater than 0');
      }
    }
  }

  stdout ??= io.stdout;
  if (!stdout.hasTerminal) {
    return;
  }

  final width = stdout.terminalColumns;

  // Reset tabs.
  stdout.write('\r${CSI}3$TBC');

  // How far along the line the stops have got. Each step is measured against
  // what is left of the width rather than added on and compared afterwards:
  // a single stop as wide as the int range takes the total round through the
  // negatives, and a negative total never reaches a width to stop at. The
  // loop below then writes until the terminal drowns.
  var pos = 0;

  // Set new tabs from list.
  if (tabs != null) {
    for (final tab in tabs) {
      if (tab >= width - pos) {
        pos = width;
        break;
      }

      pos += tab;
      stdout
        ..write(cursorRightN(tab))
        ..write(HTS);
    }
  }

  // Set default tab.
  if (defaultTab != null) {
    if (pos == 0) {
      stdout.write(HTS);
    }

    while (defaultTab < width - pos) {
      pos += defaultTab;
      stdout
        ..write(cursorRightN(defaultTab))
        ..write(HTS);
    }
  }

  stdout.write('\r');
}
