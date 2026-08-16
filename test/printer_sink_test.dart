import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

/// Holds [got] to be the same output as [want] to read.
///
/// Not the same bytes: a write begins with a reset of its own, so a line
/// handed over in pieces carries more of them than the same line handed over
/// whole. What has to match is what the output says — the text it shows, and
/// the style and the link every character of it stands in.
void expectSameReading(String got, String want, {required String reason}) {
  final read = Parser(got);
  final wanted = Parser(want);

  expect(read.removeAll(), wanted.removeAll(), reason: reason);
  expect(read.length, wanted.length, reason: reason);

  for (var i = 0; i < wanted.length; i++) {
    expect(read.stateAt(i), wanted.stateAt(i), reason: '$reason, at $i');
    expect(read.linkAt(i), wanted.linkAt(i), reason: '$reason, at $i');
  }
}

void main() {
  group('a write cut inside a sequence:', () {
    for (final (what, line) in <(String, String)>[
      ('an SGR', '${fgRed}red$reset'),
      ('a truecolour SGR', '${fgRgb(1, 2, 3)}shade$reset'),
      ('a hyperlink', '${link('https://example.com', text: 'click')} tail'),
      ('a hyperlink closed by BEL', '${linkBel('https://e.dev', text: 'x')}!'),
      ('a code that moves the cursor', '${cursorRightN(4)}over'),
    ]) {
      test('$what arrives whole however the writes fall', () {
        final whole = StringBuffer();
        SinkPrinter(whole)
          ..write(line)
          ..writeln();

        for (var cut = 1; cut < line.length; cut++) {
          final split = StringBuffer();
          SinkPrinter(split)
            ..write(line.substring(0, cut))
            ..write(line.substring(cut))
            ..writeln();

          expectSameReading(
            split.toString(),
            whole.toString(),
            reason: '$what cut at $cut',
          );
        }
      });
    }

    test('a surrogate pair cut between two writes stays one character', () {
      const line = 'a\u{1F600}b';

      final split = StringBuffer();
      SinkPrinter(split)
        ..write(line.substring(0, 2))
        ..write(line.substring(2))
        ..writeln();

      expect(
        split.toString().ansiRemoveEscapeCodes(),
        '$line\n',
        reason: 'a reset written between the halves makes two broken '
            'characters of one whole one, and nothing puts it back',
      );
      expect(
        split.toString().runes.contains(0x1F600),
        isTrue,
        reason: 'the emoji is still an emoji',
      );
    });

    test('a line written one code unit at a time reads the same', () {
      const line = '${fgRed}red$reset and ${bold}bold$reset';

      final whole = StringBuffer();
      SinkPrinter(whole)
        ..write(line)
        ..writeln();

      final byUnit = StringBuffer();
      final printer = SinkPrinter(byUnit);
      line.codeUnits.forEach(printer.writeCharCode);
      printer.writeln();

      expectSameReading(
        byUnit.toString(),
        whole.toString(),
        reason: 'writeCharCode is a write like any other',
      );
    });
  });

  group('a printer as a StringSink:', () {
    test('the one that prints holds the line until it is ended', () {
      final lines = <String>[];

      Printer(output: lines.add, defaultStyle: Styles.red)
        ..write('a')
        ..writeAll(['b', 'c'], '-')
        ..writeCharCode(0x64)
        ..writeln('e');

      expect(
        lines,
        hasLength(1),
        reason: 'writeln ends the line, nothing else',
      );
      expect(
        Parser(lines.single).showControlFunctions(),
        '[reset][fg256Red]ab-cde[reset]',
        reason: 'and the whole line is opened and closed once',
      );
    });

    test('the one that writes to a sink lets each piece through', () {
      final buf = StringBuffer();

      SinkPrinter(buf, defaultStyle: Styles.red)
        ..write('a')
        ..writeAll(['b', 'c'], '-')
        ..writeCharCode(0x64)
        ..writeln('e');

      expect(
        Parser(buf.toString()).showControlFunctions(),
        '[reset][fg256Red]a[reset]'
        '[reset][fg256Red]b-c[reset]'
        '[reset][fg256Red]d[reset]'
        '[reset][fg256Red]e[reset]\n',
        reason: 'each write is dressed on its own, and the style carries over',
      );
      expect(buf.toString().ansiRemoveEscapeCodes(), 'ab-cde\n');
    });

    test('and neither writes a code with the codes switched off', () {
      final buf = StringBuffer();

      SinkPrinter(buf, ansiCodesEnabled: false)
        ..write('${fgRed}a')
        ..writeAll(['b', '${bold}c'], '-')
        ..writeCharCode(0x64)
        ..writeln('e$reset');

      expect(
        buf.toString(),
        'ab-cde\n',
        reason: 'the codes the text carried are taken out as well',
      );
    });
  });

  group('flush:', () {
    test('lets go of a line no writeln ever ended', () {
      final lines = <String>[];
      final printer = Printer(output: lines.add)..write('half a line');

      expect(lines, isEmpty, reason: 'nothing has ended the line yet');

      printer.flush();

      expect(lines, hasLength(1));
      expect(Parser(lines.single).removeAll(), 'half a line');
    });

    test('lets go of the sequence a sink was waiting on', () {
      const title = '\x1B]0;title';
      final buf = StringBuffer();
      final printer = SinkPrinter(buf)..write('a$title');

      expect(buf.toString(), '${reset}a', reason: 'the title is still waiting');

      printer.flush();

      expect(
        buf.toString(),
        contains(title),
        reason: 'and the caller can make it let go without ending the line',
      );
      expect(
        Parser(buf.toString()).removeAll(),
        'a',
        reason: 'terminated, so what is printed next is not more of the title',
      );
    });

    test('writes nothing where nothing is held', () {
      final lines = <String>[];
      Printer(output: lines.add).flush();

      final buf = StringBuffer();
      SinkPrinter(buf)
        ..write('plain')
        ..flush();

      expect(lines, isEmpty, reason: 'an empty buffer is not an empty line');
      expect(buf.toString(), '${reset}plain', reason: 'nothing was held back');
    });

    test('a second flush adds nothing to the first', () {
      final lines = <String>[];
      final printer = Printer(output: lines.add)
        ..write('once')
        ..flush()
        ..flush();

      expect(lines, ['${reset}once']);
      expect(printer.lastState, isNotNull);
    });
  });

  group('a piece prepared and not written:', () {
    test('leaves the style where it was', () {
      final buf = StringBuffer();
      final printer = SinkPrinter(buf);

      expect(
        Parser(printer.prepare('${bold}asked about')).showControlFunctions(),
        '[reset][bold]asked about[reset]',
        reason: 'the answer is dressed as the piece asks',
      );
      expect(
        printer.lastState,
        isNull,
        reason: 'but nothing reached the sink, so nothing is carried',
      );

      printer
        ..write('one ')
        ..write('two');

      expect(
        Parser(buf.toString()).showControlFunctions(),
        '[reset]one [reset]two',
        reason: 'and the writes after it go out as if it had not been asked',
      );
    });

    test('leaves opaque rendition where it was', () {
      const unknown = '\x1B[99m';
      final buf = StringBuffer();
      final printer = SinkPrinter(buf);

      expect(
        printer.prepare('${unknown}asked about'),
        '$reset${unknown}asked about$reset',
      );

      printer.write('written');

      expect(
        buf.toString(),
        '${reset}written',
        reason: 'the unseen piece must not seed the next real write',
      );
    });

    test('while a line prepared by a printer is carried, as it always was', () {
      final printer = Printer();

      expect(
        Parser(printer.prepare('${bold}one')).showControlFunctions(),
        '[reset][bold]one[reset]',
      );
      expect(
        Parser(printer.prepare('two')).showControlFunctions(),
        '[reset][bold]two[reset]',
        reason: 'a printer reads each line from where the line before ended',
      );
    });
  });
}
