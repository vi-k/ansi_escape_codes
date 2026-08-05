import 'package:ansi_escape_codes/parsing.dart';
import 'package:test/test.dart';

void main() {
  test('the parsing entry point names the types its own API returns', () {
    final sgr = Parser('\x1B[1m').matches.first.entity as Sgr;
    expect(sgr.contains(ControlFunctionsSGR.bold), isTrue);

    final csi = Parser('\x1B[A').matches.first.entity as CsiCommon;
    expect(csi.controlSequence, ControlSequencesFunctions.CUU);

    final esc = Parser('\x1Bc').matches.first.entity as EscCommon;
    expect(esc.function, ControlFunctionsEscFs.RIS);

    expect(ControlFunctionsC0.ESC, isNotNull);
    expect(ControlFunctionsC1.CSI, isNotNull);
  });
}
