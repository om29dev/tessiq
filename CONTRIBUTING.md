# Contributing to TESSIQ

First off, thank you for considering contributing to **TESSIQ**! Every contribution, whether it's a bug fix, a gameplay improvement, a test, or a new idea, helps make the game better.

TESSIQ is a fast-paced number puzzle game built with Flutter and Dart, where players solve target-sum challenges on a 3×3 grid. Contributions that improve gameplay, reliability, performance, accessibility, and code quality are welcome.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [How to Contribute](#how-to-contribute)
- [Coding Guidelines](#coding-guidelines)
- [Testing Your Changes](#testing-your-changes)
- [Reporting Bugs](#reporting-bugs)
- [Suggesting Features](#suggesting-features)
- [Pull Request Guidelines](#pull-request-guidelines)
- [Community Guidelines](#community-guidelines)

## Getting Started

Before contributing, make sure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed.
- A compatible Dart SDK, included with Flutter.
- Git installed and configured.
- An IDE such as [Visual Studio Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio).

Basic familiarity with Flutter, Dart, and Git is recommended.

## Development Setup

### 1. Fork the Repository

Fork the [TESSIQ repository](https://github.com/om29dev/tessiq) to your GitHub account.

### 2. Clone Your Fork

```bash
git clone https://github.com/<your-username>/tessiq.git
cd tessiq
```

Replace `<your-username>` with your GitHub username.

### 3. Add the Upstream Repository

```bash
git remote add upstream https://github.com/om29dev/tessiq.git
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the Application

Connect an Android device or start an emulator, then run:

```bash
flutter run
```

You are now ready to explore the codebase and make changes.

## Project Structure

The project is organized into focused modules:

```text
lib/
├── main.dart
├── game/
│   ├── game_screen.dart
│   ├── puzzle_generator.dart
│   ├── models.dart
│   ├── sum_of_subsets.dart
│   └── levels.dart
└── storage/
    └── local_storage.dart

assets/
└── logo.png

test/
├── puzzle_generator_test.dart
└── sum_of_subsets_test.dart
```

- **game_screen.dart:** Core gameplay, timer, grid, and animations.
- **puzzle_generator.dart:** Puzzle generation and solution guarantees.
- **sum_of_subsets.dart:** Backtracking-based subset-sum solving.
- **models.dart:** Puzzle data models.
- **levels.dart:** Fallback level definitions.
- **local_storage.dart:** Persistent streak and progress data.
- **test/:** Automated tests for puzzle generation and subset-sum logic.

## How to Contribute

### 1. Find or Discuss an Issue

Check the existing [issues](https://github.com/om29dev/tessiq/issues) before starting work. If your proposed change is substantial, open an issue to discuss the approach first.

### 2. Create a Branch

Use a descriptive branch name:

```bash
git checkout -b fix/puzzle-generation
```

Other examples:

- `feat/new-game-mode`
- `fix/timer-behavior`
- `test/subset-sum`
- `docs/improve-readme`

### 3. Make Your Changes

Keep changes focused and avoid unrelated modifications. Preserve TESSIQ's core gameplay principles unless a change intentionally proposes a new direction.

### 4. Test Your Changes

Run the available analysis and tests before submitting your work:

```bash
flutter analyze
flutter test
```

Also run the app and manually verify gameplay changes when applicable.

### 5. Commit Your Changes

Write clear, descriptive commit messages:

```bash
git add .
git commit -m "fix: ensure valid puzzle solutions"
```

### 6. Push and Open a Pull Request

```bash
git push origin fix/puzzle-generation
```

Open a pull request against the `main` branch of the original repository and explain what you changed and why.

## Coding Guidelines

Please follow these guidelines when contributing:

- **Follow Dart conventions:** Use the official [Effective Dart](https://dart.dev/effective-dart) guidelines.
- **Keep code readable:** Prefer clear names, small functions, and focused responsibilities.
- **Preserve correctness:** Puzzle generation must respect the game's solution requirements.
- **Handle edge cases:** Consider duplicate values, invalid selections, timer expiration, and boundary conditions.
- **Avoid unnecessary dependencies:** Prefer existing Flutter and Dart capabilities when practical.
- **Maintain consistency:** Follow the existing architecture and coding style.
- **Add tests:** Include automated tests for new logic and bug fixes whenever practical.
- **Protect user progress:** Changes to persistence should not unintentionally reset existing streak records or saved progress.

For puzzle-generation changes, pay particular attention to the guarantee that every generated puzzle has at least one valid two-tile solution and one valid three-tile solution.

## Testing Your Changes

TESSIQ uses Flutter's testing tools.

Run static analysis:

```bash
flutter analyze
```

Run all automated tests:

```bash
flutter test
```

Run a specific test file:

```bash
flutter test test/puzzle_generator_test.dart
```

When applicable, verify:

- Generated puzzles contain valid solutions.
- Target sums are calculated correctly.
- Tile selections obey the three-tile limit.
- The countdown and timeout behavior work correctly.
- Streaks update and persist as expected.
- The optimal two-tile bonus triggers only under the intended conditions.
- Difficulty progression behaves correctly across all 100 levels.

## Reporting Bugs

Found something that does not work as expected? Please [open an issue](https://github.com/om29dev/tessiq/issues/new/choose) and include:

- **Summary:** A clear description of the problem.
- **Steps to reproduce:** How to trigger the issue.
- **Expected behavior:** What you expected to happen.
- **Actual behavior:** What happened instead.
- **Environment:** Device, operating system, and Flutter version, if relevant.
- **Evidence:** Screenshots, screen recordings, or error logs when available.

Please check existing issues first to avoid duplicates.

## Suggesting Features

Have an idea that could make TESSIQ more enjoyable?

Feature suggestions are welcome, including:

- New puzzle modes or challenges.
- Improvements to difficulty progression.
- Better animations and feedback.
- Accessibility and usability enhancements.
- Performance improvements.
- Additional puzzle-generation strategies.

When proposing a feature, explain the problem it solves, how it could work, and how it would fit into the existing game.

For major gameplay changes, please discuss the idea in an issue before submitting a pull request.

## Pull Request Guidelines

Before submitting a pull request, make sure that:

1. Your branch is based on the latest relevant version of `main`.
2. Your changes have a clear purpose and scope.
3. The code follows the project's conventions.
4. `flutter analyze` passes without new issues.
5. Relevant tests have been added or updated.
6. Existing gameplay and puzzle-generation guarantees remain intact.
7. Documentation has been updated when necessary.
8. You have provided a clear description of your changes.

A good pull request should explain:

1. What changed?
2. Why was the change needed?
3. How was it tested?
4. Are there any limitations or follow-up tasks?

Pull requests may receive feedback or requests for changes before being merged.

## Community Guidelines

Please help keep the TESSIQ community welcoming and constructive.

- Be respectful and considerate.
- Provide useful, actionable feedback.
- Focus discussions on ideas and implementations, not individuals.
- Respect differing opinions and collaborate professionally.
- Report bugs and security concerns responsibly.

## Questions?

If you have questions, ideas, or feedback, visit the open an issue.

Thank you for helping improve TESSIQ.
