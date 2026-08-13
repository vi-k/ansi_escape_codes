import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  test('the main entry point names the types its own API returns', () {
    final sgr = Parser(bold).pieces.first.entity as Sgr;
    expect(sgr.contains(ControlFunctionsSGR.bold), isTrue);

    final csi = Parser(cursorUp).pieces.first.entity as CsiCommon;
    expect(csi.controlSequence, ControlSequencesFunctions.CUU);
  });
}
