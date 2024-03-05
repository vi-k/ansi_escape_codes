import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;

void main() {
  for (var n = 1; n < 8; n++) {
    for (var i = 0; i < 16; i += 2) {
      stdout.writeln();
      for (var j = 0; j < 16; j += 2) {
        final c = i * 16 + j;
        final r = n & 1 == 0 ? 0 : c;
        final g = n & 2 == 0 ? 0 : c;
        final b = n & 4 == 0 ? 0 : c;
        final s = ' ${r.toRadixString(16).padLeft(2, '0')}'
            '${g.toRadixString(16).padLeft(2, '0')}'
            '${b.toRadixString(16).padLeft(2, '0')} ';

        stdout
          ..write(
            ansi.fg256(
              r >= 224 && g >= 224 && b >= 224 ? ansi.minGray : ansi.maxGray,
            ),
          )
          ..write(ansi.bgRgb(r, g, b))
          ..write(s)
          ..write(ansi.reset)
          ..write(ansi.fgRgb(r, g, b))
          ..write(s)
          ..write(ansi.reset);
      }
    }
    stdout.writeln();
  }
}
