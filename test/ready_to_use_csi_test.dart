import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('ready-to-use CSI:', () {
    test('every Close constant is the final byte of its control function', () {
      const closes = {
        'cursorUpClose': (cursorUpClose, 'A'),
        'cursorDownClose': (cursorDownClose, 'B'),
        'cursorRightClose': (cursorRightClose, 'C'),
        'cursorLeftClose': (cursorLeftClose, 'D'),
        'cursorNextLineClose': (cursorNextLineClose, 'E'),
        'cursorPrevLineClose': (cursorPrevLineClose, 'F'),
        'cursorHPosClose': (cursorHPosClose, 'G'),
        'cursorPosClose': (cursorPosClose, 'H'),
        'cursorHVPosClose': (cursorHVPosClose, 'f'),
        'eraseInPageClose': (eraseInPageClose, 'J'),
        'eraseInLineClose': (eraseInLineClose, 'K'),
        'scrollUpClose': (scrollUpClose, 'S'),
        'scrollDownClose': (scrollDownClose, 'T'),
      };

      for (final MapEntry(key: name, value: (actual, expected))
          in closes.entries) {
        expect(actual, expected, reason: name);
      }
    });

    test('every Open constant is the CSI bytes', () {
      const opens = {
        'cursorUpOpen': cursorUpOpen,
        'cursorDownOpen': cursorDownOpen,
        'cursorRightOpen': cursorRightOpen,
        'cursorLeftOpen': cursorLeftOpen,
        'cursorNextLineOpen': cursorNextLineOpen,
        'cursorPrevLineOpen': cursorPrevLineOpen,
        'cursorHPosOpen': cursorHPosOpen,
        'cursorPosOpen': cursorPosOpen,
        'cursorHVPosOpen': cursorHVPosOpen,
        'eraseInPageOpen': eraseInPageOpen,
        'eraseInLineOpen': eraseInLineOpen,
        'scrollUpOpen': scrollUpOpen,
        'scrollDownOpen': scrollDownOpen,
      };

      for (final MapEntry(key: name, value: value) in opens.entries) {
        expect(value, '\x1B[', reason: name);
      }
    });

    test('the functions refuse a value that would move nothing', () {
      const calls = <String, String Function(int)>{
        'cursorUpN': cursorUpN,
        'cursorDownN': cursorDownN,
        'cursorRightN': cursorRightN,
        'cursorLeftN': cursorLeftN,
        'cursorNextLineN': cursorNextLineN,
        'cursorPrevLineN': cursorPrevLineN,
        'cursorHPosTo': cursorHPosTo,
        'scrollUpN': scrollUpN,
        'scrollDownN': scrollDownN,
      };

      for (final MapEntry(key: name, value: call) in calls.entries) {
        for (final value in [0, -1]) {
          expect(
            () => call(value),
            throwsA(isA<RangeError>()),
            reason: '$name($value)',
          );
        }
      }

      expect(() => cursorPosTo(0, 1), throwsA(isA<RangeError>()));
      expect(() => cursorPosTo(1, -1), throwsA(isA<RangeError>()));
      expect(() => cursorHVPosTo(-1, 1), throwsA(isA<RangeError>()));
      expect(() => cursorHVPosTo(1, 0), throwsA(isA<RangeError>()));
    });

    test('constants and functions emit correct raw sequences', () {
      const constants = {
        'cursorUp': (cursorUp, '\x1B[A'),
        'cursorDown': (cursorDown, '\x1B[B'),
        'cursorRight': (cursorRight, '\x1B[C'),
        'cursorLeft': (cursorLeft, '\x1B[D'),
        'cursorNextLine': (cursorNextLine, '\x1B[E'),
        'cursorPrevLine': (cursorPrevLine, '\x1B[F'),
        'cursorHPosToBegin': (cursorHPosToBegin, '\x1B[G'),
        'cursorPosToTopLeft': (cursorPosToTopLeft, '\x1B[H'),
        'cursorHVPosToTopLeft': (cursorHVPosToTopLeft, '\x1B[f'),
        'eraseInPageToEnd': (eraseInPageToEnd, '\x1B[J'),
        'eraseInPageToBegin': (eraseInPageToBegin, '\x1B[1J'),
        'erasePage': (erasePage, '\x1B[2J'),
        'eraseInLineToEnd': (eraseInLineToEnd, '\x1B[K'),
        'eraseInLineToBegin': (eraseInLineToBegin, '\x1B[1K'),
        'eraseLine': (eraseLine, '\x1B[2K'),
        'scrollUp': (scrollUp, '\x1B[S'),
        'scrollDown': (scrollDown, '\x1B[T'),
        'showCursor': (showCursor, '\x1B[?25h'),
        'hideCursor': (hideCursor, '\x1B[?25l'),
        'useAlternateScreen': (useAlternateScreen, '\x1B[?1049h'),
        'useMainScreen': (useMainScreen, '\x1B[?1049l'),
      };

      for (final MapEntry(key: name, value: (actual, expected))
          in constants.entries) {
        expect(actual, expected, reason: name);
      }

      expect(cursorUpN(4), '\x1B[4A');
      expect(cursorDownN(4), '\x1B[4B');
      expect(cursorRightN(4), '\x1B[4C');
      expect(cursorLeftN(4), '\x1B[4D');
      expect(cursorNextLineN(4), '\x1B[4E');
      expect(cursorPrevLineN(4), '\x1B[4F');
      expect(cursorHPosTo(4), '\x1B[4G');
      expect(cursorPosTo(2, 3), '\x1B[2;3H');
      expect(cursorHVPosTo(2, 3), '\x1B[2;3f');
      expect(scrollUpN(4), '\x1B[4S');
      expect(scrollDownN(4), '\x1B[4T');
    });
  });
}
