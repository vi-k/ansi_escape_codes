// ignore_for_file: constant_identifier_names

import '../../ansi/esc_fs.dart' as esc_fs;

/// Independent control functions: the escape sequences of the form ESC Fs.
///
/// See [esc_fs].
enum ControlFunctionsEscFs {
  /// See [esc_fs.DMI].
  DMI(esc_fs.DMI, 'Disable Manual Input'),

  /// See [esc_fs.INT].
  INT(esc_fs.INT, 'Interrupt'),

  /// See [esc_fs.EMI].
  EMI(esc_fs.EMI, 'Enable Manual Input'),

  /// See [esc_fs.RIS].
  RIS(esc_fs.RIS, 'Reset to Initial State'),

  /// See [esc_fs.CMD].
  CMD(esc_fs.CMD, 'Coding Method Delimiter'),

  /// See [esc_fs.LS2].
  LS2(esc_fs.LS2, 'Locking-Shift Two'),

  /// See [esc_fs.LS3].
  LS3(esc_fs.LS3, 'Locking-Shift Three'),

  /// See [esc_fs.LS3R].
  LS3R(esc_fs.LS3R, 'Locking-Shift Three Right'),

  /// See [esc_fs.LS2R].
  LS2R(esc_fs.LS2R, 'Locking-Shift Two Right'),

  /// See [esc_fs.LS1R].
  LS1R(esc_fs.LS1R, 'Locking-Shift One Right');

  const ControlFunctionsEscFs(this.code, this.description);

  /// The whole sequence, ESC and the byte after it.
  final String code;

  final String description;

  /// The function the given sequence stands for, if it stands for one.
  ///
  /// The codes between the allocated ones are reserved, and answer with
  /// `null`.
  static ControlFunctionsEscFs? byCode(String code) => _byCode[code];

  static final Map<String, ControlFunctionsEscFs> _byCode = {
    for (final v in values) v.code: v,
  };
}
