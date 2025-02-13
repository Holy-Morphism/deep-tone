import 'package:flutter/material.dart';

import '../widgets/login_page.dart';
import '../widgets/signup_page.dart';
import '../widgets/switch_button.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  int index = 0;
  static const List<String> question = [
    'Already have an account?',
    'Don\'t have an account?',
  ];
  static const List<String> buttonText = ['Log In', 'Sign Up'];
  void switchPage(int page) {
    setState(() {
      index = page;
      controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 500),
        curve: Curves.ease,
      );
    });
  }

  final PageController controller = PageController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(elevation: 0),
      bottomNavigationBar: BottomAppBar(
        surfaceTintColor: Colors.white,
        child: SwitchButton(
          question: question[index],
          buttonText: buttonText[index],
          switchPage: switchPage,
          index: index == 0 ? 1 : 0,
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: controller,
          onPageChanged: switchPage,
          children: const [SignUpPage(), LogInPage()],
        ),
      ),
    );
  }
}
