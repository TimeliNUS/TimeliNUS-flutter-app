import 'package:TimeliNUS/models/userModel.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum AppStatus { authenticated, unauthenticated, onTodo, onProject, onMeeting, onInvitation, onDashboard, onProfile }

class AppState extends Equatable {
  AppState({@required this.status, this.user = User.empty, this.data});

  AppState.authenticated(User user) : this(status: AppStatus.authenticated, user: user);
  AppState.unauthenticated() : this(status: AppStatus.unauthenticated);

  AppState.onTodo(User user, {String projectId, String projectTitle})
      : this(status: AppStatus.onTodo, user: user, data: {'projectId': projectId, 'projectTitle': projectTitle});
  AppState.onInvitation(User user, String id, {bool isMeeting})
      : this(status: AppStatus.onInvitation, user: user, data: {'id': id, 'isMeeting': isMeeting});
  AppState.onProject(User user) : this(status: AppStatus.onProject, user: user);
  AppState.onMeeting(User user, {String projectId, String projectTitle})
      : this(status: AppStatus.onMeeting, user: user, data: {'projectId': projectId, 'projectTitle': projectTitle});
  AppState.onDashboard(User user) : this(status: AppStatus.onDashboard, user: user);
  AppState.onProfile(User user) : this(status: AppStatus.onProfile, user: user);

  AppStatus status;
  User user;
  dynamic data;

  @override
  List<Object> get props => [status, user, data];
}
