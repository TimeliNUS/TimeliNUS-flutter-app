import 'dart:async';

import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
// import 'package:url_launcher/url_launcher.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc({@required AuthenticationRepository authenticationRepository})
      : assert(authenticationRepository != null),
        _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : AppState.unauthenticated(),
        ) {
    _userSubscription = _authenticationRepository.user.listen(_onUserChanged);
    initDynamicLinks();
    prepareNotifications();
  }

  Future<void> prepareNotifications() async {
    RemoteMessage initialMessage = await FirebaseMessaging.instance.getInitialMessage();

    // If the message also contains a data property with a "type" of "chat",
    // navigate to a chat screen
    if (initialMessage?.data != null && initialMessage?.data['type'] == 'invitation') {
      this.add(AppOnInvitation(invitationId: initialMessage?.data['ref']));
    }

    // Also handle any interaction when the app is in the background via a
    // Stream listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('from AppBloc: ' + message.data.toString());
      if (message.data['type'] == 'invitation') {
        this.add(AppOnInvitation(invitationId: message.data['ref']));
      }
    });
  }

  Future<void> initDynamicLinks() async {
    FirebaseDynamicLinks.instance.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      if (dynamicLink != null) {
        final Uri deepLink = dynamicLink.link;
        if (deepLink != null) {
          // ignore: unawaited_futures
          this.add(AppOnInvitation());
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data = await FirebaseDynamicLinks.instance.getInitialLink();
    try {
      if (data != null) {
        final Uri deepLink = data.link;

        if (deepLink != null) {
          // ignore: unawaited_futures
          this.add(AppOnInvitation());
        }
      }
    } catch (err) {
      print('Error: ' + err.toString());
    }
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
      yield* _mapUserChangedToState(event, state);
    } else if (event is AppLogoutRequested) {
      _authenticationRepository.logOut();
      yield (AppState.unauthenticated());
    } else if (event is AppOnTodo) {
      yield (AppState.onTodo(state.user));
    } else if (event is AppOnProject) {
      yield (AppState.onProject(state.user));
    } else if (event is AppOnProfile) {
      yield (AppState.onProfile(state.user));
    } else if (event is AppOnMeeting) {
      yield (AppState.onMeeting(state.user, projectId: event.projectId, projectTitle: event.projectTitle));
    } else if (event is AppOnInvitation) {
      yield (AppState.onInvitation(state.user, event.invitationId));
    } else if (event is AppOnDashboard) {
      yield (AppState.onDashboard(state.user));
    }
  }

  Stream<AppState> _mapUserChangedToState(AppUserChanged event, AppState state) async* {
    if (event.user.isNotEmpty) {
      final token = await FirebaseMessaging.instance.getToken();
      _authenticationRepository.saveTokenToDatabase(token, event.user.id);
    }
    yield event.user.isNotEmpty ? AppState.authenticated(event.user) : AppState.unauthenticated();
  }

  @override
  Future<void> close() {
    _userSubscription.cancel();
    return super.close();
  }

  @override
  void onChange(Change<AppState> change) {
    // print("App Bloc: " + change.toString());
    super.onChange(change);
  }
}
