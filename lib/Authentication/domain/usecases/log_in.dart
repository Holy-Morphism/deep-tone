import 'package:ai_voice_coach/Authentication/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/authentication_repository.dart';

class LogIn {
  final AuthenticationRepository _authenticationRepository;
  LogIn(this._authenticationRepository);

  Future<Either<Failure, UserEntity>> call({
    required String password,
    required String email,
  }) {
    return _authenticationRepository.logIn(password: password, email: email);
  }
}
