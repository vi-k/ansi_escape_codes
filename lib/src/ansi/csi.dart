// ignore_for_file: constant_identifier_names

/// Control sequences.
///
/// A control sequence is a string starting with the control function CONTROL
/// SEQUENCE INTRODUCER (CSI) followed by one or more bytes representing
/// parameters, if any, and by one or more bytes identifying the control
/// function. The control function CSI itself is an element of the C1
/// set.
///
/// The format of a control sequence is
///
/// CSI P ... P I ... I F
///
/// where
/// a) CSI is represented by bytes 0x1B (ESC) and 0x5B "[";
/// b) P ... P are Parameter Bytes, which, if present, consist of bytes from
///    0x30 "0" to 0x3F "?";
/// c) I ... I are Intermediate Bytes, which, if present, consist of bytes from
///    0x20 " " to 0x2F "/". Together with the Final Byte F, they identify the
///    control function;
///
///    NOTE
///
///    The number of Intermediate Bytes is not limited by Standard; in
///    practice, one Intermediate Byte will be sufficient since with sixteen
///    different bit combinations available for the Intermediate Byte over one
///    thousand control functions may be identified.
///
/// d) F is the Final Byte; it consists of bytes from 0x40 to 0x7E; it
///    terminates the control sequence and together with the Intermediate
///    Bytes, if present, identifies the control function. Bytes 0x70 to 0x7E
///    are available as Final Bytes of control sequences for private (or
///    experimental) use.
///
/// The unallocated bytes are reserved for future standardization and shall not
/// be used.
///
/// Parameter representation
///
/// A control sequence may contain a string of Parameter Bytes P ... P
/// representing one or more parameters to complete the specification of the
/// control function.
///
/// The Parameter Bytes are bytes from 0x30 to 0x3F. The parameter string is
/// interpreted as follows:
///
/// a) If the first byte of the parameter string is in the range 0x30 "0" to
///    0x3B ";", the parameter string is interpreted according to the format
///    described in Parameter string format.
/// b) If the first byte of the parameter string is in the range 0x3C "<" to
///    0x3F "?", the parameter string is available for private (or
///    experimental) use. Its format and meaning are not defined by Standard.
///
/// Parameter string format
///
/// A parameter string which does not start with a byte in the range 0x3C "<"
/// to 0x3F "?" shall have the following format:
///
/// a) A parameter string consists of one or more parameter sub-strings, each
///    of which represents a number in decimal notation.
/// b) Each parameter sub-string consists of one or more bytes from 0x30 "0" to
///    0x3A ":"; the bytes from 0x30 "0" to 0x39 "9" represent the digits 0 to
///    9; byte 0x3A ":" may be used as a separator in a parameter sub-string,
///    for example, to separate the fractional part of a decimal number from
///    the integer part of that number.
/// c) Parameter sub-strings are separated by one byte 0x3B ";".
/// d) Bytes 0x3C ">" to 0x3F "?" are reserved for future standardization
///    except when used as the first byte of the parameter string.
/// e) An empty parameter sub-string represents a default value which depends
///    on the control function.
/// f) In each parameter sub-string, leading bytes 0x30 "0" are not significant
///    and may be omitted. If the parameter sub-string consists of bytes
///    0x30 "0" only, at least one of them must be retained to indicate the
///    zero value of the sub-string.
/// g) If the parameter string starts with the byte 0x3B ";", an empty
///    parameter sub-string is assumed preceding the separator; if the
///    parameter string terminates with the bit combination 0x3B ";", an empty
///    parameter sub-string is assumed following the separator; if the
///    parameter string contains successive bytes 0x3B, empty parameter
///    sub-strings are assumed between the separators.
/// h) If the control function has more than one parameter, and some parameter
///    sub-strings are empty, the separators (byte 0x3B ";") must still be
///    present. However, if the last parameter sub-string(s) is empty, the
///    separator preceding it may be omitted.
///
/// Types of parameters
///
/// In a control sequence with parameters, each parameter sub-string
/// corresponds to one parameter and represents the value of that parameter.
/// The number of parameters is either fixed or variable, depending on the
/// control function. If the number of parameters is variable, neither the
/// maximum number of values nor the order in which the corresponding actions
/// are performed are defined by Standard.
///
/// A parameter may be purely numeric (n) or it may be selective (s), i.e.
/// denoting one of a numbered list of actions the control function can
/// perform.
///
/// In the case of selected parameters a particular parameter value may have
/// the same meaning as a combination of two or more separate values.
///
/// Unassigned selective parameter values are reserved for future
/// standardization.
library;

/// Insert Character.
///
/// Representation: CSI n \x40
///
/// Parameter default value: n = 1
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, ICH is
/// used to prepare the insertion of n characters, by putting into the erased
/// state the active presentation position and, depending on the setting of
/// the CHARACTER EDITING MODE (HEM), the n-1 preceding or following
/// character positions in the presentation component. The previous contents
/// of the active presentation position and an adjacent string of character
/// positions are shifted away from the active presentation position. The
/// contents of n character positions at the other end of the shifted part
/// are removed. The active presentation position is moved to the line home
/// position in the active line. The line home position is established by the
/// parameter value of SET LINE HOME (SLH).
///
/// The extent of the shifted part is established by SELECT EDITING EXTENT
/// (SEE).
///
/// The effect of ICH on the start or end of a selected area, the start or
/// end of a qualified area, or a tabulation stop in the shifted part, is not
/// defined by Standard.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, ICH is used to
/// prepare the insertion of n characters, by putting into the erased state
/// the active data position and, depending on the setting of the CHARACTER
/// EDITING MODE (HEM), the n-1 preceding or following character positions in
/// the data component. The previous contents of the active data position and
/// an adjacent string of character positions are shifted away from the
/// active data position. The contents of n character positions at the other
/// end of the shifted part are removed. The active data position is moved to
/// the line home position in the active line. The line home position is
/// established by the parameter value of SET LINE HOME (SLH).
const String ICH = '@';

/// Cursor Up.
///
/// Representation: CSI n \x41
///
/// Parameter default value: n = 1
///
/// CUU causes the active presentation position to be moved upwards in the
/// presentation component by n line positions if the character path is
/// horizontal, or by n character positions if the character path is
/// vertical.
const String CUU = 'A';

/// Cursor Down.
///
/// Representation: CSI n \x42
///
/// Parameter default value: n = 1
///
/// CUD causes the active presentation position to be moved downwards in the
/// presentation component by n line positions if the character path is
/// horizontal, or by n character positions if the character path is
/// vertical.
const String CUD = 'B';

/// Cursor Right.
///
/// Representation: CSI n \x43
///
/// Parameter default value: n = 1
///
/// CUF causes the active presentation position to be moved rightwards in the
/// presentation component by n character positions if the character path is
/// horizontal, or by n line positions if the character path is vertical.
const String CUF = 'C';

/// Cursor Left.
///
/// Representation: CSI n \x44
///
/// Parameter default value: n = 1
///
/// CUB causes the active presentation position to be moved leftwards in the
/// presentation component by n character positions if the character path is
/// horizontal, or by n line positions if the character path is vertical.
const String CUB = 'D';

/// Cursor Next Line.
///
/// Representation: CSI n \x45
///
/// Parameter default value: n = 1
///
/// CNL causes the active presentation position to be moved to the first
/// character position of the n-th following line in the presentation
/// component.
const String CNL = 'E';

/// Cursor Preceding Line.
///
/// Representation: CSI n \x46
///
/// Parameter default value: n = 1
///
/// CPL causes the active presentation position to be moved to the first
/// character position of the n-th preceding line in the presentation
/// component.
const String CPL = 'F';

/// Cursor Character Absolute.
///
/// Representation: CSI n \x47
///
/// Parameter default value: n = 1
///
/// CHA causes the active presentation position to be moved to character
/// position n in the active line in the presentation component.
const String CHA = 'G';

/// Cursor Position.
///
/// Representation: CSI n1;n2 \x48
///
/// Parameter default values: n = 1; m = 1
///
/// CUP causes the active presentation position to be moved in the
/// presentation component to the n-th line position according to the line
/// progression and to the m-th character position according to the character
/// path.
const String CUP = 'H';

/// Cursor Forward Tabulation.
///
/// Representation: CSI n \x49
///
/// Parameter default value: n = 1
///
/// CHT causes the active presentation position to be moved to the character
/// position corresponding to the n-th following character tabulation stop in
/// the presentation component, according to the character path.
const String CHT = 'I';

/// Erase In Page.
///
/// Representation: CSI s \x4A
///
/// Parameter default value: s = 0
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, ED
/// causes some or all character positions of the active page (the page which
/// contains the active presentation position in the presentation component)
/// to be put into the erased state, depending on the parameter values:
///
/// - 0 - the active presentation position and the character positions up to
///   the end of the page are put into the erased state
/// - 1 - the character positions from the beginning of the page up to and
///   including the active presentation position are put into the erase
///   state
/// - 2 - all character positions of the page are put into the erased state
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, ED causes some
/// or all character positions of the active page (the page which contains
/// the active data position in the data component) to be put into the erased
/// state, depending on the parameter values:
///
/// - 0 - the active data position and the character positions up to the end
///   of the page are put into the erased state
/// - 1 - the character positions from the beginning of the page up to and
///   including the active data position are put into the erased state
/// - 2 - all character positions of the page are put into the erased state
///
/// Whether the character positions of protected areas are put into the
/// erased state, or the character positions of unprotected areas only,
/// depends on the setting of the ERASURE MODE (ERM).
const String ED = 'J';

