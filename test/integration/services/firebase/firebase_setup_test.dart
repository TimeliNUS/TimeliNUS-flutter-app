import 'package:TimeliNUS/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/utils/services/firebase.dart';
import '../../../utils/firebase_util.dart';
import 'firebase_auth.dart';
// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
// import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';

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
    FirebaseService.changeAuthInstance(auth, googleSignIn);
  });

  test(('test firebase register'), () async {
    User returnedUser =
        await FirebaseService.register(registerEmail, "password");
    expect(returnedUser, registerUser);
  });

  test(('test firebase login'), () async {
    User returnedUser = await FirebaseService.login(userEmail, "password");
    expect(returnedUser, loginUser);
  });

  test(('test firebase login with invalid email'), () async {
    final testResult =
        await FirebaseService.login("userEmail@asd.com", "password");
    expect(testResult, "No user found for that email.");
    // throwsA(isInstanceOf<FirebaseAuthException>()));
  });

  test(('test firebase Google login'), () async {
    User returnedUser = await FirebaseService.signInWithGoogle();
    expect(returnedUser, loginUser);
  });
}
