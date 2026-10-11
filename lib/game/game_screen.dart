import 'dart:async';
import 'package:flutter/material.dart';

import '../main.dart';
import '../storage/local_storage.dart';
import 'models.dart';
import 'puzzle_generator.dart';
import 'sum_of_subsets.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({
    super.key,
    required this.storage,
  });

  final LocalStorage storage;

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with TickerProviderStateMixin {
  late PuzzleLevel level;
  final picked = <int>{};
  final locked = <int>{};
  int undos = 0;
  bool usedHint = false;
  bool done = false;

  Timer? _timer;
  late int secondsRemaining;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;
  late AnimationController _goldFlashController;
  late Animation<double> _goldFlashAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -9.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -9.0, end: 9.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 9.0, end: -7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -7.0, end: 7.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 7.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut));

    _goldFlashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _goldFlashAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _goldFlashController, curve: Curves.easeOutQuad),
    );

    _loadPuzzle(widget.storage.currentStreak);
  }

  void _loadPuzzle(int streak) {
    level = PuzzleGenerator.generate(streak);
    picked.clear();
    locked.clear();
    undos = 0;
    usedHint = false;
    done = false;
    secondsRemaining = level.timeLimit;
    _pulseController.stop();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      if (secondsRemaining > 1) {
        setState(() {
          secondsRemaining--;
          if (secondsRemaining <= 8 && !_pulseController.isAnimating) {
            _pulseController.repeat(reverse: true);
          }
        });
      } else {
        t.cancel();
        _pulseController.stop();
        setState(() {
          secondsRemaining = 0;
        });
        _onTimeUp();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    _shakeController.dispose();
    _goldFlashController.dispose();
    super.dispose();
  }

  int get sum => picked.fold(0, (a, i) => a + level.tiles[i]);

  void tap(int i) {
    if (done || locked.contains(i)) return;
    setState(() {
      if (picked.contains(i)) {
        picked.remove(i);
      } else if (picked.length < 3) {
        picked.add(i);
      }
    });

    final isOver = sum > level.target;
    if (isOver) {
      _shakeController.forward(from: 0.0);
    }

    if (sum == level.target) {
      _win();
    }
  }

  Future<void> _win() async {
    if (done) return;
    _timer?.cancel();
    _pulseController.stop();
    setState(() => done = true);

    final isTwoTile = picked.length == 2;
    if (isTwoTile) {
      _goldFlashController.forward(from: 0.0);
    }

    final timeTaken = level.timeLimit - secondsRemaining;
    final newStreak = await widget.storage.recordWin();

    if (!mounted) return;

    if (newStreak >= 100) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogCtx) => _GrandChampionDialog(
          timeTaken: timeTaken,
          onComplete: () async {
            await widget.storage.resetCurrentStreak();
            if (dialogCtx.mounted) {
              Navigator.pop(dialogCtx);
            }
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      );
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _WinDialog(
        streak: newStreak,
        bestStreak: widget.storage.bestStreak,
        picks: picked.length,
        isTwoTile: isTwoTile,
        timeTaken: timeTaken,
        onNext: () {
          Navigator.pop(context);
          setState(() {
            _loadPuzzle(widget.storage.currentStreak);
          });
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  Future<void> _onTimeUp() async {
    if (done) return;
    _pulseController.stop();
    setState(() => done = true);

    final endedStreak = widget.storage.currentStreak;
    await widget.storage.resetCurrentStreak();

    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _TimeUpDialog(
        endedStreak: endedStreak,
        bestStreak: widget.storage.bestStreak,
        onRetry: () {
          Navigator.pop(context);
          setState(() {
            _loadPuzzle(0);
          });
        },
        onHome: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  void hint() {
    if (usedHint || done) return;
    final answer = SumOfSubsets.minimumSubset(
      level.tiles,
      level.target,
      maxCount: 3,
    );
    if (answer == null || answer.isEmpty) return;
    setState(() {
      usedHint = true;
      picked.clear();
      picked.add(answer.first);
    });
  }

  @override
  Widget build(BuildContext context) {
    final remainingMoves = 3 - picked.length;
    final progress = (secondsRemaining / level.timeLimit).clamp(0.0, 1.0);
    final isUrgent = secondsRemaining <= 8;
    final isTargetHit = sum == level.target;
    final isOverTarget = sum > level.target;
    final tierLabel = PuzzleGenerator.getTierLabel(widget.storage.currentStreak);

    return Scaffold(
      backgroundColor: const Color(0xffF8F7FB),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      _timer?.cancel();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.close),
                    tooltip: 'Exit to menu',
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xff005BFF), Color(0xff6C3BFF)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x336C3BFF),
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt, size: 16, color: Colors.white),
                        const SizedBox(width: 5),
                        Text(
                          'STREAK ${widget.storage.currentStreak}/100',
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.1,
                            color: Colors.white,
                            fontSize: 13,
                          ),
                        ),
                        if (widget.storage.bestStreak > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            'BEST ${widget.storage.bestStreak}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              color: Color(0xffDCD6F7),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => setState(() {
                      picked.clear();
                      locked.clear();
                      undos = 0;
                      usedHint = false;
                    }),
                    icon: const Icon(Icons.refresh),
                    tooltip: 'Reset selection',
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffEDE9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  tierLabel,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: violet,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) => Transform.scale(
                  scale: isUrgent ? _pulseAnimation.value : 1.0,
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: isUrgent
                          ? const Color(0xffEF4444)
                          : const Color(0xffECEAF2),
                      width: isUrgent ? 1.6 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUrgent
                            ? const Color(0x26EF4444)
                            : const Color(0x08000000),
                        blurRadius: isUrgent ? 14 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.timer_outlined,
                                size: 16,
                                color: isUrgent
                                    ? const Color(0xffEF4444)
                                    : const Color(0xff6C3BFF),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                isUrgent ? 'HURRY: TIME RUNNING OUT' : 'TIME REMAINING',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1.2,
                                  color: isUrgent
                                      ? const Color(0xffEF4444)
                                      : const Color(0xff858193),
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '${secondsRemaining}s',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isUrgent ? const Color(0xffEF4444) : ink,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 7,
                          backgroundColor: const Color(0xffF0EEF7),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isUrgent
                                ? const Color(0xffEF4444)
                                : const Color(0xff6C3BFF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'TARGET SUM',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: violet,
                ),
              ),
              const SizedBox(height: 2),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  '${level.target}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 56,
                    height: 1,
                    fontWeight: FontWeight.w900,
                    color: ink,
                    letterSpacing: -1,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedBuilder(
                animation: _shakeAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(_shakeAnimation.value, 0),
                  child: child,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: isTargetHit
                        ? const Color(0xffE6FDF4)
                        : (isOverTarget
                            ? const Color(0xffFEF2F2)
                            : Colors.white),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isTargetHit
                          ? const Color(0xff10B981)
                          : (isOverTarget
                              ? const Color(0xffEF4444)
                              : const Color(0xffECEAF2)),
                      width: isTargetHit || isOverTarget ? 1.8 : 1.0,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isTargetHit
                            ? const Color(0x3310B981)
                            : (isOverTarget
                                ? const Color(0x22EF4444)
                                : const Color(0x0a000000)),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        isTargetHit
                            ? 'TARGET REACHED'
                            : (isOverTarget ? 'EXCEEDED TARGET' : 'CURRENT SUM'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                          color: isTargetHit
                              ? const Color(0xff059669)
                              : (isOverTarget
                                  ? const Color(0xffDC2626)
                                  : const Color(0xff858193)),
                        ),
                      ),
                      const SizedBox(height: 2),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                        child: Text(
                          '$sum',
                          key: ValueKey<int>(sum),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: isTargetHit
                                ? const Color(0xff059669)
                                : (isOverTarget
                                    ? const Color(0xffDC2626)
                                    : ink),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _pill(Icons.touch_app_outlined, '$remainingMoves picks left'),
                  const SizedBox(width: 12),
                  _pill(Icons.auto_awesome, '2-tile or 3-tile solution'),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: AnimatedBuilder(
                      animation: _goldFlashAnimation,
                      builder: (context, child) => Stack(
                        children: [
                          child!,
                          if (_goldFlashController.isAnimating)
                            Positioned.fill(
                              child: IgnorePointer(
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: const Color(0xffF59E0B).withValues(
                                        alpha: 1.0 - _goldFlashAnimation.value,
                                      ),
                                      width: 4.0,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xffF59E0B).withValues(
                                          alpha: (1.0 - _goldFlashAnimation.value) * 0.45,
                                        ),
                                        blurRadius: 24,
                                        spreadRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: level.tiles.length,
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                        ),
                        itemBuilder: (_, i) => _ArcadeTile(
                          value: level.tiles[i],
                          isPicked: picked.contains(i),
                          isLocked: locked.contains(i),
                          onTap: () => tap(i),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: picked.isEmpty
                          ? null
                          : () => setState(() {
                              picked.clear();
                              locked.clear();
                              undos = 0;
                            }),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('CLEAR'),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        side: const BorderSide(color: Color(0xffD8D5E5)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: hint,
                      icon: const Icon(Icons.lightbulb_outline),
                      label: Text(usedHint ? 'HINT USED' : 'HINT'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xff0066FF),
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pill(IconData icon, String s) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xffECEAF2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: const Color(0xff777486)),
            const SizedBox(width: 5),
            Text(
              s,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xff777486),
              ),
            ),
          ],
        ),
      );
}

