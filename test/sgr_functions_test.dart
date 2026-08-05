import 'package:ansi_escape_codes/ansi_escape_codes.dart';
import 'package:ansi_escape_codes/src/internal/sgr_functions.dart';
import 'package:test/test.dart';

void main() {
  group('splitSgrFunctions:', () {
    test('a whole colour stays together', () {
      expect(splitSgrFunctions('38;5;196'), ['38;5;196']);
      expect(splitSgrFunctions('48;2;1;2;3'), ['48;2;1;2;3']);
      expect(splitSgrFunctions('58;5;196'), ['58;5;196']);
      expect(splitSgrFunctions('1;38;5;196;4'), ['1', '38;5;196', '4']);
    });

    test('leading zeroes read as numbers', () {
      expect(splitSgrFunctions('038;5;196'), ['038;5;196']);
      expect(splitSgrFunctions('38;05;196'), ['38;05;196']);
    });

    test('a colour cut short gives up the introducer and the kind alone', () {
      expect(splitSgrFunctions('38;2;1;2'), ['38;2', '1', '2']);
      expect(splitSgrFunctions('48;2;1;2'), ['48;2', '1', '2']);
      expect(splitSgrFunctions('38;5'), ['38;5']);
      expect(splitSgrFunctions('58;5'), ['58;5']);
      expect(splitSgrFunctions('38'), ['38']);
    });

    test('an unknown kind is consumed with the introducer', () {
      expect(splitSgrFunctions('38;7;1'), ['38;7', '1']);
      expect(splitSgrFunctions('58;9;1'), ['58;9', '1']);
    });

    test('the colon form is one parameter and stays whole', () {
      expect(splitSgrFunctions('38:5:196'), ['38:5:196']);
      expect(splitSgrFunctions('38:2::1:2:3;1'), ['38:2::1:2:3', '1']);
      expect(splitSgrFunctions('38;4:3'), ['38;4:3']);
    });

    test('empty parameters split as themselves', () {
      expect(splitSgrFunctions(''), <String>[]);
      expect(splitSgrFunctions(';'), ['', '']);
      expect(splitSgrFunctions('38;'), ['38;']);
    });
  });

  group('the colour surfaces after the split:', () {
    test('a colour cut short no longer eats its neighbours', () {
      expect('\x1B[38;2;1;2mX'.ansiRemoveForeground(), '\x1B[1;2mX');
      expect('\x1B[38;2;1;2mX'.ansiHasForeground, isTrue);
    });

    test('leading zeroes no longer hide the colour', () {
      expect('\x1B[38;05;196mX'.ansiRemoveForeground(), 'X');
      expect('\x1B[038;5;196mX'.ansiRemoveForeground(), 'X');
      expect('\x1B[38;05;196mX'.ansiHasForeground, isTrue);
    });

    test('an unknown kind leaves no lone parameter behind', () {
      expect('\x1B[38;7;1mX'.ansiRemoveForeground(), '\x1B[1mX');
    });

    test('what was right stays right', () {
      expect('\x1B[1;38;5;196;4mX'.ansiRemoveForeground(), '\x1B[1;4mX');
      expect('\x1B[38;5;196mX'.ansiRemoveForeground(), 'X');
      expect('\x1B[31;42mX'.ansiRemoveForeground(), '\x1B[42mX');
    });
  });
}
