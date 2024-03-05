import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart' as ansi;

void main() {
  const url = 'https://pub.dev/packages/ansi_escape_codes';

  stdout
    ..writeln(url)
    ..writeln(ansi.link(url))
    ..writeln(ansi.link(url, 'Go to pub.dev'));
}
