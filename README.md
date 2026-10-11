# TESSIQ

An endless mental arithmetic puzzle game built with Flutter.

Hit target sums by selecting tiles on a 3x3 grid before the 30-second timer expires. Build your consecutive streak across 100 levels from single digits to 4-digit arithmetic.

## Gameplay Mechanics

- 3x3 Grid: 9 randomized positive integer tiles per puzzle.
- Guaranteed Dual Solutions: Every puzzle contains at least one 2-tile solution (A + B = Target) and one 3-tile solution (C + D + E = Target).
- Optimal 2-Tile Bonus: Solving with the 2-tile combination triggers a special golden flash animation and bonus badge.
- 30-Second Countdown: Each puzzle features a strict 30-second timer with a low-time urgency warning below 8 seconds.
- Move Limit: Up to 3 tiles can be selected at a time.
- Streak Progression: Reaching target sum advances your streak. Exceeding the timer ends the run and records your best streak.

## Difficulty Curve (Streaks 1 to 100)

Difficulty scales gradually across 4 tiers:

1. Streaks 1 to 10 (Single Digits):
   - Streaks 1 to 5: Warmup with small single digits (tiles 1 to 6, targets 6 to 11).
   - Streaks 6 to 10: Full single digits (tiles 1 to 9, targets 10 to 16).
2. Streaks 11 to 50 (2-Digit Mastery):
   - Streaks 11 to 23: Small 2-digits (tiles 10 to 25, targets 30 to 48).
   - Streaks 24 to 36: Medium 2-digits (tiles 15 to 55, targets 48 to 95).
   - Streaks 37 to 50: Large 2-digits (tiles 20 to 99, targets 65 to 175).
3. Streaks 51 to 80 (3-Digit Tier):
   - Streaks 51 to 65: Small 3-digits (tiles 100 to 350, targets 310 to 650).
   - Streaks 66 to 80: Full 3-digits (tiles 150 to 999, targets 480 to 1800).
4. Streaks 81 to 100 (4-Digit Tier):
   - Streaks 81 to 90: Small 4-digits (tiles 1000 to 3500, targets 3100 to 6500).
   - Streaks 91 to 100: Grand 4-digits (tiles 1500 to 9999, targets 4800 to 18000).
5. Streak 100 Grand Championship:
   - Completing level 100 unlocks the Grand Champion victory ceremony.

## Project Structure

```
lib/
├── main.dart                  # Entry point, theme, and centered Home screen
├── game/
│   ├── game_screen.dart       # Core game loop, 30s timer, 3x3 grid, animations
│   ├── puzzle_generator.dart  # Procedural 4-tier puzzle generator with solution guarantees
│   ├── models.dart            # PuzzleLevel data class
│   ├── sum_of_subsets.dart    # Backtracking subset sum solver for hints
│   └── levels.dart            # Fallback level definitions
└── storage/
    └── local_storage.dart     # SharedPreferences persistence for current and best streaks
assets/
└── logo.png                   # Official TESSIQ controller logo
test/
├── puzzle_generator_test.dart # Mathematical verification across all 100 streak tiers
└── sum_of_subsets_test.dart   # Unit tests for the subset sum solver
```

## Getting Started

### Prerequisites

- Flutter SDK (3.13.2 or later)
- Android SDK or desktop/web development environment

### Install Dependencies

```bash
flutter pub get
```

### Run Application

```bash
flutter run
```

### Run Tests and Analysis

```bash
flutter analyze
flutter test
```
