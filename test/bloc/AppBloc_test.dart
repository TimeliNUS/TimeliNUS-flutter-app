import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoBloc.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../integration/services/firebase/firebase_auth_test.dart';
import '../utils/firebase_util.dart';
import 'InvitationBloc_test.dart';

class MockCustomUser extends Mock implements User {
  bool get isNotEmpty => true;
}

class MockAuthenticationRepository extends Mock implements AuthenticationRepository {
  User _currentUser;
  MockAuthenticationRepository(User user) {
    _currentUser = user;
  }
  @override
  User get currentUser => _currentUser;
}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockApp extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockFirebaseMessaging extends Mock implements FirebaseMessaging {}

class MockFirebaseDynamicLinks extends Mock implements FirebaseDynamicLinks {}

void main() {
  AuthenticationRepository authenticationRepository;
  AppBloc mockAppBloc;
  User user;
  setupCloudFirestoreMocks();
  setUpAll(() {
    // registerFallbackValue<MockAppState>(MockAppState());
    registerFallbackValue<MockAppEvent>(MockAppEvent());
  });
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    user = MockCustomUser();
    authenticationRepository = MockAuthenticationRepository(user);
    mockAppBloc = AppBloc(
        authenticationRepository: authenticationRepository,
        messaging: MockFirebaseMessaging(),
        dynamicLinks: MockFirebaseDynamicLinks());
    when(() => mockAppBloc.initDynamicLinks()).thenAnswer((_) => Future.delayed(Duration(milliseconds: 1)));
  });
  group('AppBloc mapEventToState', () {
    blocTest(
      'mapEventToState onTodo',
      build: () => mockAppBloc,
      act: (bloc) => bloc.add(AppOnTodo(projectId: 'id', projectTitle: 'title')),
      expect: () => [
        AppState.onTodo(user, projectId: 'id', projectTitle: 'title'),
      ],
    );
    blocTest(
      'mapEventToState AppOnProject',
      build: () => mockAppBloc,
      act: (bloc) => bloc.add(AppOnProject()),
      expect: () => [
        AppState.onProject(user),
      ],
    );
    blocTest(
      'mapEventToState AppOnProfile',
      build: () => mockAppBloc,
      act: (bloc) => bloc.add(AppOnProfile()),
      expect: () => [
        AppState.onProfile(user),
      ],
    );
    blocTest(
      'mapEventToState AppOnMeeting',
      build: () => mockAppBloc,
      act: (bloc) => bloc.add(AppOnMeeting()),
      expect: () => [
        AppState.onMeeting(user),
      ],
    );
    blocTest(
      'mapEventToState AppOnInvitation',
      build: () => mockAppBloc,
      act: (bloc) => bloc.add(AppOnInvitation(invitationId: 'id')),
      expect: () => [
        AppState.onInvitation(user, 'id', isMeeting: true),
      ],
    );
    blocTest(
      'mapEventToState AppOnDashboard',
      build: () => mockAppBloc,
      act: (bloc) => bloc.add(AppOnDashboard()),
      expect: () => [
        AppState.onDashboard(user),
      ],
    );
  });
}
