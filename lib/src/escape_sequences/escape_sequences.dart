import '../control_codes/control_codes.dart';

//
// Escape seqences constants.
//

/// CSI (Control Sequence Introducer).
///
/// Starts most of the useful sequences, terminated by a byte in the range
/// 0x40 through 0x7E.
const String csi = '$esc[';

/// ST (String Terminator).
///
/// Terminates strings in other controls.
const String st = '$esc\\';

/// OSC (Operating System Command).
///
/// Starts a control string for the operating system to use, terminated by ST.
const String osc = '$esc]';
