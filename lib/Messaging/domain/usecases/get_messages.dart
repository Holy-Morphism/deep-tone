import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../entities/message_entity.dart';
import '../repositories/messaging_repository.dart';

class GetMessages {
  final MessagingRepository _messagingRepository;
  const GetMessages(this._messagingRepository);
  Future<Either<Failure, List<MessageEntity>>> call() {
    return _messagingRepository.getMessages();
  }
}
