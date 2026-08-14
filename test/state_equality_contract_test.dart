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

    test('equal surfaces collapse as keys, history and all', () {
      final grown = Stack.terminalColors.underline.doublyUnderline;
      final direct = Stack.terminalColors.doublyUnderline;

      expect(
        {grown, direct},
        hasLength(1),
        reason: 'a Set keeps the surface, not the way it was reached',
      );
      expect(
        ({grown: 'a'}..[direct] = 'b').length,
        1,
        reason: 'and a Map overwrites rather than adds',
      );
    });

    test('a Stack equals a plain Style with the same surface', () {
      const Object stack = Stack.terminalColors;
      const Object style = Style.terminalColors;

      expect(stack == style, isTrue);
      expect(stack.hashCode, style.hashCode);
    });

    test('new rendition families compare across State implementations', () {
      final stack = Stack.terminalColors.alternativeFont3.fraktur
          .dottedUnderline.proportionalSpacing.ideogramDoublyOverline;
      const style = Style(
        fontSelection: FontSelection.alternative3,
        fraktur: true,
        dottedUnderline: true,
        proportionalSpacing: true,
        ideogramStyle: IdeogramStyle.doublyOverline,
      );

      expect(stack.toStyle(), style);
      expect(stack.hashCode, style.hashCode);
    });
  });
}
