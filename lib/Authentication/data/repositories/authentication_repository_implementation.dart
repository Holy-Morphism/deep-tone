import 'package:deeptone/Authentication/data/models/user_model.dart';
import 'package:deeptone/Authentication/domain/entities/user_entity.dart';
import 'package:deeptone/Authentication/domain/repositories/authentication_repository.dart';
import 'package:deeptone/core/error/failure.dart';
import 'package:deeptone/injection_container.dart';
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
              .select('username')
              .eq('id', res.user!.id)
              .single();

      if (res.user != null) {
        return Right(
          UserModel(username: data['username'], email: res.user!.email!),
        );
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

      if (res.user != null) {
        // Create profile after successful signup
        await locator<SupabaseClient>().from('profiles').insert({
          'id': res.user!.id,
          'username': username,
          'created_at': DateTime.now().toIso8601String(),
        });
      }

      // Return user data
      return Right(UserModel(email: email, username: username));
    } catch (e) {
      return Left(AuthenticationFailure(e.toString()));
    }
  }
}
