part of 'login_bloc.dart';

abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

// initial state of the LoginForm.
class LoginInitial extends LoginState {}

// the state of the LoginForm when we are validating credentials
class LoginLoading extends LoginState {}

// the state of the LoginForm when a login attempt has failed.
class LoginFaliure extends LoginState {
  final String error;

  const LoginFaliure({@required this.error});

  @override
  List<Object> get props => [error];

  @override
  String toString() => ' LoginFaliure { error: $error }';
}
