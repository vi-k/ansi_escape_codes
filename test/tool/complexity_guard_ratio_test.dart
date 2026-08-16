import 'package:test/test.dart';

import '../../benchmark/complexity_guard.dart';

void main() {
  group('paired ratios', () {
    test('divides within a pair rather than across the sides', () {
      // The side medians are 1 and 4, and their ratio is 4. The per-pair
      // ratios are 2, 8 and 1, and their median is 2. This test holds the
      // second number.
      final ratios = pairedRatios([1, 1, 4], [2, 8, 4]);

      expect(ratios.median, 2.0);
    });

    test('reports the extremes of the pairs', () {
      final ratios = pairedRatios([1, 1, 4], [2, 8, 4]);

      expect(ratios.min, 1.0);
      expect(ratios.max, 8.0);
    });

    test('rejects sides of different length', () {
      // The longer side is the silent path: without the length guard the
      // extra samples are dropped and the answer looks ordinary, so the
      // first side is left odd and non-empty to reach that guard alone.
      expect(
        () => pairedRatios([1, 1, 4], [2, 8, 4, 100, 100]),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('differ in length'),
          ),
        ),
      );
    });

    test('rejects an empty measurement', () {
      expect(
        () => pairedRatios([], []),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('no pairs'),
          ),
        ),
      );
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

    test('rejects a sample that is not a finite number', () {
      expect(
        () => pairedRatios([1, 1, 1], [double.nan, 1, 1]),
        throwsA(
          isA<ArgumentError>().having(
            (error) => error.message,
            'message',
            contains('could not resolve'),
          ),
        ),
      );
      expect(
        () => pairedRatios([double.infinity, 1, 1], [1, 1, 1]),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
