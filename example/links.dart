import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void main() {
  const url = 'https://pub.dev/packages/ansi_escape_codes';

  stdout
    ..writeln(url)
    ..writeln(link(url))
    ..writeln(link(url, text: 'Go to pub.dev'));
}
