import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// The renditions 4.0.0 added and nothing walked.
///
/// The alternative fonts past the second, the five ideogram renditions and
/// the dotted and dashed underlines are public API, and the branches of
/// `transitTo` that write them were never executed — every mutation to those
/// lines would have lived. Reading a code back was covered; writing one, and
/// writing the code that takes it off again, is what is here.
///
/// Each entry is one rendition and nothing else, so a code written for it can
/// only have come from it.
final _singles = <String, (Style, Stack)>{
  'alternativeFont1': (
    Styles.alternativeFont1,
    Stack.terminalColors.alternativeFont1
  ),
  'alternativeFont2': (
    Styles.alternativeFont2,
    Stack.terminalColors.alternativeFont2
  ),
  'alternativeFont3': (
    Styles.alternativeFont3,
    Stack.terminalColors.alternativeFont3
  ),
  'alternativeFont4': (
    Styles.alternativeFont4,
    Stack.terminalColors.alternativeFont4
  ),
  'alternativeFont5': (
    Styles.alternativeFont5,
    Stack.terminalColors.alternativeFont5
  ),
  'alternativeFont6': (
    Styles.alternativeFont6,
    Stack.terminalColors.alternativeFont6
  ),
  'alternativeFont7': (
    Styles.alternativeFont7,
    Stack.terminalColors.alternativeFont7
  ),
  'alternativeFont8': (
    Styles.alternativeFont8,
    Stack.terminalColors.alternativeFont8
  ),
  'alternativeFont9': (
    Styles.alternativeFont9,
    Stack.terminalColors.alternativeFont9
  ),
  'fraktur': (Styles.fraktur, Stack.terminalColors.fraktur),
  'curlyUnderline': (
    Styles.curlyUnderline,
    Stack.terminalColors.curlyUnderline
  ),
  'dottedUnderline': (
    Styles.dottedUnderline,
    Stack.terminalColors.dottedUnderline
  ),
  'dashedUnderline': (
    Styles.dashedUnderline,
    Stack.terminalColors.dashedUnderline
  ),
  'ideogramUnderline': (
    Styles.ideogramUnderline,
    Stack.terminalColors.ideogramUnderline
  ),
  'ideogramDoublyUnderline': (
    Styles.ideogramDoublyUnderline,
    Stack.terminalColors.ideogramDoublyUnderline
  ),
  'ideogramOverline': (
    Styles.ideogramOverline,
    Stack.terminalColors.ideogramOverline
  ),
  'ideogramDoublyOverline': (
    Styles.ideogramDoublyOverline,
    Stack.terminalColors.ideogramDoublyOverline
  ),
  'ideogramStress': (
    Styles.ideogramStress,
    Stack.terminalColors.ideogramStress
  ),
  'proportionalSpacing': (
    Styles.proportionalSpacing,
    Stack.terminalColors.proportionalSpacing
  ),
};

void main() {
  group('a rendition written and read back:', () {
    for (final MapEntry(key: name, value: (style, stack)) in _singles.entries) {
      test('$name comes back as itself', () {
        final codes = Style.terminalColors.transitTo(style);

        expect(
          codes,
          isNotEmpty,
          reason: '$name: a style carrying something must write something',
        );
        expect(
          Parser(codes).finalState,
          style,
          reason: '$name: read back off the codes that put it on',
        );
      });

      test('and $name is taken off again', () {
        final on = Style.terminalColors.transitTo(style);
        final off = style.transitTo(Style.terminalColors);

        expect(
          Parser('$on$off').finalState,
          Style.terminalColors,
          reason: '$name: what puts it on and what takes it off leave the '
              'terminal where they found it',
        );
      });

      test('and a stack says the same of $name', () {
        final codes = Stack.terminalColors.transitTo(stack);

        expect(
          StackedParser(codes).finalState.toStyle(),
          style,
          reason: '$name: the stacked reading of the same rendition',
        );
        expect(
          StackedParser('$codes${stack.transitTo(Stack.terminalColors)}')
              .finalState
              .toStyle(),
          Style.terminalColors,
          reason: '$name: and off again',
        );
      });
    }
  });

  test('every value of each enum stands behind one of the entries', () {
    expect(FontSelection.values, hasLength(10));
    expect(UnderlineStyle.values, hasLength(5));
    expect(IdeogramStyle.values, hasLength(5));
    expect(
      _singles,
      hasLength(19),
      reason: 'nine alternative fonts, fraktur, three underlines beyond the '
          'two held elsewhere, five ideogram renditions, and proportional '
          'spacing',
    );
  });
}
