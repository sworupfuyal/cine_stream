import 'package:cine_stream/features/auth/presentation/state/auth_state.dart';
import 'package:cine_stream/features/auth/presentation/view_model/auth_view_model.dart';
import 'package:cine_stream/widgets/app_button.dart';
import 'package:cine_stream/widgets/app_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SignInScreen extends ConsumerStatefulWidget {
  const SignInScreen({super.key});

  @override
  ConsumerState<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends ConsumerState<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> handleSignIn() async {
    if (_formKey.currentState!.validate()) {
      await ref.read(authViewModelProvider.notifier).login(
            userName: usernameController.text,
            password: passwordController.text,
          );
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _navigateToDashboard() {
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, "/dashboard");
  }

  @override
  void dispose() {
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Watch auth state
    final authState = ref.watch(authViewModelProvider);

    // Listen for state changes
    ref.listen<AuthState>(
      authViewModelProvider,
      (previous, next) {
        if (next.status == AuthStatus.error) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showSnackBar(
              next.errorMessage ?? 'Login Failed',
              Colors.red,
            );
          });
        } else if (next.status == AuthStatus.authenticated) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _navigateToDashboard();
          });
        }
      },
    );

    // Get loading state from auth state
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Text(
                  "Welcome Back",
                  style: theme.textTheme.headlineLarge,
                ),

                const SizedBox(height: 30),

                AppTextField(
                  controller: usernameController,
                  label: "Username",
                  icon: Icons.person,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Username is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                AppTextField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Password is required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 10),

                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password screen
                      // Navigator.pushNamed(context, "/forgot-password");
                    },
                    child: Text(
                      "Forgot Password?",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                AppButton(
                  text: "Sign In",
                  isLoading: isLoading,
                  onPressed:  handleSignIn,
                ),

                const SizedBox(height: 25),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/signup");
                    },
                    child: Text(
                      "Don't have an account? Sign Up",
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}