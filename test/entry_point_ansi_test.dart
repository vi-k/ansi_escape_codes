import 'package:ansi_escape_codes/ansi.dart';
import 'package:test/test.dart';

void main() {
  test('the ansi entry point names its constants', () {
    expect(CSI, '\x1B[');
    expect(FG_RED, 31);
    expect(SGR, 'm');
  });
}
