// ignore_for_file: constant_identifier_names

import '../../controls/c0.dart';
import '../../controls/c1.dart' as c1;
import 'control_functions_c0.dart';

/// Control functions: elements of the C1 set.
///
/// See [c1].
enum ControlFunctionsC1 {
  /// Reserved: \x40
  RESERVED_40('$ESC@', 'Reserved'),

  /// Reserved: \x41
  RESERVED_41('${ESC}A', 'Reserved'),

  /// See [c1.BPH].
  BPH(c1.BPH, 'Break Permitted Here'),

  /// See [c1.NBH].
  NBH(c1.NBH, 'No Break Here'),

  /// Reserved: \x44
  RESERVED_44('${ESC}D', 'Reserved'),

  /// See [c1.NEL].
  NEL(c1.NEL, 'Next Line'),

  /// See [c1.SSA].
  SSA(c1.SSA, 'Start Of Selected Area'),

  /// See [c1.ESA].
  ESA(c1.ESA, 'End Of Selected Area'),

  /// See [c1.HTS].
  HTS(c1.HTS, 'Character Tabulation Set'),

  /// See [c1.HTJ].
  HTJ(c1.HTJ, 'Character Tabulation With Justification'),

  /// See [c1.VTS].
  VTS(c1.VTS, 'Line Tabulation Set'),

  /// See [c1.PLD].
  PLD(c1.PLD, 'Partial Line Forward'),

  /// See [c1.PLU].
  PLU(c1.PLU, 'Partial Line Backward'),

  /// See [c1.RI].
  RI(c1.RI, 'Reverse Line Feed'),

  /// See [c1.SS2].
  SS2(c1.SS2, 'Single-Shift Two'),

  /// See [c1.SS3].
  SS3(c1.SS3, 'Single-Shift Three'),

  /// See [c1.DCS].
  DCS(c1.DCS, 'Device Control String'),

  /// See [c1.PU1].
  PU1(c1.PU1, 'Private Use One'),

  /// See [c1.PU2].
  PU2(c1.PU2, 'Private Use Two'),

  /// See [c1.STS].
  STS(c1.STS, 'Set Transmit State'),

  /// See [c1.CCH].
  CCH(c1.CCH, 'Cancel Character'),

  /// See [c1.MW].
  MW(c1.MW, 'Message Waiting'),

  /// See [c1.SPA].
  SPA(c1.SPA, 'Start Of Guarded Area'),

  /// See [c1.EPA].
  EPA(c1.EPA, 'End Of Guarded Area'),

  /// See [c1.SOS].
  SOS(c1.SOS, 'Start Of String'),

  /// Reserved: \x59
  RESERVED_59('${ESC}Y', 'Reserved'),

  /// See [c1.SCI].
  SCI(c1.SCI, 'Single Character Introducer'),

  /// See [c1.CSI].
  CSI(c1.CSI, 'Control Sequence Introducer'),

  /// See [c1.ST].
  ST(c1.ST, 'String Terminator'),

  /// See [c1.OSC].
  OSC(c1.OSC, 'Operating System Command'),

  /// See [c1.PM].
  PM(c1.PM, 'Privacy Message'),

  /// See [c1.APC].
  APC(c1.APC, 'Application Program Command');

  const ControlFunctionsC1(this.code, this.description);

  final String code;

  final String description;

  static ControlFunctionsC1? byCode(String code) {
    if (code.length == 2 &&
        code.codeUnitAt(0) == ControlFunctionsC0.ESC.index) {
      final index = code.codeUnitAt(1) - 0x40;

      return index >= 0 && index < values.length ? values[index] : null;
    }

    return null;
  }
}