class _ArcadeTile extends StatefulWidget {
  const _ArcadeTile({
    required this.value,
    required this.isPicked,
    required this.isLocked,
    required this.onTap,
  });

  final int value;
  final bool isPicked;
  final bool isLocked;
  final VoidCallback onTap;

  @override
  State<_ArcadeTile> createState() => _ArcadeTileState();
}

class _ArcadeTileState extends State<_ArcadeTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.92 : (widget.isPicked ? 1.04 : 1.0),
        duration: const Duration(milliseconds: 140),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            gradient: widget.isPicked
                ? const LinearGradient(
                    colors: [Color(0xff0052FF), Color(0xff6C3BFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.isPicked ? null : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.isPicked
                  ? Colors.transparent
                  : const Color(0xffE5E2EE),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.isPicked
                    ? const Color(0x556C3BFF)
                    : const Color(0x10000000),
                blurRadius: widget.isPicked ? 14 : 8,
                offset: widget.isPicked
                    ? const Offset(0, 6)
                    : const Offset(0, 3),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      '${widget.value}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: widget.value >= 1000
                            ? 20
                            : (widget.value >= 100 ? 22 : 26),
                        fontWeight: FontWeight.w900,
                        color: widget.isPicked ? Colors.white : ink,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.isLocked)
                const Positioned(
                  right: 8,
                  top: 8,
                  child: Icon(
                    Icons.lock,
                    size: 13,
                    color: Colors.white70,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WinDialog extends StatelessWidget {
  const _WinDialog({
    required this.streak,
    required this.bestStreak,
    required this.picks,
    required this.isTwoTile,
    required this.timeTaken,
    required this.onNext,
    required this.onHome,
  });

  final int streak, bestStreak, picks;
  final bool isTwoTile;
  final int timeTaken;
  final VoidCallback onNext, onHome;

  @override
  Widget build(BuildContext context) {
    final isNewRecord = streak >= bestStreak && streak > 1;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isTwoTile
                    ? const Color(0xffFEF3C7)
                    : const Color(0xffE6FDF4),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: isTwoTile
                        ? const Color(0x44F59E0B)
                        : const Color(0x2210B981),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                isTwoTile ? Icons.auto_awesome : Icons.check_rounded,
                size: 38,
                color: isTwoTile
                    ? const Color(0xffD97706)
                    : const Color(0xff10B981),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              isTwoTile ? 'PERFECT 2-TILE SOLVE' : 'TARGET HIT',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: isTwoTile
                    ? const Color(0xffD97706)
                    : const Color(0xff10B981),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isTwoTile
                      ? [const Color(0xffF59E0B), const Color(0xffD97706)]
                      : [const Color(0xff0052FF), const Color(0xff6C3BFF)],
                ),
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: isTwoTile
                        ? const Color(0x44D97706)
                        : const Color(0x336C3BFF),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt, color: Colors.white, size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'STREAK: $streak / 100',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            if (isTwoTile) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xffFDE68A)),
                ),
                child: const Text(
                  'OPTIMAL SOLUTION BONUS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Color(0xffB45309),
                  ),
                ),
              ),
            ],
            if (isNewRecord && !isTwoTile) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xffFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'NEW BEST RECORD',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1,
                    color: Color(0xffD97706),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 14),
            Text(
              'Solved in ${timeTaken}s using $picks tiles',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xff777486), fontSize: 13),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: violet,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'NEXT PUZZLE',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onHome,
              child: const Text('BACK TO MENU'),
            ),
          ],
        ),
      ),
    );
  }
}

