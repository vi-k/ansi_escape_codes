import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/controls.dart';

void main() {
  stdout
    ..writeln()
    ..writeln('Standard colors:');

  for (var i = 0; i < 16; i++) {
    final s = ' ${'$i'.padLeft(3, '0')} ';

    if (i % 8 == 0) stdout.writeln();

    stdout
      ..write(fg256(i % 8 == 7 ? GRAY0 : GRAY23))
      ..write(fg256Open)
      ..write(i % 8 == 7 ? GRAY0 : GRAY23)
      ..write(fg256Close)
      ..write(bg256(i))
      ..write(s)
      ..write(reset)
      ..write(fg256(i))
      ..write(s)
      ..write(reset);
  }
  stdout
    ..writeln()
    ..writeln()
    ..writeln('RGB colors:');

  for (var r = 0; r < 6; r++) {
    stdout
      ..writeln()
      ..writeln('r=$r')
      ..write('    ');
    for (var b = 0; b < 6; b++) {
      stdout.write(' b=$b      ');
    }
    for (var g = 0; g < 6; g++) {
      stdout.write('\ng=$g ');

      for (var b = 0; b < 6; b++) {
        final c = rgb(r, g, b);
        final s = ' ${'$c'.padLeft(3, '0')} ';

        stdout
          ..write(
            fg256(g >= 3 ? GRAY0 : GRAY23),
          )
          ..write(bg256(c))
          ..write(s)
          ..write(reset)
          ..write(fg256(c))
          ..write(s)
          ..write(reset);
      }
    }
    stdout.writeln();
  }

  stdout.writeln('\nGrayscale colors:');
  for (var i = 0; i < 24; i++) {
    final c = gray(i);
    final s = ' ${'$c'.padLeft(3, '0')} ';

    if (i % 8 == 0) {
      stdout.writeln();
      for (var g = 0; g < 8; g++) {
        final n = i + g;
        stdout.write('  ${n.toString().padRight(2)}      ');
      }
      stdout.writeln();
    }

    stdout
      ..write(fg256(i >= 16 ? GRAY0 : GRAY23))
      ..write(bg256(c))
      ..write(s)
      ..write(reset)
      ..write(fg256(c))
      ..write(s)
      ..write(reset);
  }
  stdout.writeln();
}
