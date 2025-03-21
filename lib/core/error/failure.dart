import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object> get props => [message];

  @override
  bool get stringify => true;
}

class ConnectionFailure extends Failure {
  const ConnectionFailure(super.message);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message);
}

class RecordingFailure extends Failure {
  const RecordingFailure(super.message);
}

class MicError extends Failure {
  const MicError(super.message);
}

class APIFailure extends Failure {
  const APIFailure(super.message);
}