class _GrandChampionDialog extends StatelessWidget {
  const _GrandChampionDialog({
    required this.timeTaken,
    required this.onComplete,
  });

  final int timeTaken;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xffF59E0B), Color(0xffD97706)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0x55F59E0B),
                    blurRadius: 20,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                size: 52,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'STREAK 100 CHAMPION',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 2,
                color: Color(0xffD97706),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'GRAND VICTORY',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: ink,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'You have conquered all 100 puzzles across single digits, 2-digits, 3-digits, and 4-digits.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xff747486),
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xffD97706),
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'CLAIM VICTORY & FINISH RUN',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeUpDialog extends StatelessWidget {
  const _TimeUpDialog({
    required this.endedStreak,
    required this.bestStreak,
    required this.onRetry,
    required this.onHome,
  });

  final int endedStreak, bestStreak;
  final VoidCallback onRetry, onHome;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(26),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: const BoxDecoration(
                color: Color(0xffFEF2F2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.timer_off_outlined,
                size: 38,
                color: Color(0xffEF4444),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              "TIME'S UP",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Color(0xffEF4444),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              endedStreak > 0
                  ? 'Your streak ended at $endedStreak / 100'
                  : 'Time expired before completing the target.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xff777486), fontSize: 13),
            ),
            const SizedBox(height: 6),
            Text(
              'Best streak: $bestStreak / 100',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: ink,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(
                backgroundColor: violet,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'TRY AGAIN',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: onHome,
              child: const Text('BACK TO MENU'),
            ),
          ],
        ),
      ),
    );
  }
}
