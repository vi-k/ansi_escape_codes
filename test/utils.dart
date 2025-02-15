import 'dart:async';

List<String> interceptPrint(
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
