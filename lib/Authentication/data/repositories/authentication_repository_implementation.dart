import 'package:ai_voice_coach/Authentication/data/models/user_model.dart';
import 'package:ai_voice_coach/Authentication/domain/entities/user_entity.dart';
import 'package:ai_voice_coach/Authentication/domain/repositories/authentication_repository.dart';
import 'package:ai_voice_coach/core/error/failure.dart';
import 'package:ai_voice_coach/injection_container.dart';
import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthenticationRepositoryImplementation
    implements AuthenticationRepository {
  @override
  Future<Either<Failure, UserEntity>> logIn({
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await locator<SupabaseClient>().auth
          .signInWithPassword(email: email, password: password);

      final data =
          await locator<SupabaseClient>()
              .from('profiles')
              .select('username, users!inner(email)')
              .eq('id', res.user!.id)
              .single();

      if (res.user != null) {
        return Right(UserModel.fromMap(data));
      } else {
        return Left(
          AuthenticationFailure('Failed to create account, no user received'),
        );
      }
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signUp({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final AuthResponse res = await locator<SupabaseClient>().auth.signUp(
        email: email,
        password: password,
      );
      final data =
          await locator<SupabaseClient>()
              .from('profiles')
              .select('username, users!inner(email)')
              .eq('id', res.user!.id)
              .single();

      if (res.user != null) {
        return Right(UserModel.fromMap(data));
      } else {
        return Left(AuthenticationFailure("Failed to log In"));
      }
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }
}
