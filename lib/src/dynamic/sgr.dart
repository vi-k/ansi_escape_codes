import '../constants/sgr.dart';

const _colorNumberAssert = 'The color number must be in the range 0..255';

String fg256(int color) {
  assert(color >= 0 && color <= 255, _colorNumberAssert);
  return '$fg256Open$color$fg256Close';
}

String bg256(int color) {
  assert(color >= 0 && color <= 255, _colorNumberAssert);
  return '$bg256Open$color$bg256Close';
}

String underline256(int color) {
  assert(color >= 0 && color <= 255, _colorNumberAssert);
  return '$underline256Open$color$underline256Close';
}

const _colorComponentAssert =
    'The rgb color component must be in the range 0..255';

String fgRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);
  return '$fgRgbOpen$r;$g;$b$fgRgbClose';
}

String bgRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);
  return '$bgRgbOpen$r;$g;$b$bgRgbClose';
}

String underlineRgb(int r, int g, int b) {
  assert(r >= 0 && r <= 255, _colorComponentAssert);
  assert(g >= 0 && g <= 255, _colorComponentAssert);
  assert(b >= 0 && b <= 255, _colorComponentAssert);
  return '$underlineRgbOpen$r;$g;$b$underlineRgbClose';
}
