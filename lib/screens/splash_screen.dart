import 'dart:async';
import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {

  late AnimationController fadeController;
  late AnimationController glowController;
  late Animation<double> fadeAnimation;
  late Animation<double> glowAnimation;

  bool showDots = false;
  bool showTagline = false;
  bool showBottomLine = false;

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
      setState(() => showDots = true);
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() => showTagline = true);
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() => showBottomLine = true);
    });

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, "/onboarding");
    });
  }

  @override
  void dispose() {
    fadeController.dispose();
    glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.black,
          ),

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
                    children: const [
                      AnimatedDot(delay: 0),
                      SizedBox(width: 6),
                      AnimatedDot(delay: 300),
                      SizedBox(width: 6),
                      AnimatedDot(delay: 600),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                AnimatedOpacity(
                  opacity: showTagline ? 1 : 0,
                  duration: const Duration(milliseconds: 700),
                  child: const Text(
                    "STREAM WITHOUT LIMITS",
                    style: TextStyle(
                      letterSpacing: 6,
                      fontSize: 12,
                      color: Colors.white60,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedOpacity(
              opacity: showBottomLine ? 1 : 0,
              duration: const Duration(milliseconds: 900),
              child: Container(
                height: 1,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.blue,
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class AnimatedDot extends StatefulWidget {
  final int delay;
  const AnimatedDot({super.key, required this.delay});

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
      controller.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: anim,
      child: Container(
        height: 8,
        width: 8,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.blue,
        ),
      ),
    );
  }
}
