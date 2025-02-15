import 'package:flutter/material.dart';

class ModelMessage extends StatelessWidget {
  final String message;
  const ModelMessage({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Text('🤖'),
      title: Text('Model'),
      subtitle: Text(message),
    );
  }
}
