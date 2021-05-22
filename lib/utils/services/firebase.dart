import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:google_sign_in/google_sign_in.dart';

class FirebaseService {
  static FirebaseAuth auth = FirebaseAuth.instance;
  // static FirebaseFirestore firestore = FirebaseFirestore.instance;
  static GoogleSignIn googleSignIn = GoogleSignIn();

  static void changeAuthInstance(
      FirebaseAuth newInstance, GoogleSignIn newGoogleSignIn) {
    auth = newInstance;
    googleSignIn = newGoogleSignIn;
  }

  Stream<User> get user => auth.authStateChanges();

  static Future<User> register(String email, String password) async {
    // FirebaseAuth.instance.useEmulator('http://localhost:9099');
    User user;
    try {
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      print('Failed with error code: ${e.code}');
      print(e.message);
    }
    return user;
  }

  static Future<dynamic> login(String email, String password) async {
    User user;
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password provided for that user.';
      }
    }
    return user;
  }

  static Future<User> signInWithGoogle({BuildContext context}) async {
    User user;
    final GoogleSignInAccount googleSignInAccount =
        (await googleSignIn.signIn());

    if (googleSignInAccount != null) {
      final GoogleSignInAuthentication googleSignInAuthentication =
          await googleSignInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken,
      );

      try {
        final UserCredential userCredential =
            await auth.signInWithCredential(credential);

        user = userCredential.user;
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

    return user;
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
