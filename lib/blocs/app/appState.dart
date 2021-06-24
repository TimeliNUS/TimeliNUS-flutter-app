import 'package:TimeliNUS/models/userModel.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
  onTodo,
  onProject,
  onMeeting,
  onInvitation
}

class AppState extends Equatable {
  const AppState({@required this.status, this.user = User.empty, this.data});

  const AppState.authenticated(User user)
      : this(status: AppStatus.authenticated, user: user);

  const AppState.unauthenticated() : this(status: AppStatus.unauthenticated);

  const AppState.onTodo(User user) : this(status: AppStatus.onTodo, user: user);
  const AppState.onInvitation(User user, String id)
      : this(status: AppStatus.onInvitation, user: user, data: id);
  const AppState.onProject(User user)
      : this(status: AppStatus.onProject, user: user);

  const AppState.onMeeting(User user)
      : this(status: AppStatus.onMeeting, user: user);

  final AppStatus status;
  final User user;
  final dynamic data;

  @override
  List<Object> get props => [status, user];
}
