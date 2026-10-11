class SumOfSubsets {
  static List<int>? minimumSubset(List<int> v, int target, {int? maxCount}) {
    if (maxCount != null && maxCount < 0) return null;
    if (target == 0) return const [];

    List<int>? best;
    void visit(int i, int sum, List<int> take) {
      if (sum == target && (best == null || take.length < best!.length)) {
        best = List.of(take);
        return;
      }
      if (i == v.length ||
          (maxCount != null && take.length >= maxCount) ||
          (best != null && take.length >= best!.length)) {
        return;
      }
      var low = sum, high = sum;
      for (var j = i; j < v.length; j++) {
        if (v[j] < 0) {
          low += v[j];
        } else {
          high += v[j];
        }
      }
      if (target < low || target > high) return;
      take.add(i);
      visit(i + 1, sum + v[i], take);
      take.removeLast();
      visit(i + 1, sum, take);
    }

    visit(0, 0, []);
    return best;
  }
}
