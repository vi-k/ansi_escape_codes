import '../controls/c0.dart';
import '../controls/c1.dart';

/// Link.
///
/// https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
String linkBel(String url, {String? text}) =>
    '${OSC}8;;$url$BEL' '${text ?? url}' '${OSC}8;;$BEL';

/// Opening tag for [link].
///
/// Template: `${linkOpen}${url}${linkTextOpen}${text}${linkClose}`.
const String linkOpen = '${OSC}8;;';

/// Opening tag for [link] text.
///
/// See [linkOpen].
const String linkTextOpen = ST;

/// Closing tag for [link].
///
/// See [linkOpen].
const String linkClose = '${OSC}8;;$ST';

/// Link.
///
/// https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
String link(String url, {String? text}) =>
    '$linkOpen$url$linkTextOpen${text ?? url}$linkClose';
