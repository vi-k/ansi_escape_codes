import 'package:ansi_escape_codes/ansi_escape_codes.dart';

String show(String s) => s
    .replaceAll('\x1b', '<ESC>')
    .replaceAll('\x07', '<BEL>')
    .replaceAll('\x9c', '<ST8>');

void main() {
  const cases = {
    'non-link OSC, unterminated': '\x1b]0;titleword',
    'non-link OSC, ST-terminated': '\x1b]0;title\x1b\\word',
    'non-link OSC, BEL-terminated': '\x1b]0;title\x07word',
    'link, unterminated (fixed by N5)': '\x1b]8;;https://a.testword',
    'non-link OSC + style': '\x1b]0;title${fgRed}word',
    'non-link OSC alone': '\x1b]0;title',
  };

  for (final e in cases.entries) {
    final input = e.value;
    print('--- ${e.key}');
    print('  input      ${show(input)}');
    print('  substring0 ${show(Parser(input).substring(0))}');
    print('  substring1 ${show(Parser(input).substring(1))}');
    print('  optimize   ${show(Parser(input).optimize())}');
    final lines = <String>[];
    Printer(output: lines.add).prepare(input);
    print('  printer    ${lines.map(show).toList()}');
    print('  removeAll  ${show(Parser(input).removeAll())}');
    print('  plain len  ${Parser(input).length}');
  }
}
