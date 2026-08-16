/// The index in the 256-colour table of a colour of the cube (r, g, b: 0..5).
///
/// 6 × 6 × 6 cube (216 colours): 16 + 36 × r + 6 × g + b. An index is what
/// `fg256` and its pair write; `fgRgb` and its pair are the other thing, and
/// take a truecolour triple of 0..255 that goes into the sequence itself.
///
/// ```dart
/// print(fg256(rgb256(5, 0, 0))); // the reddest colour the cube has
/// print(fgRgb(255, 0, 0)); // the reddest colour there is
/// ```
int rgb256(int r, int g, int b) {
  IndexError.check(r, 6, name: 'r');
  IndexError.check(g, 6, name: 'g');
  IndexError.check(b, 6, name: 'b');

  return 16 + 36 * r + 6 * g + b;
}

/// The index in the 256-colour table of a grey of the ramp (g: 0..23).
///
/// The grey ramp runs from dark to light in 24 steps, and stands beside the
/// cube [rgb256] indexes, rather than inside it.
int gray256(int g) {
  IndexError.check(g, 24, name: 'g');

  return 232 + g;
}
