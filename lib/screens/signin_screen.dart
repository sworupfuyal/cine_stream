import 'package:cine_stream/widgets/app_button.dart';
import 'package:cine_stream/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  void handleSignIn() {
    Navigator.pushReplacementNamed(context, "/dashboard");
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),

              // Heading uses headlineLarge from theme (with custom font)
              Text(
                "Welcome Back",
                style: theme.textTheme.headlineLarge,
              ),

              const SizedBox(height: 30),

              // Username field
              AppTextField(
                controller: usernameController,
                label: "Username",
                icon: Icons.person,
              ),

              const SizedBox(height: 20),

              // Password field
              AppTextField(
                controller: passwordController,
                label: "Password",
                icon: Icons.lock,
                isPassword: true,
              ),

              const SizedBox(height: 30),

              // Sign In button uses theme’s ElevatedButton style
              AppButton(
                text: "Sign In",
                onPressed: handleSignIn,
              ),

              const SizedBox(height: 25),

              // Sign Up text uses bodyMedium from theme
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
    );
  }
}
