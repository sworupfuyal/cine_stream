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
  
  // ScaffoldMessenger key for safe snackbar access
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Text controllers
  late final TextEditingController usernameController;
  late final TextEditingController emailController;
  late final TextEditingController passwordController;
  late final TextEditingController confirmPasswordController;

  // Track if we've already handled the success to prevent duplicate actions
  bool _hasHandledSuccess = false;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  // Signup handler
  void handleSignup() {
    // Reset the success flag when starting a new registration
    _hasHandledSuccess = false;
    
    if (!_formKey.currentState!.validate()) return;

    ref.read(authViewModelProvider.notifier).register(
      fullName: usernameController.text.trim(),
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      confirmPassword: confirmPasswordController.text.trim(),
    );
  }

  void _handleSuccess() {
    // Prevent duplicate handling
    if (_hasHandledSuccess || _isNavigating) return;
    _hasHandledSuccess = true;
    _isNavigating = true;

    // Use the ScaffoldMessenger key directly
    _scaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: Text("Account created successfully"),
        backgroundColor: Colors.green,
        duration: Duration(milliseconds: 1500),
      ),
    );

    // Navigate after a short delay
    Future.delayed(const Duration(milliseconds: 800), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/signin");
    });
  }

  void _handleError(String message) {
    // Don't show error if we're already navigating away
    if (_isNavigating) return;
    
    // Use the ScaffoldMessenger key directly
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Listen to auth state changes
    ref.listen<AuthState>(
      authViewModelProvider,
      (previous, next) {

          print('Auth Status Changed: ${next.status}'); // Add this
          print('Error Message: ${next.errorMessage}'); 
        if (next.status == AuthStatus.registered) {
          _handleSuccess();
        } else if (next.status == AuthStatus.error) {
          _handleError(next.errorMessage ?? "Registration failed");
        }
      },
    );

    final theme = Theme.of(context);
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return ScaffoldMessenger(
      key: _scaffoldMessengerKey,
      child: Scaffold(
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

                      // Full Name
                      AppTextField(
                        controller: usernameController,
                        label: "Full Name",
                        icon: Icons.person,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Full name is required" : null,
                      ),

                      const SizedBox(height: 20),

                      // Email
                      AppTextField(
                        controller: emailController,
                        label: "Email",
                        icon: Icons.email,
                        validator: (v) =>
                            v == null || v.isEmpty ? "Email is required" : null,
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
    ));
  }
}