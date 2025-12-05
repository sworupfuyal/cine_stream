import 'package:cine_stream/widgets/app_button.dart';
import 'package:cine_stream/widgets/app_text_field.dart';
import 'package:flutter/material.dart';


class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;

  void handleSignIn() {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);

    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                  ),
                ),

                const SizedBox(height: 30),

                AppTextField(
                  controller: usernameController,
                  label: "Username",
                  icon: Icons.person,
                  validator: (vali) =>
                      vali!.isEmpty ? "Please enter your username" : null,
                ),

                const SizedBox(height: 20),

                AppTextField(
                  controller: passwordController,
                  label: "Password",
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (vali) =>
                      vali!.isEmpty ? "Please enter your password" : null,
                ),

                const SizedBox(height: 30),

                AppButton(
                  text: "Sign In",
                  isLoading: isLoading,
                  onPressed: handleSignIn,
                ),

                const SizedBox(height: 25),

                Center(
                  child: TextButton(
                    onPressed: () {

                   
                    Navigator.pushReplacementNamed(context, "/dashboard");

                            
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
