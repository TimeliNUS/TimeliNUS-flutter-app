import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class User extends Equatable {
  /// {@macro user}
  const User({@required this.id, this.email, this.name, this.ref, this.profilePicture});

  /// The current user's email address.
  final String email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String name;

  final DocumentReference ref;

  final String profilePicture;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object> get props => [email, id, name];

  static User fromJson(Map<String, dynamic> json, String id, {DocumentReference ref}) {
    return new User(id: id, name: json['name'], email: json['email'], ref: ref);
  }

  Map<String, Object> toJson() {
    return {
      'ref': ref,
      // 'id': id,
      'name': name,
      // 'email': email,
    };
  }

  @override
  String toString() {
    return 'id: $id, email: $email, name: $name, ref: $ref';
  }
}
