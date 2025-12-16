import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/signin_screen.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      routes: {
        "/splash": (_) => const SplashScreen(),
        "/onboarding": (_) => const OnboardingScreen(),
        "/signup": (_) => const SignupScreen(),
        "/signin": (_) => const SignInScreen(),
        "/dashboard": (_) => const BottomNavigationScreen(),
      },
    );
  }
}
