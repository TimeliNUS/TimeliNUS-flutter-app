import 'package:TimeliNUS/models/userModel.dart';
import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

class AppLogoutRequested extends AppEvent {}

class AppOnTodo extends AppEvent {}

class AppOnProject extends AppEvent {}

class AppOnMeeting extends AppEvent {}

class AppUserChanged extends AppEvent {
  const AppUserChanged(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}
