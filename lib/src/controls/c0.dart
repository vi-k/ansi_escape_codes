// ignore_for_file: constant_identifier_names

/// Control functions: elements of the C0 set.
///
/// These control functions are represented by codes from 0x00 to 0x1F.
///
/// https://www.ecma-international.org/wp-content/uploads/ECMA-48_5th_edition_june_1991.pdf
///
/// See also [ControlFunctionsC0].
library;

import '../parsing/control_functions/control_functions_c0.dart';

/// Null.
///
/// NUL is used for media-fill or time-fill. NUL characters may be inserted
/// into, or removed from, a data stream without affecting the information
/// content of that stream, but such action may affect the information layout
/// and/or the control of equipment.
const String NUL = '\x00';

/// Start Of Heading.
///
/// SOH is used to indicate the beginning of a heading.
///
/// The use of SOH is defined in ISO 1745.
const String SOH = '\x01';

/// Start Of Text.
///
/// STX is used to indicate the beginning of a text and the end of a heading.
///
/// The use of STX is defined in ISO 1745.
const String STX = '\x02';

/// End Of Text.
///
/// ETX is used to indicate the end of a text.
///
/// The use of ETX is defined in ISO 1745.
const String ETX = '\x03';

/// End Of Transmission.
///
/// EOT is used to indicate the conclusion of the transmission of one or more
/// texts.
///
/// The use of EOT is defined in ISO 1745.
const String EOT = '\x04';

/// Enquiry.
///
/// ENQ is transmitted by a sender as a request for a response from
/// a receiver.
///
/// The use of ENQ is defined in ISO 1745.
const String ENQ = '\x05';

/// Acknowledge.
///
/// ACK is transmitted by a receiver as an affirmative response to the
/// sender.
///
/// The use of ACK is defined in ISO 1745.
const String ACK = '\x06';

/// Bell.
///
/// BEL is used when there is a need to call for attention; it may control
/// alarm or attention devices.
const String BEL = '\x07';

/// Backspace.
///
/// BS causes the active data position to be moved one character position in
/// the data component in the direction opposite to that of the implicit
/// movement.
///
/// The direction of the implicit movement depends on the parameter value of
/// SELECT IMPLICIT MOVEMENT DIRECTION (SIMD).
const String BS = '\b';

/// Horizontal Tabulation.
///
/// HT causes the active presentation position to be moved to the following
/// character tabulation stop in the presentation component.
///
/// In addition, if that following character tabulation stop has been set by
/// TABULATION ALIGN CENTRE (TAC), TABULATION ALIGN LEADING EDGE (TALE),
/// TABULATION ALIGN TRAILING EDGE (TATE) or TABULATION CENTRED ON CHARACTER
/// (TCC), HT indicates the beginning of a string of text which is to be
/// positioned within a line according to the properties of that tabulation
/// stop. The end of the string is indicated by the next occurrence of HT or
/// CARRIAGE RETURN (CR) or NEXT LINE (NEL) in the data stream.
const String HT = '\t';

/// Line Feed.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, LF
/// causes the active presentation position to be moved to the corresponding
/// character position of the following line in the presentation component.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, LF causes the
/// active data position to be moved to the corresponding character position
/// of the following line in the data component.
const String LF = '\n';

/// Vertical Tabulation.
///
/// VT causes the active presentation position to be moved in the
/// presentation component to the corresponding character position on the
/// line at which the following line tabulation stop is set.
const String VT = '\x0B';

/// Form Feed.
///
/// FF causes the active presentation position to be moved to the
/// corresponding character position of the line at the page home position
/// of the next form or page in the presentation component. The page home
/// position is established by the parameter value of SET PAGE HOME (SPH).
const String FF = '\f';

/// Carriage Return.
///
/// The effect of CR depends on the setting of the DEVICE COMPONENT SELECT
/// MODE (DCSM) and on the parameter value of SELECT IMPLICIT MOVEMENT
/// DIRECTION (SIMD).
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION and
/// with the parameter value of SIMD equal to 0, CR causes the active
/// presentation position to be moved to the line home position of the same
/// line in the presentation component. The line home position is established
/// by the parameter value of SET LINE HOME (SLH).
///
/// With a parameter value of SIMD equal to 1, CR causes the active
/// presentation position to be moved to the line limit position of the same
/// line in the presentation component. The line limit position is
/// established by the parameter value of SET LINE LIMIT (SLL).
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA and with
/// a parameter value of SIMD equal to 0, CR causes the active data position
/// to be moved to the line home position of the same line in the data
/// component. The line home position is established by the parameter value
/// of SET LINE HOME (SLH).
///
/// With a parameter value of SIMD equal to 1, CR causes the active data
/// position to be moved to the line limit position of the same line in the
/// data component. The line limit position is established by the parameter
/// value of SET LINE LIMIT (SLL).
const String CR = '\r';

/// Shift-Out.
///
/// SO is used for code extension purposes. It causes the meanings of the bit
/// combinations following it in the data stream to be changed.
///
/// The use of SO is defined in Standard ECMA-35.
///
/// NOTE
///
/// SO is used in 7-bit environments only; in 8-bit environments
/// LOCKING-SHIFT ONE (LS1) is used instead.
///
/// Locking-Shift One.
///
/// LS1 is used for code extension purposes. It causes the meanings of the
/// bit combinations following it in the data stream to be changed.
///
/// The use of LS1 is defined in Standard ECMA-35.
///
/// NOTE
///
/// LS1 is used in 8-bit environments only; in 7-bit environments SHIFT-OUT
/// (SO) is used instead.
const String SO = '\x0E';

