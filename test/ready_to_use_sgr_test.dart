// The point of these tests is to pin the deprecated names themselves.
// ignore_for_file: deprecated_member_use_from_same_package

import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  test('every deprecated alias carries the code its name stands for', () {
    const aliases = {
      'faint': (faint, DIM),
      'resetBoldAndFaint': (resetBoldAndFaint, NOT_BOLD_NOT_DIM),
      'italicized': (italicized, ITALIC),
      'resetItalicized': (resetItalicized, NOT_ITALIC),
      'singlyUnderlined': (singlyUnderlined, UNDERLINE),
      'doublyUnderlined': (doublyUnderlined, DOUBLY_UNDERLINE),
      'resetUnderlined': (resetUnderlined, NOT_UNDERLINE),
      'slowlyBlinking': (slowlyBlinking, BLINK),
      'rapidlyBlinking': (rapidlyBlinking, BLINK_RAPID),
      'resetBlinking': (resetBlinking, NOT_BLINK),
      'negative': (negative, INVERSE),
      'resetNegative': (resetNegative, NOT_INVERSE),
      'concealed': (concealed, INVISIBLE),
      'resetConcealed': (resetConcealed, NOT_INVISIBLE),
      'crossedOut': (crossedOut, STRIKETHROUGH),
      'resetCrossedOut': (resetCrossedOut, NOT_STRIKETHROUGH),
      'framed': (framed, FRAME),
      'encircled': (encircled, ENCIRCLE),
      'resetFramedAndEncircled': (
        resetFramedAndEncircled,
        NOT_FRAME_NOT_ENCIRCLE,
      ),
      'overlined': (overlined, OVERLINE),
      'resetOverlined': (resetOverlined, NOT_OVERLINE),
      'superscripted': (superscripted, SUPERSCRIPT),
      'subscripted': (subscripted, SUBSCRIPT),
      'resetSuperAndSubscripted': (
        resetSuperAndSubscripted,
        NOT_SUPER_NOT_SUBSCRIPT,
      ),
    };

    for (final MapEntry(key: name, value: (actual, code)) in aliases.entries) {
      expect(actual, '$CSI$code$SGR', reason: name);
    }
  });
}
