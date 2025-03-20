part of 'messaging_bloc.dart';

sealed class MessagingState extends Equatable {
  final List<MessageEntity> messages;
  const MessagingState(this.messages);

  @override
  List<Object> get props => [messages];
}

final class MessagingBlocInitial extends MessagingState {
  const MessagingBlocInitial() : super(const []);
}

final class MicPermissionDeniedState extends MessagingState {
  final String message;
  const MicPermissionDeniedState(this.message) : super(const []);
}

final class LoadingMessagesState extends MessagingState {
  const LoadingMessagesState() : super(const []);
}

//reading Passage
final class GeneratingPassageState extends MessagingState {
  const GeneratingPassageState(super.messages);
}

final class ReadingPassageState extends MessagingState {
  const ReadingPassageState(super.messages);
}

// Analysis
final class RecordingState extends MessagingState {
  const RecordingState(super.messages);
}

final class AnalysisState extends MessagingState {
  const AnalysisState(super.messages);
}

final class GeneratingReportState extends MessagingState {
  const GeneratingReportState(super.messages);
}

final class MessageSuccesState extends MessagingState {
  const MessageSuccesState(super.messages);
}

final class MessagingErrorState extends MessagingState {
  final String message;
  const MessagingErrorState(this.message) : super(const []);
}
