import 'dart:io' as io;

import '../controls/c1.dart';
import '../controls/csi.dart';

void tabs({
  int? defaultTab,
  List<int>? tabs,
  io.Stdout? stdout,
}) {
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
