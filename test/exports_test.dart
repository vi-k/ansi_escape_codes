/// The main entry point, holding what it brings.
///
/// `entry_point_style_test.dart` holds the same four things through
/// `style.dart`, and the two files are alike on purpose: each entry point has
/// to stand on its own, and a test that reached for whichever import happened
/// to be open would not say that. Edit one and look at the other.
library;

import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  test('the main entry point names the types its own API returns', () {
    final sgr = Parser(bold).pieces.first.entity as Sgr;
    expect(sgr.contains(ControlFunctionsSGR.bold), isTrue);

    final csi = Parser(cursorUp).pieces.first.entity as CsiCommon;
    expect(csi.controlSequence, ControlSequencesFunctions.CUU);

    const style = Style(
      fontSelection: FontSelection.alternative1,
      fraktur: true,
      curlyUnderline: true,
      proportionalSpacing: true,
      ideogramStyle: IdeogramStyle.stress,
    );

    expect(style.fontShape, FontShape.fraktur);
    expect(Styles.dashedUnderline.underlineStyle, UnderlineStyle.dashed);
  });
}
