import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../repositories/messaging_repository.dart';

class GeneratePassage {
  final MessagingRepository _messagingRepository;
  const GeneratePassage(this._messagingRepository);
  Future<Either<Failure, String>> call() {
    return _messagingRepository.generatePassage();
  }
}
