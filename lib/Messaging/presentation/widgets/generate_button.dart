import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/messaging_bloc.dart';

class GenerateButton extends StatelessWidget {
  final VoidCallback stopRecording;
  final VoidCallback startRecording;
  final VoidCallback generatePassage;
  final MessagingState state;
  const GenerateButton({
    super.key,
    required this.state,
    required this.stopRecording,
    required this.startRecording,
    required this.generatePassage,
  });

  @override
  Widget build(BuildContext context) {
    if (state is MicPermissionDeniedState) {
      return FloatingActionButton(
        onPressed:
            () => BlocProvider.of<MessagingBloc>(
              context,
            ).add(GetMicPermissionEvent()),
        backgroundColor: Colors.orange,
        child: Icon(Icons.mic_off),
      );
    }

    if (state is RecordingState) {
      return FloatingActionButton(
        onPressed: () => stopRecording(),
        backgroundColor: Colors.red,
        child: Icon(Icons.stop),
      );
    }

    if (state is ReadingPassageState) {
      return FloatingActionButton(
        onPressed: () => startRecording(),
        backgroundColor: Colors.blue,
        child: Icon(Icons.mic),
      );
    }

    // Default state - generate passage

    return FloatingActionButton.extended(
      onPressed: () => generatePassage(),
      backgroundColor: Colors.green,
      icon: Icon(Icons.description),
      label: Text("Generate Passage", style: TextStyle(color: Colors.white)),
    );
  }
}
