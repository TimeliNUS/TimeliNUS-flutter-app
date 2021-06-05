import 'package:equatable/equatable.dart';

abstract class LandingEvent extends Equatable {
  const LandingEvent();

  @override
  List<Object> get props => [];
}

class LoginUsernameChanged extends LandingEvent {
  const LoginUsernameChanged(this.username);

  final String username;

  @override
  List<Object> get props => [username];
}

class LoginPasswordChanged extends LandingEvent {
  const LoginPasswordChanged(this.password);

  final String password;

  @override
  List<Object> get props => [password];
}

class LoginSubmitted extends LandingEvent {
  const LoginSubmitted();
}
