import 'dart:math';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:async';
import 'package:mockito/mockito.dart';

const String testDisabledEmail = 'disabled@example.com';
const String testEmail = 'test@example.com';
const String testPassword = 'testpassword';
const String testPhoneNumber = '+447111555666';
const String _testFirebaseProjectId = 'timelinus-2021';

class EmulatorOobCode {
  @protected
  EmulatorOobCode({
    this.type,
    this.email,
    this.oobCode,
    this.oobLink,
  });

  final EmulatorOobCodeType type;
  final String email;
  final String oobCode;
  final String oobLink;
}

enum EmulatorOobCodeType {
  emailSignIn,
  passwordReset,
  recoverEmail,
  verifyEmail,
}

String get testEmulatorHost {
  if (defaultTargetPlatform == TargetPlatform.android && !kIsWeb) {
    return '10.0.2.2';
  }
  return 'localhost';
}

const String testEmulatorPort = '9099';

String generateRandomEmail({
  String prefix = '',
  String suffix = '@foo.bar',
}) {
  var uuid = createCryptoRandomString();
  var testEmail = prefix + uuid + suffix;
  return testEmail;
}

Future<void> emulatorClearAllUsers() async {
  await http.delete(
    Uri.parse(
        'http://$testEmulatorHost:$testEmulatorPort/emulator/v1/projects/$_testFirebaseProjectId/accounts'),
    headers: {
      'Authorization': 'Bearer owner',
    },
  );
}

Future<EmulatorOobCode> emulatorOutOfBandCode(
  String email,
  EmulatorOobCodeType type,
) async {
  final response = await http.get(
    Uri.parse(
        'http://$testEmulatorHost:$testEmulatorPort/emulator/v1/projects/$_testFirebaseProjectId/oobCodes'),
    headers: {
      'Authorization': 'Bearer owner',
    },
  );

  String requestType;
  switch (type) {
    case EmulatorOobCodeType.emailSignIn:
      requestType = 'EMAIL_SIGNIN';
      break;
    case EmulatorOobCodeType.passwordReset:
      requestType = 'PASSWORD_RESET';
      break;
    case EmulatorOobCodeType.recoverEmail:
      requestType = 'RECOVER_EMAIL';
      break;
    case EmulatorOobCodeType.verifyEmail:
      requestType = 'VERIFY_EMAIL';
      break;
  }

  final responseBody = Map<String, dynamic>.from(jsonDecode(response.body));
  final oobCodes = List<Map<String, dynamic>>.from(responseBody['oobCodes']);
  final dynamic oobCode = oobCodes.reversed.firstWhere(
    (oobCode) =>
        oobCode['email'] == email && oobCode['requestType'] == requestType,
  );

  if (oobCode == null) {
    return null;
  }

  return EmulatorOobCode(
    type: type,
    email: oobCode['email'],
    oobCode: oobCode['oobCode'],
    oobLink: oobCode['oobLink'],
  );
}

Future<void> emulatorDisableUser(String uid) async {
  String body = jsonEncode({'disableUser': true, 'localId': uid});
  await http.post(
    Uri.parse(
        'http://$testEmulatorHost:$testEmulatorPort/identitytoolkit.googleapis.com/v1/accounts:update'),
    headers: {
      'Authorization': 'Bearer owner',
      'Content-Type': 'application/json',
      'Content-Length': '${body.length}',
    },
    body: body,
  );
}

Future<void> ensureSignedOut() async {
  if (FirebaseAuth.instance.currentUser != null) {
    await FirebaseAuth.instance.signOut();
  }
}

Future<void> ensureSignedIn(String testEmail) async {
  if (FirebaseAuth.instance.currentUser == null) {
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: testEmail,
        password: testPassword,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'email-already-in-use') {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword,
        );
      }
    } catch (e) {
      print('ensureSignedIn Error $e');
    }
  }
}

typedef Callback(MethodCall call);

Random _random = Random.secure();

