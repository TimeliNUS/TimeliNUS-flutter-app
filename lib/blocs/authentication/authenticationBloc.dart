import 'dart:async';
import 'package:TimeliNUS/blocs/authentication/authenticationState.dart';
import 'package:TimeliNUS/blocs/authentication/authenticationEvent.dart';
import 'package:TimeliNUS/utils/services/firebase.dart';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {
  AuthenticationBloc({@required FirebaseService userRepository})
      : assert(userRepository != null),
        super(Uninitialized());

  @override
  Stream<AuthenticationState> mapEventToState(
    AuthenticationEvent event,
  ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await FirebaseService().isSignedIn();
      if (isSignedIn) {
        final name = await FirebaseService().getUser();
        yield Authenticated(name.displayName);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield Authenticated(
        await (FirebaseService().getUser().then((value) => value.displayName)));
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    FirebaseService().logOut();
  }
}