/// Erase In Line.
///
/// Representation: CSI s \x4B
///
/// Parameter default value: s = 0
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, EL
/// causes some or all character positions of the active line (the line which
/// contains the active presentation position in the presentation component)
/// to be put into the erased state, depending on the parameter values:
///
/// - 0 - the active presentation position and the character positions up to
///   the end of the line are put into the erased state
/// - 1 - the character positions from the beginning of the line up to and
///   including the active presentation position are put into the erased
///   state
/// - 2 - all character positions of the line are put into the erased state
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, EL causes some
/// or all character positions of the active line (the line which contains
/// the active data position in the data component) to be put into the erased
/// state, depending on the parameter values:
///
/// - 0 - the active data position and the character positions up to the end
/// of the line are put into the erased state
/// - 1 - the character positions from the beginning of the line up to and
///   including the active data position are put into the erased state
/// - 2 - all character positions of the line are put into the erased state
///
/// Whether the character positions of protected areas are put into the
/// erased state, or the character positions of unprotected areas only,
/// depends on the setting of the ERASURE MODE (ERM).
const String EL = 'K';

/// Insert Line.
///
/// Representation: CSI n \x4C
///
/// Parameter default value: n = 1
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, IL is
/// used to prepare the insertion of n lines, by putting into the erased
/// state in the presentation component the active line (the line that
/// contains the active presentation position) and, depending on the setting
/// of the LINE EDITING MODE (VEM), the n-1 preceding or following lines. The
/// previous contents of the active line and of adjacent lines are shifted
/// away from the active line. The contents of n lines at the other end of
/// the shifted part are removed. The active presentation position is
/// moved to the line home position in the active line. The line home
/// position is established by the parameter value of SET LINE HOME (SLH).
///
/// The extent of the shifted part is established by SELECT EDITING EXTENT
/// (SEE).
///
/// Any occurrences of the start or end of a selected area, the start or end
/// of a qualified area, or a tabulation stop in the shifted part, are also
/// shifted.
///
/// If the TABULATION STOP MODE (TSM) is set to SINGLE, character tabulation
/// stops are cleared in the lines that are put into the erased state.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, IL is used to
/// prepare the insertion of n lines, by putting into the erased state in the
/// data component the active line (the line that contains the active data
/// position) and, depending on the setting of the LINE EDITING MODE (VEM),
/// the n-1 preceding or following lines. The previous contents of the active
/// line and of adjacent lines are shifted away from the active line. The
/// contents of n lines at the other end of the shifted part are removed. The
/// active data position is moved to the line home position in the active
/// line. The line home position is established by the parameter value of SET
/// LINE HOME (SLH).
const String IL = 'L';

/// Delete Line.
///
/// Representation: CSI n \x4D
///
/// Parameter default value: n = 1
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, DL
/// causes the contents of the active line (the line that contains the active
/// presentation position) and, depending on the setting of the LINE EDITING
/// MODE (VEM), the contents of the n-1 preceding or following lines to be
/// removed from the presentation component. The resulting gap is closed by
/// shifting the contents of a number of adjacent lines towards the active
/// line. At the other end of the shifted part, n lines are put into the
/// erased state.
///
/// The active presentation position is moved to the line home position in
/// the active line. The line home position is established by the parameter
/// value of SET LINE HOME (SLH). If the TABULATION STOP MODE (TSM) is set to
/// SINGLE, character tabulation stops are cleared in the lines that are put
/// into the erased state.
///
/// The extent of the shifted part is established by SELECT EDITING EXTENT
/// (SEE).
///
/// Any occurrences of the start or end of a selected area, the start or end
/// of a qualified area, or a tabulation stop in the shifted part, are also
/// shifted.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, DL causes the
/// contents of the active line (the line that contains the active data
/// position) and, depending on the setting of the LINE EDITING MODE (VEM),
/// the contents of the n-1 preceding or following lines to be removed from
/// the data component. The resulting gap is closed by shifting the contents
/// of a number of adjacent lines towards the active line. At the other end
/// of the shifted part, n lines are put into the erased state. The active
/// data position is moved to the line home position in the active line. The
/// line home position is established by the parameter value of SET LINE HOME
/// (SLH).
const String DL = 'M';

/// Erase In Field.
///
/// Representation: CSI s \x4E
///
/// Parameter default value: s = 0
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, EF
/// causes some or all character positions of the active field (the field
/// which contains the active presentation position in the presentation
/// component) to be put into the erased state, depending on the parameter
/// values:
///
/// - 0 - the active presentation position and the character positions up to
///   the end of the field are put into the erased state
/// - 1 - the character positions from the beginning of the field up to and
///   including the active presentation position are put into the erased
///   state
///
/// - 2 - all character positions of the field are put into the erased state
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, EF causes some
/// or all character positions of the active field (the field which contains
/// the active data position in the data component) to be put into the erased
/// state, depending on the parameter values:
///
/// - 0 - the active data position and the character positions up to the end
///   of the field are put into the erased state
/// - 1 - the character positions from the beginning of the field up to and
///   including the active data position are put into the erased state
/// - 2 - all character positions of the field are put into the erased state
///
/// Whether the character positions of protected areas are put into the
/// erased state, or the character positions of unprotected areas only,
/// depends on the setting of the ERASURE MODE (ERM).
const String EF = 'N';

/// Erase In Area.
///
/// Representation: CSI s \x4F
///
/// Parameter default value: s = 0
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, EA
/// causes some or all character positions in the active qualified area (the
/// qualified area in the presentation component which contains the active
/// presentation position) to be put into the erased state, depending on the
/// parameter values:
///
/// - 0 - the active presentation position and the character positions up to
///   the end of the qualified area are put into the erased state
/// - 1 - the character positions from the beginning of the qualified area up
///   to and including the active presentation position are put into the
///   erased state
/// - 2 - all character positions of the qualified area are put into the
///   erased state
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, EA causes some
/// or all character positions in the active qualified area (the qualified
/// area in the data component which contains the active data position) to be
/// put into the erased state, depending on the parameter values:
///
/// - 0 - the active data position and the character positions up to the end
///   of the qualified area are put into the erased state
/// - 1 - the character positions from the beginning of the qualified area up
///   to and including the active data position are put into the erased state
/// - 2 - all character positions of the qualified area are put into the
///   erased state
///
/// Whether the character positions of protected areas are put into the
/// erased state, or the character positions of unprotected areas only,
/// depends on the setting of the ERASURE MODE (ERM).
const String EA = 'O';

/// Delete Character.
///
/// Representation: CSI n \x50
///
/// Parameter default value: n = 1
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, DCH
/// causes the contents of the active presentation position and, depending on
/// the setting of the CHARACTER EDITING MODE (HEM), the contents of the n-1
/// preceding or following character positions to be removed from the
/// presentation component. The resulting gap is closed by shifting the
/// contents of the adjacent character positions towards the active
/// presentation position. At the other end of the shifted part, n character
/// positions are put into the erased state.
///
/// The extent of the shifted part is established by SELECT EDITING EXTENT
/// (SEE).
///
/// The effect of DCH on the start or end of a selected area, the start or
/// end of a qualified area, or a tabulation stop in the shifted part is not
/// defined by Standard.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, DCH causes the
/// contents of the active data position and, depending on the setting of the
/// CHARACTER EDITING MODE (HEM), the contents of the n-1 preceding or
/// following character positions to be removed from the data component. The
/// resulting gap is closed by shifting the contents of the adjacent
/// character positions towards the active data position. At the other end of
/// the shifted part, n character positions are put into the erased state.
const String DCH = 'P';

/// Select Editing Extent.
///
/// Representation: CSI s \x51
///
/// Parameter default value: s = 0
///
/// SEE is used to establish the editing extent for subsequent character or
/// line insertion or deletion. The established extent remains in effect
/// until the next occurrence of SEE in the data stream. The editing extent
/// depends on the parameter value:
///
/// - 0 - the shifted part is limited to the active page in the presentation
///   component
/// - 1 - the shifted part is limited to the active line in the presentation
///   component
/// - 2 - the shifted part is limited to the active field in the presentation
///   component
/// - 3 - the shifted part is limited to the active qualified area
/// - 4 - the shifted part consists of the relevant part of the entire
///   presentation component
const String SEE = 'Q';

/// Active Position Report.
///
/// Representation: CSI n;m \x52
///
/// Parameter default values: n = 1; m = 1
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, CPR is
/// used to report the active presentation position of the sending device as
/// residing in the presentation component at the n-th line position
/// according to the line progression and at the m-th character position
/// according to the character path.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, CPR is used to
/// report the active data position of the sending device as residing in the
/// data component at the n-th line position according to the line
/// progression and at the m-th character position according to the character
/// progression.
///
/// CPR may be solicited by a DEVICE STATUS REPORT (DSR) or be sent
/// unsolicited.
const String CPR = 'R';

/// Scroll Up.
///
/// Representation: CSI n \x53
///
/// Parameter default value: n = 1
///
/// SU causes the data in the presentation component to be moved by n line
/// positions if the line orientation is horizontal, or by n character
/// positions if the line orientation is vertical, such that the data appear
/// to move up.
///
/// The active presentation position is not affected by this control
/// function.
const String SU = 'S';

/// Scroll Down.
///
/// Representation: CSI n \x54
///
/// Parameter default value: n = 1
///
/// SD causes the data in the presentation component to be moved by n line
/// positions if the line orientation is horizontal, or by n character
/// positions if the line orientation is vertical, such that the data appear
/// to move down.
///
/// The active presentation position is not affected by this control
/// function.
const String SD = 'T';

/// Next Page.
///
/// Representation: CSI n \x55
///
/// Parameter default value: n = 1
///
/// NP causes the n-th following page in the presentation component to be
/// displayed.
///
/// The effect of this control function on the active presentation position
/// is not defined by Standard.
const String NP = 'U';

/// Preceding Page.
///
/// Representation: CSI n \x56
///
/// Parameter default value: n = 1
///
/// PP causes the n-th preceding page in the presentation component to be
/// displayed. The effect of this control function on the active presentation
/// position is not defined by Standard.
const String PP = 'V';

