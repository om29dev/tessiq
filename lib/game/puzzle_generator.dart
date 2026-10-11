import 'dart:math';
import 'models.dart';

class PuzzleGenerator {
  static final Random _rng = Random();

  /// Generates a puzzle following a gradual progression curve up to streak 100:
  /// - Streaks 0 - 9 (Puzzles 1 - 10): 1-digit numbers (starts 1-6, then 1-9)
  /// - Streaks 10 - 49 (Puzzles 11 - 50): 2-digit mastery (small 10-25 -> medium 15-55 -> large 20-99)
  /// - Streaks 50 - 79 (Puzzles 51 - 80): 3-digit numbers (small 100-350 -> full up to 999)
  /// - Streaks 80 - 99 (Puzzles 81 - 100): 4-digit numbers (small 1000-3500 -> full up to 9999)
  static PuzzleLevel generate(int streak) {
    if (streak < 5) {
      return _generateRange(
        minTile: 1,
        maxTile: 6,
        minTarget: 6,
        maxTarget: 11,
      );
    } else if (streak < 10) {
      return _generateRange(
        minTile: 1,
        maxTile: 9,
        minTarget: 10,
        maxTarget: 16,
      );
    } else if (streak < 23) {
      return _generateRange(
        minTile: 10,
        maxTile: 25,
        minTarget: 30,
        maxTarget: 48,
      );
    } else if (streak < 36) {
      return _generateRange(
        minTile: 15,
        maxTile: 55,
        minTarget: 48,
        maxTarget: 95,
      );
    } else if (streak < 50) {
      return _generateRange(
        minTile: 20,
        maxTile: 99,
        minTarget: 65,
        maxTarget: 175,
      );
    } else if (streak < 65) {
      return _generateRange(
        minTile: 100,
        maxTile: 350,
        minTarget: 310,
        maxTarget: 650,
      );
    } else if (streak < 80) {
      return _generateRange(
        minTile: 150,
        maxTile: 999,
        minTarget: 480,
        maxTarget: 1800,
      );
    } else if (streak < 90) {
      return _generateRange(
        minTile: 1000,
        maxTile: 3500,
        minTarget: 3100,
        maxTarget: 6500,
      );
    } else {
      return _generateRange(
        minTile: 1500,
        maxTile: 9999,
        minTarget: 4800,
        maxTarget: 18000,
      );
    }
  }

  static String getTierLabel(int streak) {
    if (streak < 5) return '1-DIGIT WARMUP';
    if (streak < 10) return '1-DIGIT TIER';
    if (streak < 23) return 'SMALL 2-DIGIT';
    if (streak < 36) return 'MEDIUM 2-DIGIT';
    if (streak < 50) return 'LARGE 2-DIGIT';
    if (streak < 65) return 'SMALL 3-DIGIT';
    if (streak < 80) return 'FULL 3-DIGIT';
    if (streak < 90) return 'SMALL 4-DIGIT';
    return 'GRAND 4-DIGIT';
  }

  static PuzzleLevel _generateRange({
    required int minTile,
    required int maxTile,
    required int minTarget,
    required int maxTarget,
  }) {
    final target = minTarget + _rng.nextInt(maxTarget - minTarget + 1);

    // 2-tile solution: a + b = target, minTile <= a, b <= maxTile
    final minA = max(minTile, target - maxTile);
    final maxA = min(maxTile, target - minTile);
    final a = minA + _rng.nextInt(maxA - minA + 1);
    final b = target - a;

    // 3-tile solution: c + d + e = target, minTile <= c, d, e <= maxTile
    final minC = max(minTile, target - 2 * maxTile);
    final maxC = min(maxTile, target - 2 * minTile);
    final c = minC + _rng.nextInt(maxC - minC + 1);
    final rem = target - c;
    final minD = max(minTile, rem - maxTile);
    final maxD = min(maxTile, rem - minTile);
    final d = minD + _rng.nextInt(maxD - minD + 1);
    final e = rem - d;

    // 4 filler tiles in range [minTile, maxTile], != target
    final fillers = <int>[];
    final span = maxTile - minTile + 1;
    while (fillers.length < 4) {
      final f = minTile + _rng.nextInt(span);
      if (f != target) fillers.add(f);
    }

    final tiles = [a, b, c, d, e, ...fillers];
    tiles.shuffle(_rng);

    return PuzzleLevel(
      tiles: tiles,
      target: target,
      moves: 3,
      timeLimit: 30,
    );
  }
}
