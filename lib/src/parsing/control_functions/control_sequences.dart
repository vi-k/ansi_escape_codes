// ignore_for_file: constant_identifier_names

import '../../controls/csi.dart' as csi;

/// Control sequences.
///
/// See [csi].
enum ControlSequencesFunctions {
  /// See [csi.ICH].
  ICH(csi.ICH, 'Insert Character'),

  /// See [csi.CUU].
  CUU(csi.CUU, 'Cursor Up'),

  /// See [csi.CUD].
  CUD(csi.CUD, 'Cursor Down'),

  /// See [csi.CUF].
  CUF(csi.CUF, 'Cursor Right'),

  /// See [csi.CUB].
  CUB(csi.CUB, 'Cursor Left'),

  /// See [csi.CNL].
  CNL(csi.CNL, 'Cursor Next Line'),

  /// See [csi.CPL].
  CPL(csi.CPL, 'Cursor Preceding Line'),

  /// See [csi.CHA].
  CHA(csi.CHA, 'Cursor Character Absolute'),

  /// See [csi.CUP].
  CUP(csi.CUP, 'Cursor Position'),

  /// See [csi.CHT].
  CHT(csi.CHT, 'Cursor Forward Tabulation'),

  /// See [csi.ED].
  ED(csi.ED, 'Erase In Page'),

  /// See [csi.EL].
  EL(csi.EL, 'Erase In Line'),

  /// See [csi.IL].
  IL(csi.IL, 'Insert Line'),

  /// See [csi.DL].
  DL(csi.DL, 'Delete Line'),

  /// See [csi.EF].
  EF(csi.EF, 'Erase In Field'),

  /// See [csi.EA].
  EA(csi.EA, 'Erase In Area'),

  /// See [csi.DCH].
  DCH(csi.DCH, 'Delete Character'),

  /// See [csi.SEE].
  SEE(csi.SEE, 'Select Editing Extent'),

  /// See [csi.CPR].
  CPR(csi.CPR, 'Active Position Report'),

  /// See [csi.SU].
  SU(csi.SU, 'Scroll Up'),

  /// See [csi.SD].
  SD(csi.SD, 'Scroll Down'),

  /// See [csi.NP].
  NP(csi.NP, 'Next Page'),

  /// See [csi.PP].
  PP(csi.PP, 'Preceding Page'),

  /// See [csi.CTC].
  CTC(csi.CTC, 'Cursor Tabulation Control'),

  /// See [csi.ECH].
  ECH(csi.ECH, 'Erase Character'),

  /// See [csi.CVT].
  CVT(csi.CVT, 'Cursor Line Tabulation'),

  /// See [csi.CBT].
  CBT(csi.CBT, 'Cursor Backward Tabulation'),

  /// See [csi.SRS].
  SRS(csi.SRS, 'Start Reversed String'),

  /// See [csi.PTX].
  PTX(csi.PTX, 'Parallel Texts'),

  /// See [csi.SDS].
  SDS(csi.SDS, 'Start Directed String'),

  /// See [csi.SIMD].
  SIMD(csi.SIMD, 'Select Implicit Movement Direction'),

  /// Reserved.
  RESERVED('_', null, _Type.reserved),

  /// See [csi.HPA].
  HPA(csi.HPA, 'Character Position Absolute'),

  /// See [csi.HPR].
  HPR(csi.HPR, 'Character Position Forward'),

  /// See [csi.REP].
  REP(csi.REP, 'Repeat'),

  /// See [csi.DA].
  DA(csi.DA, 'Device Attributes'),

  /// See [csi.VPA].
  VPA(csi.VPA, 'Line Position Absolute'),

  /// See [csi.VPR].
  VPR(csi.VPR, 'Line Position Forward'),

  /// See [csi.HVP].
  HVP(csi.HVP, 'Character And Line Position'),

  /// See [csi.TBC].
  TBC(csi.TBC, 'Tabulation Clear'),

