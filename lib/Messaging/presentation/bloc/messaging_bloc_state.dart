part of 'messaging_bloc_bloc.dart';

sealed class MessagingState extends Equatable {
  const MessagingState();

  @override
  List<Object> get props => [];
}

final class MessagingBlocInitial extends MessagingState {}
