/// Returns the color index from 256-color table by rgb levels (r,g,b: 0..5).
///
/// 6 × 6 × 6 cube (216 colors): 16 + 36 × r + 6 × g + b.
int rgb(int r, int g, int b) {
  IndexError.check(r, 6, name: 'r');
  IndexError.check(g, 6, name: 'g');
  IndexError.check(b, 6, name: 'b');

  return 16 + 36 * r + 6 * g + b;
}

/// Returns the color index from 256-color table by gray level (g: 0..23).
///
/// Gray scale from dark to light in 24 steps.
int gray(int g) {
  IndexError.check(g, 24, name: 'g');

  return 232 + g;
}
