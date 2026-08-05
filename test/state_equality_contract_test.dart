import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('equality is the visible surface:', () {
    test('histories differ, surfaces equal', () {
      final grown = Stack.terminalColors.underline.doublyUnderline;
      final direct = Stack.terminalColors.doublyUnderline;

      expect(grown, direct);
      expect(grown.hashCode, direct.hashCode);
    });

    test('and equal stacks may part after one and the same reset', () {
      final grown = Stack.terminalColors.underline.doublyUnderline;
      final direct = Stack.terminalColors.doublyUnderline;

      expect(grown.resetUnderline, isNot(direct.resetUnderline));
      expect(
        grown.resetUnderline.isUnderline,
        isTrue,
        reason: 'the remembered underline comes back',
      );
      expect(
        direct.resetUnderline.isUnderline,
        isFalse,
        reason: 'there was nothing underneath to come back to',
      );
    });
  });
}
