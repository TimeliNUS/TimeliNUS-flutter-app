import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

class User extends Equatable {
  /// {@macro user}
  const User({
    @required this.id,
    this.email,
    this.name,
  });

  /// The current user's email address.
  final String email;

  /// The current user's id.
  final String id;

  /// The current user's name (display name).
  final String name;

  /// Empty user which represents an unauthenticated user.
  static const empty = User(id: '');

  /// Convenience getter to determine whether the current user is empty.
  bool get isEmpty => this == User.empty;

  /// Convenience getter to determine whether the current user is not empty.
  bool get isNotEmpty => this != User.empty;

  @override
  List<Object> get props => [email, id, name];

  static User fromJson(Map<String, dynamic> json, String id) {
    return new User(
      id: id,
      name: json['name'],
      email: json['email'],
    );
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
    };
  }

  @override
  String toString() {
    return 'id: $id, email: $email, name: $name';
  }
}