String createCryptoRandomString([int length = 32]) {
  var values = List<int>.generate(length, (i) => _random.nextInt(256));

  return base64Url.encode(values).toLowerCase();
}

class MockFirebaseAuth extends Mock implements FirebaseAuth {
  final stateChangedStreamController = StreamController<User>();
  MockUser _mockUser;
  User _currentUser;

  MockFirebaseAuth({signedIn = false, MockUser mockUser})
      : _mockUser = mockUser {
    if (signedIn) {
      signInWithCredential(null);
    }
  }

  @override
  User get currentUser {
    return _currentUser;
  }

  @override
  Future<UserCredential> createUserWithEmailAndPassword({
    String email,
    String password,
  }) {
    _mockUser = MockUser(email: email);
    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithCredential(AuthCredential credential) {
    return _fakeSignIn();
  }

  @override
  Future<UserCredential> signInWithEmailAndPassword({
    String email,
    String password,
  }) {
    if (email != _mockUser._email) {
      throw FirebaseAuthException(code: 'user-not-found');
    } else {
      return _fakeSignIn();
    }
  }

  @override
  Future<UserCredential> signInWithCustomToken(String token) async {
    return _fakeSignIn();
  }

  @override
  Future<ConfirmationResult> signInWithPhoneNumber(String phoneNumber,
      [RecaptchaVerifier verifier]) async {
    return MockConfirmationResult(onConfirm: () => _fakeSignIn());
  }

  @override
  Future<UserCredential> signInAnonymously() {
    return _fakeSignIn(isAnonymous: true);
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    stateChangedStreamController.add(null);
  }

  Future<UserCredential> _fakeSignIn({bool isAnonymous = false}) {
    final userCredential =
        MockUserCredential(isAnonymous: isAnonymous, mockUser: _mockUser);
    _currentUser = userCredential.user;
    stateChangedStreamController.add(_currentUser);
    return Future.value(userCredential);
  }

  @override
  Stream<User> authStateChanges() => stateChangedStreamController.stream;
}

class MockConfirmationResult extends Mock implements ConfirmationResult {
  Function onConfirm;

  MockConfirmationResult({this.onConfirm});

  @override
  Future<UserCredential> confirm(String verificationCode) {
    return onConfirm();
  }
}

class MockUserCredential extends Mock implements UserCredential {
  final bool _isAnonymous;
  final MockUser _mockUser;

  MockUserCredential({bool isAnonymous, MockUser mockUser})
      // Ensure no mocked credentials or mocked for Anonymous
      : assert(mockUser == null || mockUser.isAnonymous == isAnonymous),
        _isAnonymous = isAnonymous,
        _mockUser = mockUser;

  @override
  User get user => _mockUser ?? MockUser(isAnonymous: _isAnonymous);
}

class MockUser extends Mock with EquatableMixin implements User {
  final bool _isAnonymous;
  final String _uid;
  final String _email;
  final String _displayName;
  final String _phoneNumber;
  final String _photoURL;
  final String _refreshToken;

  MockUser({
    bool isAnonymous = false,
    String uid = 'some_random_id',
    String email,
    String displayName,
    String phoneNumber,
    String photoURL,
    String refreshToken,
  })  : _isAnonymous = isAnonymous,
        _uid = uid,
        _email = email,
        _displayName = displayName,
        _phoneNumber = phoneNumber,
        _photoURL = photoURL,
        _refreshToken = refreshToken;

  @override
  bool get isAnonymous => _isAnonymous;

  @override
  String get uid => _uid;

  @override
  String get email => _email;

  @override
  String get displayName => _displayName;

  @override
  String get phoneNumber => _phoneNumber;

  @override
  String get photoURL => _photoURL;

  @override
  String get refreshToken => _refreshToken;

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async {
    return Future.value('fake_token');
  }

  @override
  List<Object> get props => [
        _isAnonymous,
        _uid,
        _email,
        _displayName,
        _phoneNumber,
        _photoURL,
        _refreshToken,
      ];
}
