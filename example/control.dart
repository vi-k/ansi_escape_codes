import 'dart:io';
import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

Future<void> main() async {
  const pause = 500;
  const delay = 50;
  final random = Random();

  stdout
    ..writeln('Usage:')
    ..writeln('dart run example/control.dart');
  await Future<void>.delayed(const Duration(seconds: 2));

  stdout.write('Erase in page');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  stdout.write(erasePage);
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout.write('${cursorPosTo(1, 1)}Cursor Position');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 20; i++) {
    final col = random.nextInt(20) + 1;
    final row = random.nextInt(10) + 2;
    stdout.write('${cursorPosTo(row, col)}*');
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write(
      '${cursorHVPosTo(1, 21)}Horizontal Vertical Position',
    );

  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 20; i++) {
    final col = random.nextInt(20) + 21;
    final row = random.nextInt(10) + 2;
    stdout.write('${cursorHVPosTo(row, col)}*');
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..write(cursorPosTo(12, 1))
    ..write('Cursor up/Cursor down');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    stdout.write(cursorUp);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  for (var i = 0; i < 10; i++) {
    stdout.write(cursorDown);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write('Cursor forward/Cursor back');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    stdout.write(cursorRight);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  for (var i = 0; i < 10; i++) {
    stdout.write(cursorLeft);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write('Cursor next line/Cursor previous line');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    stdout.write(cursorNextLine);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  for (var i = 0; i < 10; i++) {
    stdout.write(cursorPrevLine);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write('Cursor Horizontal Absolute');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 20; i++) {
    final col = random.nextInt(50) + 31;
    stdout.write('${cursorHPosTo(col)}*');
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write('Erase in line');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 8; i++) {
    stdout.write(cursorLeft);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));
  stdout.write(eraseInLineToBegin);
  await Future<void>.delayed(const Duration(milliseconds: pause));
  stdout.write(eraseInLineToEnd);
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 5; i++) {
    stdout.write(cursorLeft);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout.write('Scroll up/Scroll down                    ');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(const Duration(milliseconds: delay));
    stdout.write(scrollDown);
  }
  stdout.write('up');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: delay));
    stdout.write(scrollUp);
  }
  stdout.write('down');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(const Duration(milliseconds: delay));
    stdout.write(scrollDown);
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  try {
    stdout
      ..writeln()
      ..write('Device Status Report: ');
    await Future<void>.delayed(const Duration(milliseconds: pause));
    final pos = await currentCursorPos(stdout, stdin);
    stdout.writeln(pos);
    await Future<void>.delayed(const Duration(milliseconds: pause));
    // ignore: avoid_catching_errors
  } on UnsupportedError catch (error) {
    stdout.writeln(error);
  }

  stdout.write('Hide the cursor/Show the cursor');
  for (var i = 0; i < 3; i++) {
    await Future<void>.delayed(const Duration(milliseconds: pause));
    stdout.write(hideCursor);
    await Future<void>.delayed(const Duration(milliseconds: pause));
    stdout.write(showCursor);
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));
}
