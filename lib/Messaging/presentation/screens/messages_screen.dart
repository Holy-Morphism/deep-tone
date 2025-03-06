import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/drawer.dart';
import '../bloc/messaging_bloc.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    void startRecording() {
      print('Recording started in screen');
      BlocProvider.of<MessagingBloc>(context).add(StartRecordingEvent());
    }

    void stopRecording() =>
        BlocProvider.of<MessagingBloc>(context).add(StopRecordingEvent());

    void generatePassage() =>
        BlocProvider.of<MessagingBloc>(context).add(GeneratePassageEvent());

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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton:
              state is GettingMicPermissionState
                  ? null
                  : FloatingActionButton(
                    onPressed:
                        state is RecordingState
                            ? stopRecording
                            : state is ReadingPassageState
                            ? startRecording
                            : generatePassage,
                    backgroundColor:
                        state is RecordingState
                            ? Colors.red
                            : state is ReadingPassageState
                            ? Colors.blue
                            : Colors.green,
                    child:
                        state is ReadingPassageState
                            ? Icon(
                              state is RecordingState ? Icons.stop : Icons.mic,
                            )
                            : Text(
                              "Generate Passage",
                              style: TextStyle(color: Colors.white),
                            ),
                  ),
          body: SafeArea(child: Center(child: Text("Welcome Back !"))),
        );
      },
    );
  }
}
