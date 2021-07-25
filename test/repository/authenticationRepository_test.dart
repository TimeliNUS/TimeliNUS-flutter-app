import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart' as authMocks;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:http/http.dart';
// import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:mockito/mockito.dart';
import 'package:TimeliNUS/models/userModel.dart' as UserModel;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';

import '../integration/services/firebase/firebase_auth_test.dart';
import '../utils/firebase_util.dart';

bool useEmulator = true;

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

class MockAuthClient extends Mock implements AutoRefreshingAuthClient {
  AccessCredentials credentials;

  MockAuthClient({AccessToken accessToken, String refreshToken}) {
    credentials = AccessCredentials(accessToken, refreshToken, []);
  }
}

class MockFunction extends Mock {
  // Future<AuthClient> call({clientId: String, prompt: dynamic, scopes: List});
  Future<AuthClient> call(clientId, prompt, scopes);
}

void main() {
  setupCloudFirestoreMocks();
  final String userEmail = "bob@somedomain.com";
  final String registerEmail = "markmcwong@yahoo.com";
  AuthenticationRepository authenticationRepository;
  FakeFirebaseFirestore instance;
  final loginUser = MockUser(
    isAnonymous: false,
    uid: 'someuid',
    email: userEmail,
    displayName: 'Bob',
  );
  final registerUser = MockUser(isAnonymous: false, uid: 'some_random_id', email: registerEmail);
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    instance = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(mockUser: loginUser);
    authenticationRepository = new AuthenticationRepository(
        firebaseAuth: auth, firebaseFirestore: instance, secureStorage: MockSecureStorage());
  });

  test(('test firebase login'), () async {
    await authenticationRepository.logInWithEmailAndPassword(email: userEmail, password: "password");
    UserModel.User returnedUser = authenticationRepository.getUser();
    expect(
        UserModel.User(
            id: 'someuid',
            email: userEmail,
            name: 'Bob',
            ref: FirebaseFirestore.instance.collection('user').doc('someuid')),
        returnedUser);
  });

  test(('test firebase login fail'), () async {
    expect(
      () async => await authenticationRepository.logInWithEmailAndPassword(email: registerEmail, password: "password"),
      throwsA(isInstanceOf<AuthenticationFailture>()),
    );
  });

  test(('test signup'), () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    expect(returnedUser.email, loginUser.email);
  });

  test(('test firebase logout'), () async {
    await authenticationRepository.logInWithEmailAndPassword(email: userEmail, password: "password");
    await authenticationRepository.logOut();
    UserModel.User returnedUser = authenticationRepository.getUser();
    expect(returnedUser, null);
  });

  test(('test Google login new user'), () async {
    final auth = MockFirebaseAuth(mockUser: loginUser, isNewUser: true);
    final googleSignIn = MockGoogleSignIn();
    final signinAccount = await googleSignIn.signIn();
    final googleAuth = await signinAccount.authentication;
    final Function(String, dynamic, dynamic) mockFunction = MockFunction();
    when(mockFunction(any, any, any)).thenAnswer((_) {
      return Future.value(MockAuthClient(
          accessToken: AccessToken('Bearer', googleAuth.accessToken, DateTime.now().add(Duration(days: 1)).toUtc()),
          refreshToken: googleAuth.idToken));
    });
    authenticationRepository = new AuthenticationRepository(
        firebaseAuth: auth,
        firebaseFirestore: instance,
        secureStorage: MockSecureStorage(),
        popupFunction: mockFunction);
    await authenticationRepository.logInWithGoogle();
    UserModel.User returnedUser = authenticationRepository.getUser();
    expect(returnedUser.email, loginUser.email);
    final snapshot = await instance.collection('user').get();
    expect(snapshot.docs[0].data()['googleRefreshToken'], googleAuth.idToken);
  });

  test(('test Google login existing user'), () async {
    final auth = MockFirebaseAuth(mockUser: loginUser, isNewUser: false);
    final googleSignIn = MockGoogleSignIn();
    final signinAccount = await googleSignIn.signIn();
    final googleAuth = await signinAccount.authentication;
    final Function(String, dynamic, dynamic) mockFunction = MockFunction();
    when(mockFunction(any, any, any)).thenAnswer((_) {
      return Future.value(MockAuthClient(
          accessToken: AccessToken('Bearer', googleAuth.accessToken, DateTime.now().add(Duration(days: 1)).toUtc()),
          refreshToken: googleAuth.idToken));
    });
    authenticationRepository = new AuthenticationRepository(
        firebaseAuth: auth,
        firebaseFirestore: instance,
        secureStorage: MockSecureStorage(),
        popupFunction: mockFunction);
    await authenticationRepository.logInWithGoogle();
    UserModel.User returnedUser = authenticationRepository.getUser();
    expect(returnedUser.email, loginUser.email);
    final snapshot = await instance.collection('user').get();
    expect(snapshot.docs[0].data()['googleRefreshToken'], googleAuth.idToken);
  });

  test(('test saveTokenToDatabase'), () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    await authenticationRepository.saveTokenToDatabase('token', returnedUser.id);
    final snapshot = await instance.collection('user').get();
    expect(snapshot.docs[0].data()['tokens'], ['token']);
  });

  test(('test importNewCalendar'), () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    await authenticationRepository.importNewCalendar('calendarUrl', returnedUser.id);
    final snapshot = await instance.collection('user').get();
    expect(snapshot.docs[0].data()['calendar'], 'calendarUrl');
  });

  test(('test linkedToZoom'), () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    String token = await authenticationRepository.checkLinkedToZoom(returnedUser.id);
    expect(token, isNull);
  });

  test(('test linkedToGoogle'), () async {
    final auth = MockFirebaseAuth(mockUser: loginUser, isNewUser: false);
    final googleSignIn = MockGoogleSignIn();
    final signinAccount = await googleSignIn.signIn();
    final googleAuth = await signinAccount.authentication;
    final Function(String, dynamic, dynamic) mockFunction = MockFunction();
    when(mockFunction(any, any, any)).thenAnswer((_) {
      return Future.value(MockAuthClient(
          accessToken: AccessToken('Bearer', googleAuth.accessToken, DateTime.now().add(Duration(days: 1)).toUtc()),
          refreshToken: googleAuth.idToken));
    });
    authenticationRepository = new AuthenticationRepository(
        firebaseAuth: auth,
        firebaseFirestore: instance,
        secureStorage: MockSecureStorage(),
        popupFunction: mockFunction);
    await authenticationRepository.logInWithGoogle();
    UserModel.User returnedUser = authenticationRepository.getUser();
    String token = await authenticationRepository.checkLinkedToGoogle(returnedUser.id);
    expect(token, isNot(null));
  });

  test(('test link to Google'), () async {
    final auth = MockFirebaseAuth(mockUser: loginUser, isNewUser: false);
    final googleSignIn = MockGoogleSignIn();
    final signinAccount = await googleSignIn.signIn();
    final googleAuth = await signinAccount.authentication;
    final Function(String, dynamic, dynamic) mockFunction = MockFunction();
    when(mockFunction(any, any, any)).thenAnswer((_) {
      return Future.value(MockAuthClient(
          accessToken: AccessToken('Bearer', googleAuth.accessToken, DateTime.now().add(Duration(days: 1)).toUtc()),
          refreshToken: googleAuth.idToken));
    });
    authenticationRepository = new AuthenticationRepository(
        firebaseAuth: auth,
        firebaseFirestore: instance,
        secureStorage: MockSecureStorage(),
        popupFunction: mockFunction);
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    await authenticationRepository.linkAccountWithGoogle();
    returnedUser = authenticationRepository.getUser();
    String token = await authenticationRepository.checkLinkedToGoogle(returnedUser.id);
    expect(token, isNot(null));
  });
}
