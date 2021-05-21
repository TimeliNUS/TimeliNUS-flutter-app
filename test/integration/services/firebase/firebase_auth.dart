import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/utils/services/firebase.dart';

import '../../../utils/firebase_util.dart';

void main() {
  String email = generateRandomEmail();

  test('should throw user-not-found or user-mismatch ', () async {
    // Setup
    User user = await FirebaseService.register(email, testPassword);

    try {
      // Test
      AuthCredential credential = EmailAuthProvider.credential(
          email: 'userdoesnotexist@foobar.com', password: testPassword);
      await user.reauthenticateWithCredential(credential);
      throw FirebaseAuthException(message: "hi", code: "123");
    } on FirebaseAuthException catch (e) {
      // Platforms throw different errors. For now, leave them as is
      // but in future we might want to edit them before sending to user.
      if (e.code != 'user-mismatch' && e.code != 'user-not-found') {
        fail('should have thrown a valid error code (got ${e.code}');
      }
      return;
    } catch (e) {
      fail('should have thrown an FirebaseAuthException');
    }
    fail('should have thrown an error');
  });
}
