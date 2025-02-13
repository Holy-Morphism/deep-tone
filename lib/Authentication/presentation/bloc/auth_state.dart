part of 'auth_bloc.dart';

@immutable
sealed class AuthenticationState {}

final class AuthenticationInitial extends AuthenticationState {}

final class AuthLoadingState extends AuthenticationState {}

final class UnauthenticatedState extends AuthenticationState {}

final class AuthenticatedState extends AuthenticationState {
  final UserEntity user;
  AuthenticatedState(this.user);
}

final class AuthErrorState extends AuthenticationState {
  final String message;
  AuthErrorState(this.message);
}

final class AuthIncorrectCredentialsState extends AuthenticationState {
  final String message;
  AuthIncorrectCredentialsState(this.message);
}
