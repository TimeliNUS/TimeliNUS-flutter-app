import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/utils/services/firebase.dart';
import '../../../utils/firebase_util.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';

bool useEmulator = true;
setupCloudFirestoreMocks([Callback customHandlers]) {
  TestWidgetsFlutterBinding.ensureInitialized();

  MethodChannelFirebase.channel.setMockMethodCallHandler((call) async {
    if (call.method == 'Firebase#initializeCore') {
      return [
        {
          'name': defaultFirebaseAppName,
          'options': {
            'apiKey': '123',
            'appId': '123',
            'messagingSenderId': '123',
            'projectId': '123',
          },
          'pluginConstants': {},
        }
      ];
    }

    if (call.method == 'Firebase#initializeApp') {
      return {
        'name': call.arguments['appName'],
        'options': call.arguments['options'],
        'pluginConstants': {},
      };
    }

    if (customHandlers != null) {
      customHandlers(call);
    }

    return null;
  });
}

void main() {
  final String userEmail = "bob@somedomain.com";
  final String registerEmail = "markmcwong@yahoo.com";
  final loginUser = MockUser(
    isAnonymous: false,
    uid: 'someuid',
    email: userEmail,
    displayName: 'Bob',
  );
  final registerUser =
      MockUser(isAnonymous: false, uid: 'some_random_id', email: registerEmail);
  setupCloudFirestoreMocks();
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    final auth = MockFirebaseAuth(mockUser: loginUser);
    MockGoogleSignIn googleSignIn = MockGoogleSignIn();
    FirebaseService().changeAuthInstance(auth, googleSignIn);
  });

  test(('test firebase register'), () async {
    await FirebaseService().register(registerEmail, "password");
    User returnedUser = await FirebaseService().getUser();
    expect(returnedUser, registerUser);
  });

  test(('test firebase login'), () async {
    await FirebaseService().login(userEmail, "password");
    User returnedUser = await FirebaseService().getUser();
    expect(returnedUser, loginUser);
  });

  test(('test firebase login with invalid email'), () async {
    final testResult =
        await FirebaseService().login("userEmail@asd.com", "password");
    expect(testResult, "No user found for that email.");
    // throwsA(isInstanceOf<FirebaseAuthException>()));
  });

  test(('test firebase Google login'), () async {
    await FirebaseService().signInWithGoogle();
    User returnedUser = await FirebaseService().getUser();
    expect(returnedUser, loginUser);
  });

  test(('test firebase logout'), () async {
    await FirebaseService().signInWithGoogle();
    await FirebaseService().logOut();
    User returnedUser = await FirebaseService().getUser();
    expect(returnedUser, null);
  });
}