  /// See [csi.SM].
  SM(csi.SM, 'SET MODE'),

  /// See [csi.MC].
  MC(csi.MC, 'Media Copy'),

  /// See [csi.HPB].
  HPB(csi.HPB, 'Character Position Backward'),

  /// See [csi.VPB].
  VPB(csi.VPB, 'Line Position Backward'),

  /// See [csi.RM].
  RM(csi.RM, 'Reset Mode'),

  /// See [csi.SGR].
  SGR(csi.SGR, 'Select Graphic Rendition'),

  /// See [csi.DSR].
  DSR(csi.DSR, 'Device Status Report'),

  /// See [csi.DAQ].
  DAQ(csi.DAQ, 'Define Area Qualification'),

  /// Private.
  PRIVATEUSE_70('p', null, _Type.private),

  /// Private.
  PRIVATEUSE_71('q', null, _Type.private),

  /// Private.
  PRIVATEUSE_72('r', null, _Type.private),

  /// See [csi.SAVE_CURSOR].
  SAVE_CURSOR(csi.SAVE_CURSOR, 'Save Crusor'),

  /// Private.
  PRIVATEUSE_74('t', null, _Type.private),

  /// See [csi.RESTORE_CURSOR].
  RESTORE_CURSOR(csi.RESTORE_CURSOR, 'Restore Cursor'),

  /// Private.
  PRIVATEUSE_76('v', null, _Type.private),

  /// Private.
  PRIVATEUSE_77('w', null, _Type.private),

  /// Private.
  PRIVATEUSE_78('x', null, _Type.private),

  /// Private.
  PRIVATEUSE_79('y', null, _Type.private),

  /// Private.
  PRIVATEUSE_7A('z', null, _Type.private),

  /// Private.
  PRIVATEUSE_7B('{', null, _Type.private),

  /// Private.
  PRIVATEUSE_7C('|', null, _Type.private),

  /// Private.
  PRIVATEUSE_7D('}', null, _Type.private),

  /// Private.
  PRIVATEUSE_7E('~', null, _Type.private),

  // Final Bytes of control sequences with a single Intermediate Byte 0x20.

  /// See [csi.SL].
  SL(csi.SL, 'Scroll Left'),

  /// See [csi.SR].
  SR(csi.SR, 'Scroll Right'),

  /// See [csi.GSM].
  GSM(csi.GSM, 'Graphic Size Modification'),

  /// See [csi.GSS].
  GSS(csi.GSS, 'Graphic Size Selection'),

  /// See [csi.FNT].
  FNT(csi.FNT, 'Font Selection'),

  /// See [csi.TSS].
  TSS(csi.TSS, 'Thin Space Specification'),

  /// See [csi.JFY].
  JFY(csi.JFY, 'Justify'),

  /// See [csi.SPI].
  SPI(csi.SPI, 'Spacing Increment'),

  /// See [csi.QUAD].
  QUAD(csi.QUAD, 'Quad'),

  /// See [csi.SSU].
  SSU(csi.SSU, 'Select Size Unit'),

  /// See [csi.PFS].
  PFS(csi.PFS, 'Page Format Selection'),

  /// See [csi.SHS].
  SHS(csi.SHS, 'Select Character Spacing'),

  /// See [csi.SVS].
  SVS(csi.SVS, 'Select Line Spacing'),

  /// See [csi.IGS].
  IGS(csi.IGS, 'Identify Graphic Subrepertoire'),

  /// Reserved.
  RESERVED_20_4E(' N', null, _Type.reserved),

  /// See [csi.IDCS].
  IDCS(csi.IDCS, 'Identify Device Control String'),

  /// See [csi.PPA].
  PPA(csi.PPA, 'Page Position Absolute'),

  /// See [csi.PPR].
  PPR(csi.PPR, 'Page Position Forward'),

  /// See [csi.PPB].
  PPB(csi.PPB, 'Page Position Backward'),

  /// See [csi.SPD].
  SPD(csi.SPD, 'Select Presentation Directions'),

