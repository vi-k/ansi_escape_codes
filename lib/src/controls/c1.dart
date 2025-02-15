// ignore_for_file: constant_identifier_names

/// Control functions: elements of the C1 set.
///
/// These control functions are represented by 2-character escape sequences
/// of the form [ESC] Fe, where [ESC] is represented by code 0x1B and Fe is
/// represented by codes from 0x40 to 0x5F.
///
/// The unallocated codes are reserved for future standardization and shall not
/// be used.
///
/// https://www.ecma-international.org/wp-content/uploads/ECMA-48_5th_edition_june_1991.pdf
library;

import 'c0.dart';

/// Break Permitted Here.
///
/// BPH is used to indicate a point where a line break may occur when text is
/// formatted. BPH may occur between two graphic characters, either or both
/// of which may be SPACE.
const String BPH = '${ESC}B';

/// No Break Here.
///
/// NBH is used to indicate a point where a line break shall not occur when
/// text is formatted. NBH may occur between two graphic characters either or
/// both of which may be SPACE.
const String NBH = '${ESC}C';

/// Next Line.
///
/// The effect of NEL depends on the setting of the DEVICE COMPONENT SELECT
/// MODE (DCSM) and on the parameter value of SELECT IMPLICIT MOVEMENT
/// DIRECTION (SIMD).
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION and
/// with a parameter value of SIMD equal to 0, NEL causes the active
/// presentation position to be moved to the line home position of the
/// following line in the presentation component. The line home position is
/// established by the parameter value of SET LINE HOME (SLH).
///
/// With a parameter value of SIMD equal to 1, NEL causes the active
/// presentation position to be moved to the line limit position of the
/// following line in the presentation component. The line limit position is
/// established by the parameter value of SET LINE LIMIT (SLL).
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA and with
/// a parameter value of SIMD equal to 0, NEL causes the active data position
/// to be moved to the line home position of the following line in the data
/// component. The line home position is established by the parameter value
/// of SET LINE HOME (SLH).
///
/// With a parameter value of SIMD equal to 1, NEL causes the active data
/// position to be moved to the line limit position of the following line in
/// the data component. The line limit position is established by the
/// parameter value of SET LINE LIMIT (SLL).
const String NEL = '${ESC}E';

/// Start Of Selected Area.
///
/// SSA is used to indicate that the active presentation position is the
/// first of a string of character positions in the presentation component,
/// the contents of which are eligible to be transmitted in the form of
/// a data stream or transferred to an auxiliary input/output device.
///
/// The end of this string is indicated by END OF SELECTED AREA (ESA). The
/// string of characters actually transmitted or transferred depends on the
/// setting of the GUARDED AREA TRANSFER MODE (GATM) and on any guarded areas
/// established by DEFINE AREA QUALIFICATION (DAQ), or by START OF GUARDED
/// AREA (SPA) and END OF GUARDED AREA (EPA).
///
/// NOTE
///
/// The control functions for area definition (DAQ, EPA, ESA, SPA, SSA)
/// should not be used within an SRS string or an SDS string.
const String SSA = '${ESC}F';

/// End Of Selected Area.
///
/// ESA is used to indicate that the active presentation position is the last
/// of a string of character positions in the presentation component, the
/// contents of which are eligible to be transmitted in the form of a data
/// stream or transferred to an auxiliary input/output device. The beginning
/// of this string is indicated by START OF SELECTED AREA (SSA).
///
/// NOTE
///
/// The control function for area definition (DAQ, EPA, ESA, SPA, SSA) should
/// not be used within an SRS string or an SDS string.
const String ESA = '${ESC}G';

/// Character Tabulation Set.
///
/// HTS causes a character tabulation stop to be set at the active
/// presentation position in the presentation component.
///
/// The number of lines affected depends on the setting of the TABULATION
/// STOP MODE (TSM).
const String HTS = '${ESC}H';

