import '../control_codes/control_codes.dart';

/// Saves the cursor.
///
/// Saves the cursor position, encoding shift state and formatting attributes.
const String saveCursor = '${esc}7';

/// Restores the cursor.
///
/// Restores the cursor position, encoding shift state and formatting
/// attributes from the previous [saveCursor] if any, otherwise resets these
/// all to their defaults.
const String restoreCursor = '${esc}8';
