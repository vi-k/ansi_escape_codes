/// The bytes the standard names, and nothing built on them.
///
/// `CSI`, `CUU`, `BOLD`, `RESERVED_5F` — constants checked against ECMA-48,
/// for writing sequences by hand or reading someone else's. The ready-to-use
/// strings of the main import are built from these, and neither import brings
/// the other: this one is for the times the standard itself is what is being
/// worked with.
///
/// Every one of them is listed in `doc/reference.md`.
library;

export 'src/ansi/c0.dart';
export 'src/ansi/c1.dart';
export 'src/ansi/colors.dart';
export 'src/ansi/csi.dart';
export 'src/ansi/esc_fs.dart';
export 'src/ansi/sgr.dart';
