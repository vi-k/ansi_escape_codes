import 'control_codes.dart';
import 'escape_codes.dart';

/// Link.
///
/// https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
String linkBel(String url, {String? text}) =>
    '${osc}8;;$url$bel' '${text ?? url}' '${osc}8;;$bel';

/// Opening tag for [link].
///
/// Template: `${linkOpen}${url}${linkTextOpen}${text}${linkClose}`.
const String linkOpen = '${osc}8;;';

/// Opening tag for [link] text.
///
/// See [linkOpen].
const String linkTextOpen = st;

/// Closing tag for [link].
///
/// See [linkOpen].
const String linkClose = '${osc}8;;$st';

/// Link.
///
/// https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
String link(String url, {String? text}) =>
    '$linkOpen$url$linkTextOpen${text ?? url}$linkClose';
