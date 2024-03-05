import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;

Future<void> progressTest(
  String caption,
  String restorePosition, {
  String? onStart,
}) async {
  stdout
    ..write(ansi.hideCursor)
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

  stdout.writeln(ansi.showCursor);
}

Future<void> main() async {
  await progressTest(
    'Carriage return',
    ansi.cr,
  );

  await progressTest(
    'Cursor back',
    '${ansi.cursorBackOpen}4${ansi.cursorBackClose}',
  );

  await progressTest(
    'Cursor absolute position',
    ansi.cursorHPos,
  );

  await progressTest(
    'Save and restore cursor',
    ansi.restoreCursor,
    onStart: ansi.saveCursor,
  );
}
