import 'package:ansi_escape_codes/style.dart';

/// Usage:
///
/// ```bash
/// dart run example/styles.dart
/// ```
void main() {
  final text1 = 'Hello, ${red.bold('World')}!!';
  final text2 = 'Hello, ${bold.underline.green('World')}!!';
  final text3 =
      'Hello, ${strikethrough.bold.blue.background(Color16.yellow)('World')}!!';

  print('The default colors are set by the terminal:');
  print(text1);
  print(text2);
  print(text3);

  final defaultStyle = rgb442.background(Color256.rgb110);

  print('');
  print('The custom default colors:');
  print(defaultStyle(text1));
  print(defaultStyle(text2));
  print(defaultStyle(text3));

  print('');
  print('The default colors are overrided:');
  runZonedPrinter(
    defaultStyle: defaultStyle,
    () {
      print(text1);
      print(text2);
      print(text3);
    },
  );
}
