import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:firebase_auth_platform_interface/src/method_channel/method_channel_firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

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
  final oobCode = oobCodes.reversed.firstWhere(
    (oobCode) =>
        oobCode['email'] == email && oobCode['requestType'] == requestType,
    orElse: () => null,
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
