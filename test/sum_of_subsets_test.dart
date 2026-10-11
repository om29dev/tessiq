import 'package:flutter_test/flutter_test.dart';
import 'package:tessiq/game/sum_of_subsets.dart';

void main() {
  test('finds the smallest exact subset', () {
    final result = SumOfSubsets.minimumSubset([2, 3, 5, 8, 9], 8);
    expect(result, [3]);
  });

  test('handles negative values and duplicate values by index', () {
    final result = SumOfSubsets.minimumSubset([-4, 3, 7, 7, 11], 10);
    expect(result, isNotNull);
    expect(result!.map((i) => [-4, 3, 7, 7, 11][i]).reduce((a, b) => a + b), 10);
  });

  test('returns the empty subset for a zero target', () {
    expect(SumOfSubsets.minimumSubset([4, -4, 7], 0), []);
    expect(SumOfSubsets.minimumSubset([1, 2, 3], 0), []);
  });
}
