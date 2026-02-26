import 'dart:async';
import 'package:cine_stream/core/services/storage/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController fadeController;
  late AnimationController glowController;
  late Animation<double> fadeAnimation;
  late Animation<double> glowAnimation;

  bool showDots = false;
  bool showTagline = false;
  bool showBottomLine = false;

  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();

    fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: fadeController, curve: Curves.easeOut),
    );

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    glowAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: glowController, curve: Curves.easeInOut),
    );

    fadeController.forward();

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => showDots = true);
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => showTagline = true);
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) setState(() => showBottomLine = true);
    });

    _navigationTimer = Timer(const Duration(seconds: 3), _handleNavigation);
  }

  Future<void> _handleNavigation() async {
    final tokenService = ref.read(tokenServiceProvider);

    final token = await tokenService.getToken();
    final isLoggedIn = token != null && token.isNotEmpty;

    if (!mounted) return;

    Navigator.pushReplacementNamed(
      context,
      isLoggedIn ? "/dashboard" : "/onboarding",
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    fadeController.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Stack(
        children: [
          // ── Logo + dots + tagline ──────────────────────────────────────
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: glowAnimation,
                  child: FadeTransition(
                    opacity: fadeAnimation,
                    child: Image.asset(
                      "assets/images/cinestream-logo.png",
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                AnimatedOpacity(
                  opacity: showDots ? 1 : 0,
                  duration: const Duration(milliseconds: 600),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedDot(delay: 0,   color: colorScheme.primary),
                      const SizedBox(width: 6),
                      AnimatedDot(delay: 300, color: colorScheme.primary),
                      const SizedBox(width: 6),
                      AnimatedDot(delay: 600, color: colorScheme.primary),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                AnimatedOpacity(
                  opacity: showTagline ? 1 : 0,
                  duration: const Duration(milliseconds: 700),
                  child: Text(
                    "STREAM WITHOUT LIMITS",
                    style: textTheme.bodyMedium?.copyWith(
                      letterSpacing: 6,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Bottom accent line ─────────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: showBottomLine ? 1 : 0,
              duration: const Duration(milliseconds: 900),
              child: Container(
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      colorScheme.primary,
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Animated dot ────────────────────────────────────────────────────────────

class AnimatedDot extends StatefulWidget {
  final int delay;
  final Color color;

  const AnimatedDot({super.key, required this.delay, required this.color});

  @override
  State<AnimatedDot> createState() => _AnimatedDotState();
}

class _AnimatedDotState extends State<AnimatedDot>
    with SingleTickerProviderStateMixin {

  late AnimationController controller;
  late Animation<double> anim;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    anim = Tween<double>(begin: 0.3, end: 1).animate(
      CurvedAnimation(parent: controller, curve: Curves.easeInOut),
    );

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) controller.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: anim,
      child: Container(
        height: 8,
        width: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: widget.color,
        ),
      ),
    );
  }
}