/// Cursor Tabulation Control.
///
/// Representation: CSI s \x57
///
/// Parameter default value: s = 0
///
/// CTC causes one or more tabulation stops to be set or cleared in the
/// presentation component, depending on the parameter values:
///
/// - 0 - a character tabulation stop is set at the active presentation
///   position
/// - 1 - a line tabulation stop is set at the active line (the line that
///   contains the active presentation position)
/// - 2 - the character tabulation stop at the active presentation position
///   is cleared
/// - 3 - the line tabulation stop at the active line is cleared
/// - 4 - all character tabulation stops in the active line are cleared
/// - 5 - all character tabulation stops are cleared
/// - 6 - all line tabulation stops are cleared
///
/// In the case of parameter values 0, 2 or 4 the number of lines affected
/// depends on the setting of the TABULATION STOP MODE (TSM).
const String CTC = 'W';

/// Erase Character.
///
/// Representation: CSI n \x58
///
/// Parameter default value: n = 1
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to PRESENTATION, ECH
/// causes the active presentation position and the n-1 following character
/// positions in the presentation component to be put into the erased state.
///
/// If the DEVICE COMPONENT SELECT MODE (DCSM) is set to DATA, ECH causes the
/// active data position and the n-1 following character positions in the
/// data component to be put into the erased state.
///
/// Whether the character positions of protected areas are put into the
/// erased state, or the character positions of unprotected areas only,
/// depends on the setting of the ERASURE MODE (ERM).
const String ECH = 'X';

/// Cursor Line Tabulation.
///
/// Representation: CSI n \x59
///
/// Parameter default value: n = 1
///
/// CVT causes the active presentation position to be moved to the
/// corresponding character position of the line corresponding to the n-th
/// following line tabulation stop in the presentation component.
const String CVT = 'Y';

/// Cursor Backward Tabulation.
///
/// Representation: CSI n \x5A
///
/// Parameter default value: n = 1
///
/// 'CBT' causes the active presentation position to be moved to the character
/// position corresponding to the n-th preceding character tabulation stop in
/// the presentation component, according to the character path.
const String CBT = 'Z';

/// Start Reversed String.
///
/// Representation: CSI s \x5B
///
/// Parameter default value: s = 0
///
/// SRS is used to establish in the data component the beginning and the end
/// of a string of characters as well as the direction of the string. This
/// direction is opposite to that currently established. The indicated string
/// follows the preceding text. The established character progression is not
/// affected.
///
/// The beginning of a reversed string is indicated by SRS with a parameter
/// value of 1. A reversed string may contain one or more nested strings.
/// These nested strings may be reversed strings the beginnings of which are
/// indicated by SRS with a parameter value of 1, or directed strings the
/// beginnings of which are indicated by START DIRECTED STRING (SDS) with
/// a parameter value not equal to 0. Every beginning of such a string
/// invokes the next deeper level of nesting.
///
/// The Standard does not define the location of the active data position
/// within any such nested string.
///
/// The end of a reversed string is indicated by SRS with a parameter value
/// of 0. Every end of such a string re-establishes the next higher level of
/// nesting (the one in effect prior to the string just ended). The direction
/// is re-established to that in effect prior to the string just ended. The
/// active data position is moved to the character position following the
/// characters of the string just ended.
///
/// The parameter values are:
///
/// - 0 - end of a reversed string; re-establish the previous direction
/// - 1 - beginning of a reversed string; reverse the direction.
///
/// NOTE 1
///
/// The effect of receiving a CVT, HT, SCP, SPD or VT control function within
/// an SRS string is not defined by Standard.
///
/// NOTE 2
///
/// The control functions for area definition (DAQ, EPA, ESA, SPA, SSA)
/// should not be used within an SRS string.
const String SRS = '[';

/// Parallel Texts.
///
/// Representation: CSI s \x5C
///
/// Parameter default value: s = 0
///
/// PTX is used to delimit strings of graphic characters that are
/// communicated one after another in the data stream but that are intended
/// to be presented in parallel with one another, usually in adjacent lines.
///
/// The parameter values are:
///
/// - 0 - end of parallel texts
/// - 1 - beginning of a string of principal parallel text
/// - 2 - beginning of a string of supplementary parallel text
/// - 3 - beginning of a string of supplementary Japanese phonetic annotation
/// - 4 - beginning of a string of supplementary Chinese phonetic annotation
/// - 5 - end of a string of supplementary phonetic annotations
///
/// PTX with a parameter value of 1 indicates the beginning of the string of
/// principal text intended to be presented in parallel with one or more
/// strings of supplementary text.
///
/// PTX with a parameter value of 2, 3 or 4 indicates the beginning of
/// a string of supplementary text that is intended to be presented in
/// parallel with either a string of principal text or the immediately
/// preceding string of supplementary text, if any; at the same time it
/// indicates the end of the preceding string of principal text or of the
/// immediately preceding string of supplementary text, if any. The end of
/// a string of supplementary text is indicated by a subsequent occurrence of
/// PTX with a parameter value other than 1.
///
/// PTX with a parameter value of 0 indicates the end of the strings of text
/// intended to be presented in parallel with one another.
///
/// NOTE
///
/// PTX does not explicitly specify the relative placement of the strings of
/// principal and supplementary parallel texts, or the relative sizes of
/// graphic characters in the strings of parallel text. A string of
/// supplementary text is normally presented in a line adjacent to the line
/// containing the string of principal text, or adjacent to the line
/// containing the immediately preceding string of supplementary text, if
/// any. The first graphic character of the string of principal text and the
/// first graphic character of a string of supplementary text are normally
/// presented in the same position of their respective lines. However,
/// a string of supplementary text longer (when presented) than the
/// associated string of principal text may be centred on that string. In the
/// case of long strings of text, such as paragraphs in different languages,
/// the strings may be presented in successive lines in parallel columns,
/// with their beginnings aligned with one another and the shorter of the
/// paragraphs followed by an appropriate amount of "white space".
///
/// Japanese phonetic annotation typically consists of a few half-size or
/// smaller Kana characters which indicate the pronunciation or
/// interpretation of one or more Kanji characters and are presented above
/// those Kanji characters if the character path is horizontal, or to the
/// right of them if the character path is vertical.
///
/// Chinese phonetic annotation typically consists of a few Pinyin characters
/// which indicate the pronunciation of one or more Hanzi characters and are
/// presented above those Hanzi characters. Alternatively, the Pinyin
/// characters may be presented in the same line as the Hanzi characters and
/// following the respective Hanzi characters. The Pinyin characters will
/// then be presented within enclosing pairs of parentheses.
const String PTX = r'\';

/// Start Directed String.
///
/// Representation: CSI s \x5D
///
/// Parameter default value: s = 0
///
/// SDS is used to establish in the data component the beginning and the end
/// of a string of characters as well as the direction of the string. This
/// direction may be different from that currently established. The indicated
/// string follows the preceding text. The established character progression
/// is not affected.
///
/// The beginning of a directed string is indicated by SDS with a parameter
/// value not equal to 0. A directed string may contain one or more nested
/// strings. These nested strings may be directed strings the beginnings of
/// which are indicated by SDS with a parameter value not equal to 0, or
/// reversed strings the beginnings of which are indicated by START REVERSED
/// STRING (SRS) with a parameter value of 1. Every beginning of such
/// a string invokes the next deeper level of nesting.
///
/// The Standard does not define the location of the active data position
/// within any such nested string.
///
/// The end of a directed string is indicated by SDS with a parameter value
/// of 0. Every end of such a string re-establishes the next higher level of
/// nesting (the one in effect prior to the string just ended). The direction
/// is re-established to that in effect prior to the string just ended. The
/// active data position is moved to the character position following the
/// characters of the string just ended.
///
/// The parameter values are:
///
/// - 0 - end of a directed string; re-establish the previous direction
/// - 1 - start of a directed string; establish the direction left-to-right
/// - 2 - start of a directed string; establish the direction right-to-left
///
/// NOTE 1
///
/// The effect of receiving a CVT, HT, SCP, SPD or VT control function within
/// an SDS string is not defined by Standard.
///
/// NOTE 2
///
/// The control functions for area definition (DAQ, EPA, ESA, SPA, SSA)
/// should not be used within an SDS string.
const String SDS = ']';

/// Select Implicit Movement Direction.
///
/// Representation: CSI s \x5E
///
/// Parameter default value: s = 0
///
/// SIMD is used to select the direction of implicit movement of the data
/// position relative to the character progression. The direction selected
/// remains in effect until the next occurrence of SIMD.
///
/// The parameter values are:
///
/// - 0 - the direction of implicit movement is the same as that of the
///   character progression
/// - 1 - the direction of implicit movement is opposite to that of the
///   character progression.
const String SIMD = '^';

const String RESERVED = '_';

/// Character Position Absolute.
///
/// Representation: CSI n \x60
///
/// Parameter default value: n = 1
///
/// HPA causes the active data position to be moved to character position n
/// in the active line (the line in the data component that contains the
/// active data position).
const String HPA = '`';

/// Character Position Forward.
///
/// Representation: CSI n \x61
///
/// Parameter default value: n = 1
///
/// HPR causes the active data position to be moved by n character positions
/// in the data component in the direction of the character progression.
const String HPR = 'a';

/// Repeat.
///
/// Representation: CSI n \x62
///
/// Parameter default value: n = 1
///
/// REP is used to indicate that the preceding character in the data stream,
/// if it is a graphic character (represented by one or more bytes) including
/// SPACE, is to be repeated n times. If the character preceding REP is
/// a control function or part of a control function, the effect of REP is
/// not defined by Standard.
const String REP = 'b';

