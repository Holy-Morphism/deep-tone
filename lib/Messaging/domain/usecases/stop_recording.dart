import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../entities/model_message_entity.dart';
import '../repositories/messaging_repository.dart';

class StopRecording {
  final MessagingRepository _messagingRepository;
  const StopRecording(this._messagingRepository);

  Future<Either<Failure, ModelMessageEntity>> call() {
    return _messagingRepository.stopRecording();
  }
}
