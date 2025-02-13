import 'package:ai_voice_coach/injection_container.dart';
import 'package:flutter/material.dart';
import 'router/router.dart';

void main() async {
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(title: 'AI Voice Coach', routerConfig: router);
  }
}
