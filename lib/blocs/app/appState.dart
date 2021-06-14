import 'package:TimeliNUS/models/userModel.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum AppStatus { authenticated, unauthenticated, onTodo, onProject }

class AppState extends Equatable {
  const AppState({
    @required this.status,
    this.user = User.empty,
  });

  const AppState.authenticated(User user)
      : this(status: AppStatus.authenticated, user: user);

  const AppState.unauthenticated() : this(status: AppStatus.unauthenticated);

  const AppState.onTodo(User user) : this(status: AppStatus.onTodo, user: user);

  const AppState.onProject(User user)
      : this(status: AppStatus.onProject, user: user);

  final AppStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];
}
