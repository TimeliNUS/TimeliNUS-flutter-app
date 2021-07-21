import 'dart:async';
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:TimeliNUS/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:meta/meta.dart';
import 'package:url_launcher/url_launcher.dart';
// Thrown if during the sign up process if a failure occurs.

class AuthenticationFailture implements Exception {
  String cause;
  AuthenticationFailture(this.cause);

  @override
  String toString() {
    return "Authentication Failure: " + cause;
  }
}

class SignUpFailure implements AuthenticationFailture {
  String cause;
  SignUpFailure(this.cause);
}

/// Thrown during the login process if a failure occurs.
class LogInWithEmailAndPasswordFailure implements Exception {}

/// Thrown during the sign in with google process if a failure occurs.
class LogInWithGoogleFailure implements Exception {}

/// Thrown during the logout process if a failure occurs.
class LogOutFailure implements Exception {}

class AuthenticationRepository {
  /// {@macro authentication_repository}
  AuthenticationRepository({
    FirebaseAuth.FirebaseAuth firebaseAuth,
    GoogleSignIn googleSignIn,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.FirebaseAuth.instance;
  // _googleSignIn = googleSignIn ??
  //     GoogleSignIn(
  //       scopes: [
  //         'email',
  //         'https://www.googleapis.com/auth/calendar',
  //       ],
  // );

  final FirebaseAuth.FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      'email',
      'https://www.googleapis.com/auth/calendar',
    ],
  );
  User _currentUser;

  static ClientId id =
      ClientId("114066663509-q3koofrq4dsvve435l786tuke74q4pof.apps.googleusercontent.com", "lVKx-s1uUAP_JmY-qsQ6p1Bv");
  static final scopes = ['email', 'https://www.googleapis.com/auth/calendar'];
  static final storage = new FlutterSecureStorage();

