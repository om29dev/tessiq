import 'package:flutter/material.dart';

import 'game/game_screen.dart';
import 'storage/local_storage.dart';

const violet = Color(0xff6C3BFF);
const cobalt = Color(0xff0052FF);
const ink = Color(0xff181A25);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storage = LocalStorage();
  await storage.load();
  runApp(TessiqApp(storage: storage));
}

class TessiqApp extends StatelessWidget {
  const TessiqApp({super.key, required this.storage});
  final LocalStorage storage;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'TESSIQ',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: violet),
          scaffoldBackgroundColor: const Color(0xffF8F7FB),
        ),
        home: HomeScreen(storage: storage),
      );
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.storage});
  final LocalStorage storage;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _start() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GameScreen(storage: widget.storage),
      ),
    ).then((_) => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF8F7FB),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const _Logo(),
                const SizedBox(height: 26),
                Text(
                  'Think Smart.\nHit the Target.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontWeight: FontWeight.w900,
                        color: ink,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Beat the 30s timer. Reach the ultimate streak of 100.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xff747486),
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 26,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xffECEAF2)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0e000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _streakStat(
                        label: 'CURRENT STREAK',
                        value: '${widget.storage.currentStreak} / 100',
                        icon: Icons.bolt,
                        color: violet,
                      ),
                      Container(
                        height: 44,
                        width: 1,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        color: const Color(0xffECEAF2),
                      ),
                      _streakStat(
                        label: 'BEST STREAK',
                        value: '${widget.storage.bestStreak} / 100',
                        icon: Icons.emoji_events_outlined,
                        color: const Color(0xffD97706),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 36),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 320),
                  child: Column(
                    children: [
                      _AnimatedPrimaryButton(
                        label: widget.storage.currentStreak > 0
                            ? 'CONTINUE (${widget.storage.currentStreak}/100)'
                            : 'START PLAYING',
                        onPressed: _start,
                      ),
                      if (widget.storage.currentStreak > 0) ...[
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () async {
                            await widget.storage.resetCurrentStreak();
                            setState(() {});
                            _start();
                          },
                          child: const Text(
                            'START FRESH RUN',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xff747486),
                              letterSpacing: .5,
                            ),
                          ),
                        ),
                      ],
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xffECEAF2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          '1-DIGIT TO 4-DIGITS : REACH STREAK 100',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            letterSpacing: 1.1,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xff6C687E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _streakStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: Color(0xff858193),
            ),
          ),
        ],
      );
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x16000000),
                  blurRadius: 22,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: Image.asset(
              'assets/logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'TESSIQ',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: 4,
              color: ink,
            ),
          ),
        ],
      );
}

class _AnimatedPrimaryButton extends StatefulWidget {
  const _AnimatedPrimaryButton({
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  State<_AnimatedPrimaryButton> createState() => _AnimatedPrimaryButtonState();
}

class _AnimatedPrimaryButtonState extends State<_AnimatedPrimaryButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onPressed();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOutCubic,
          child: Container(
            height: 56,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [cobalt, violet],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x386C3BFF),
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
                fontSize: 15,
                letterSpacing: .6,
              ),
            ),
          ),
        ),
      );
}
