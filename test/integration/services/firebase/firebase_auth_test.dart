import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in_mocks/google_sign_in_mocks.dart';
import 'package:mockito/mockito.dart';
import '../../../utils/firebase_util.dart';
import 'package:TimeliNUS/models/userModel.dart' as UserModel;
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';

// bool useEmulator = true;

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

// class MockSecureStorage extends Mock implements FlutterSecureStorage {}

// class MockAuthClient extends Mock implements AutoRefreshingAuthClient {
//   AccessCredentials credentials;

//   MockAuthClient({AccessToken accessToken, String refreshToken}) {
//     credentials = AccessCredentials(accessToken, refreshToken, []);
//   }
// }

void main() {}
//   setupCloudFirestoreMocks();
//   final String userEmail = "bob@somedomain.com";
//   final String registerEmail = "markmcwong@yahoo.com";
//   AuthenticationRepository authenticationRepository;
//   final loginUser = MockUser(
//     isAnonymous: false,
//     uid: 'someuid',
//     email: userEmail,
//     displayName: 'Bob',
//   );
//   final registerUser = MockUser(isAnonymous: false, uid: 'some_random_id', email: registerEmail);
//   setUp(() async {
//     TestWidgetsFlutterBinding.ensureInitialized();
//     await Firebase.initializeApp();
//     final auth = MockFirebaseAuth(mockUser: loginUser);
//     authenticationRepository = new AuthenticationRepository(
//         firebaseAuth: auth, firebaseFirestore: FakeFirebaseFirestore(), secureStorage: MockSecureStorage());
//     // MockGoogleSignIn googleSignIn = MockGoogleSignIn();
//     // FirebaseService().changeAuthInstance(auth, null);
//   });

//   test(('test firebase login'), () async {
//     await authenticationRepository.logInWithEmailAndPassword(email: userEmail, password: "password");
//     UserModel.User returnedUser = authenticationRepository.getUser();
//     expect(
//         UserModel.User(
//             id: 'someuid',
//             email: userEmail,
//             name: 'Bob',
//             ref: FirebaseFirestore.instance.collection('user').doc('someuid')),
//         returnedUser);
//   });

//   test(('test firebase login fail'), () async {
//     expect(
//       () async => await authenticationRepository.logInWithEmailAndPassword(email: registerEmail, password: "password"),
//       throwsA(isInstanceOf<AuthenticationFailture>()),
//     );
//   });

// //   test(('test firebase login'), () async {
// //     await FirebaseService().login(userEmail, "password");
// //     User returnedUser = await FirebaseService().getUser();
// //     expect(returnedUser, loginUser);
// //   });

// //   test(('test firebase login with invalid email'), () async {
// //     final testResult = await FirebaseService().login("userEmail@asd.com", "password");
// //     expect(testResult, "No user found for that email.");
// //     // throwsA(isInstanceOf<FirebaseAuthException>()));
// //   });

//   // test(('test firebase Google login'), () async {
//   //   final googleSignIn = MockGoogleSignIn();
//   //   final signinAccount = await googleSignIn.signIn();
//   //   final googleAuth = await signinAccount.authentication;
//   //   when(clientViaUserConsent(any, any, any)).thenAnswer((ans) => Future.value(MockAuthClient(
//   //       accessToken: AccessToken('Bearer', googleAuth.accessToken, DateTime.now().add(Duration(days: 1))),
//   //       refreshToken: googleAuth.idToken)));
//   //   await authenticationRepository.logInWithGoogle();
//   //   // User returnedUser = await FirebaseService().getUser();
//   //   // expect(returnedUser, loginUser);
//   // });

//   test(('test firebase logout'), () async {
//     await authenticationRepository.logInWithEmailAndPassword(email: userEmail, password: "password");
//     await authenticationRepository.logOut();
//     UserModel.User returnedUser = authenticationRepository.getUser();
//     expect(returnedUser, null);
//   });

//   // test(('test firebase logout failure'), () async {
//   //   await authenticationRepository.logOut();
//   //   // await authenticationRepository.logInWithEmailAndPassword(email: userEmail, password: "password");
//   //   // UserModel.User returnedUser = authenticationRepository.getUser();
//   //   expect(() async => await authenticationRepository.logOut(), throwsA(isInstanceOf<LogOutFailure>()));
//   // });
// }
