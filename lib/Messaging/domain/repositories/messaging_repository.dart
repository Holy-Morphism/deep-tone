import 'package:dartz/dartz.dart';
import 'package:deeptone/Messaging/domain/entities/speech_analysis_metrics_entity.dart';

import '../../../core/error/failure.dart';
import '../entities/message_entity.dart';

abstract class MessagingRepository {
  Future<Either<Failure, void>> startRecording();
  Future<Either<Failure, SpeechAnalysisMetricsEntity>> stopRecording();
  Future<Either<Failure, MessageEntity>> generateReport();
  Future<Either<Failure, String>> generatePassage();
  Future<Either<Failure, void>> getMicPermission();
}
