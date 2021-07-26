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
  FirebaseMessaging _messaging;
  FirebaseDynamicLinks _dynamicLinks;
  AppBloc(
      {@required AuthenticationRepository authenticationRepository,
      FirebaseMessaging messaging,
      FirebaseDynamicLinks dynamicLinks})
      : assert(authenticationRepository != null),
        _authenticationRepository = authenticationRepository,
        super(
          authenticationRepository.currentUser.isNotEmpty
              ? AppState.authenticated(authenticationRepository.currentUser)
              : AppState.unauthenticated(),
        ) {
    // _userSubscription = _authenticationRepository.user.listen(_onUserChanged);
    _messaging = messaging ?? FirebaseMessaging.instance;
    _dynamicLinks = dynamicLinks ?? FirebaseDynamicLinks.instance;
    initDynamicLinks();
    prepareNotifications();
  }
  StreamSubscription<User> _userSubscription;

  Future<void> prepareNotifications() async {
    RemoteMessage initialMessage = await _messaging.getInitialMessage();

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
    _dynamicLinks.onLink(onSuccess: (PendingDynamicLinkData dynamicLink) async {
      if (dynamicLink != null) {
        final Uri deepLink = dynamicLink.link;
        if (deepLink != null) {
          print(dynamicLink.link.query);
          this.add(AppOnProfile());
        }
      }
    }, onError: (OnLinkErrorException e) async {
      print('onLinkError');
      print(e.message);
    });

    final PendingDynamicLinkData data = await _dynamicLinks.getInitialLink();
    try {
      if (data != null) {
        final Uri deepLink = data.link;

        if (deepLink != null) {
          // ignore: unawaited_futures
          this.add(AppOnProfile());
        }
      }
    } catch (err) {
      print('Error: ' + err.toString());
    }
  }

  final AuthenticationRepository _authenticationRepository;
  // StreamSubscription<User> _userSubscription;

  User getCurrentUser() {
    return _authenticationRepository.currentUser;
  }

  // void _onUserChanged(User user) => add(AppUserChanged(user));

  @override
  Stream<AppState> mapEventToState(AppEvent event) async* {
    if (event is AppUserChanged) {
      yield* _mapUserChangedToState(event, state);
    } else if (event is AppLogoutRequested) {
      _authenticationRepository.logOut();
      yield (AppState.unauthenticated());
    } else if (event is AppOnTodo) {
      yield (AppState.onTodo(state.user, projectId: event.projectId, projectTitle: event.projectTitle));
    } else if (event is AppOnProject) {
      yield (AppState.onProject(state.user));
    } else if (event is AppOnProfile) {
      yield (AppState.onProfile(state.user));
    } else if (event is AppOnMeeting) {
      yield (AppState.onMeeting(state.user, projectId: event.projectId, projectTitle: event.projectTitle));
    } else if (event is AppOnInvitation) {
      yield (AppState.onInvitation(state.user, event.invitationId, isMeeting: event.isMeeting));
    } else if (event is AppOnDashboard) {
      yield (AppState.onDashboard(state.user));
    }
    // else if (event is AppRefreshToken) {
    //   _authenticationRepository.refreshToken();
    //   yield AppState.authenticated(state.user);
    // }
  }

  Stream<AppState> _mapUserChangedToState(AppUserChanged event, AppState state) async* {
    if (event.user.isNotEmpty) {
      final token = await _messaging.getToken();
      _authenticationRepository.saveTokenToDatabase(token, event.user.id);
    }
    if (state.user.calendar != event.user.calendar) {
      AuthenticationRepository().importNewCalendar(event.user.calendar, event.user.id);
    }
    yield event.user.isNotEmpty
        ? (state.status == AppStatus.onMeeting ? AppState.onMeeting(event.user) : AppState.authenticated(event.user))
        : AppState.unauthenticated();
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
