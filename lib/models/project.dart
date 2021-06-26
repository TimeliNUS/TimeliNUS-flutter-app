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
  final DocumentReference ref;

  const Project(this.title,
      {this.id,
      this.moduleCode,
      this.progress = 1,
      this.deadline,
      this.groupmates = const [],
      this.meetings = const [],
      this.todos = const [],
      this.ref});

  static Project fromEntity(ProjectEntity entity) {
    return Project(entity.title,
        moduleCode: entity.moduleCode,
        id: entity.id,
        progress: entity.progress,
        deadline: entity.deadline != null ? entity.deadline.toDate() : null,
        groupmates: entity.groupmates != null ? entity.groupmates : [],
        meetings: entity.meetings,
        todos: entity.todos,
        ref: entity.ref);
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
        title,
        moduleCode,
        id,
        progress,
        deadline != null ? Timestamp.fromDate(deadline) : null,
        groupmates,
        meetings,
        todos,
        ref);
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
      DocumentReference ref}) {
    return Project(title ?? this.title,
        moduleCode: moduleCode ?? this.moduleCode,
        id: id ?? this.id,
        progress: progress ?? this.progress,
        deadline: deadline ?? this.deadline,
        groupmates: groupmates ?? this.groupmates,
        meetings: meetings ?? this.meetings,
        todos: todos ?? this.todos,
        ref: ref ?? this.ref);
  }

  @override
  List<Object> get props => [
        id,
        title,
        moduleCode,
        progress,
        deadline,
        groupmates,
        meetings,
        ref,
        todos
      ];

  @override
  String toString() {
    return 'Project[' +
        // this.title +
        // ' ' + this.id != null
        //     ? this.id
        //     : '' +
        // ' ' +
        // this.progress.toString() +
        // ' ' +
        // this.deadline.toString() +
        // ' ' +
        // this.groupmates.toString() +
        ']';
  }
}
