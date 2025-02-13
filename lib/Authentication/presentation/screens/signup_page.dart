import 'package:ai_voice_coach/Authentication/presentation/widgets/user_input.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final usernameController = TextEditingController();
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')), // Changed to Sign Up
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            UserInput(
              textEditingController: usernameController,
              textInputType: TextInputType.text,
              hintText: 'xoxo',
              label: 'Username',
            ),
            UserInput(
              textEditingController: emailController,
              textInputType:
                  TextInputType.emailAddress, // Changed to emailAddress
              hintText: 'abac@gmail.com',
              label: 'Email',
            ),
            UserInput(
              textEditingController: passwordController,
              textInputType: TextInputType.text,
              isPass: true,
              hintText: '***',
              label: 'Password',
            ),
            UserInput(
              textEditingController: confirmPasswordController,
              textInputType: TextInputType.text,
              isPass: true,
              hintText: '***',
              label: 'Confirm Password',
            ),
            const SizedBox(height: 16), // Added spacing
            ElevatedButton(
              onPressed: () {
                // Add sign up logic here
              },
              child: const Text("Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
