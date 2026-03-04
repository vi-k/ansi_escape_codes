import 'dart:async';

import 'package:ansi_escape_codes/parsing.dart';

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
  String ansiShowControlFunctions({
    String open = '[',
    String close = ']',
  }) =>
      Parser(this).showControlFunctions(open: open, close: close);

  String ansiOptimizeControlFunctions({bool close = true}) =>
      Parser(this).optimize(close: close);
}
