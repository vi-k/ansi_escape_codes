import 'dart:async';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

List<String> interceptZonedPrint(
  void Function() body, {
  bool debugPrint = false,
}) {
  final output = <String>[];

  runZoned(
    body,
    zoneSpecification: ZoneSpecification(
      print: (_, parent, zone, line) {
        output.add(line);
        if (debugPrint) {
          parent.print(zone, line);
        }
      },
    ),
  );

  return output;
}

extension StringTextExtension on String {
  String showAnsiControlFunctions() => AnsiParser(this).showControlFunctions();

  String optimizeAnsiControlFunctions({bool close = true}) =>
      AnsiParser(this).optimize(close: close);
}
