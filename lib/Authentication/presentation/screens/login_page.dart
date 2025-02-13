import 'package:ai_voice_coach/Authentication/presentation/bloc/auth_bloc.dart';
import 'package:ai_voice_coach/Authentication/presentation/widgets/user_input.dart';
import 'package:ai_voice_coach/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LogInPage extends StatelessWidget {
  const LogInPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    // not a GlobalKey<MyCustomFormState>.
    final formKey = GlobalKey<FormState>();

    void login() => BlocProvider.of<AuthenticationBloc>(context).add(
      LoginEvent(
        email: emailController.text,
        password: passwordController.text,
      ),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: SafeArea(
        child: BlocConsumer(
          listener: (context, state) {
            //for taking action
          },
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    UserInput(
                      textEditingController: emailController,
                      textInputType: TextInputType.text,
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
                    TextButton(onPressed: login, child: Text("Sign In")),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
