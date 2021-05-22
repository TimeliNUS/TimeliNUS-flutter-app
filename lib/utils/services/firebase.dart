import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseAuth _auth = FirebaseAuth.instance;
  // static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static GoogleSignIn _googleSignIn = GoogleSignIn();

  static void changeAuthInstance(
      FirebaseAuth newInstance, GoogleSignIn newGoogleSignIn) {
    _auth = newInstance;
    _googleSignIn = newGoogleSignIn;
  }

  static Future<void> switchToEmulator() async {
    await FirebaseAuth.instance.useEmulator('http://localhost:9099');
  }

  static Stream<User> get user => _auth.authStateChanges();

  static Future<String> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      return ('Failed with error code: ${e.code} ${e.message}');
    }
    return '';
  }

  static Future<String> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
    return '';
  }

  static Future<void> signInWithGoogle({BuildContext context}) async {
    final GoogleSignInAccount googleSignInAccount =
        (await _googleSignIn.signIn());

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        await _auth.signInWithCredential(credential);
      } on FirebaseAuthException catch (e) {
        if (e.code == 'account-exists-with-different-credential') {
          // handle the error here
        } else if (e.code == 'invalid-credential') {
          // handle the error here
        }
      } catch (e) {
        // handle the error here
      }
    }
  }

  static Future<bool> isSignedIn() async {
    final currentUser = await getUser();
    return currentUser != null;
  }

  static Future<User> getUser() async {
    return _auth.currentUser;
  }

  static Future<void> logOut() async {
    return Future.wait([
      _auth.signOut(),
      // _googleSignIn.signOut(),
    ]);
  }

  // static Future<String> add() async {
  //   FirebaseFirestore.instance.settings = Settings(
  //       host: 'localhost:8080', sslEnabled: false, persistenceEnabled: false);
  //   CollectionReference users = FirebaseFirestore.instance.collection('users');
  //   return users
  //       .add({
  //         'full_name': 'fullName', // John Doe
  //         'company': 'company', // Stokes and Sons
  //         'age': 'age' // 42
  //       })
  //       .then((value) => ("User Added"))
  //       .catchError((error) => ("Failed to add user: $error"));
  // }
}
