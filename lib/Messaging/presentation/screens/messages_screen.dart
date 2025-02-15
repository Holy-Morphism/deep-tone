import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/drawer.dart';
import '../bloc/messaging_bloc.dart';
import '../widgets/model_message.dart';
import '../widgets/response_loading.dart';

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
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton:
              state is GettingMicPermissionState
                  ? null
                  : FloatingActionButton(
                    onPressed:
                        state is RecordingState
                            ? stopRecording
                            : startRecording,
                    backgroundColor:
                        state is RecordingState ? Colors.red : Colors.blue,
                    child: Icon(
                      state is RecordingState ? Icons.stop : Icons.mic,
                    ),
                  ),
          body:
              state is GettingMicPermissionState
                  ? Center(child: Text('Geetting Mic permission'))
                  : state is MessageSuccesState
                  ? ModelMessage(modelMessageEntity: state.modelMessageEntity)
                  : state is MessagingLoadingState
                  ? ResponseLoading()
                  : null,
        );
      },
    );
  }
}
