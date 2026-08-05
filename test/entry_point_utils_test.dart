import 'package:ansi_escape_codes/utils.dart';
import 'package:test/test.dart';

void main() {
  test('the utils entry point names its functions', () {
    expect(currentCursorPos, isNotNull);
    expect(tabs, isNotNull);
  });
}
