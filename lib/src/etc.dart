import 'common.dart';

/// Saves the cursor.
///
/// Saves the cursor position, encoding shift state and formatting attributes.
const String saveCursor = '${esc}7';

/// Restores the cursor.
///
/// Restores the cursor position, encoding shift state and formatting
/// attributes from the previous DECSC if any, otherwise resets these all to
/// their defaults.
const String restoreCursor = '${esc}8';

/// Link.
///
/// https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
String link(String url, [String? text]) =>
    '$esc]8;;$url$bel${text ?? url}$esc]8;;$bel';
