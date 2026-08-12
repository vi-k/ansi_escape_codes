import 'package:ansi_escape_codes/ansi.dart';
import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  // These pass on the day they are written, and that is what they are for.
  // The package reads decoded Dart strings, not byte streams, and in one of
  // those a lone U+009B is far likelier to be a character than a CSI — so
  // not recognizing the eight-bit C1 as openers is a position, not an
  // oversight. Prose cannot hold it: the next reader meets "the package does
  // not recognize the eight-bit C1", takes it for a defect and fixes it.
  // These tests are what a fix would have to argue with.
  //
  // The class of openers is written down twice — the alternatives of
  // `escapeCodesRe` and the `indexOf(ESC)` scan in `ParserIterator` that
  // decides where the regex is even applied — so widening the pattern alone
  // moves nothing here.
  group('the eight-bit C1 open nothing:', () {
    test('an eight-bit CSI stays text, and the length counts it', () {
      final parser = Parser('aa\u{9B}31mbb');

      expect(parser.matches.map((m) => m.entity.runtimeType).toList(), [Text]);
      expect(parser.removeAll(), 'aa\u{9B}31mbb');
      expect(parser.length, 8);
    });

    test('the other eight-bit openers stay text too', () {
      for (final byte in [0x9D, 0x90, 0x98, 0x9E, 0x9F]) {
        final opener = String.fromCharCode(byte);
        final input = 'aa${opener}pay\u{9C}bb';
        final parser = Parser(input);

        expect(
          parser.matches.map((m) => m.entity.runtimeType).toList(),
          [Text],
          reason: 'byte 0x${byte.toRadixString(16)}',
        );
        expect(parser.removeAll(), input);
        expect(parser.length, 9, reason: 'byte 0x${byte.toRadixString(16)}');
      }
    });

    test(
      'a seven-bit opener is not closed by an eight-bit ST, as in a '
      'UTF-8 terminal',
      () {
        expect(Parser('aa\x1B]0;t\u{9C}bb').removeAll(), 'aa');

        // All five of the strings the parser knows, not the OSC alone: the
        // terminator is written once per family in `patterns.dart`, and
        // teaching any one of them the eight-bit ST would swallow `bb` in
        // that one only.
        for (final opener in [OSC, DCS, SOS, PM, APC]) {
          expect(
            Parser('aa${opener}pay\u{9C}bb').removeAll(),
            'aa',
            reason: 'opener ${opener.ansiShowEscapeSequences()}',
          );

          // The contrast that gives the line above its meaning: the
          // seven-bit ST does end them, so what the eight-bit one fails to
          // do is end a string, not merely be absent.
          expect(
            Parser('aa${opener}pay${ST}bb').removeAll(),
            'aabb',
            reason: 'opener ${opener.ansiShowEscapeSequences()}',
          );
        }
      },
    );

    test('the seven-bit forms are read as they always were', () {
      expect(Parser('aa\x1B[31mbb').removeAll(), 'aabb');
      expect(Parser('aa\x1B]0;t\x1B\\bb').removeAll(), 'aabb');
    });
  });

  // Opening no sequence is not the same as being a character. These bytes are
  // controls by Unicode's own category and print as rubbish, so what asks
  // after control codes and what strips them must know them — and that is
  // `controlCodesRe`, which the parser never reads.
  group('the eight-bit C1 are control codes all the same:', () {
    test('they are seen and taken out', () {
      expect('aa\u{9B}bb'.ansiHasControlCodes, isTrue);
      expect('aa\u{9B}31mbb'.ansiRemoveControlCodes(), 'aa31mbb');
    });

    test('the whole set is covered', () {
      for (var byte = 0x80; byte <= 0x9F; byte++) {
        final text = 'aa${String.fromCharCode(byte)}bb';

        expect(
          text.ansiHasControlCodes,
          isTrue,
          reason: 'byte 0x${byte.toRadixString(16)}',
        );
        expect(text.ansiRemoveControlCodes(), 'aabb');
      }
    });

    test('the range ends where the controls do', () {
      expect('aa\u{A0}bb'.ansiHasControlCodes, isFalse);
      expect('aa\u{A0}bb'.ansiRemoveControlCodes(), 'aa\u{A0}bb');
    });

    test('the C0 set and DEL are untouched by the widening', () {
      expect('a\nb\tc'.ansiRemoveControlCodes(), 'abc');
      expect('a\x00b\x1Fc\x7Fd'.ansiRemoveControlCodes(), 'abcd');
      expect('плайн текст'.ansiRemoveControlCodes(), 'плайн текст');
    });

    test('no exclusion reaches them, keeping every C0 included', () {
      // `exclude` takes `ControlFunctionsC0`, and the eight-bit C1 have no
      // enum here to be named by, so asking to keep all of them keeps every
      // C0 and takes the eight-bit C1 out regardless.
      expect(
        'a\nb\u{9B}c'.ansiRemoveControlCodes(
          exclude: ControlFunctionsC0.values.toSet(),
        ),
        'a\nbc',
      );
    });
  });
}
