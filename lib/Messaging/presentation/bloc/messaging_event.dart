part of 'messaging_bloc.dart';

sealed class MessagingEvent extends Equatable {
  const MessagingEvent();

  @override
  List<Object> get props => [];
}

class GetMicPermissionEvent extends MessagingEvent {}

class StartRecordingEvent extends MessagingEvent {}

class StopRecordingEvent extends MessagingEvent {}