/// Device Attributes.
///
/// Representation: CSI s \x63
///
/// Parameter default value: s = 0
///
/// With a parameter value not equal to 0, DA is used to identify the device
/// which sends the DA. The parameter value is a device type identification
/// code according to a register which is to be established. If the parameter
/// value is 0, DA is used to request an identifying DA from a device.
const String DA = 'c';

/// Line Position Absolute.
///
/// Representation: CSI n \x64
///
/// Parameter default value: n = 1
///
/// VPA causes the active data position to be moved to line position n in the
/// data component in a direction parallel to the line progression.
const String VPA = 'd';

/// Line Position Forward.
///
/// Representation: CSI n \x65
///
/// Parameter default value: n = 1
///
/// VPR causes the active data position to be moved by n line positions in
/// the data component in a direction parallel to the line progression.
const String VPR = 'e';

/// Character And Line Position.
///
/// Representation: CSI n;m \x66
///
/// Parameter default values: n = 1; m = 1
///
/// HVP causes the active data position to be moved in the data component to
/// the n-th line position according to the line progression and to the m-th
/// character position according to the character progression.
const String HVP = 'f';

/// Tabulation Clear.
///
/// Representation: CSI s \x67
///
/// Parameter default value: s = 0
///
/// TBC causes one or more tabulation stops in the presentation component to
/// be cleared, depending on the parameter value:
///
/// - 0 - the character tabulation stop at the active presentation position
///   is cleared
/// - 1 - the line tabulation stop at the active line is cleared
/// - 2 - all character tabulation stops in the active line are cleared
/// - 3 - all character tabulation stops are cleared
/// - 4 - all line tabulation stops are cleared
/// - 5 - all tabulation stops are cleared
///
/// In the case of parameter value 0 or 2 the number of lines affected
/// depends on the setting of the TABULATION STOP MODE (TSM)
const String TBC = 'g';

/// Set Mode.
///
/// Representation: CSI s... \x68
///
/// No parameter default value.
///
/// SM causes the modes of the receiving device to be set as specified by the
/// parameter values:
///
/// - 1 - GUARDED AREA TRANSFER MODE (GATM)
/// - 2 - KEYBOARD ACTION MODE (KAM)
/// - 3 - CONTROL REPRESENTATION MODE (CRM)
/// - 4 - INSERTION REPLACEMENT MODE (IRM)
/// - 5 - STATUS REPORT TRANSFER MODE (SRTM)
/// - 6 - ERASURE MODE (ERM)
/// - 7 - LINE EDITING MODE (VEM)
/// - 8 - BI-DIRECTIONAL SUPPORT MODE (BDSM)
/// - 9 - DEVICE COMPONENT SELECT MODE (DCSM)
/// - 10 - CHARACTER EDITING MODE (HEM)
/// - 11 - POSITIONING UNIT MODE (PUM)
/// - 12 - SEND/RECEIVE MODE (SRM)
/// - 13 - FORMAT EFFECTOR ACTION MODE (FEAM)
/// - 14 - FORMAT EFFECTOR TRANSFER MODE (FETM)
/// - 15 - MULTIPLE AREA TRANSFER MODE (MATM)
/// - 16 - TRANSFER TERMINATION MODE (TTM)
/// - 17 - SELECTED AREA TRANSFER MODE (SATM)
/// - 18 - TABULATION STOP MODE (TSM)
/// - 19 - (Shall not be used)
/// - 20 - (Shall not be used)
/// - 21 - GRAPHIC RENDITION COMBINATION (GRCM)
/// - 22 - ZERO DEFAULT MODE (ZDM)
///
/// NOTE
///
/// Private modes may be implemented using private parameters.
const String SM = 'h';

/// Media Copy.
///
/// Representation: CSI s \x69
///
/// Parameter default value: s = 0
///
/// MC is used either to initiate a transfer of data from or to an auxiliary
/// input/output device or to enable or disable the relay of the received
/// data stream to an auxiliary input/output device, depending on the
/// parameter value:
///
/// - 0 - initiate transfer to a primary auxiliary device
/// - 1 - initiate transfer from a primary auxiliary device
/// - 2 - initiate transfer to a secondary auxiliary device
/// - 3 - initiate transfer from a secondary auxiliary device
/// - 4 - stop relay to a primary auxiliary device
/// - 5 - start relay to a primary auxiliary device
/// - 6 - stop relay to a secondary auxiliary device
/// - 7 - start relay to a secondary auxiliary device
///
/// This control function may not be used to switch on or off an auxiliary
/// device.
const String MC = 'i';

/// Character Position Backward.
///
/// Representation: CSI n \x6A
///
/// Parameter default value: n = 1
///
/// HPB causes the active data position to be moved by n character positions
/// in the data component in the direction opposite to that of the character
/// progression.
const String HPB = 'j';

/// Line Position Backward.
///
/// Representation: CSI n \x6B
///
/// Parameter default value: n = 1
///
/// VPB causes the active data position to be moved by n line positions in
/// the data component in a direction opposite to that of the line
/// progression.
const String VPB = 'k';

/// Reset Mode.
///
/// Representation: CSI s... \x6C
///
/// No parameter default value.
///
/// RM causes the modes of the receiving device to be reset as specified by
/// the parameter values:
///
/// - 1 - GUARDED AREA TRANSFER MODE (GATM)
/// - 2 - KEYBOARD ACTION MODE (KAM)
/// - 3 - CONTROL REPRESENTATION MODE (CRM)
/// - 4 - INSERTION REPLACEMENT MODE (IRM)
/// - 5 - STATUS REPORT TRANSFER MODE (SRTM)
/// - 6 - ERASURE MODE (ERM)
/// - 7 - LINE EDITING MODE (VEM)
/// - 8 - BI-DIRECTIONAL SUPPORT MODE (BDSM)
/// - 9 - DEVICE COMPONENT SELECT MODE (DCSM)
/// - 10 - CHARACTER EDITING MODE (HEM)
/// - 11 - POSITIONING UNIT MODE (PUM)
/// - 12 - SEND/RECEIVE MODE (SRM)
/// - 13 - FORMAT EFFECTOR ACTION MODE (FEAM)
/// - 14 - FORMAT EFFECTOR TRANSFER MODE (FETM)
/// - 15 - MULTIPLE AREA TRANSFER MODE (MATM)
/// - 16 - TRANSFER TERMINATION MODE (TTM)
/// - 17 - SELECTED AREA TRANSFER MODE (SATM)
/// - 18 - TABULATION STOP MODE (TSM)
/// - 19 - (Shall not be used)
/// - 20 - (Shall not be used)
/// - 21 - GRAPHIC RENDITION COMBINATION MODE (GRCM)
/// - 22 - ZERO DEFAULT MODE (ZDM)
///
/// NOTE
///
/// Private modes may be implemented using private parameters.
const String RM = 'l';

/// Select Graphic Rendition.
///
/// Representation: CSI s... \x6D
///
/// Parameter default value: s = 0
///
/// SGR is used to establish one or more graphic rendition aspects for
/// subsequent text. The established aspects remain in effect until the next
/// occurrence of SGR in the data stream, depending on the setting of the
/// GRAPHIC RENDITION COMBINATION MODE (GRCM). Each graphic rendition aspect
/// is specified by a parameter value:
///
/// - 0 - default rendition (implementation-defined), cancels the effect of
///   any preceding occurrence of SGR in the data stream regardless of the
///   setting of the GRAPHIC RENDITION COMBINATION MODE (GRCM)
/// - 1 - bold or increased intensity
/// - 2 - faint, decreased intensity or second colour
/// - 3 - italicized
/// - 4 - singly underlined
/// - 5 - slowly blinking (less then 150 per minute)
/// - 6 - rapidly blinking (150 per minute or more)
/// - 7 - negative image
/// - 8 - concealed characters
/// - 9 - crossed-out (characters still legible but marked as to be deleted)
/// - 10 - primary (default) font
/// - 11 - first alternative font
/// - 12 - second alternative font
/// - 13 - third alternative font
/// - 14 - fourth alternative font
/// - 15 - fifth alternative font
/// - 16 - sixth alternative font
/// - 17 - seventh alternative font
/// - 18 - eighth alternative font
/// - 19 - ninth alternative font
/// - 20 - Fraktur (Gothic)
/// - 21 - doubly underlined
/// - 22 - normal colour or normal intensity (neither bold nor faint)
/// - 23 - not italicized, not fraktur
/// - 24 - not underlined (neither singly nor doubly)
/// - 25 - steady (not blinking)
/// - 26 - (reserved for proportional spacing as specified in CCITT
///   Recommendation T.61)
/// - 27 - positive image
/// - 28 - revealed characters
/// - 29 - not crossed out
/// - 30 - black display
/// - 31 - red display
/// - 32 - green display
/// - 33 - yellow display
/// - 34 - blue display
/// - 35 - magenta display
/// - 36 - cyan display
/// - 37 - white display
/// - 38 - (reserved for future standardization; intended for setting
///   character foreground colour as specified in ISO - 8613-6 (CCITT
///   Recommendation T.416))
/// - 39 - default display colour (implementation-defined)
/// - 40 - black background
/// - 41 - red background
/// - 42 - green background
/// - 43 - yellow background
/// - 44 - blue background
/// - 45 - magenta background
/// - 46 - cyan background
/// - 47 - white background
/// - 48 - (reserved for future standardization; intended for setting
///   character background colour as specified in ISO 8613-6 (CCITT
///   Recommendation T.416))
/// - 49 - default background colour (implementation-defined)
/// - 50 - (reserved for cancelling the effect of the rendering aspect
///   established by parameter value 26)
/// - 51 - framed
/// - 52 - encircled
/// - 53 - overlined
/// - 54 - not framed, not encircled
/// - 55 - not overlined
/// - 56 - (reserved for future standardization)
/// - 57 - (reserved for future standardization)
/// - 58 - (reserved for future standardization)
/// - 59 - (reserved for future standardization)
/// - 60 - ideogram underline or right side line
/// - 61 - ideogram double underline or double line on the right side
/// - 62 - ideogram overline or left side line
/// - 63 - ideogram double overline or double line on the left side
/// - 64 - ideogram stress marking
/// - 65 - cancels the effect of the rendition aspects established by
///   parameter values 60 to 64
///
/// NOTE
///
/// The usable combinations of parameter values are determined by the
/// implementation.
///
/// See also:
/// https://invisible-island.net/xterm/ctlseqs/ctlseqs.html
const String SGR = 'm';

