import 'package:flutter_test/flutter_test.dart';
import 'package:tessiq/game/puzzle_generator.dart';

void main() {
  test('generates gradual 3x3 puzzles across all sub-tiers up to streak 100', () {
    final sampleStreaks = [
      0, 2, 4, // 1-digit warmup (1-6)
      5, 7, 9, // 1-digit full (1-9)
      10, 15, 22, // small 2-digit (10-25)
      23, 28, 35, // medium 2-digit (15-55)
      36, 42, 49, // large 2-digit (20-99)
      50, 56, 64, // small 3-digit (100-350)
      65, 72, 79, // full 3-digit (150-999)
      80, 85, 89, // small 4-digit (1000-3500)
      90, 95, 99, // grand 4-digit (1500-9999)
    ];

    for (final streak in sampleStreaks) {
      for (var attempt = 0; attempt < 20; attempt++) {
        final puzzle = PuzzleGenerator.generate(streak);

        expect(puzzle.tiles.length, 9);
        expect(puzzle.moves, 3);
        expect(puzzle.timeLimit, 30);

        for (final t in puzzle.tiles) {
          expect(t > 0, isTrue);
          expect(t != puzzle.target, isTrue);

          if (streak < 5) {
            expect(t >= 1 && t <= 6, isTrue);
          } else if (streak < 10) {
            expect(t >= 1 && t <= 9, isTrue);
          } else if (streak < 23) {
            expect(t >= 10 && t <= 25, isTrue);
          } else if (streak < 36) {
            expect(t >= 15 && t <= 55, isTrue);
          } else if (streak < 50) {
            expect(t >= 20 && t <= 99, isTrue);
          } else if (streak < 65) {
            expect(t >= 100 && t <= 350, isTrue);
          } else if (streak < 80) {
            expect(t >= 150 && t <= 999, isTrue);
          } else if (streak < 90) {
            expect(t >= 1000 && t <= 3500, isTrue);
          } else {
            expect(t >= 1500 && t <= 9999, isTrue);
          }
        }

        // Verify 2-tile solution exists
        var has2Tile = false;
        for (var i = 0; i < puzzle.tiles.length; i++) {
          for (var j = i + 1; j < puzzle.tiles.length; j++) {
            if (puzzle.tiles[i] + puzzle.tiles[j] == puzzle.target) {
              has2Tile = true;
              break;
            }
          }
          if (has2Tile) break;
        }
        expect(has2Tile, isTrue, reason: 'No 2-tile solution for streak $streak, target ${puzzle.target}');

        // Verify 3-tile solution exists
        var has3Tile = false;
        for (var i = 0; i < puzzle.tiles.length; i++) {
          for (var j = i + 1; j < puzzle.tiles.length; j++) {
            for (var k = j + 1; k < puzzle.tiles.length; k++) {
              if (puzzle.tiles[i] + puzzle.tiles[j] + puzzle.tiles[k] == puzzle.target) {
                has3Tile = true;
                break;
              }
            }
            if (has3Tile) break;
          }
          if (has3Tile) break;
        }
        expect(has3Tile, isTrue, reason: 'No 3-tile solution for streak $streak, target ${puzzle.target}');
      }
    }
  });
}
