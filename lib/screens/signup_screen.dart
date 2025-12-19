import 'package:cine_stream/widgets/app_button.dart';
import 'package:cine_stream/widgets/app_text_field.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool isLoading = false;

  void handleSignup() {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

      Future.delayed(const Duration(seconds: 2), () {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Account created successfully")),
        );
        Navigator.pushReplacementNamed(context, "/signin");
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

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

                AppTextField(
                  controller: usernameController,
                  label: "Username",
                  icon: Icons.person,
                  validator: (v) =>
                      v == null || v.isEmpty ? "Username is required" : null,
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
                    if (v.length < 6) {
                      return "Minimum 6 characters required";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                AppTextField(
                  controller: confirmPasswordController,
                  label: "Confirm Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Please confirm your password";
                    }
                    if (v != passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 35),

                AppButton(
                  text: "Sign Up",
                  isLoading: isLoading,
                  onPressed: handleSignup,
                ),

                const SizedBox(height: 30),

                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacementNamed(context, "/signin");
                    },
                    child: Text(
                      "Already have an account? Sign In",
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
