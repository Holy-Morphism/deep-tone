import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../entities/model_message_entity.dart';

abstract class MessagingRepository {
  Future<Either<Failure, void>> startRecording();
  Future<Either<Failure,ModelMessageEntity>> stopRecording();
  Future<Either<Failure,void>> getMicPermission();
}
