
import 'package:cine_stream/features/auth/domain/usecases/login_usecases.dart';
import 'package:cine_stream/features/auth/domain/usecases/register_usecases.dart';
import 'package:cine_stream/features/auth/presentation/pages/signin_screen.dart';
import 'package:cine_stream/widgets/app_button.dart';
import 'package:cine_stream/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mocktail/mocktail.dart';

// Mock NavigatorObserver to track navigation
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}


void main() {
  late MockRegisterUsecase mockRegisterUsecase;
  late MockLoginUsecase mockLoginUsecase;


  setUp(() {
    mockRegisterUsecase = MockRegisterUsecase();
    mockLoginUsecase = MockLoginUsecase();

  });

  Widget createTestWidget() {
    return ProviderScope(
      overrides: [
        registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
        loginUsecasesProvider.overrideWithValue(mockLoginUsecase),
      
      ],
      child: MaterialApp(
        home: const SignInScreen(),
        routes: {
          '/dashboard': (context) => const Scaffold(body: Text('Dashboard')),
          '/signup': (context) => const Scaffold(body: Text('Sign Up')),
        },
      ),
    );
  }

  group('SignInScreen UI Elements', () {
    testWidgets('should display welcome text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Welcome Back'), findsOneWidget);
    });

    testWidgets('should display email and password labels', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
    });

    testWidgets('should display sign in button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Sign In'), findsOneWidget);
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('should display two app text fields', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(AppTextField), findsNWidgets(2));
    });

    testWidgets('should display email icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('should display lock icon', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.lock), findsOneWidget);
    });

    testWidgets('should display forgot password button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.byType(TextButton), findsNWidgets(2)); 
    });

    testWidgets('should display signup link text', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text("Don't have an account? Sign Up"), findsOneWidget);
    });
  });

}