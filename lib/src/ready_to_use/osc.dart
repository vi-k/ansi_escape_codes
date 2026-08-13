import '../ansi/c0.dart';
import '../ansi/c1.dart';
import '../internal/strings.dart';

/// Link, in the older form a `BEL` closes.
///
/// The same as [link] in every other way, terminator apart — see there for
/// what becomes of [url] and of [text].
///
/// https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
String linkBel(String url, {String? text}) {
  final address = encodeControlBytes(url);

  return '${OSC}8;;$address$BEL' '${text ?? address}' '${OSC}8;;$BEL';
}

/// Opening tag for [link].
///
/// Template: `${linkOpen}${url}${linkTextOpen}${text}${linkClose}`.
///
/// Writing the parts by hand puts the address into the sequence unchecked;
/// [link] is the one that encodes it. See there.
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
/// A control byte in [url] is written as its percent-escape, because the body
/// of an `OSC 8` cannot carry one: an `ESC` there ends the sequence where it
/// stands, and the rest of what was meant as the address reaches the terminal
/// as codes of its own. An address that carries none — which is every address
/// that is one — comes out byte for byte, percent-escapes and all. See
/// `encodeControlBytes` for what is encoded and what is deliberately not.
///
/// [text] is what is shown between the two, and it is written as it came:
/// styling the text of a link is what the codes are there for. The close
/// begins with an `ESC` and so ends whatever the text left open, but a text
/// from a source you do not trust shows what it says — strip its codes first
/// if that matters. Where no [text] is given the encoded address stands for
/// it.
///
/// https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
String link(String url, {String? text}) {
  final address = encodeControlBytes(url);

  return '$linkOpen$address$linkTextOpen${text ?? address}$linkClose';
}
