import '../ansi/c0.dart';
import '../ansi/esc_fs.dart';

/// Resets the terminal to the state it has when it is made operational.
///
/// This clears the screen, puts the tabulation stops and the graphic
/// rendition back to their defaults and returns the cursor to the first
/// position of the first line. The SGR reset, by comparison, ends the graphic
/// rendition and touches nothing else.
///
/// See [RIS].
const String resetTerminal = RIS;

/// Saves the cursor.
///
/// Saves the cursor position, encoding shift state and formatting attributes.
///
/// Compatibility:
/// - -vscode
/// - -as
/// - +mac Terminal
/// - +mac iTerm2
/// - +mac Warp
///
/// See also [restoreCursor].
const String saveCursor = '${ESC}7';

/// Restores the cursor.
///
/// Restores the cursor position, encoding shift state and formatting
/// attributes from the previous [saveCursor] if any, otherwise resets these
/// all to their defaults.
///
/// See also [saveCursor].
const String restoreCursor = '${ESC}8';