/// Device Status Report.
///
/// Representation: CSI s \x6E
///
/// Parameter default value: s = 0
///
/// DSR is used either to report the status of the sending device or to
/// request a status report from the receiving device, depending on the
/// parameter values:
///
/// - 0 - ready, no malfunction detected
/// - 1 - busy, another DSR must be requested later
/// - 2 - busy, another DSR will be sent later
/// - 3 - some malfunction detected, another DSR must be requested later
/// - 4 - some malfunction detected, another DSR will be sent later
/// - 5 - a DSR is requested
/// - 6 - a report of the active presentation position or of the active data
///   position in the form of ACTIVE POSITION REPORT (CPR) is requested
///
/// DSR with parameter value 0, 1, 2, 3 or 4 may be sent either unsolicited
/// or as a response to a request such as a DSR with a parameter value 5 or
/// MESSAGE WAITING (MW).
const String DSR = 'n';

/// Define Area Qualification.
///
/// Representation: CSI s \x6F
///
/// Parameter default value: s = 0
///
/// DAQ is used to indicate that the active presentation position in the
/// presentation component is the first character position of a qualified
/// area. The last character position of the qualified area is the character
/// position in the presentation component immediately preceding the first
/// character position of the following qualified area.
///
/// The parameter value designates the type of qualified area:
///
/// - 0 - unprotected and unguarded
/// - 1 - protected and guarded
/// - 2 - graphic character input
/// - 3 - numeric input
/// - 4 - alphabetic input
/// - 5 - input aligned on the last character position of the qualified area
/// - 6 - fill with ZEROs
/// - 7 - set a character tabulation stop at the active presentation position
///   (the first character position of the qualified area) to indicate the
///   beginning of a field
/// - 8 - protected and unguarded
/// - 9 - fill with SPACEs
/// - 10 - input aligned on the first character position of the qualified
///   area
/// - 11 - the order of the character positions in the input field is
///   reversed, i.e. the last position in each line becomes the first and
///   vice versa; input begins at the new first position.
///
/// This control function operates independently of the setting of the
/// TABULATION STOP MODE (TSM). The character tabulation stop set by
/// parameter value 7 applies to the active line only.
///
/// NOTE
///
/// The control functions for area definition (DAQ, EPA, ESA, SPA, SSA)
/// should not be used within an SRS string or an SDS string.
const String DAQ = 'o';

const String PRIVATEUSE_70 = 'p';
const String PRIVATEUSE_71 = 'q';
const String PRIVATEUSE_72 = 'r';

/// Save Cursor (not standart).
const String SAVE_CURSOR = 's';

const String PRIVATEUSE_74 = 't';

/// Restore Cursor (not standart).
const String RESTORE_CURSOR = 'u';

// Final Bytes of control sequences with a single Intermediate Byte 0x20.

/// Scroll Left.
///
/// Representation: CSI n \x20 \x40
///
/// Parameter default value: n = 1
///
/// SL causes the data in the presentation component to be moved by n
/// character positions if the line orientation is horizontal, or by n line
/// positions if the line orientation is vertical, such that the data appear
/// to move to the left.
///
/// The active presentation position is not affected by this control
/// function.
const String SL = ' @';

/// Scroll Right.
///
/// Representation: CSI n \x20 \x41
///
/// Parameter default value: n = 1
///
/// SR causes the data in the presentation component to be moved by n
/// character positions if the line orientation is horizontal, or by n line
/// positions if the line orientation is vertical, such that the data appear
/// to move to the right.
///
/// The active presentation position is not affected by this control
/// function.
const String SR = ' A';

/// Graphic Size Modification.
///
/// Representation: CSI n1;n2 \x20 \x42
///
/// Parameter default values: n1 = 100; n2 = 100
///
/// GSM is used to modify for subsequent text the height and/or the width of
/// all primary and alternative fonts identified by FONT SELECTION (FNT) and
/// established by GRAPHIC SIZE SELECTION (GSS). The established values
/// remain in effect until the next occurrence of GSM or GSS in the data
/// steam.
///
/// n1 specifies the height as a percentage of the height established by GSS.
/// n2 specifies the width as a percentage of the width established by GSS.
const String GSM = ' B';

/// Graphic Size Selection.
///
/// Representation: CSI n \x20 \x43
///
/// No parameter default value.
///
/// GSS is used to establish for subsequent text the height and the width of
/// all primary and alternative fonts identified by FONT SELECTION (FNT). The
/// established values remain in effect until the next occurrence of GSS in
/// the data stream.
///
/// n specifies the height, the width is implicitly defined by the height.
///
/// The unit in which the parameter value is expressed is that established by
/// the parameter value of SELECT SIZE UNIT (SSU).
const String GSS = ' C';

/// Font Selection.
///
/// Representation: CSI s1;s2 \x20 \x44
///
/// Parameter default values: s1 = 0; s2 = 0
///
/// FNT is used to identify the character font to be selected as primary or
/// alternative font by subsequent occurrences of SELECT GRAPHIC RENDITION
/// (SGR) in the data stream. s1 specifies the primary or alternative font
/// concerned:
///
/// - 0 - primary font
/// - 1 - first alternative font
/// - 2 - second alternative font
/// - 3 - third alternative font
/// - 4 - fourth alternative font
/// - 5 - fifth alternative font
/// - 6 - sixth alternative font
/// - 7 - seventh alternative font
/// - 8 - eighth alternative font
/// - 9 - ninth alternative font
///
/// s2 identifies the character font according to a register which is to be
/// established.
const String FNT = ' D';

/// Thin Space Specification.
///
/// Representation: CSI n \x20 \x45
///
/// No parameter default value.
///
/// TSS is used to establish the width of a thin space for subsequent text.
/// The established width remains in effect until the next occurrence of TSS
/// in the data stream.
///
/// n specifies the width of the thin space.
///
/// The unit in which the parameter value is expressed is that established by
/// the parameter value of SELECT SIZE UNIT (SSU).
const String TSS = ' E';

/// Justify.
///
/// Representation: CSI s... \x20 \x46
///
/// Parameter default value: s = 0
///
/// JFY is used to indicate the beginning of a string of graphic characters
/// in the presentation component that are to be justified according to the
/// layout specified by the parameter values:
///
/// - 0 - no justification, end of justification of preceding text
/// - 1 - word fill
/// - 2 - word space
/// - 3 - letter space
/// - 4 - hyphenation
/// - 5 - flush to line home position margin
/// - 6 - centre between line home position and line limit position margins
/// - 7 - flush to line limit position margin
/// - 8 - Italian hyphenation
///
/// The end of the string to be justified is indicated by the next occurrence
/// of JFY in the data stream.
///
/// The line home position is established by the parameter value of SET LINE
/// HOME (SLH). The line limit position is established by the parameter value
/// of SET LINE LIMIT (SLL).
const String JFY = ' F';

/// Spacing Increment.
///
/// Representation: CSI n1;n2 \x20 \x47
///
/// No parameter default values.
///
/// SPI is used to establish the line spacing and the character spacing for
/// subsequent text. The established line spacing remains in effect until the
/// next occurrence of SPI or of SET LINE SPACING (SLS) or of SELECT LINE
/// SPACING (SVS) in the data stream. The established character spacing
/// remains in effect until the next occurrence of SET CHARACTER SPACING
/// (SCS) or of SELECT CHARACTER SPACING (SHS) in the data stream.
///
/// n1 specifies the line spacing. n2 specifies the character spacing.
///
/// The unit in which the parameter values are expressed is that established
/// by the parameter value of SELECT SIZE UNIT (SSU).
const String SPI = ' G';

/// Quad.
///
/// Representation: CSI s... \x20 \x48
///
/// Parameter default value: s = 0
///
/// QUAD is used to indicate the end of a string of graphic characters that
/// are to be positioned on a single line according to the layout specified
/// by the parameter values:
///
/// - 0 - flush to line home position margin
/// - 1 - flush to line home position margin and fill with leader
/// - 2 - centre between line home position and line limit position margins
/// - 3 - centre between line home position and line limit position margins
///   and fill with leader
/// - 4 - flush to line limit position margin
/// - 5 - flush to line limit position margin and fill with leader
/// - 6 - flush to both margins
///
/// The beginning of the string to be positioned is indicated by the
/// preceding occurrence in the data stream of either QUAD or one of the
/// following formator functions: FORM FEED (FF), CHARACTER AND LINE POSITION
/// (HVP), LINE FEED (LF), NEXT LINE (NEL), PAGE POSITION ABSOLUTE (PPA),
/// PAGE POSITION BACKWARD (PPB), PAGE POSITION FORWARD (PPR), REVERSE LINE
/// FEED (RI), LINE POSITION ABSOLUTE (VPA), LINE POSITION BACKWARD (VPB),
/// LINE POSITION FORWARD (VPR), or LINE TABULATION (VT).
///
/// The line home position is established by the parameter value of SET LINE
/// HOME (SLH). The line limit position is established by the parameter value
/// of SET LINE LIMIT (SLL).
const String QUAD = ' H';

