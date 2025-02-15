import 'package:deeptone/Authentication/domain/entities/user_entity.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../repositories/authentication_repository.dart';

class SignUp {
  final AuthenticationRepository _authenticationRepository;
  SignUp(this._authenticationRepository);

  Future<Either<Failure, UserEntity>> call({
    required String password,
    required String email,
    required String username,
  }) {
    return _authenticationRepository.signUp(
      password: password,
      email: email,
      username: username,
    );
  }
}
