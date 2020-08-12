part of 'authentication_bloc.dart';

abstract class AuthenticationEvent extends Equatable {
  const AuthenticationEvent();

  @override
  List<Object> get props => [];
}

// AppStarted will be dispatched when the Flutter application first loads.
// It will notify bloc that it needs to determine whether or not there is an existing user.
class AppStarted extends AuthenticationEvent {}

// LoggedIn will be dispatched on a successful login.
// It will notify the bloc that the user has successfully logged in.
class LoggedIn extends AuthenticationEvent {
  final User user;

  const LoggedIn({@required this.user});

  @override
  List<Object> get props => [user];

  @override
  String toString() => 'LoggedIn { user: $user.username.toString() }';
}

// It will notify the bloc that the user has successfully logged out.
class LoggedOut extends AuthenticationEvent {
  @override
  String toString() => 'AUTH event: Logged Out';
}
