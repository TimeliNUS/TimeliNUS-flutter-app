import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class User extends Equatable {
  /// {@macro user}
  const User({@required this.id, this.calendar, this.email, this.name, this.ref, this.profilePicture});

  /// The current user's email address.
  final String email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String name;

  final DocumentReference ref;

  final String profilePicture;

  final String calendar;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object> get props => [email, id, name];

  static User fromJson(Map<String, dynamic> json, String id, {DocumentReference ref}) {
    return new User(
        id: id,
        name: json['name'],
        email: json['email'],
        ref: ref,
        calendar: json['calendar'],
        profilePicture: json['photoURL'] ??
            'https://firebasestorage.googleapis.com/v0/b/timelinus-2021.appspot.com/o/default_profile_pic.jpg?alt=media&token=093aee02-56ad-45b8-a937-ab337cf145f1');
  }

  Map<String, Object> toJson() {
    return {
      'ref': ref,
      // 'id': id,
      'name': name,
      // 'email': email,
    };
  }

  User updateNewCalendar(String url) {
    return new User(id: id, name: name, email: email, ref: ref, calendar: url, profilePicture: profilePicture);
  }

  @override
  String toString() {
    return 'id: $id, email: $email, name: $name, ref: $ref';
  }
}
