import 'package:cine_stream/core/services/hive/hive_service.dart';
import 'package:cine_stream/core/services/storage/user_session_service.dart';
import 'package:cine_stream/core/providers/theme_provider.dart'; // Add this
import 'package:cine_stream/features/auth/presentation/pages/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'themes/theme.dart';
import 'screens/splash_screen.dart';
import 'screens/onboarding_screen.dart';
import 'features/auth/presentation/pages/signup_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final hiveService = HiveService();
  await hiveService.init();

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget { // Changed from StatelessWidget
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // Added WidgetRef
    final isDark = ref.watch(themeProvider);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: isDark ? AppTheme.darkTheme : AppTheme.lightTheme, // Reactive
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