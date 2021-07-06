import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/models/projectEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class Project extends Equatable {
  final String title;
  final String id;
  final String moduleCode;
  final double progress;
  final DateTime deadline;
  final List<User> groupmates;
  final List<Meeting> meetings;
  final List<Todo> todos;
  // final List<User> confirmed;
  // final List<User> invited;
  final DocumentReference ref;

  const Project(this.title,
      {this.id,
      this.moduleCode,
      this.progress = 1,
      this.deadline,
      this.groupmates = const [],
      this.meetings = const [],
      this.todos = const [],
      // this.confirmed = const [],
      // this.invited = const [],
      this.ref});

  static Project fromEntity(ProjectEntity entity) {
    return Project(
      entity.title,
      moduleCode: entity.moduleCode,
      id: entity.id,
      progress: entity.progress,
      deadline: entity.deadline != null ? entity.deadline.toDate() : null,
      groupmates: entity.groupmates != null ? entity.groupmates : [],
      meetings: entity.meetings,
      todos: entity.todos,
      ref: entity.ref,
      // confirmed: entity.confirmed,
      // invited: entity.invited
    );
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
      title, moduleCode, id, progress, deadline != null ? Timestamp.fromDate(deadline) : null,
      groupmates, meetings, todos, ref,
      // confirmed, invited
    );
  }

  Project copyWith(
      {String title,
      String moduleCode,
      String id,
      double progress,
      DateTime deadline,
      List<User> groupmates,
      List<Meeting> meetings,
      List<Todo> todos,
      DocumentReference ref,
      List<User> confirmed,
      List<User> invited}) {
    return Project(
      title ?? this.title,
      moduleCode: moduleCode ?? this.moduleCode,
      id: id ?? this.id,
      progress: progress ?? this.progress,
      deadline: deadline ?? this.deadline,
      groupmates: groupmates ?? this.groupmates,
      meetings: meetings ?? this.meetings,
      todos: todos ?? this.todos,
      ref: ref ?? this.ref,
      // confirmed: confirmed ?? this.confirmed,
      // invited: invited ?? this.invited
    );
  }

  @override
  List<Object> get props => [id, title, moduleCode, progress, deadline, groupmates, meetings, ref, todos];
}
