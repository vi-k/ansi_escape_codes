import 'package:ansi_escape_codes/ansi_escape_codes.dart';

void title(String text) {
  print('\n$fg256Rgb531▶︎ $text$reset');
}

void subtitle(String text) {
  print('\n$fg256Rgb420$text$reset');
}

void subsubtitle(String text) {
  print('$fg256Rgb320$text$reset');
}
