import 'package:TimeliNUS/models/userModel.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

class AppState extends Equatable {
  const AppState._({
    @required this.status,
    this.user = User.empty,
  });

  const AppState.authenticated(User user)
      : this._(status: AppStatus.authenticated, user: user);

  const AppState.unauthenticated() : this._(status: AppStatus.unauthenticated);

  final AppStatus status;
  final User user;

  @override
  List<Object> get props => [status, user];
}
