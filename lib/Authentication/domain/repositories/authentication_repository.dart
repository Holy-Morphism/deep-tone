import 'package:deeptone/Authentication/domain/entities/user_entity.dart';
import 'package:deeptone/core/error/failure.dart';
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
