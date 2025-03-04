import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../entities/message_entity.dart';
import '../repositories/messaging_repository.dart';

class GenerateReport {
  final MessagingRepository _messagingRepository;
  const GenerateReport(this._messagingRepository);
  Future<Either<Failure, MessageEntity>> call() {
    return _messagingRepository.generateReport();
  }
}
