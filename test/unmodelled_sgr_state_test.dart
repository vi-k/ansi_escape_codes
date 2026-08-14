import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  test('Style exposes every newly modelled property', () {
    const style = Style(
      fontSelection: FontSelection.alternative3,
      fraktur: true,
      dottedUnderline: true,
      proportionalSpacing: true,
      ideogramStyle: IdeogramStyle.doublyOverline,
    );

    expect(style.fontSelection, FontSelection.alternative3);
    expect(style.fontShape, FontShape.fraktur);
    expect(style.isItalic, isFalse);
    expect(style.isFraktur, isTrue);
    expect(style.underlineStyle, UnderlineStyle.dotted);
    expect(style.isUnderline, isTrue);
    expect(style.isDottedUnderline, isTrue);
    expect(style.isProportionalSpacing, isTrue);
    expect(style.ideogramStyle, IdeogramStyle.doublyOverline);
  });

  test('fluent setters replace members of the same family', () {
    final style = Style.terminalColors.alternativeFont2.fraktur.curlyUnderline
        .proportionalSpacing.ideogramStress;

    expect(style.italic.fontShape, FontShape.italic);
    expect(style.dashedUnderline.underlineStyle, UnderlineStyle.dashed);
    expect(style.resetFont.fontSelection, FontSelection.primary);
    expect(style.resetFontShape.fontShape, isNull);
    expect(style.resetProportionalSpacing.isProportionalSpacing, isFalse);
    expect(style.resetIdeogram.ideogramStyle, isNull);
    expect(style.resetItalic, style.resetFontShape);
  });

  test('transitTo writes selective standard functions', () {
    expect(
      Styles.alternativeFont1.transitTo(Styles.bold),
      '\x1B[10;1m',
    );
    expect(Styles.italic.transitTo(Styles.fraktur), fraktur);
    expect(Styles.fraktur.transitTo(Styles.bold), '\x1B[23;1m');
    expect(Styles.underline.transitTo(Styles.curlyUnderline), curlyUnderline);
    expect(
      Styles.proportionalSpacing.transitTo(Styles.bold),
      '\x1B[50;1m',
    );
    expect(
      Styles.ideogramStress.transitTo(Styles.bold),
      '\x1B[65;1m',
    );
  });

  test('changeDefaultsTo fills only terminal defaults', () {
    final defaults = Styles.alternativeFont4.fraktur.dashedUnderline
        .proportionalSpacing.ideogramOverline;

    expect(Style.terminalColors.changeDefaultsTo(defaults), defaults);
    expect(
      Styles.alternativeFont2.italic.curlyUnderline.ideogramStress
          .changeDefaultsTo(defaults),
      Styles.alternativeFont2.italic.curlyUnderline.proportionalSpacing
          .ideogramStress,
    );
  });

  test('equality distinguishes every enum value', () {
    expect(Styles.curlyUnderline, isNot(Styles.dottedUnderline));
    expect(Styles.alternativeFont1, isNot(Styles.alternativeFont2));
    expect(Styles.ideogramUnderline, isNot(Styles.ideogramOverline));
    expect(
      {Styles.curlyUnderline, Styles.dottedUnderline},
      hasLength(2),
    );
  });

  test('Stack keeps one persistent history per reset family', () {
    final stack = Stack
        .terminalColors
        .alternativeFont1
        .alternativeFont2
        .italic
        .fraktur
        .curlyUnderline
        .dottedUnderline
        .proportionalSpacing
        .proportionalSpacing
        .ideogramUnderline
        .ideogramStress;

    expect(stack.resetFont.fontSelection, FontSelection.alternative1);
    expect(stack.resetFontShape.fontShape, FontShape.italic);
    expect(stack.resetUnderline.underlineStyle, UnderlineStyle.curly);
    expect(stack.resetProportionalSpacing.isProportionalSpacing, isTrue);
    expect(stack.resetIdeogram.ideogramStyle, IdeogramStyle.underline);
  });
}
