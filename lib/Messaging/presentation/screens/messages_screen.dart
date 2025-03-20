import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/drawer.dart';
import '../bloc/messaging_bloc.dart';
import '../widgets/generate_button.dart';
import '../widgets/loading_message.dart';
import '../widgets/message.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

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
          appBar: AppBar(title: Text('AI Voice Coach')),
          drawer: AiDrawer(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: GenerateButton(
            state: state,
            generatePassage: generatePassage,
            startRecording: startRecording,
            stopRecording: stopRecording,
          ),
          body: SafeArea(
            child:
                state is LoadingMessagesState
                    ? Center(child: Text('Loading Messages ...'))
                    : state.messages.isEmpty
                    ? Center(
                      child: Text(
                        'No messages yet. Generate a passage to start!',
                      ),
                    )
                    : Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: ListView.builder(
                            itemCount: state.messages.length,
                            padding: EdgeInsets.only(bottom: 80),
                            itemBuilder: (context, index) {
                              return Message(
                                passage: state.messages[index].passage,
                                speechAnalysisMetricsEntity:
                                    state.messages[index].speechAnalysisMetrics,
                                report: state.messages[index].report,
                              );
                            },
                          ),
                        ),
                        LoadingMessage(state: state),
                      ],
                    ),
          ),
        );
      },
    );
  }


}
