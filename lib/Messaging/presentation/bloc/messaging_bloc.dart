import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../domain/entities/model_message_entity.dart';
import '../../domain/usecases/get_mic_permission.dart';
import '../../domain/usecases/start_recording.dart';
import '../../domain/usecases/stop_recording.dart';
part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final StartRecording startRecording;
  final StopRecording stopRecording;
  final GetMicPermission getMicPermission;

  MessagingBloc({
    required this.startRecording,
    required this.stopRecording,
    required this.getMicPermission,
  }) : super(MessagingBlocInitial()) {
    // Get Mic permission
    on<GetMicPermissionEvent>((event, emit) async {
      emit(GettingMicPermissionState());
      final result = await getMicPermission();
      result.fold((failure) {
        if (failure is MicError) {
          emit(MicPermissionDeniedState(failure.message));
        } else if (failure is RecordingFailure) {
          emit(MessagingErrorState(failure.message));
        }
      }, (success) => emit(MicPermissionSuccessState()));
    });

    on<StartRecordingEvent>((event, emit) async {
      emit(RecordingState());
      final result = await startRecording();
      result.fold(
        (failure) => emit(MessagingErrorState(failure.message)),
        (succes) => emit(RecordingState()),
      );
    });

    on<StopRecordingEvent>((event, emit) async {
      emit(MessagingLoadingState());
      final result = await stopRecording();
      result.fold(
        (failure) => emit(MessagingErrorState(failure.message)),
        (success) => emit(MessageSuccesState(modelMessageEntity: success)),
      );
    });
  }
}
