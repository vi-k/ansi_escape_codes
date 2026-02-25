import 'dart:io';
import 'dart:math' as math;

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

String _c(String value, int width) {
  final diff = width - value.length;
  if (diff <= 0) return value;
  return '${' ' * (diff ~/ 2)}$value${' ' * (diff - diff ~/ 2)}';
}

/// Usage:
///
/// ```bash
/// dart run example/colors256.dart
/// ```
void main() {
  stdout
    ..writeln()
    ..writeln('256-color table');

  {
    stdout
      ..writeln()
      ..writeln('Standard colors:')
      ..writeln();

    final values = List<(Color256, Color256)>.generate(16, (i) {
      final color = Color256(Colors.values[i]);
      return (color.withPrefix('fg'), color.withPrefix('bg'));
    });

    int combine(int max, (Color256, Color256) value) =>
        math.max(math.max(max, value.$1.id.length), value.$2.id.length);

    final colWidths = [
      values.take(8).fold(0, combine) + 2,
      values.skip(8).fold(0, combine) + 2,
    ];

    for (var i = 0; i < 8; i++) {
      for (var j = 0; j < 2; j++) {
        final index = i + j * 8;
        final (fg, bg) = values[index];
        if (j != 0) stdout.write('  ');
        stdout
          ..write(index.toString().padRight(2))
          ..write(fg256(fg.index))
          ..write(_c(fg.id, colWidths[j]))
          ..write(reset)
          ..write(bg256(bg.index))
          ..write(_c(bg.id, colWidths[j]))
          ..write(reset);
      }
      stdout.writeln();
    }
  }

  {
    stdout
      ..writeln()
      ..writeln('RGB colors:')
      ..writeln();

    const columns = 3;
    const fieldWidth = 13;

    for (var i = 0; i < 216 ~/ columns; i++) {
      for (var j = 0; j < columns; j++) {
        final index = 16 + i + j * 216 ~/ columns;
        final color = Color256(Colors.values[index]);
        if (j != 0) stdout.write('  ');
        stdout
          ..write(index.toString().padRight(3))
          ..write(fg256(index))
          ..write(_c(color.withPrefix('fg').id, fieldWidth))
          ..write(reset)
          ..write(bg256(index))
          ..write(_c(color.withPrefix('bg').id, fieldWidth))
          ..write(reset);
      }
      stdout.writeln();
    }
  }

  {
    stdout
      ..writeln()
      ..writeln('Grayscale colors:')
      ..writeln();

    const columns = 3;
    const fieldWidth = 13;

    for (var i = 0; i < 24 ~/ columns; i++) {
      for (var j = 0; j < columns; j++) {
        final index = 232 + i + j * 24 ~/ columns;
        final color = Color256(Colors.values[index]);
        if (j != 0) stdout.write('  ');
        stdout
          ..write(index.toString().padRight(3))
          ..write(fg256(index))
          ..write(_c(color.withPrefix('fg').id, fieldWidth))
          ..write(reset)
          ..write(bg256(index))
          ..write(_c(color.withPrefix('bg').id, fieldWidth))
          ..write(reset);
      }
      stdout.writeln();
    }
  }
}
