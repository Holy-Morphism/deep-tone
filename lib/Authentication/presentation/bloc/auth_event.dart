part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent extends Equatable {}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String username;

  SignUpEvent({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class OnChangeSignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String username;

  OnChangeSignUpEvent({
    required this.email,
    required this.password,
    required this.username,
  });

  @override
  List<Object> get props => [email, password, username];
}

class OnChangeLoginEvent extends AuthEvent {
  final String email;
  final String password;

  OnChangeLoginEvent({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}
