# TESSIQ

An offline, minimalist number-strategy puzzle game built with Flutter.

Tap tiles to make the target sum with the fewest selections. The game includes 30 levels, locally persisted stars/unlocks, hints, limited undo, negative and duplicate values, and Tile Lock levels.

## Run

```bash
flutter pub get
flutter run
```

## Core logic

`lib/game/sum_of_subsets.dart` implements a backtracking sum-of-subsets solver. It calculates the smallest valid subset from the actual available tile indices and uses bounds that remain correct with negative numbers.