/// Select Size Unit.
///
/// Representation: CSI s \x20 \x49
///
/// Parameter default value: s = 0
///
/// SSU is used to establish the unit in which the numeric parameters of
/// certain control functions are expressed. The established unit remains in
/// effect until the next occurrence of SSU in the data stream.
///
/// The parameter values are:
///
/// - 0 - CHARACTER - The dimensions of this unit are device-dependent
/// - 1 - MILLIMETRE
/// - 2 - COMPUTER DECIPOINT - 0,035 28 mm (1/720 of 25,4 mm)
/// - 3 - DECIDIDOT - 0,037 59 mm (10/266 mm)
/// - 4 - MIL - 0,025 4 mm (1/1 000 of 25,4 mm)
/// - 5 - BASIC MEASURING UNIT (BMU) - 0,021 17 mm (1/1 200 of 25,4 mm)
/// - 6 - MICROMETRE - 0,001 mm
/// - 7 - PIXEL - The smallest increment that can be specified in a device
/// - 8 - DECIPOINT - 0,035 14 mm (35/996 mm)
const String SSU = ' I';

/// Page Format Selection.
///
/// Representation: CSI s \x20 \x4A
///
/// Parameter default value: s = 0
///
/// PFS is used to establish the available area for the imaging of pages of
/// text based on paper size. The pages are introduced by the subsequent
/// occurrence of FORM FEED (FF) in the data stream.
///
/// The established image area remains in effect until the next occurrence of
/// PFS in the data stream. The parameter values are:
///
/// - 0 - tall basic text communication format
/// - 1 - wide basic text communication format
/// - 2 - tall basic A4 format
/// - 3 - wide basic A4 format
/// - 4 - tall North American letter format
/// - 5 - wide North American letter format
/// - 6 - tall extended A4 format
/// - 7 - wide extended A4 format
/// - 8 - tall North American legal format
/// - 9 - wide North American legal format
/// - 10 - A4 short lines format
/// - 11 - A4 long lines format
/// - 12 - B5 short lines format
/// - 13 - B5 long lines format
/// - 14 - B4 short lines format
/// - 15 - B4 long lines format
///
/// The page home position is established by the parameter value of SET PAGE
/// HOME (SPH), the page limit position is established by the parameter value
/// of SET PAGE LIMIT (SPL).
const String PFS = ' J';

/// Select Character Spacing.
///
/// Representation: CSI s \x20 \x4B
///
/// Parameter default value: s = 0
///
/// SHS is used to establish the character spacing for subsequent text. The
/// established spacing remains in effect until the next occurrence of SHS or
/// of SET CHARACTER SPACING (SCS) or of SPACING INCREMENT (SPI) in the data
/// stream. The parameter values are:
///
/// - 0 - 10 characters per 25,4 mm
/// - 1 - 12 characters per 25,4 mm
/// - 2 - 15 characters per 25,4 mm
/// - 3 - 6 characters per 25,4 mm
/// - 4 - 3 characters per 25,4 mm
/// - 5 - 9 characters per 50,8 mm
/// - 6 - 4 characters per 25,4 mm
const String SHS = ' K';

/// Select Line Spacing.
///
/// Representation: CSI s \x20 \x4C
///
/// Parameter default value: s = 0
///
/// SVS is used to establish the line spacing for subsequent text. The
/// established spacing remains in effect until the next occurrence of SVS or
/// of SET LINE SPACING (SLS) or of SPACING INCREMENT (SPI) in the data
/// stream. The parameter values are:
///
/// - 0 - 6 lines per 25,4 mm
/// - 1 - 4 lines per 25,4 mm
/// - 2 - 3 lines per 25,4 mm
/// - 3 - 12 lines per 25,4 mm
/// - 4 - 8 lines per 25,4 mm
/// - 5 - 6 lines per 30,0 mm
/// - 6 - 4 lines per 30,0 mm
/// - 7 - 3 lines per 30,0 mm
/// - 8 - 12 lines per 30,0 mm
/// - 9 - 2 lines per 25,4 mm
const String SVS = ' L';

/// Identify Graphic Subrepertoire.
///
/// Representation: CSI s \x20 \x4D
///
/// No parameter default value.
///
/// IGS is used to indicate that a repertoire of the graphic characters of
/// ISO/IEC 10367 is used in the subsequent text.
///
/// The parameter value of IGS identifies a graphic character repertoire
/// registered in accordance with ISO/IEC 7350.
const String IGS = ' M';

const String RESERVED_20_4E = ' N';

/// Identify Device Control String.
///
/// Representation: CSI s \x20 \x4F
///
/// No parameter default value.
///
/// IDCS is used to specify the purpose and format of the command string of
/// subsequent DEVICE CONTROL STRINGs (DCS). The specified purpose and format
/// remain in effect until the next occurrence of IDCS in the data stream.
///
/// The parameter values are:
///
/// - 1 - reserved for use with the DIAGNOSTIC state of the STATUS REPORT
///   TRANSFER MODE (SRTM)
/// - 2 - reserved for Dynamically Redefinable Character Sets (DRCS)
///   according to Standard ECMA-35.
///
/// The format and interpretation of the command string corresponding to
/// these parameter values are to be defined in appropriate standards. If
/// this control function is used to identify a private command string, a
/// private parameter value shall be used.
const String IDCS = ' O';

/// Page Position Absolute.
///
/// Representation: CSI n \x20 \x50
///
/// Parameter default value: n = 1
///
/// PPA causes the active data position to be moved in the data component to
/// the corresponding character position on the n-th page.
const String PPA = ' P';

/// Page Position Forward.
///
/// Representation: CSI n \x20 \x51
///
/// Parameter default value: n = 1
///
/// PPR causes the active data position to be moved in the data component to
/// the corresponding character position on the n-th following page.
const String PPR = ' Q';

/// Page Position Backward.
///
/// Representation: CSI n \x20 \x52
///
/// Parameter default value: n = 1
///
/// PPB causes the active data position to be moved in the data component to
/// the corresponding character position on the n-th preceding page.
const String PPB = ' R';

/// Select Presentation Directions.
///
/// Representation: CSI s1;s2 \x20 \x53
///
/// Parameter default value: s1 = 0; s2 = 0
///
/// SPD is used to select the line orientation, the line progression, and the
/// character path in the presentation component. It is also used to update
/// the content of the presentation component and the content of the data
/// component. This takes effect immediately.
///
/// s1 specifies the line orientation, the line progression and the character
/// path:
///
/// - 0 - line orientation: horizontal, line progression: top-to-bottom,
///   character path: left-to-right
/// - 1 - line orientation: vertical, line progression: right-to-left,
///   character path: top-to-bottom
/// - 2 - line orientation: vertical, line progression: left-to-right,
///   character path: top-to-bottom
/// - 3 - line orientation: horizontal, line progression: top-to-bottom,
///   character path: right-to-left
/// - 4 - line orientation: vertical, line progression: left-to-right,
///   character path: bottom-to-top
/// - 5 - line orientation: horizontal, line progression: bottom-to-top,
///   character path: right-to-left
/// - 6 - line orientation: horizontal, line progression: bottom-to-top,
///   character path: left-to-right
/// - 7 - line orientation: vertical, line progression: right-to-left,
///   character path: bottom-to-top
///
/// s2 specifies the effect on the content of the presentation component and
/// the content of the data component:
///
/// - 0 - undefined (implementation-dependent)
///
///   NOTE
///
///   This may also permit the effect to take place after the next occurrence
///   of CR, FF or any control function which initiates an absolute movement
///   of the active presentation position or the active data position.
///
/// - 1 - the content of the presentation component is updated to correspond
///   to the content of the data component according to the newly established
///   characteristics of the presentation component; the active data position
///   is moved to the first character position in the first line in the data
///   component, the active presentation position in the presentation
///   component is updated accordingly
/// - 2 - the content of the data component is updated to correspond to the
///   content of the presentation component according to the newly
///   established characteristics of the presentation component; the active
///   presentation position is moved to the first character position in the
///   first line in the presentation component, the active data position in
///   the data component is updated accordingly.
const String SPD = ' S';

/// Dimension Text Area.
///
/// Representation: CSI n1;n2 \x20 \x54
///
/// No parameter default value.
///
/// DTA is used to establish the dimensions of the text area for subsequent
/// pages.
///
/// The established dimensions remain in effect until the next occurrence of
/// DTA in the data stream.
///
/// n1 specifies the dimension in the direction perpendicular to the line
/// orientation. n2 - specifies the dimension in the direction parallel to
/// the line orientation.
///
/// The unit in which the parameter value is expressed is that established by
/// the parameter value of SELECT SIZE UNIT (SSU).
const String DTA = ' T';

/// Set Line Home.
///
/// Representation: CSI n \x20 \x55
///
/// No parameter default value.
///
/// If the DEVICE COMPONENT SELECT MODE is set to PRESENTATION, SLH is used
/// to establish at character position n in the active line (the line that
/// contains the active presentation position) and lines of subsequent text
/// in the presentation component the position to which the active
/// presentation position will be moved by subsequent occurrences of CARRIAGE
/// RETURN (CR), DELETE LINE (DL), INSERT LINE (IL) or NEXT LINE (NEL) in the
/// data stream. In the case of a device without data component, it is also
/// the position ahead of which no implicit movement of the active
/// presentation position shall occur.
///
/// If the DEVICE COMPONENT SELECT MODE is set to DATA, SLH is used to
/// establish at character position n in the active line (the line that
/// contains the active data position) and lines of subsequent text in the
/// data component the position to which the active data position will be
/// moved by subsequent occurrences of CARRIAGE RETURN (CR), DELETE LINE
/// (DL), INSERT LINE (IL) or NEXT LINE (NEL) in the data stream. It is also
/// the position ahead of which no implicit movement of the active data
/// position shall occur.
///
/// The established position is called the line home position and remains in
/// effect until the next occurrence of SLH in the data stream.
const String SLH = ' U';