  /// See [csi.DTA].
  DTA(csi.DTA, 'Dimension Text Area'),

  /// See [csi.SLH].
  SLH(csi.SLH, 'Set Line Home'),

  /// See [csi.SLL].
  SLL(csi.SLL, 'SET LINE LIMIT'),

  /// See [csi.FNK].
  FNK(csi.FNK, 'Function Key'),

  /// See [csi.SPQR].
  SPQR(csi.SPQR, 'Select Print Quality And Rapidity'),

  /// See [csi.SEF].
  SEF(csi.SEF, 'Sheet Eject And Feed'),

  /// See [csi.PEC].
  PEC(csi.PEC, 'Presentation Expand Or Contract'),

  /// See [csi.SSW].
  SSW(csi.SSW, 'Set Space Width'),

  /// See [csi.SACS].
  SACS(csi.SACS, 'Set Additional Character Separation'),

  /// See [csi.SAPV].
  SAPV(csi.SAPV, 'Select Alternative Presentation Variants'),

  /// See [csi.STAB].
  STAB(csi.STAB, 'Selective Tabulation'),

  /// See [csi.GCC].
  GCC(csi.GCC, 'Graphic Character Combination'),

  /// See [csi.TATE].
  TATE(csi.TATE, 'Tabulation Aligned Trailing Edge'),

  /// See [csi.TALE].
  TALE(csi.TALE, 'Tabulation Aligned Leading Edge'),

  /// See [csi.TAC].
  TAC(csi.TAC, 'Tabulation Aligned Centred'),

  /// See [csi.TCC].
  TCC(csi.TCC, 'Tabulation Centred On Character'),

  /// See [csi.TSR].
  TSR(csi.TSR, 'Tabulation Stop Remove'),

  /// See [csi.SCO].
  SCO(csi.SCO, 'Select Character Orientation'),

  /// See [csi.SRCS].
  SRCS(csi.SRCS, 'SET REDUCED CHARACTER SEPARATION'),

  /// See [csi.SCS].
  SCS(csi.SCS, 'Set Character Spacing'),

  /// See [csi.SLS].
  SLS(csi.SLS, 'Set Line Spacing'),

  /// See [csi.SPH].
  SPH(csi.SPH, 'Set Page Home'),

  /// See [csi.SPL].
  SPL(csi.SPL, 'Set Page Limit'),

  /// See [csi.SCP].
  SCP(csi.SCP, 'Select Character Path'),

  /// Reserved.
  RESERVED_20_6C(' l', null, _Type.reserved),

  /// Reserved.
  RESERVED_20_6D(' m', null, _Type.reserved),

  /// Reserved.
  RESERVED_20_6E(' n', null, _Type.reserved),

  /// Reserved.
  RESERVED_20_6F(' o', null, _Type.reserved),

  /// Private.
  PRIVATEUSE_20_70(' p', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_71(' q', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_72(' r', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_73(' s', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_74(' t', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_75(' u', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_76(' v', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_77(' w', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_78(' x', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_79(' y', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_7A(' z', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_7B(' {', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_7C(' |', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_7D(' }', null, _Type.private),

  /// Private.
  PRIVATEUSE_20_7E(' ~', null, _Type.private);

  final String code;
  final String? _description;
  final _Type _type;

  const ControlSequencesFunctions(
    this.code, [
    this._description,
    this._type = _Type.normal,
  ]);

  String get description =>
      _description ??
      switch (_type) {
        _Type.normal => 'Unknown',
        _Type.private => 'Private',
        _Type.reserved => 'Reserved',
      };

  bool get isPrivate => _type == _Type.private;

  bool get isReserved => _type == _Type.reserved;

  static ControlSequencesFunctions? byCode(String code) {
    for (final v in values) {
      if (v.code == code && v._description != null && v._type == _Type.normal) {
        return v;
      }
    }

    return null;
  }
}

enum _Type { normal, private, reserved }
