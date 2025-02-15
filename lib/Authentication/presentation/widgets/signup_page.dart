import 'package:deeptone/Authentication/presentation/widgets/user_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/auth_bloc.dart';

class SignUpPage extends StatelessWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final usernameController = TextEditingController();

    void signup() => BlocProvider.of<AuthenticationBloc>(context).add(
      SignUpEvent(
        email: emailController.text,
        password: passwordController.text,
        username: usernameController.text,
      ),
    );

    void showSnackBar(String message) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }

    return BlocConsumer<AuthenticationBloc, AuthenticationState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          showSnackBar(state.message);
        }
      },
      builder: (context, state) {
        return Padding(
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
              ElevatedButton(onPressed: signup, child: const Text("Sign Up")),
            ],
          ),
        );
      },
    );
  }
}
