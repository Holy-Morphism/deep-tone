import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failure.dart';
import '../../domain/entities/message_entity.dart';
import '../../domain/entities/speech_analysis_metrics_entity.dart';
import '../../domain/usecases/generate_passage.dart';
import '../../domain/usecases/generate_report.dart';
import '../../domain/usecases/get_messages.dart';
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
  final GetMessages getMessages;
  String? passage;
  SpeechAnalysisMetricsEntity? speechAnalysisMetricsEntity;
  List<MessageEntity> messages = [];

  MessagingBloc({
    required this.startRecording,
    required this.stopRecording,
    required this.getMicPermission,
    required this.generatePassage,
    required this.generateReport,
    required this.getMessages,
  }) : super(MessagingBlocInitial()) {
    // Get Mic permission
    on<GetMicPermissionEvent>((event, emit) async {
      emit(MicPermissionDeniedState("Mic permission currently"));
      final result = await getMicPermission();
      result.fold((failure) {
        if (failure is MicError) {
          emit(MicPermissionDeniedState(failure.message));
        } else if (failure is RecordingFailure) {
          emit(MessagingErrorState(failure.message));
        }
      }, (success) => emit(MessageSuccesState(messages: [])));
    });

    // Load existing messages when app starts
    on<LoadMessagesEvent>((event, emit) async {
      // This would typically load messages from a repository or database
      // For now, we'll just display the current messages list
      final result = await getMessages();
      result.fold((l) => emit(MessagingErrorState(l.message)), (r) {
        messages = r;
      });
      emit(MessageSuccesState(messages: messages));
    });

    on<GeneratePassageEvent>((event, emit) async {
      emit(GeneratingPassageState());
      final result = await generatePassage();
      result.fold((failure) => emit(MessagingErrorState(failure.message)), (
        succes,
      ) {
        messages.add(MessageEntity(dateTime: DateTime.now(), passage: succes));
        passage = succes;
        emit(ReadingPassageState(messages: messages));
      });
    });

    on<StartRecordingEvent>((event, emit) async {
      emit(RecordingState(messages));
      final result = await startRecording();
      result.fold(
        (failure) => emit(MessagingErrorState(failure.message)),
        (success) => emit(RecordingState(messages)),
      );
    });

    on<StopRecordingEvent>((event, emit) async {
      emit(AnalysisState());
      final metrics = await stopRecording();
      metrics.fold((failure) => emit(MessagingErrorState(failure.message)), (
        success,
      ) {
        messages.removeLast();
        messages.add(
          MessageEntity(
            dateTime: DateTime.now(),
            passage: passage!,
            speechAnalysisMetrics: success,
          ),
        );
        speechAnalysisMetricsEntity = success;
        // Emit an intermediate state to update the UI
        emit(AnalysisCompletedState(messages: messages));
        // Then emit the report generation state
        emit(GeneratingReportState());
      });

      // Only proceed to generate report if we received valid metrics
      if (speechAnalysisMetricsEntity != null) {
        final result = await generateReport();
        result.fold((failure) => emit(MessagingErrorState(failure.message)), (
          success,
        ) {
          messages.removeLast();
          messages.add(success);
          emit(MessageSuccesState(messages: messages));
        });
      }
    });
  }
}
