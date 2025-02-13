import 'package:ai_voice_coach/Authentication/domain/entities/user_entity.dart';
import 'package:ai_voice_coach/Authentication/domain/usecases/log_in.dart';
import 'package:ai_voice_coach/Authentication/domain/usecases/sign_in.dart';
import 'package:ai_voice_coach/core/error/failure.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  final LogIn logIn;
  final SignUp signUp;

  AuthenticationBloc({required this.logIn, required this.signUp})
    : super(AuthenticationInitial()) {
    on<SignUpEvent>((event, emit) async {
      emit(AuthLoadingState());
      final Either<Failure, UserEntity> result = await signUp(
        email: event.email,
        password: event.password,
        username: event.username,
      );

      result.fold(
        (failure) =>
            emit(AuthErrorState(failure.message)), // Handle failure case
        (userEntity) =>
            emit(AuthenticatedState(userEntity)), // Handle success case
      );
    });

    on<LoginEvent>((event, emit) async {
      final Either<Failure, UserEntity> result = await logIn(
        email: event.email,
        password: event.password,
      );
      result.fold(
        (failure) =>
            emit(AuthErrorState(failure.message)), // Handle failure case
        (userEntity) =>
            emit(AuthenticatedState(userEntity)), // Handle success case
      );
    });
  }
}