/// Set Line Limit.
///
/// Representation: CSI n \x20 \x56
///
/// No parameter default value.
///
/// If the DEVICE COMPONENT SELECT MODE is set to PRESENTATION, SLL is used
/// to establish at character position n in the active line (the line that
/// contains the active presentation position) and lines of subsequent text
/// in the presentation component the position to which the active
/// presentation position will be moved by subsequent occurrences of CARRIAGE
/// RETURN (CR), or NEXT LINE (NEL) in the data stream if the parameter value
/// of SELECT IMPLICIT MOVEMENT DIRECTION (SIMD) is equal to 1. In the case
/// of a device without data component, it is also the position beyond which
/// no implicit movement of the active presentation position shall occur.
///
/// If the DEVICE COMPONENT SELECT MODE is set to DATA, SLL is used to
/// establish at character position n in the active line (the line that
/// contains the active data position) and lines of subsequent text in the
/// data component the position beyond which no implicit movement of the
/// active data position shall occur. It is also the position in the data
/// component to which the active data position will be moved by subsequent
/// occurrences of CR or NEL in the data stream, if the parameter value of
/// SELECT IMPLICIT MOVEMENT DIRECTION (SIMD) is equal to 1.
///
/// The established position is called the line limit position and remains in
/// effect until the next occurrence of SLL in the data stream.
const String SLL = ' V';

/// Function Key.
///
/// Representation: CSI n \x20 \x57
///
/// No parameter default value.
///
/// FNK is a control function in which the parameter value identifies the
/// function key which has been operated.
const String FNK = ' W';

/// Select Print Quality And Rapidity.
///
/// Representation: CSI s \x20 \x58
///
/// Parameter default value: s = 0
///
/// SPQR is used to select the relative print quality and the print speed for
/// devices the output quality and speed of which are inversely related. The
/// selected values remain in effect until the next occurrence of SPQR in the
/// data stream. The parameter values are:
///
/// - 0 - highest available print quality, low print speed
/// - 1 - medium print quality, medium print speed
/// - 2 - draft print quality, highest available print speed
const String SPQR = ' X';

/// Sheet Eject And Feed.
///
/// Representation: CSI s1;s2 \x20 \x59
///
/// Parameter default values: s1 = 0; s2 = 0
///
/// SEF causes a sheet of paper to be ejected from a printing device into
/// a specified output stacker and another sheet to be loaded into the
/// printing device from a specified paper bin.
///
/// Parameter values of s1 are:
///
/// - 0 - eject sheet, no new sheet loaded
/// - 1 - eject sheet and load another from bin 1
/// - 2 - eject sheet and load another from bin 2
/// ...
/// - n - eject sheet and load another from bin n
///
/// Parameter values of s2 are:
///
/// - 0 - eject sheet, no stacker specified
/// - 1 - eject sheet into stacker 1
/// - 2 - eject sheet into stacker 2
/// ...
/// - n - eject sheet into stacker n
const String SEF = ' Y';

/// Presentation Expand Or Contract.
///
/// Representation: CSI s \x20 \x5A
///
/// Parameter default value: s = 0
///
/// PEC is used to establish the spacing and the extent of the graphic
/// characters for subsequent text. The spacing is specified in the line as
/// multiples of the spacing established by the most recent occurrence of
/// SET CHARACTER SPACING (SCS) or of SELECT CHARACTER SPACING (SHS) or of
/// SPACING INCREMENT (SPI) in the data stream. The extent of the characters
/// is implicitly established by these control functions. The established
/// spacing and the extent remain in effect until the next occurrence of PEC,
/// of SCS, of SHS or of SPI in the data stream. The parameter values are:
///
/// - 0 - normal (as specified by SCS, SHS or SPI)
/// - 1 - expanded (multiplied by a factor not greater than 2)
/// - 2 - condensed (multiplied by a factor not less than 0,5)
const String PEC = ' Z';

/// Set Space Width.
///
/// Representation: CSI n \x20 \x5B
///
/// No parameter default value.
///
/// SSW is used to establish for subsequent text the character escapement
/// associated with the character SPACE. The established escapement remains
/// in effect until the next occurrence of SSW in the data stream or until it
/// is reset to the default value by a subsequent occurrence of CARRIAGE
/// RETURN/LINE FEED (CR/LF), CARRIAGE RETURN/FORM FEED (CR/FF), or of NEXT
/// LINE (NEL) in the data stream.
///
/// n specifies the escapement.
///
/// The unit in which the parameter value is expressed is that established by
/// the parameter value of SELECT SIZE UNIT (SSU).
///
/// The default character escapement of SPACE is specified by the most recent
/// occurrence of SET CHARACTER SPACING (SCS) or of SELECT CHARACTER SPACING
/// (SHS) or of SELECT SPACING INCREMENT (SPI) in the data stream if the
/// current font has constant spacing, or is specified by the nominal width
/// of the character SPACE in the current font if that font has proportional
/// spacing.
const String SSW = ' [';

/// Set Additional Character Separation.
///
/// Representation: CSI n \x20 \x5C
///
/// Parameter default value: n = 0
///
/// SACS is used to establish extra inter-character escapement for subsequent
/// text. The established extra escapement remains in effect until the next
/// occurrence of SACS or of SET REDUCED CHARACTER SEPARATION (SRCS) in the
/// data stream or until it is reset to the default value by a subsequent
/// occurrence of CARRIAGE RETURN/LINE FEED (CR LF) or of NEXT LINE (NEL) in
/// the data stream.
///
/// n specifies the number of units by which the inter-character escapement
/// is enlarged.
///
/// The unit in which the parameter value is expressed is that established by
/// the parameter value of SELECT SIZE UNIT (SSU).
const String SACS = r' \';

/// Select Alternative Presentation Variants.
///
/// Representation: CSI s... \x20 \x5D
///
/// Parameter default value: s = 0
///
/// SAPV is used to specify one or more variants for the presentation of
/// subsequent text. The parameter values are:
///
/// - 0 - default presentation (implementation-defined); cancels the effect of
///   any preceding occurrence of SAPV in the data stream
/// - 1 - the decimal digits are presented by means of the graphic symbols
///   used in the Latin script
/// - 2 - the decimal digits are presented by means of the graphic symbols
///   used in the Arabic script, i.e. the Hindi symbols
/// - 3 - when the direction of the character path is right-to-left, each of
///   the graphic characters in the graphic character set(s) in use which is
///   one of a left/right-handed pair (parentheses, square brackets, curly
///   brackets, greater-than/less-than signs, etc.) is presented as
///   "mirrored", i.e. as the other member of the pair. For example, the
///   coded graphic character given the name LEFT PARENTHESIS is presented as
///   RIGHT PARENTHESIS, and vice versa
/// - 4 - when the direction of the character path is right-to-left, all
///   graphic characters which represent operators and delimiters in
///   mathematical formulae and which are not symmetrical about a vertical
///   axis are presented as mirrored about that vertical axis
/// - 5 - the following graphic character is presented in its isolated form
/// - 6 - the following graphic character is presented in its initial form
/// - 7 - the following graphic character is presented in its medial form
/// - 8 - the following graphic character is presented in its final form
/// - 9 - where the bit combination 02/14 is intended to represent a decimal
///   mark in a decimal number it shall be presented by means of the graphic
///   symbol FULL STOP
/// - 10 - where the bit combination 02/14 is intended to represent a decimal
///   mark in a decimal number it shall be presented by means of the graphic
///   symbol COMMA
/// - 11 - vowels are presented above or below the preceding character
/// - 12 - vowels are presented after the preceding character
/// - 13 - contextual shape determination of Arabic scripts, including the
///   LAM-ALEPH ligature but excluding all other Arabic ligatures
/// - 14 - contextual shape determination of Arabic scripts, excluding all
///   Arabic ligatures
/// - 15 - cancels the effect of parameter values 3 and 4
/// - 16 - vowels are not presented
/// - 17 - when the string direction is right-to-left, the italicized
///   characters are slanted to the left; when the string direction is
///   left-to-right, the italicized characters are slanted to the right
/// - 18 - contextual shape determination of Arabic scripts is not used, the
///   graphic characters - including the digits - are presented in the form
///   they are stored (Pass-through)
/// - 19 - contextual shape determination of Arabic scripts is not used, the
///   graphic characters- excluding the digits - are presented in the form
///   they are stored (Pass-through)
/// - 20 - the graphic symbols used to present the decimal digits are device
///   dependent
/// - 21 - establishes the effect of parameter values 5, 6, 7, and 8 for the
///   following graphic characters until cancelled
/// - 22 - cancels the effect of parameter value 21, i.e. re-establishes the
///   effect of parameter values 5, 6, 7, and 8 for the next single graphic
///   character only.
const String SAPV = ' ]';

/// Selective Tabulation.
///
/// Representation: CSI s \x20 \x5E
///
/// No parameter default value.
///
/// STAB causes subsequent text in the presentation component to be aligned
/// according to the position and the properties of a tabulation stop which
/// is selected from a list according to the value of the parameter s.
///
/// The use of this control function and means of specifying a list of
/// tabulation stops to be referenced by the control function are specified
/// in other standards, for example ISO 8613-6.
const String STAB = ' ^';

/// Graphic Character Combination.
///
/// Representation: CSI s \x20 \x5F
///
/// Parameter default value: s = 0
///
/// GCC is used to indicate that two or more graphic characters are to be
/// imaged as one single graphic symbol. GCC with a parameter value of 0
/// indicates that the following two graphic characters are to be imaged as
/// one single graphic symbol; GCC with a parameter value of 1 and GCC with
/// a parameter value of 2 indicate respectively the beginning and the end of
/// a string of graphic characters which are to be imaged as one single
/// graphic symbol.
///
/// NOTE
///
/// GCC does not explicitly specify the relative sizes or placements of the
/// component parts of a composite graphic symbol. In the simplest case, two
/// components may be "half-width" and side-by-side. For example, in Japanese
/// text a pair of characters may be presented side-by-side, and occupy the
/// space of a normal-size Kanji character.
const String GCC = ' _';

