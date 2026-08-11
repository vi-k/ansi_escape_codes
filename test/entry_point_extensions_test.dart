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

  test('the extensions entry point names the exception its insertions throw',
      () {
    expect(
      const UnfinishedSequenceException(pos: 2, offset: 2),
      isA<Exception>(),
      reason: 'the two insertions throw it, and it has to be nameable here',
    );
  });
}
