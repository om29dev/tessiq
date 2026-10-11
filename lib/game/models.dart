class PuzzleLevel {
  const PuzzleLevel({
    required this.tiles,
    required this.target,
    required this.moves,
    this.undoLimit = 99,
    this.lockAfterPick = false,
    this.timeLimit = 30,
  });
  final List<int> tiles;
  final int target, moves, undoLimit, timeLimit;
  final bool lockAfterPick;
}