/// Shift-In.
///
/// SI is used for code extension purposes. It causes the meanings of the bit
/// combinations following it in the data stream to be changed.
///
/// The use of SI is defined in Standard ECMA-35.
///
/// NOTE
///
/// SI is used in 7-bit environments only; in 8-bit environments
/// LOCKING-SHIFT ZERO (LS0) is used instead.
///
/// Locking-Shift Zero.
///
/// LS0 is used for code extension purposes. It causes the meanings of the
/// bit combinations following it in the data stream to be changed.
///
/// The use of LS0 is defined in Standard ECMA-35.
///
/// NOTE
///
/// LS0 is used in 8-bit environments only; in 7-bit environments SHIFT-IN
/// (SI) is used instead.
const String SI = '\x0F';

/// Data Link Escape.
///
/// DLE is used exclusively to provide supplementary transmission control
/// functions.
///
/// The use of DLE is defined in ISO 1745.
const String DLE = '\x10';

/// Device Control One.
///
/// DC1 is primarily intended for turning on or starting an ancillary device.
/// If it is not required for this purpose, it may be used to restore
/// a device to the basic mode of operation (see also DC2 and DC3), or any
/// other device control function not provided by other DCs.
///
/// NOTE
///
/// When used for data flow control, DC1 is sometimes called "X-ON".
const String DC1 = '\x11';

/// Device Control Two.
///
/// DC2 is primarily intended for turning on or starting an ancillary device.
/// If it is not required for this purpose, it may be used to set a device to
/// a special mode of operation (in which case DC1 is used to restore the
/// device to the basic mode), or for any other device control function not
/// provided by other DCs.
const String DC2 = '\x12';

/// Device Control Three.
///
/// DC3 is primarily intended for turning off or stopping an ancillary
/// device. This function may be a secondary level stop, for example wait,
/// pause, stand-by or halt (in which case DC1 is used to restore normal
/// operation). If it is not required for this purpose, it may be used for
/// any other device control function not provided by other DCs.
///
/// NOTE
///
/// When used for data flow control, DC3 is sometimes called "X-OFF".
const String DC3 = '\x13';

/// Device Control Four.
///
/// DC4 is primarily intended for turning off, stopping or interrupting an
/// ancillary device. If it is not required for this purpose, it may be used
/// for any other device control function not provided by other DCs.
const String DC4 = '\x14';

/// NEGATIVE ACKNOWLEDGE.
///
/// NAK is transmitted by a receiver as a negative response to the sender.
///
/// The use of NAK is defined in ISO 1745.
const String NAK = '\x15';

/// Synchronous Idle.
///
/// SYN is used by a synchronous transmission system in the absence of any
/// other character (idle condition) to provide a signal from which
/// synchronism may be achieved or retained between data terminal equipment.
///
/// The use of SYN is defined in ISO 1745.
const String SYN = '\x16';

/// End Of Transmission Block.
///
/// ETB is used to indicate the end of a block of data where the data are
/// divided into such blocks for transmission purposes.
///
/// The use of ETB is defined in ISO 1745.
const String ETB = '\x17';

/// Cancel.
///
/// CAN is used to indicate that the data preceding it in the data stream is
/// in error. As a result, this data shall be ignored. The specific meaning
/// of this control function shall be defined for each application and/or
/// between sender and recipient.
const String CAN = '\x18';

/// End Of Medium.
///
/// EM is used to identify the physical end of a medium, or the end of the
/// used portion of a medium, or the end of the wanted portion of data
/// recorded on a medium.
const String EM = '\x19';

/// Substitute.
///
/// SUB is used in the place of a character that has been found to be invalid
/// or in error. SUB is intended to be introduced by automatic means.
const String SUB = '\x1A';

/// Escape.
///
/// ESC is used for code extension purposes. It causes the meanings of
/// a limited number of bit combinations following it in the data stream
/// to be changed.
///
/// The use of ESC is defined in Standard ECMA-35.
const String ESC = '\x1B';

/// File Separator (or IS4 - Information Separator Four).
///
/// IS4 is used to separate and qualify data logically; its specific meaning
/// has to be defined for each application. If this control function is used
/// in hierarchical order, it may delimit a data item called a file.
const String FS = '\x1C';

/// Group Separator (or IS3 - Information Separator Three).
///
/// IS3 is used to separate and qualify data logically; its specific meaning
/// has to be defined for each application. If this control function is used
/// in hierarchical order, it may delimit a data item called a group.
const String GS = '\x1D';

/// Record Separator (or IS2 - Information Separator Two).
///
/// IS2 is used to separate and qualify data logically; its specific meaning
/// has to be defined for each application. If this control function is used
/// in hierarchical order, it may delimit a data item called a record.
const String RS = '\x1E';

/// Unit Separator (or IS1 - Information Separator One).
///
/// IS1 is used to separate and qualify data logically; its specific meaning
/// has to be defined for each application. If this control function is used
/// in hierarchical order, it may delimit a data item called a unit.
const String US = '\x1F';
