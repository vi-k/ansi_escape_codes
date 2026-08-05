import 'package:ansi_escape_codes/extensions.dart';
import 'package:test/test.dart';

void main() {
  test('the extensions entry point works on its own', () {
    expect('a\x1B[31mb'.ansiRemoveEscapeCodes(), 'ab');
    expect('a\x1B[31mb'.ansiHasSgr, isTrue);
    expect(
      'a\nb'.ansiRemoveControlCodes(exclude: {ControlFunctionsC0.LF}),
      'a\nb',
    );
  });
}
