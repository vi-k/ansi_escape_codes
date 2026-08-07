import 'dart:io';

import 'package:ansi_escape_codes/ansi_escape_codes.dart';

/// Usage:
///
/// ```bash
/// dart run example/links.dart
/// ```
void main() {
  const url = 'https://pub.dev/packages/ansi_escape_codes';

  stdout
    ..writeln(url)
    ..writeln(link(url))
    ..writeln(link(url, text: 'Go to pub.dev'))
    ..writeln();

  // A link with line breaks inside it: the opening stands before the first
  // line and the close after the last, and nothing on the lines between says
  // that they are part of a link at all.
  const paragraph = '$linkOpen$url$linkTextOpen'
      'This paragraph is one hyperlink\n'
      'broken across three lines,\n'
      'and every one of them is clickable.$linkClose';

  // A printer takes it a line at a time: a line closes the link it leaves
  // open — what is printed after it must not stay clickable on this url —
  // and the line after opens it again, in the bytes it was opened with.
  SinkPrinter(stdout).writeln(paragraph);
  stdout.writeln();

  // The same lines with their codes named, to see where the closes and the
  // openings fell.
  final printed = StringBuffer();
  SinkPrinter(printed).writeln(paragraph);
  stdout
    ..writeln(Parser(printed.toString()).showControlFunctions())
    ..writeln();

  // A slice cut out of the middle of the link stands on its own the same
  // way: it opens the link in front of its own text and closes it at the
  // end, so the line is clickable wherever the cut fell.
  final parser = Parser(paragraph);
  final start = parser.indexOf('broken');
  final slice = parser.substring(start, maxLength: 'broken across'.length);
  stdout
    ..writeln(slice)
    ..writeln(Parser(slice).showControlFunctions());
}
