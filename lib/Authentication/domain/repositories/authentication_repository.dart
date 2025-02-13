import 'package:ai_voice_coach/Authentication/domain/entities/user_entity.dart';
import 'package:ai_voice_coach/core/error/failure.dart';
import 'package:dartz/dartz.dart';

abstract class AuthenticationRepository {
  Future<Either<Failure, UserEntity>> signUp({
    required String username,
    required String email,
    required String password,
  });

  Future<Either<Failure, UserEntity>> logIn({
    required String email,
    required String password,
  });
}
