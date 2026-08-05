import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:test/test.dart';

void main() {
  group('a private control sequence ending in m:', () {
    test('is not SGR', () {
      expect('\x1B[?5m'.ansiHasSgr, isFalse);
      expect('\x1B[>4;1m'.ansiHasSgr, isFalse);
      expect('\x1B[<35;10;2m'.ansiHasSgr, isFalse);
      expect('\x1B[=5m'.ansiHasSgr, isFalse);
    });

    test('is still CSI', () {
      expect('\x1B[?5m'.ansiHasCsi, isTrue);
      expect('\x1B[?5m'.ansiRemoveCsi(), '');
    });

    test('survives the removal of styles', () {
      expect('\x1B[>4;1m'.ansiRemoveSgr(), '\x1B[>4;1m');
      expect(
        'a\x1B[<35;10;2mb\x1B[31mc'.ansiRemoveSgr(),
        'a\x1B[<35;10;2mbc',
      );
    });

    test('is no colour to the colour surfaces', () {
      // A pin: the textual split never saw ?38 as a colour either.
      expect('\x1B[?38;5;196m'.ansiHasForeground, isFalse);
      expect('\x1B[?38;5;196m'.ansiRemoveForeground(), '\x1B[?38;5;196m');
    });

    test('what is SGR still is', () {
      expect('\x1B[1;38;5;196m'.ansiHasSgr, isTrue);
      expect('\x1B[4:3m'.ansiHasSgr, isTrue);
      expect('\x1B[;1m'.ansiHasSgr, isTrue);
      expect('\x1B[m'.ansiHasSgr, isTrue);
      expect('\x1B[038;5;196m'.ansiHasSgr, isTrue);
      expect('\x1B[1m'.ansiRemoveSgr(), '');
    });
  });
}
