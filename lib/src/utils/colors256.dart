const _colorComponentAssert = 'The color component must be in the range 0..5';

/// Returns the color index by rgb levels (r: 0..5, g: 0..5, b: 0..5)
int rgb(int r, int g, int b) {
  assert(r >= 0 && r <= 5, _colorComponentAssert);
  assert(g >= 0 && g <= 5, _colorComponentAssert);
  assert(b >= 0 && b <= 5, _colorComponentAssert);

  return 16 + 36 * r + 6 * g + b;
}

/// Returns the color index by gray level (g: 0..23)
int gray(int g) {
  assert(g >= 0 && g <= 23, 'The gray color must be in the range 0..23');

  return 232 + g;
}
