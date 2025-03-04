import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/usecases/generate_passage.dart';
import '../../domain/usecases/generate_report.dart';
import '../../domain/usecases/get_mic_permission.dart';
import '../../domain/usecases/start_recording.dart';
import '../../domain/usecases/stop_recording.dart';
part 'messaging_event.dart';
part 'messaging_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final StartRecording startRecording;
  final StopRecording stopRecording;
  final GetMicPermission getMicPermission;
  final GeneratePassage generatePassage;
  final GenerateReport generateReport;

  MessagingBloc({
    required this.startRecording,
    required this.stopRecording,
    required this.getMicPermission,
    required this.generatePassage,
    required this.generateReport,
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

    on<GeneratePassageEvent>((event, emit) async {
      emit(GeneratingPassageState());
      final result = await generatePassage();
      result.fold(
        (failure) => emit(MessagingErrorState(failure.message)),
        (succes) => emit(ReadingPassageState(succes)),
      );
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
      emit(AnalysisState());
      final metrics = await stopRecording();
      metrics.fold(
        (failure) => emit(MessagingErrorState(failure.message)),
        (success) => emit(
          GeneratingReportState(
            pitch: success.pitch,
            pace: success.pace,
            clarity: success.clarity,
            volume: success.volume,
            pronunciationAccuracy: success.pronunciationAccuracy,
            confidence: success.confidence,
            overallScore: success.overallScore,
            transcript: success.transcript,
          ),
        ),
      );
      final result = await generateReport();
      result.fold(
        (failure) => emit(MessagingErrorState(failure.message)),
        (success) => emit(MessageSuccesState(message:  success)),
      );
    });
  }
}
