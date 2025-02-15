import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/drawer.dart';
import '../../../shared/snackbar.dart';
import '../bloc/messaging_bloc.dart';
import '../widgets/model_message.dart';
import '../widgets/user_message.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

const List messages = [
  {
    "user": "Hello! I need help improving my singing technique.",
    "model":
        "Hello! I'm here to help you with your singing. What specific aspect would you like to work on?",
  },
  {
    "user": "I'm having trouble hitting high notes without straining.",
    "model":
        "That's a common issue. Let's start with some breathing exercises and proper vocal support techniques. First, ensure you're breathing from your diaphragm.",
  },
  {
    "user": "How do I know if I'm breathing correctly?",
    "model":
        "Place your hand on your stomach. When you breathe, your stomach should expand, not your chest. Try lying on your back and practice this breathing technique for 5 minutes.",
  },
  {
    "user": "That feels different! What's next?",
    "model":
        "Great! Now let's try some gentle vocal exercises starting in your comfortable range. We'll gradually work our way up while maintaining that proper breath support.",
  },
  {
    "user": "Can you suggest some specific exercises?",
    "model":
        "Start with sirens (sliding from low to high notes) using 'ng' sound. Then try 'mee-meh-mah-moh-moo' exercises, keeping your jaw relaxed and maintaining consistent breath support.",
  },
];

class _MessagingScreenState extends State<MessagingScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void startRecording() {
      print('Recodding tarted in screen');
      BlocProvider.of<MessagingBloc>(context).add(StartRecordingEvent());
    }

    void stopRecording() =>
        BlocProvider.of<MessagingBloc>(context).add(StopRecordingEvent());

    return BlocConsumer<MessagingBloc, MessagingState>(
      listener: (context, state) {
        if (state is MessagingErrorState) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(),
          drawer: AiDrawer(),
          floatingActionButton: Align(
            alignment: Alignment.bottomCenter,
            child: FloatingActionButton(
              onPressed:
                  state is RecordingState ? stopRecording : startRecording,
              backgroundColor:
                  state is RecordingState ? Colors.red : Colors.blue,
              child: Icon(state is RecordingState ? Icons.stop : Icons.mic),
            ),
          ),
          body: ListView.builder(
            controller: _scrollController,
            itemCount: messages.length,
            padding: const EdgeInsets.all(8.0),
            itemBuilder: (context, item) {
              return Column(
                children: [
                  UserMessage(message: messages[item]['user']),
                  const Divider(),
                  ModelMessage(message: messages[item]['model']),
                  const Divider(),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
