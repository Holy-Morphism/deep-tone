import 'package:dartz/dartz.dart';

import '../../../core/error/failure.dart';
import '../repositories/messaging_repository.dart';

class GetMicPermission {
  final MessagingRepository _messagingRepository;
  const GetMicPermission(this._messagingRepository);
  Future<Either<Failure, void>> call() {
    return _messagingRepository.getMicPermission();
  }
}
