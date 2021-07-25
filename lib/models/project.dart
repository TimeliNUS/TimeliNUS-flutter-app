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
  final int noOfMeetings;
  final List<Todo> todos;
  final List<User> invited;
  final List<User> confirmed;
  final DocumentReference ref;

  const Project(this.title,
      {this.id,
      this.moduleCode,
      this.progress = 1,
      this.deadline,
      this.groupmates = const [],
      this.noOfMeetings = 0,
      this.todos = const [],
      this.invited = const [],
      this.confirmed = const [],
      this.ref});

  static Project fromEntity(ProjectEntity entity) {
    return Project(
      entity.title,
      moduleCode: entity.moduleCode,
      id: entity.id,
      progress: entity.progress,
      deadline: entity.deadline != null ? entity.deadline.toDate() : null,
      groupmates: entity.groupmates != null ? entity.groupmates : [],
      noOfMeetings: entity.noOfMeetings,
      todos: entity.todos,
      ref: entity.ref,
      invited: entity.invited ?? [],
      confirmed: entity.confirmed ?? [],
    );
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
      title, moduleCode, id, progress, deadline != null ? Timestamp.fromDate(deadline) : null,
      groupmates, noOfMeetings, todos, invited, confirmed, ref,
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
      int noOfMeetings,
      List<Todo> todos,
      DocumentReference ref,
      List<User> confirmed,
      List<User> invited}) {
    return Project(title ?? this.title,
        moduleCode: moduleCode ?? this.moduleCode,
        id: id ?? this.id,
        progress: progress ?? this.progress,
        deadline: deadline ?? this.deadline,
        groupmates: groupmates ?? this.groupmates,
        noOfMeetings: noOfMeetings ?? this.noOfMeetings,
        todos: todos ?? this.todos,
        ref: ref ?? this.ref,
        confirmed: confirmed ?? this.confirmed,
        invited: invited ?? this.invited);
  }

  @override
  List<Object> get props =>
      [id, title, moduleCode, progress, deadline, groupmates, noOfMeetings, ref, todos, confirmed, invited];
}
