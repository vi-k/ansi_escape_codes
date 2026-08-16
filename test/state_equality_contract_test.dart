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

  group('a colour hashes as itself and not as its neighbour:', () {
    test('the sixteen and the 256 do not share a hash', () {
      // Both hold the same `Colors` value, so hashing the field alone put
      // every one of the 256 pairs in one bucket. Equality told them apart,
      // which is why nothing misbehaved and nothing noticed.
      //
      // Held as `Color` rather than as their own types: comparing the two
      // directly is what the analyser calls an unrelated type equality
      // check, and it is right — the point here is that two colours a
      // caller holds as colours are not each other.
      const Color sixteen = Color16.red;
      const Color extended = Color256.red;

      expect(sixteen == extended, isFalse);
      expect(sixteen.hashCode, isNot(extended.hashCode));
    });

    test('and the same holds through a style', () {
      const sixteen = Style(foreground: Color16.red);
      const extended = Style(foreground: Color256.red);

      expect(sixteen == extended, isFalse);
      expect(sixteen.hashCode, isNot(extended.hashCode));
    });

    test('equal colours still hash alike', () {
      // The half that must not break: hashCode is only allowed to tell
      // apart what == tells apart.
      expect(Color16.red, Color16.red);
      expect(Color16.red.hashCode, Color16.red.hashCode);
      expect(Color256.red.hashCode, Color256.red.hashCode);
      expect(ColorRgb(1, 2, 3).hashCode, ColorRgb(1, 2, 3).hashCode);
    });
  });
}
