import '../controls/c0.dart';

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
