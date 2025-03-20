part of 'messaging_bloc.dart';

sealed class MessagingState extends Equatable {
  const MessagingState();

  @override
  List<Object> get props => [];
}

final class MessagingBlocInitial extends MessagingState {}

final class MicPermissionDeniedState extends MessagingState {
  final String message;
  const MicPermissionDeniedState(this.message);
}

//reading Passage
final class GeneratingPassageState extends MessagingState {}

final class ReadingPassageState extends MessagingState {
  final List<MessageEntity> messages;

  const ReadingPassageState({required this.messages});
}

// Analysis
final class RecordingState extends MessagingState {
  final List<MessageEntity> messages;

  const RecordingState(this.messages);
}

final class AnalysisState extends MessagingState {}

final class GeneratingReportState extends MessagingState {}

final class MessageSuccesState extends MessagingState {
  final List<MessageEntity> messages;
  const MessageSuccesState({required this.messages});
}

final class MessagingErrorState extends MessagingState {
  final String message;
  const MessagingErrorState(this.message);
}

class AnalysisCompletedState extends MessagingState {
  final List<MessageEntity> messages;

  AnalysisCompletedState({required this.messages});

  @override
  List<Object> get props => [messages];
}