  /// Stream of [User] which will emit the current user when
  /// the authentication state changes.
  ///
  /// Emits [User.empty] if the user is not authenticated.
  Stream<User> get user {
    return _firebaseAuth.userChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _currentUser = user;
      return user;
    });
  }

  /// Returns the current cached user.
  /// Defaults to [User.empty] if there is no cached user.
  User get currentUser {
    return _currentUser;
  }

  /// Creates a new user with the provided [email] and [password].
  ///
  /// Throws a [SignUpFailure] if an exception occurs.
  Future<void> signUp({@required String email, @required String password, @required String name}) async {
    try {
      FirebaseAuth.UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      List<Future> promises = [];
      promises.add(credential.user.updateProfile(displayName: name));
      promises.add(FirebaseFirestore.instance
          .collection('user')
          .doc(credential.user.uid)
          .set({'name': name, 'email': email, 'project': [], 'todo': [], 'meeting': []}));
      Future.wait(promises);
      // await _firebaseAuth.signOut();
      print(_firebaseAuth.currentUser);
    } on FirebaseAuth.FirebaseAuthException catch (err) {
      throw AuthenticationFailture(err.code);
    }
  }

  /// Starts the Sign In with Google Flow.
  ///
  /// Throws a [logInWithGoogle] if an exception occurs.
  Future<void> logInWithGoogle() async {
    try {
      clientViaUserConsent(id, scopes, prompt).then((AuthClient client) async {
        await closeWebView();
        print('writing tokens...');
        await storage.write(key: 'refreshToken', value: client.credentials.refreshToken);
        await storage.write(key: 'accessToken', value: client.credentials.accessToken.data);
        await storage.write(key: 'expiryDate', value: client.credentials.accessToken.expiry.toIso8601String());
        final credential = FirebaseAuth.GoogleAuthProvider.credential(
          accessToken: client.credentials.accessToken.data,
          idToken: client.credentials.idToken,
        );
        FirebaseAuth.UserCredential cred = await _firebaseAuth.signInWithCredential(credential);
        client.close();
        if (cred.additionalUserInfo.isNewUser) {
          await (FirebaseFirestore.instance.collection('user').doc(cred.user.uid).set({
            'name': cred.user.displayName,
            'email': cred.user.email,
            'project': [],
            'todo': [],
            'meeting': [],
            'googleRefreshToken': client.credentials.refreshToken
          }));
        } else {
          await (FirebaseFirestore.instance
              .collection('user')
              .doc(cred.user.uid)
              .update({'googleRefreshToken': client.credentials.refreshToken}));
        }
      });
    } on FirebaseAuth.FirebaseAuthException catch (err) {
      throw AuthenticationFailture(err.code);
    }
  }

  static void linkAccountWithGoogle() async {
    try {
      final storage = new FlutterSecureStorage();

      clientViaUserConsent(id, scopes, prompt).then((AuthClient client) async {
        await closeWebView();
        print('writing tokens...');
        await storage.write(key: 'refreshToken', value: client.credentials.refreshToken);
        await storage.write(key: 'accessToken', value: client.credentials.accessToken.data);
        await storage.write(key: 'expiryDate', value: client.credentials.accessToken.expiry.toIso8601String());
        final credential = FirebaseAuth.GoogleAuthProvider.credential(
          accessToken: client.credentials.accessToken.data,
          idToken: client.credentials.idToken,
        );
        FirebaseAuth.UserCredential cred =
            await FirebaseAuth.FirebaseAuth.instance.currentUser.linkWithCredential(credential);
        client.close();
        await (FirebaseFirestore.instance
            .collection('user')
            .doc(cred.user.uid)
            .update({'googleRefreshToken': client.credentials.refreshToken}));
      });
    } on FirebaseAuth.FirebaseAuthException catch (err) {
      throw AuthenticationFailture(err.code);
    }
  }

  static void prompt(String url) async {
    print("Please go to the following URL and grant access:");
    print("  => $url");
    print("");
    await launch(url, forceWebView: true, forceSafariVC: true);
  }

  /// Signs in with the provided [email] and [password].
  ///
  /// Throws a [LogInWithEmailAndPasswordFailure] if an exception occurs.
  Future<void> logInWithEmailAndPassword({
    @required String email,
    @required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuth.FirebaseAuthException catch (err) {
      throw AuthenticationFailture(err.code);
    }
  }

  /// Signs out the current user which will emit
  /// [User.empty] from the [user] Stream.
  ///
  /// Throws a [LogOutFailure] if an exception occurs.
  Future<void> logOut() async {
    try {
      await storage.deleteAll();
      await _firebaseAuth.signOut();
      // await Future.wait([_firebaseAuth.signOut(), _googleSignIn.signOut(), _googleSignIn.disconnect()]);
    } on Exception {
      throw LogOutFailure();
    }
  }

  Future<void> saveTokenToDatabase(String token, String userId) async {
    // Assume user is logged in for this example
    // String userId = FirebaseAuth.FirebaseAuth.instance.currentUser.uid;
    await FirebaseFirestore.instance.collection('user').doc(userId).update({
      'tokens': FieldValue.arrayUnion([token]),
    });
  }

  static Future<List<User>> findUsersByRef(List<dynamic> refs) async {
    List<User> users = [];
    for (DocumentReference documentReference in refs) {
      final DocumentSnapshot temp = await documentReference.get();
      User documentSnapshotTask = User.fromJson(temp.data(), temp.id, ref: temp.reference);
      users.add(documentSnapshotTask);
    }
    return users;
  }

  Future<void> updateProfilePicture(String url) async {
    // Assume user is logged in for this example
    // String userId = FirebaseAuth.FirebaseAuth.instance.currentUser.uid;
    await _firebaseAuth.currentUser.updateProfile(photoURL: url);
    await FirebaseFirestore.instance.collection('user').doc(_firebaseAuth.currentUser.uid).update({
      'photoURL': url,
    });
  }

  static Future<void> importNewCalendar(String url, String userId) async {
    await FirebaseFirestore.instance.collection('user').doc(userId).update({
      'calendar': url,
    });
  }

  Future<String> refreshTokenAPI(String token) async {
    final response = await http.post(
      Uri.parse("https://oauth2.googleapis.com/token"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "grant_type": 'refresh_token',
        "refresh_token": token,
        'client_secret': 'lVKx-s1uUAP_JmY-qsQ6p1Bv',
        'client_id': '114066663509-q3koofrq4dsvve435l786tuke74q4pof.apps.googleusercontent.com'
      }),
    );
    return jsonDecode(response.body)['access_token'];
  }

  static Future<String> checkLinkedToGoogle(String id) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('user').doc(id).get();
    Map<String, Object> data = snapshot.data();
    return ((data['googleRefreshToken'] != null ? data['googleRefreshToken'] as String : null));
  }

  Future<void> refreshToken(String refreshToken) async {
    print("Token Refresh : " + refreshToken);
    String token = await refreshTokenAPI(refreshToken);
    await storage.write(key: 'accessToken', value: token);
    print('token: ' + token);
    return;
  }

  static Future<String> checkLinkedToZoom(String id) async {
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('user').doc(id).get();
    Map<String, Object> data = snapshot.data();
    // print('isLinked to Zoom ? : ' + (data['zoomRefreshToken'] != null).toString());
    return (((data != null && data['zoomRefreshToken'] != null) ? data['zoomRefreshToken'] as String : null));
  }
}

extension on FirebaseAuth.User {
  User get toUser {
    return User(
        id: uid,
        email: email,
        name: displayName,
        ref: FirebaseFirestore.instance.collection('user').doc(uid),
        profilePicture: (photoURL ?? 'https://via.placeholder.com/500x500'));
  }
}
