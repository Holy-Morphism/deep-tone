import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../repositories/messaging_repository.dart';

class GetMessages {
  final MessagingRepository _messagingRepository;
  const GetMessages(this._messagingRepository);
  Future<Either<Failure, void>> call() {
    return _messagingRepository.getMessages();
  }
}
