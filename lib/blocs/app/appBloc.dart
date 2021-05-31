import 'dart:async';

import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/blocs/user/userModel.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({@required AuthenticationRepository authenticationRepository})
      : _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : const AppState.unauthenticated(),
        ) {
    _userSubscription = _authenticationRepository.user.listen(_onUserChanged);
  }

  final AuthenticationRepository _authenticationRepository;
  StreamSubscription<User> _userSubscription;

  User getCurrentUser() {
    return _authenticationRepository.currentUser;
  }

  void _onUserChanged(User user) => add(AppUserChanged(user));

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppUserChanged) {
      yield _mapUserChangedToState(event, state);
    } else if (event is AppLogoutRequested) {
      _authenticationRepository.logOut();
    }
  }

  AppState _mapUserChangedToState(AppUserChanged event, AppState state) {
    return event.user.isNotEmpty
        ? AppState.authenticated(event.user)
        : const AppState.unauthenticated();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  @override
  void onChange(Change<AppState> change) {
    print("Hello " + change.toString());
    super.onChange(change);
  }
}
