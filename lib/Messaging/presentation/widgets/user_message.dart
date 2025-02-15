import 'package:flutter/material.dart';

class UserMessage extends StatelessWidget {
  final String message;
  const UserMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('👤'),
      title: Text('User'),
      subtitle: Text(message),
    );
  }
}
