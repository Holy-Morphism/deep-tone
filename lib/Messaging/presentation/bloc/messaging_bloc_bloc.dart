import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'messaging_bloc_event.dart';
part 'messaging_bloc_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  MessagingBloc() : super(MessagingBlocInitial()) {
    on<MessagingEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
