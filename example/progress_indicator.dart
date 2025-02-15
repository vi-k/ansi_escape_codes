import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/controls.dart';

Future<void> progressTest(
  String caption,
  String restorePosition, {
  String? onStart,
}) async {
  stdout
    ..write(hideCursor)
    ..writeln(caption);

  if (onStart != null) {
    stdout.write(onStart);
  }

  for (var i = 0; i <= 100; i++) {
    stdout
      ..write(restorePosition)
      ..write(i)
      ..write('%');

    await Future<void>.delayed(const Duration(milliseconds: 10));
  }

  stdout.writeln(showCursor);
}

Future<void> main() async {
  await progressTest(
    'Carriage return',
    CR,
  );

  await progressTest(
    'Cursor back',
    '${cursorLeftOpen}4$cursorLeftClose',
  );

  await progressTest(
    'Cursor absolute position',
    cursorHPosToBegin,
  );

  await progressTest(
    'Save and restore cursor',
    restoreCursor,
    onStart: saveCursor,
  );
}
