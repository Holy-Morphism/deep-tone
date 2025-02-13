import 'package:ai_voice_coach/injection_container.dart';
import 'package:ai_voice_coach/Authentication/presentation/screens/login_page.dart';
import 'package:ai_voice_coach/Authentication/presentation/screens/signup_page.dart';
import 'package:flutter/material.dart';

void main() async {
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'AI Voice Coach', home: SignUpPage());
  }
}
