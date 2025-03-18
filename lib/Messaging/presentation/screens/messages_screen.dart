import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../shared/drawer.dart';
import '../../domain/entities/message_entity.dart';
import '../bloc/messaging_bloc.dart';
import '../widgets/message.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  @override
  void initState() {
    super.initState();
    // Load existing messages when screen initializes
    BlocProvider.of<MessagingBloc>(context).add(LoadMessagesEvent());
  }

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
          appBar: AppBar(title: Text('AI Voice Coach')),
          drawer: AiDrawer(),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: _buildFloatingActionButton(
            state: state,
            generatePassage: generatePassage,
            startRecording: startRecording,
            stopRecording: stopRecording,
          ),
          body: SafeArea(
            child: Column(
              children: [
                _buildProcessingStatus(state),
                Expanded(child: _buildMessagesList(state)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildFloatingActionButton({
    required MessagingState state,
    required Function generatePassage,
    required Function startRecording,
    required Function stopRecording,
  }) {
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
    if (!(state is AnalysisState ||
        state is GeneratingReportState ||
        state is GeneratingPassageState)) {
      return FloatingActionButton.extended(
        onPressed: () => generatePassage(),
        backgroundColor: Colors.green,
        icon: Icon(Icons.description),
        label: Text("Generate Passage", style: TextStyle(color: Colors.white)),
      );
    }

    // For states where we don't want any button
    return SizedBox();
  }

  Widget _buildProcessingStatus(MessagingState state) {
    if (state is GeneratingPassageState) {
      return _buildStatusIndicator('Generating passage...');
    } else if (state is AnalysisState) {
      return _buildStatusIndicator('Analyzing your speech...');
    } else if (state is GeneratingReportState) {
      return _buildStatusIndicator('Generating your report...');
    }
    return SizedBox.shrink(); // Return empty widget when not in loading state
  }

  Widget _buildStatusIndicator(String message) {
    return Container(
      padding: EdgeInsets.all(8),
      color: Colors.amber.shade100,
      width: double.infinity,
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 10),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildMessagesList(MessagingState state) {
    if (state is MessageSuccesState ||
        state is ReadingPassageState ||
        state is RecordingState) {
      List<MessageEntity> messages = _getMessagesForState(state);

      return messages.isEmpty
          ? Center(child: Text('No messages yet. Generate a passage to start!'))
          : ListView.builder(
            itemCount: messages.length,
            padding: EdgeInsets.only(bottom: 80), // Add padding for FAB
            itemBuilder: (context, index) {
              return Message(
                passage: messages[index].passage,
                speechAnalysisMetricsEntity:
                    messages[index].speechAnalysisMetrics,
                report: messages[index].report,
              );
            },
          );
    }

    if (state is MessagingBlocInitial) {
      return Center(
        child: Text('Welcome! Generate a passage to start practicing.'),
      );
    }

    if (state is GeneratingPassageState ||
        state is AnalysisState ||
        state is GeneratingReportState) {
      // When in these processing states, still show existing messages in the background
      final bloc = BlocProvider.of<MessagingBloc>(context);
      return bloc.messages.isEmpty
          ? Center(child: Text('Processing...'))
          : ListView.builder(
            itemCount: bloc.messages.length,
            padding: EdgeInsets.only(bottom: 80),
            itemBuilder: (context, index) {
              return Message(
                passage: bloc.messages[index].passage,
                speechAnalysisMetricsEntity:
                    bloc.messages[index].speechAnalysisMetrics,
                report: bloc.messages[index].report,
              );
            },
          );
    }

    return Center(child: Text('Ready to start practicing'));
  }

  List<MessageEntity> _getMessagesForState(MessagingState state) {
    if (state is MessageSuccesState) return state.messages;
    if (state is ReadingPassageState) return state.messages;
    if (state is RecordingState) return state.messages;
    return [];
  }
}
