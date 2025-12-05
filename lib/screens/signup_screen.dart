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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Signup Successful")));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                const Center(
                  child: Text(
                    "Welcome to Cinestream",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                const Center(
                  child: Text(
                    "STREAM WITHOUT LIMITS",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                const Text(
                  "Create Account",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                  ),
                ),

                const SizedBox(height: 30),

                AppTextField(
                  controller: usernameController,
                  label: "Username",
                  icon: Icons.person,
                  validator: (v) =>
                      v!.isEmpty ? "Please enter a username" : null,
                ),

                const SizedBox(height: 20),

                AppTextField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (v) =>
                      v!.length < 6 ? "Password must be at least 6 characters" : null,
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

                const SizedBox(height: 30),

                AppButton(
                  text: "Sign Up",
                  isLoading: isLoading,
                  onPressed: handleSignup,
                ),

                const SizedBox(height: 25),

                Center(
                  child: TextButton(
                    onPressed: () {
  Navigator.pushReplacementNamed(context, "/signin");

                        
                    },
                    child: const Text(
                      "Already a member? Sign In",
                      style: TextStyle(color: Colors.white70),
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
