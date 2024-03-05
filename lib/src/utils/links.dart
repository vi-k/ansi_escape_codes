import '../constants/common.dart';

/// Link.
///
/// https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
String link(String url, [String? text]) =>
    '$esc]8;;$url$bel${text ?? url}$esc]8;;$bel';
