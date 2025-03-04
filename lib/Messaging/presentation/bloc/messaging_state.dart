part of 'messaging_bloc.dart';

sealed class MessagingState extends Equatable {
  const MessagingState();

  @override
  List<Object> get props => [];
}

final class MessagingBlocInitial extends MessagingState {
  // Get previous chat
}

// Related To Mic
final class GettingMicPermissionState extends MessagingState {
  // Waiting for mic permission
}

final class MicPermissionDeniedState extends MessagingState {
  final String message;
  const MicPermissionDeniedState(this.message);
}

final class MicPermissionSuccessState extends MessagingState {}

//reading Passage
final class GeneratingPassageState extends MessagingState {}

final class ReadingPassageState extends MessagingState {
  final String passage;
  const ReadingPassageState(this.passage);
}

// Analysis
final class RecordingState extends MessagingState {}

final class AnalysisState extends MessagingState {}

final class GeneratingReportState extends MessagingState {
  final double pitch;
  final double pace;
  final double clarity;
  final double volume;
  final double pronunciationAccuracy;
  final double confidence;
  final String transcript;
  final double overallScore;

  const GeneratingReportState({
    required this.pitch,
    required this.pace,
    required this.clarity,
    required this.volume,
    required this.pronunciationAccuracy,
    required this.confidence,
    required this.overallScore,
    required this.transcript,
  });
}

final class MessageSuccesState extends MessagingState {
  final MessageEntity message;
  const MessageSuccesState({required this.message});
}

final class MessagingErrorState extends MessagingState {
  final String message;
  const MessagingErrorState(this.message);
}
