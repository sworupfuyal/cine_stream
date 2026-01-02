import 'package:cine_stream/widgets/app_button.dart';
import 'package:cine_stream/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../state/auth_state.dart';
import '../view_model/auth_view_model.dart';

class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  // Form key
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  late final TextEditingController usernameController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Signup handler - synchronous wrapper
  void handleSignup() {
    if (!_formKey.currentState!.validate()) return;
    
    // Call async method without awaiting
    ref.read(authViewModelProvider.notifier).register(
      userName: usernameController.text.trim(),
      password: passwordController.text.trim(),
    );
  }

  // Show snackbar safely
  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    });
  }

  // Navigate safely
  void _navigateToSignIn() {
    if (!mounted) return;
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Navigator.pushReplacementNamed(context, "/signin");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes safely
    ref.listen<AuthState>(
      authViewModelProvider,
      (previous, next) {
        if (next.status == AuthStatus.registered) {
          _showSnackBar("Account created successfully", Colors.green);
          _navigateToSignIn();
        }

        if (next.status == AuthStatus.error) {
          _showSnackBar(
            next.errorMessage ?? "Registration failed",
            Colors.red,
          );
        }
      },
    );

    final theme = Theme.of(context);
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            AbsorbPointer(
              absorbing: isLoading,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(22),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 30),

                      // Welcome Header
                      Center(
                        child: Column(
                          children: [
                            Text(
                              "Welcome to CineStream",
                              style: theme.textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 6),
                            Text(
                              "STREAM WITHOUT LIMITS",
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 50),

                      Text(
                        "Create Account",
                        style: theme.textTheme.headlineLarge,
                      ),

                      const SizedBox(height: 30),

                      // Username
                      AppTextField(
                        controller: usernameController,
                        label: "Username",
                        icon: Icons.person,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Username is required" : null,
                      ),

                      const SizedBox(height: 20),

                      // Password
                      AppTextField(
                        controller: passwordController,
                        label: "Password",
                        icon: Icons.lock,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Password is required";
                          if (v.length < 6) return "Minimum 6 characters required";
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      // Confirm Password
                      AppTextField(
                        controller: confirmPasswordController,
                        label: "Confirm Password",
                        icon: Icons.lock_outline,
                        isPassword: true,
                        validator: (v) {
                          if (v == null || v.isEmpty) return "Confirm your password";
                          if (v != passwordController.text) {
                            return "Passwords do not match";
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 35),

                      // Register button
                      AppButton(
                        text: isLoading ? "Creating Account..." : "Register",
                        onPressed: handleSignup,
                      ),

                      const SizedBox(height: 30),

                      // Navigate to Sign In
                      Center(
                        child: TextButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  Navigator.pushReplacementNamed(context, "/signin");
                                },
                          child: const Text("Already have an account? Sign In"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Loading overlay
            if (isLoading)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}