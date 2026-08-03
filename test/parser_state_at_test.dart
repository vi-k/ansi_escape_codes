import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  // Four pieces of text under four different styles, so that every answer
  // says which piece the position fell in.
  const text = '${bold}one $fgRed' 'two $resetBoldAndDim' 'three $reset' 'four';

  /// The answer a parser that has been asked nothing else would give.
  Style fresh(int pos) => Parser(text).stateAt(pos);

  group('asking a parser where it left off:', () {
    test('a progression gives what a fresh parser would', () {
      final parser = Parser(text);

      for (var pos = 0; pos < parser.length; pos++) {
        expect(parser.stateAt(pos), fresh(pos), reason: 'at $pos');
      }
    });

    test('and so does going backwards afterwards', () {
      final parser = Parser(text);

      for (var pos = 0; pos < parser.length; pos++) {
        parser.stateAt(pos);
      }
      for (var pos = parser.length - 1; pos >= 0; pos--) {
        expect(parser.stateAt(pos), fresh(pos), reason: 'at $pos');
      }
    });

    test('and jumping about', () {
      final parser = Parser(text);

      for (final pos in [12, 3, 17, 0, 9, 17, 3]) {
        expect(parser.stateAt(pos), fresh(pos), reason: 'at $pos');
      }
    });

    test('the same position twice is the same answer', () {
      final parser = Parser(text);

      expect(parser.stateAt(6), parser.stateAt(6));
      expect(parser.stateAt(6), fresh(6));
    });

    test('the end of the text and past it', () {
      final parser = Parser(text);

      for (var pos = 0; pos < parser.length; pos++) {
        parser.stateAt(pos);
      }

      expect(
        parser.stateAt(parser.length),
        parser.finalState,
        reason: 'the position behind the text is the final state',
      );
      expect(() => parser.stateAt(parser.length + 1), throwsRangeError);
      expect(
        parser.stateAt(0),
        fresh(0),
        reason: 'and the walk still answers after the refusal',
      );
    });

    test('other questions in between leave the answers alone', () {
      final parser = Parser(text);

      expect(parser.stateAt(2), fresh(2));
      expect(parser.substring(4, maxLength: 3), isNotEmpty);
      expect(parser.stateAt(6), fresh(6));
      expect(parser.matches, isNotEmpty);
      expect(parser.stateAt(10), fresh(10));
      parser.prepare();
      expect(parser.stateAt(14), fresh(14));
      expect(parser.stateAt(1), fresh(1));
    });

    test('a stacked parser walks the same way', () {
      final parser = StackedParser(text);

      for (var pos = 0; pos < parser.length; pos++) {
        expect(
          parser.stateAt(pos),
          StackedParser(text).stateAt(pos),
          reason: 'at $pos',
        );
      }
    });

    test('an iterator kept while another reads on stays where it was', () {
      final parser = Parser(text);
      final held = parser.matches.iterator;

      // Through the first code and the text after it, which leaves the
      // iterator holding the code it found ahead of that text.
      expect(held.moveNext(), isTrue);
      expect(held.moveNext(), isTrue);
      expect(held.current.entity, isA<Text>());

      // Another reader goes further, and the matches it read are now in the
      // cache this one takes from.
      parser.substring(4, maxLength: 3);

      final rest = <String>[];
      while (held.moveNext()) {
        rest.add(held.current.entity.toString());
      }

      final whole =
          Parser(text).matches.map((m) => m.entity.toString()).toList();

      expect(
        rest,
        whole.sublist(2),
        reason: 'it carries on through the cache and out the other side, '
            'without handing out anything twice',
      );
    });

    test('reading only as far as it must is still true', () {
      final parser = Parser(text);

      expect(parser.stateAt(2).isBold, isTrue);
      expect(
        parser.isParsed,
        isFalse,
        reason: 'the walk stops at the answer, cursor or no cursor',
      );
    });
  });
}
