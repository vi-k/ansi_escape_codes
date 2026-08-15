import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Returns the FNV-1a-32 digest of [strings], mixing `0xff` after each one
/// so that where one result ends and the next begins is part of the digest.
///
/// It mixes UTF-16 code units, not bytes, so the separator is only as
/// unambiguous as the corpus: a string holding U+00FF could imitate it.
/// Every corpus here is ASCII with `ESC`, which cannot.
String _fnv1a32(Iterable<String> strings) {
  var hash = 0x811c9dc5;

  void mix(int byte) {
    hash ^= byte;
    hash = (hash * 0x01000193) & 0xffffffff;
  }

  for (final string in strings) {
    string.codeUnits.forEach(mix);
    mix(0xff);
  }

  return hash.toRadixString(16).padLeft(8, '0');
}

void main() {
  group('complexity anchors', () {
    test('parsing walks and removes ANSI sentinels from every line', () {
      const plainLine = 'an ordinary line of an ordinary log, no codes';
      const lines = 2000;
      final plainPage = List.filled(lines, plainLine).join('\n');
      final ansiPage = List.filled(
        lines,
        '\x1B[31m$plainLine\x1B[0m',
      ).join('\n');

      final cleaned = Parser(ansiPage).removeAll();

      expect(cleaned, plainPage);
      expect(cleaned.length, 91999);
      expect(_fnv1a32([cleaned]), 'a20a9a76');
    });

    test('slicing walks every styled line and closes each result', () {
      // Every line carries its own number, so the digest is positional: a
      // walk that answers each of the 400 questions from the wrong offset
      // changes it. A corpus of identical lines could not tell the
      // difference, and a substring pinned to offset 0 passed under one.
      String line(int i) => '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
          'a sentence of ordinary words to slice, no. '
          '${i.toString().padLeft(3, '0')}';
      const first = '\x1B[31;1mtag\x1B[0m '
          'a sentence of ordinary words to slice, no. 000';
      const last = '\x1B[31;1mtag\x1B[0m '
          'a sentence of ordinary words to slice, no. 399';
      const lines = 400;
      final page = [for (var i = 0; i < lines; i++) line(i)].join('\n');
      final parser = Parser(page)..prepare();
      final width = Parser(line(0)).length;
      final slices = [
        for (var i = 0; i < lines; i++)
          parser.substring(i * (width + 1), maxLength: width),
      ];

      expect(width, 50);
      expect(slices, hasLength(400));
      expect(
        slices.toSet(),
        hasLength(400),
        reason: 'each slice must be able to disagree with every other',
      );
      expect(slices.first, first);
      expect(slices.last, last);
      expect(slices.first.length, 61);
      expect(slices.last.length, 61);
      expect(_fnv1a32(slices), 'b8dc6f45');
    });

    test('a stack retains every foreground frame to pop', () {
      String page(int runs) => '\x1B[31mfoo\x1B[32mbar' * runs;
      const runs = 4000;
      final parsed = StackedParser(page(runs));

      expect(parsed.length, 24000, reason: 'foo and bar, once a run');
      var state = parsed.finalState;
      expect(state.foregroundColor, Color16.green);
      for (var i = 0; i < 6; i++) {
        state = state.resetForeground;
        expect(
          state.foregroundColor,
          i.isEven ? Color16.red : Color16.green,
          reason: 'the colours were pushed and are still there to pop, '
              'rather than the last of them standing alone',
        );
      }
    });

    test('shared and fresh insertion routes answer every request', () {
      const line = '\x1B[1m\x1B[31mtag\x1B[22m\x1B[39m '
          'a sentence of ordinary words to insert into';
      const lines = 400;
      final page = List.filled(lines, line).join('\n');
      final plainPage = Parser(page).removeAll();
      final width = Parser(line).length;
      final sharedParser = Parser(page);
      final shared = [
        for (var i = 0; i < lines; i++)
          sharedParser.insertAfter(i * (width + 1), '@'),
      ];
      final fresh = [
        for (var i = 0; i < lines; i++)
          Parser(page).insertAfter(i * (width + 1), '@'),
      ];

      expect(shared, hasLength(400));
      expect(fresh, hasLength(400));
      expect(shared, fresh);
      expect(_fnv1a32(shared), '7879f6e5');
      expect(_fnv1a32(fresh), '7879f6e5');
      expect(Parser(shared.first).removeAll(), '@$plainPage');
      expect(
        Parser(shared.last).removeAll(),
        '${plainPage.substring(0, (lines - 1) * (width + 1))}'
        '@${plainPage.substring((lines - 1) * (width + 1))}',
      );
    });
  });

  group('memory pins', () {
    test('a Text piece materializes its string once', () {
      final parser = Parser('\x1B[31mred\x1B[0m and plain');
      final texts = [
        for (final m in parser.pieces)
          if (m.entity case final Text text) text,
      ];

      expect(texts, isNotEmpty);
      for (final text in texts) {
        expect(
          identical(text.string, text.string),
          isTrue,
          reason: 'string must be built once and kept, not rebuilt per read',
        );
      }
    });
  });
}
