import 'dart:io' as io;

import '../ansi/c1.dart';
import '../ansi/csi.dart';

/// Sets the tabulation stops of the terminal.
///
/// Every stop advances the cursor, so [defaultTab] and each element of [tabs]
/// must be greater than `0`, otherwise a [RangeError] is thrown and nothing is
/// written.
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
  final width = stdout.terminalColumns;

  // Reset tabs.
  stdout.write('\r${CSI}3$TBC');

  var pos = 0;

  // Set new tabs from list.
  if (tabs != null) {
    for (final tab in tabs) {
      pos += tab;
      if (pos >= width) {
        break;
      }
      stdout
        ..write(' ' * tab)
        ..write(HTS);
    }
  }

  // Set default tab.
  if (defaultTab != null) {
    if (pos == 0) {
      stdout.write(HTS);
    }

    while (true) {
      pos += defaultTab;
      if (pos >= width) {
        break;
      }
      stdout
        ..write(' ' * defaultTab)
        ..write(HTS);
    }
  }

  stdout.write('\r');
}