/// Tabulation Aligned Trailing Edge.
///
/// Representation: CSI n \x20 \x60
///
/// No parameter default value.
///
/// TATE causes a character tabulation stop calling for trailing edge
/// alignment to be set at character position n in the active line (the line
/// that contains the active presentation position) and lines of subsequent
/// text in the presentation component. TATE causes the replacement of any
/// tabulation stop previously set at that character position, but does not
/// affect other tabulation stops.
///
/// A text string aligned with a tabulation stop set by TATE will be
/// positioned so that the (trailing edge of the) first graphic character of
/// the string is placed at the tabulation stop.
const String TATE = ' `';

/// Tabulation Aligned Leading Edge.
///
/// Representation: CSI n \x20 \x61
///
/// No parameter default value.
///
/// TALE causes a character tabulation stop calling for leading edge
/// alignment to be set at character position n in the active line (the line
/// that contains the active presentation position) and lines of subsequent
/// text in the presentation component. TALE causes the replacement of any
/// tabulation stop previously set at that character position, but does not
/// affect other tabulation stops.
///
/// A text string aligned with a tabulation stop set by TALE will be
/// positioned so that the (leading edge of the) last graphic character of
/// the string is placed at the tabulation stop.
const String TALE = ' a';

/// Tabulation Aligned Centred.
///
/// Representation: CSI n \x20 \x62
///
/// No parameter default value.
///
/// TAC causes a character tabulation stop calling for centring to be set at
/// character position n in the active line (the line that contains the
/// active presentation position) and lines of subsequent text in the
/// presentation component. TAC causes the replacement of any tabulation stop
/// previously set at that character position, but does not affect other
/// tabulation stops.
///
/// A text string centred upon a tabulation stop set by TAC will be
/// positioned so that the (trailing edge of the) first graphic character and
/// the (leading edge of the) last graphic character are at approximately
/// equal distances from the tabulation stop.
const String TAC = ' b';

/// Tabulation Centred On Character.
///
/// Representation: CSI n1;n2 \x20 \x63
///
/// No parameter default value for n1
/// Parameter default value: n2 = 32
///
/// TCC causes a character tabulation stop calling for alignment of a target
/// graphic character to be set at character position n in the active line
/// (the line that contains the active presentation position) and lines of
/// subsequent text in the presentation component, and the target character
/// about which centring is to be performed is specified by n2. TCC causes
/// the replacement of any tabulation stop previously set at that character
/// position, but does not affect other tabulation stops.
///
/// The positioning of a text string aligned with a tabulation stop set by
/// TCC will be determined by the first occurrence in the string of the
/// target graphic character; that character will be centred upon the
/// tabulation stop. If the target character does not occur within the
/// string, then the trailing edge of the first character of the string will
/// be positioned at the tabulation stop.
///
/// The value of n2 indicates the code table position (binary value) of the
/// target character in the currently invoked code. The permissible range of
/// values is 32 to 127.
const String TCC = ' c';

/// Tabulation Stop Remove.
///
/// Representation: CSI n \x20 \x64
///
/// No parameter default value.
///
/// TSR causes any character tabulation stop at character position n in the
/// active line (the line that contains the active presentation position) and
/// lines of subsequent text in the presentation component to be cleared, but
/// does not affect other tabulation stops.
const String TSR = ' d';

/// Select Character Orientation.
///
/// Representation: CSI s \x20 \x65
///
/// Parameter default value: s = 0
///
/// SCO is used to establish the amount of rotation of the graphic characters
/// following in the data stream. The established value remains in effect
/// until the next occurrence of SCO in the data stream.
///
/// The parameter values are:
///
/// - 0 - 0°
/// - 1 - 45°
/// - 2 - 90°
/// - 3 - 135°
/// - 4 - 180°
/// - 5 - 225°
/// - 6 - 270°
/// - 7 - 315°
///
/// Rotation is positive, i.e. counter-clockwise and applies to the normal
/// presentation of the graphic characters along the character path. The
/// centre of rotation of the affected graphic characters is not defined by
/// Standard.
const String SCO = ' e';

/// Set Reduced Character Separation.
///
/// Representation: CSI n \x20 \x66
///
/// Parameter default value: n = 0
///
/// SRCS is used to establish reduced inter-character escapement for
/// subsequent text. The established reduced escapement remains in effect
/// until the next occurrence of SRCS or of SET ADDITIONAL CHARACTER
/// SEPARATION (SACS) in the data stream or until it is reset to the default
/// value by a subsequent occurrence of CARRIAGE RETURN/LINE FEED (CR/LF) or
/// of NEXT LINE (NEL) in the data stream.
///
/// n specifies the number of units by which the inter-character escapement
/// is reduced.
///
/// The unit in which the parameter values are expressed is that established
/// by the parameter value of SELECT SIZE UNIT (SSU).
const String SRCS = ' f';

/// Set Character Spacing.
///
/// Representation: CSI n \x20 \x67
///
/// No parameter default value.
///
/// SCS is used to establish the character spacing for subsequent text. The
/// established spacing remains in effect until the next occurrence of SCS,
/// or of SELECT CHARACTER SPACING (SHS) or of SPACING INCREMENT (SPI) in the
/// data stream.
///
/// n specifies the character spacing.
///
/// The unit in which the parameter value is expressed is that established by
/// the parameter value of SELECT SIZE UNIT (SSU).
const String SCS = ' g';

/// Set Line Spacing.
///
/// Representation: CSI n \x20 \x68
///
/// No parameter default value.
///
/// SLS is used to establish the line spacing for subsequent text. The
/// established spacing remains in effect until the next occurrence of SLS or
/// of SELECT LINE SPACING (SVS) or of SPACING INCREMENT (SPI) in the data
/// stream.
///
/// n specifies the line spacing.
///
/// The unit in which the parameter value is expressed is that established by
/// the parameter value of SELECT SIZE UNIT (SSU).
const String SLS = ' h';

/// Set Page Home.
///
/// Representation: CSI n \x20 \x69
///
/// No parameter default value.
///
/// If the DEVICE COMPONENT SELECT MODE is set to PRESENTATION, SPH is used
/// to establish at line position n in the active page (the page that
/// contains the active presentation position) and subsequent pages in the
/// presentation component the position to which the active presentation
/// position will be moved by subsequent occurrences of FORM FEED (FF) in the
/// data stream. In the case of a device without data component, it is also
/// the position ahead of which no implicit movement of the active
/// presentation position shall occur.
///
/// If the DEVICE COMPONENT SELECT MODE is set to DATA, SPH is used to
/// establish at line position n in the active page (the page that contains
/// the active data position) and subsequent pages in the data component the
/// position to which the active data position will be moved by subsequent
/// occurrences of FORM FEED (FF) in the data stream. It is also the position
/// ahead of which no implicit movement of the active presentation position
/// shall occur.
///
/// The established position is called the page home position and remains in
/// effect until the next occurrence of SPH in the data stream.
const String SPH = ' i';

/// Set Page Limit.
///
/// Representation: CSI n \x20 \x6A
///
/// No parameter default value.
///
/// If the DEVICE COMPONENT SELECT MODE is set to PRESENTATION, SPL is used
/// to establish at line position n in the active page (the page that
/// contains the active presentation position) and pages of subsequent text
/// in the presentation component the position beyond which the active
/// presentation position can normally not be moved. In the case of a device
/// without data component, it is also the position beyond which no implicit
/// movement of the active presentation position shall occur.
///
/// If the DEVICE COMPONENT SELECT MODE is set to DATA, SPL is used to
/// establish at line position n in the active page (the page that contains
/// the active data position) and pages of subsequent text in the data
/// component the position beyond which no implicit movement of the active
/// data position shall occur.
///
/// The established position is called the page limit position and remains in
/// effect until the next occurrence of SPL in the data stream.
const String SPL = ' j';

/// Select Character Path.
///
/// Representation: CSI s1;s2 \x20 \x6B
///
/// No parameter default values.
///
/// SCP is used to select the character path, relative to the line
/// orientation, for the active line (the line that contains the active
/// presentation position) and subsequent lines in the presentation
/// component. It is also used to update the content of the active line in
/// the presentation component and the content of the active line (the line
/// that contains the active data position) in the data component. This takes
/// effect immediately.
///
/// s1 specifies the character path:
///
/// - 1 - left-to-right (in the case of horizontal line orientation), or
///   top-to-bottom (in the case of vertical line orientation)
/// - 2 - right-to-left (in the case of horizontal line orientation), or
///   bottom-to-top (in the case of vertical line orientation)
///
/// s2 specifies the effect on the content of the presentation component and
/// the content of the data component:
///
/// - 0 - undefined (implementation-dependent)
///
///   NOTE
///
///   This may also permit the effect to take place after the next occurrence
///   of CR, NEL or any control function which initiates an absolute movement
///   of the active presentation position or the active data position.
///
/// - 1 - the content of the active line in the presentation component (the
///   line that contains the active presentation position) is updated to
///   correspond to the content of the active line in the data component (the
///   line that contains the active data position) according to the newly
///   established character path characteristics in the presentation
///   component; the active data position is moved to the first character
///   position in the active line in the data component, the active
///   presentation position in the presentation component is updated
///   accordingly
/// - 2 - the content of the active line in the data component (the line that
///   contains the active data position) is updated to correspond to the
///   content of the active line in the presentation component (the line that
///   contains the active presentation position) according to the newly
///   established character path characteristics of the presentation
///   component; the active presentation position is moved to the first
///   character position in the active line in the presentation component,
///   the active data position in the data component is updated accordingly.
const String SCP = ' k';
