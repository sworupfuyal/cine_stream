import 'package:cine_stream/core/services/hive/hive_service.dart';
import 'package:cine_stream/core/services/storage/user_session_service.dart';
import 'package:cine_stream/features/auth/presentation/pages/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Add this import

import 'themes/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'features/auth/presentation/pages/signup_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize HiveService
  final hiveService = HiveService();
  await hiveService.init();

  // Initialize SharedPreferences
  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences), // Override SharedPreferences
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
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