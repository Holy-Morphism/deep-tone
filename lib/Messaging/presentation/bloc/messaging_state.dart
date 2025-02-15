part of 'messaging_bloc.dart';

sealed class MessagingState extends Equatable {
  const MessagingState();

  @override
  List<Object> get props => [];
}

final class MessagingBlocInitial extends MessagingState {
  // Get previous chat
}

final class GettingMicPermissionState extends MessagingState {
  // Waiting for mic permission
}

final class MicPermissionDeniedState extends MessagingState {
  final String message;
  const MicPermissionDeniedState(this.message);
}

final class MicPermissionSuccessState extends MessagingState {}

final class MessagingLoadingState extends MessagingState {}

final class RecordingState extends MessagingState {}

final class MessagingErrorState extends MessagingState {
  final String message;
  const MessagingErrorState(this.message);
}
