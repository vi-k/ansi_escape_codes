import 'dart:io';
import 'dart:math';

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;

Future<void> main() async {
  const pause = 500;
  const delay = 50;
  final random = Random();

  stdout
    ..writeln('Usage:')
    ..writeln('dart run example/control.dart');
  await Future<void>.delayed(const Duration(seconds: 2));

  stdout.write('Erase in display');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  stdout
    ..write(ansi.clearScreen)
    ..write(ansi.clearScreenWithBuf);
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout.write('${ansi.cursorPosTo(1, 1)}Cursor Position');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 20; i++) {
    final col = random.nextInt(20) + 1;
    final row = random.nextInt(10) + 2;
    stdout.write('${ansi.cursorPosTo(row, col)}*');
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write(
      '${ansi.cursorHVPosTo(1, 21)}Horizontal Vertical Position',
    );

  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 20; i++) {
    final col = random.nextInt(20) + 21;
    final row = random.nextInt(10) + 2;
    stdout.write('${ansi.cursorHVPosTo(row, col)}*');
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..write(ansi.cursorPosTo(12, 1))
    ..write('Cursor up/Cursor down');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    stdout.write(ansi.cursorUp);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  for (var i = 0; i < 10; i++) {
    stdout.write(ansi.cursorDown);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write('Cursor forward/Cursor back');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    stdout.write(ansi.cursorForward);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  for (var i = 0; i < 10; i++) {
    stdout.write(ansi.cursorBack);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write('Cursor next line/Cursor previous line');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    stdout.write(ansi.cursorNextLine);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  for (var i = 0; i < 10; i++) {
    stdout.write(ansi.cursorPrevLine);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write('Cursor Horizontal Absolute');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 20; i++) {
    final col = random.nextInt(50) + 31;
    stdout.write('${ansi.cursorHPosN(col)}*');
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout
    ..writeln()
    ..write('Erase in line');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 8; i++) {
    stdout.write(ansi.cursorBack);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));
  stdout.write(ansi.eraseLineToBegin);
  await Future<void>.delayed(const Duration(milliseconds: pause));
  stdout.write(ansi.eraseLineToEnd);
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 5; i++) {
    stdout.write(ansi.cursorBack);
    await Future<void>.delayed(const Duration(milliseconds: delay));
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  stdout.write('Scroll up/Scroll down                    ');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(const Duration(milliseconds: delay));
    stdout.write(ansi.scrollDown);
  }
  stdout.write('up');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 20; i++) {
    await Future<void>.delayed(const Duration(milliseconds: delay));
    stdout.write(ansi.scrollUp);
  }
  stdout.write('down');
  await Future<void>.delayed(const Duration(milliseconds: pause));
  for (var i = 0; i < 10; i++) {
    await Future<void>.delayed(const Duration(milliseconds: delay));
    stdout.write(ansi.scrollDown);
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));

  try {
    stdout
      ..writeln()
      ..write('Device Status Report: ');
    await Future<void>.delayed(const Duration(milliseconds: pause));
    final pos = await ansi.currentCursorPos(stdout, stdin);
    stdout.writeln(pos);
    await Future<void>.delayed(const Duration(milliseconds: pause));
    // ignore: avoid_catching_errors
  } on UnsupportedError catch (error) {
    stdout.writeln(error);
  }

  stdout.write('Hide the cursor/Show the cursor');
  for (var i = 0; i < 3; i++) {
    await Future<void>.delayed(const Duration(milliseconds: pause));
    stdout.write(ansi.hideCursor);
    await Future<void>.delayed(const Duration(milliseconds: pause));
    stdout.write(ansi.showCursor);
  }
  await Future<void>.delayed(const Duration(milliseconds: pause));
}