/// Character Tabulation With Justification.
///
/// HTJ causes the contents of the active field (the field in the
/// presentation component that contains the active presentation position) to
/// be shifted forward so that it ends at the character position preceding
/// the following character tabulation stop. The active presentation position
/// is moved to that following character tabulation stop. The character
/// positions which precede the beginning of the shifted string are put into
/// the erased state.
const String HTJ = '${ESC}I';

/// Line Tabulation Set.
///
/// VTS causes a line tabulation stop to be set at the active line (the line
/// that contains the active presentation position).
const String VTS = '${ESC}J';

/// Partial Line Forward.
///
/// PLD causes the active presentation position to be moved in the
/// presentation component to the corresponding position of an imaginary line
/// with a partial offset in the direction of the line progression. This
/// offset should be sufficient either to image following characters as
/// subscripts until the first following occurrence of PARTIAL LINE BACKWARD
/// (PLU) in the data stream, or, if preceding characters were imaged as
/// superscripts, to restore imaging of following characters to the active
/// line (the line that contains the active presentation position).
///
/// Any interactions between PLD and format effectors other than PLU are not
/// defined by Standard.
const String PLD = '${ESC}K';

/// Partial Line Backward.
///
/// PLU causes the active presentation position to be moved in the
/// presentation component to the corresponding position of an imaginary line
/// with a partial offset in the direction opposite to that of the line
/// progression. This offset should be sufficient either to image following
/// characters as superscripts until the first following occurrence of
/// PARTIAL LINE FORWARD (PLD) in the data stream, or, if preceding
/// characters were imaged as subscripts, to restore imaging of following
/// characters to the active line (the line that contains the active
/// presentation position).
///
/// Any interactions between PLU and format effectors other than PLD are not
/// defined by Standard.
const String PLU = '${ESC}L';

/// Reverse Line Feed.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, RI
/// causes the active presentation position to be moved in the presentation
/// component to the corresponding character position of the preceding line.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, RI causes the
/// active data position to be moved in the data component to the
/// corresponding character position of the preceding line.
const String RI = '${ESC}M';

/// Single-Shift Two.
///
/// SS2 is used for code extension purposes. It causes the meanings of the
/// bytes following it in the data stream to be changed.
///
/// The use of SS2 is defined in Standard ECMA-35.
const String SS2 = '${ESC}N';

/// Single-Shift Three.
///
/// SS3 is used for code extension purposes. It causes the meanings of the
/// bytes following it in the data stream to be changed.
///
/// The use of SS3 is defined in Standard ECMA-35.
const String SS3 = '${ESC}O';

/// Device Control String.
///
/// DCS is used as the opening delimiter of a control string for device
/// control use. The command string following may consist of bytes in the
/// range 0x08 to 0x0D and 0x20 to 0x7E. The control string is closed by the
/// terminating delimiter STRING TERMINATOR (ST).
///
/// The command string represents either one or more commands for the
/// receiving device, or one or more status reports from the sending device.
/// The purpose and the format of the command string are specified by the
/// most recent occurrence of IDENTIFY DEVICE CONTROL STRING (IDCS), if any,
/// or depend on the sending and/or the receiving device.
const String DCS = '${ESC}P';

/// Private Use One.
///
/// PU1 is reserved for a function without standardized meaning for private
/// use as required, subject to the prior agreement between the sender and
/// the recipient of the data.
const String PU1 = '${ESC}Q';

/// Private Use Two.
///
/// PU2 is reserved for a function without standardized meaning for private
/// use as required, subject to the prior agreement between the sender and
/// the recipient of the data.
const String PU2 = '${ESC}R';

/// Set Transmit State.
///
/// STS is used to establish the transmit state in the receiving device. In
/// this state the transmission of data from the device is possible.
///
/// The actual initiation of transmission of data is performed by a data
/// communication or input/output interface control procedure which is
/// outside the scope of Standard.
///
/// The transmit state is established either by STS appearing in the received
/// data stream or by the operation of an appropriate key on a keyboard.
const String STS = '${ESC}S';

/// Cancel Character.
///
/// CCH is used to indicate that both the preceding graphic character in the
/// data stream, (represented by one or more bytes) including SPACE, and the
/// control function CCH itself are to be ignored for further interpretation
/// of the data stream.
///
/// If the character preceding CCH in the data stream is a control function
/// (represented by one or more bytes), the effect of CCH is not defined by
/// Standard.
const String CCH = '${ESC}T';

