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
    fadeAnimation =
        Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(
      parent: fadeController,
      curve: Curves.easeOut,
    ));

    glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    glowAnimation = Tween<double>(begin: 0.85, end: 1.15)
        .animate(CurvedAnimation(
      parent: glowController,
      curve: Curves.easeInOut,
    ));

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

          Positioned(
            top: -120,
            left: MediaQuery.of(context).size.width / 2 - 120,
            child: AnimatedGlowOrb(
              size: 240,
              delay: 0,
              color: Colors.blueAccent.withOpacity(0.2),
            ),
          ),

          Positioned(
            bottom: -80,
            left: MediaQuery.of(context).size.width / 2 - 180,
            child: AnimatedGlowOrb(
              size: 300,
              delay: 3,
              color: Colors.purpleAccent.withOpacity(0.15),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).size.height * 0.33,
            left: -60,
            child: AnimatedGlowOrb(
              size: 180,
              delay: 1.5,
              color: Colors.redAccent.withOpacity(0.12),
            ),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.blue.withOpacity(0.3),
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



class AnimatedGlowOrb extends StatefulWidget {
  final double size;
  final double delay;
  final Color color;

  const AnimatedGlowOrb({
    super.key,
    required this.size,
    required this.delay,
    required this.color,
  });

  @override
  State<AnimatedGlowOrb> createState() => _AnimatedGlowOrbState();
}

class _AnimatedGlowOrbState extends State<AnimatedGlowOrb>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;
  late Animation<double> floatAnim;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    floatAnim = Tween<double>(begin: -8, end: 8)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));

    Future.delayed(Duration(seconds: widget.delay.round()), () {
      controller.repeat(reverse: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatAnim,
      builder: (_, __) {
        return Transform.translate(
          offset: Offset(0, floatAnim.value),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: widget.color,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: widget.color,
                  blurRadius: widget.size / 2,
                  spreadRadius: widget.size / 3,
                )
              ],
            ),
          ),
        );
      },
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
