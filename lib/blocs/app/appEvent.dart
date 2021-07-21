import 'package:TimeliNUS/models/userModel.dart';
import 'package:equatable/equatable.dart';

abstract class AppEvent extends Equatable {
  const AppEvent();

  @override
  List<Object> get props => [];
}

// class AppRefreshToken extends AppEvent {}

class AppLogoutRequested extends AppEvent {}

class AppOnTodo extends AppEvent {
  final String projectId;
  final String projectTitle;
  const AppOnTodo({this.projectId, this.projectTitle});
}

class AppOnProject extends AppEvent {}

class AppOnMeeting extends AppEvent {
  final String projectId;
  final String projectTitle;
  const AppOnMeeting({this.projectId, this.projectTitle});

  @override
  String toString() {
    return "AppOnMeeting($projectId)";
  }
}

class AppOnInvitation extends AppEvent {
  final String invitationId;
  final bool isMeeting;
  const AppOnInvitation({this.invitationId, this.isMeeting = true});
}

class AppUserChanged extends AppEvent {
  const AppUserChanged(this.user);

  final User user;

  @override
  List<Object> get props => [user];
}

class AppOnDashboard extends AppEvent {}

class AppOnProfile extends AppEvent {}
