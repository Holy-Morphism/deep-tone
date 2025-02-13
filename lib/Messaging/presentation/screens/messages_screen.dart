import 'package:flutter/material.dart';

import '../../../shared/drawer.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      drawer: AiDrawer(),
      body: Center(child: Text("Welcome back")),
    );
  }
}
