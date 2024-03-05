import '../constants/csi.dart';

String cursorUpN(int n) => '$cursorUpOpen$n$cursorUpClose';

String cursorDownN(int n) => '$cursorDownOpen$n$cursorDownClose';

String cursorForwardN(int n) => '$cursorForwardOpen$n$cursorForwardClose';

String cursorBackN(int n) => '$cursorBackOpen$n$cursorBackClose';

String cursorNextLineN(int n) => '$cursorNextLineOpen$n$cursorNextLineClose';

String cursorPrevLineN(int n) => '$cursorPrevLineOpen$n$cursorPrevLineClose';

String cursorHVPos(int row, int col) =>
    '$cursorHVPosOpen$row;$col$cursorHVPosClose';

String cursorHPos(int n) => '$cursorHPosOpen$n$cursorHPosClose';

String cursorPos(int row, int col) => '$cursorPosOpen$row;$col$cursorPosClose';

String scrollUpN(int n) => '$scrollUpOpen$n$scrollUpClose';

String scrollDownN(int n) => '$scrollDownOpen$n$scrollDownClose';