/// Message Waiting.
///
/// MW is used to set a message waiting indicator in the receiving device.
/// An appropriate acknowledgement to the receipt of MW may be given by using
/// DEVICE STATUS REPORT (DSR).
const String MW = '${ESC}U';

/// Start Of Guarded Area.
///
/// SPA is used to indicate that the active presentation position is the
/// first of a string of character positions in the presentation component,
/// the contents of which are protected against manual alteration, are
/// guarded against transmission or transfer, depending on the setting of
/// the GUARDED AREA TRANSFER MODE (GATM) and may be protected against
/// erasure, depending on the setting of the ERASURE MODE (ERM). The end of
/// this string is indicated by END OF GUARDED AREA (EPA).
///
/// NOTE
///
/// The control functions for area definition (DAQ, EPA, ESA, SPA, SSA)
/// should not be used within an SRS string or an SDS string.
const String SPA = '${ESC}V';

/// End Of Guarded Area.
///
/// EPA is used to indicate that the active presentation position is the last
/// of a string of character positions in the presentation component, the
/// contents of which are protected against manual alteration, are guarded
/// against transmission or transfer, depending on the setting of the GUARDED
/// AREA TRANSFER MODE (GATM), and may be protected against erasure,
/// depending on the setting of the ERASURE MODE (ERM). The beginning of this
/// string is indicated by START OF GUARDED AREA (SPA).
///
/// NOTE
///
/// The control functions for area definition (DAQ, EPA, ESA, SPA, SSA)
/// should not be used within an SRS string or an SDS string.
const String EPA = '${ESC}W';

/// Start Of String.
///
/// SOS is used as the opening delimiter of a control string. The character
/// string following may consist of any bytes, except those representing SOS
/// or STRING TERMINATOR (ST). The control string is closed by the
/// terminating delimiter STRING TERMINATOR (ST). The interpretation of the
/// character string depends on the application.
const String SOS = '${ESC}X';

/// Single Character Introducer.
///
/// SCI and the byte following it are used to represent a control function or
/// a graphic character. The byte following SCI must be from 0x08 to 0x0D or
/// 0x20 to 0x7E. The use of SCI is reserved for future standardization.
const String SCI = '${ESC}Z';

/// Control Sequence Introducer.
///
/// CSI is used as the first character of a control sequence.
const String CSI = '$ESC[';

/// String Terminator.
///
/// ST is used as the closing delimiter of a control string opened by
/// APPLICATION PROGRAM COMMAND (APC), DEVICE CONTROL STRING (DCS), OPERATING
/// SYSTEM COMMAND (OSC), PRIVACY MESSAGE (PM), or START OF STRING (SOS).
const String ST = '$ESC\\';

/// Operating System Command.
///
/// OSC is used as the opening delimiter of a control string for operating
/// system use. The command string following may consist of a sequence of
/// bytes in the range 0x08 to 0x0D and 0x20 to 0x7E. The control string is
/// closed by the terminating delimiter STRING TERMINATOR (ST). The
/// interpretation of the command string depends on the relevant operating
/// system.
const String OSC = '$ESC]';

/// Privacy Message.
///
/// PM is used as the opening delimiter of a control string for privacy
/// message use. The command string following may consist of a sequence of
/// bytes in the range 0x08 to 0x0D and 0x20 to 0x7E. The control string is
/// closed by the terminating delimiter STRING TERMINATOR (ST). The
/// interpretation of the command string depends on the relevant privacy
/// discipline.
const String PM = '$ESC^';

/// Application Program Command.
///
/// APC is used as the opening delimiter of a control string for application
/// program use. The command string following may consist of bytes in the
/// range 0x08 to 0x0D and 0x20 to 0x7E. The control string is closed by the
/// terminating delimiter STRING TERMINATOR (ST). The interpretation of the
/// command string depends on the relevant application program.
const String APC = '${ESC}_';
