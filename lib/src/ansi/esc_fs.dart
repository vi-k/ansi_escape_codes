// ignore_for_file: constant_identifier_names

/// Independent control functions.
///
/// These control functions are represented by 2-character escape sequences
/// of the form [ESC] Fs, where [ESC] is represented by code 0x1B and Fs is
/// represented by codes from 0x60 to 0x7E.
///
/// They are called independent because they are not affected by the shift
/// states or by the announced code structure: whatever the receiving device
/// has been told about the coding in use, these keep their meaning.
///
/// The unallocated codes are reserved for future standardization and shall not
/// be used.
///
/// https://www.ecma-international.org/wp-content/uploads/ECMA-48_5th_edition_june_1991.pdf
library;

import 'c0.dart';

/// Disable Manual Input.
///
/// DMI causes the manual input facilities of a device to be disabled.
const String DMI = '$ESC`';

/// Interrupt.
///
/// INT is used to indicate to the receiving device that the current process
/// is to be interrupted and an agreed procedure is to be initiated.
const String INT = '${ESC}a';

/// Enable Manual Input.
///
/// EMI is used to enable the manual input facilities of a device.
const String EMI = '${ESC}b';

/// Reset to Initial State.
///
/// RIS causes a device to be reset to its initial state, that is, the state
/// it has after it is made operational. This may imply, if applicable,
/// clearing the screen, resetting the tabulation stops and the graphic
/// rendition, and returning the cursor to the first position of the first
/// line.
const String RIS = '${ESC}c';

/// Coding Method Delimiter.
///
/// CMD is used as the delimiter of a string of data coded according to
/// Standard ECMA-35 and to switch to a general level of control.
const String CMD = '${ESC}d';

/// Locking-Shift Two.
///
/// LS2 is used for code extension purposes. It causes the meanings of the bit
/// combinations following it to be changed: the G2 set is invoked into
/// columns 02 to 07.
const String LS2 = '${ESC}n';

/// Locking-Shift Three.
///
/// LS3 is used for code extension purposes. It causes the meanings of the bit
/// combinations following it to be changed: the G3 set is invoked into
/// columns 02 to 07.
const String LS3 = '${ESC}o';

/// Locking-Shift Three Right.
///
/// LS3R is used for code extension purposes. It causes the meanings of the
/// bit combinations following it to be changed: the G3 set is invoked into
/// columns 10 to 15.
const String LS3R = '$ESC|';

/// Locking-Shift Two Right.
///
/// LS2R is used for code extension purposes. It causes the meanings of the
/// bit combinations following it to be changed: the G2 set is invoked into
/// columns 10 to 15.
const String LS2R = '$ESC}';

/// Locking-Shift One Right.
///
/// LS1R is used for code extension purposes. It causes the meanings of the
/// bit combinations following it to be changed: the G1 set is invoked into
/// columns 10 to 15.
const String LS1R = '$ESC~';
