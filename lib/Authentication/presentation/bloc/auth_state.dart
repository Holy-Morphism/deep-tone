part of 'auth_bloc.dart';

@immutable
sealed class AuthState {}

final class AuthenticationInitial extends AuthState {}

final class AuthLoadingState extends AuthState {}

final class UnauthenticatedState extends AuthState {}

final class AuthenticatedState extends AuthState {
  final UserEntity user;
  AuthenticatedState(this.user);
}

final class AuthErrorState extends AuthState {
  final String message;
  AuthErrorState(this.message);
}

final class AuthIncorrectCredentialsState extends AuthState {
  final String message;
  AuthIncorrectCredentialsState(this.message);
}
