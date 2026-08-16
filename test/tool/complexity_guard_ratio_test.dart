import 'package:test/test.dart';

import '../../benchmark/complexity_guard.dart';

void main() {
  group('paired ratios', () {
    test('divides within a pair rather than across the sides', () {
      // Медианы сторон — 1 и 4, их отношение 4. Попарные отношения —
      // 2, 8 и 1, их медиана 2. Тест держит именно вторую величину.
      final ratios = pairedRatios([1, 1, 4], [2, 8, 4]);

      expect(ratios.median, 2.0);
    });

    test('reports the extremes of the pairs', () {
      final ratios = pairedRatios([1, 1, 4], [2, 8, 4]);

      expect(ratios.min, 1.0);
      expect(ratios.max, 8.0);
    });

    test('rejects sides of different length', () {
      expect(
        () => pairedRatios([1, 2], [1, 2, 3]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects an empty measurement', () {
      expect(() => pairedRatios([], []), throwsA(isA<ArgumentError>()));
    });

    test('rejects an even number of pairs', () {
      expect(
        () => pairedRatios([1, 2], [2, 4]),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('rejects a sample the timer could not resolve', () {
      expect(
        () => pairedRatios([1, 0, 1], [1, 1, 1]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
