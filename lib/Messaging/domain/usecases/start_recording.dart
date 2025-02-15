import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../repositories/messaging_repository.dart';

class StartRecording {
  final MessagingRepository _messagingRepository;
  const StartRecording(this._messagingRepository);

  Future<Either<Failure, void>> call() {
    return _messagingRepository.startRecording();
  }
}
