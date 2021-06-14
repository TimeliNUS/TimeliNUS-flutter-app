import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/models/projectEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

@immutable
class Project extends Equatable {
  final String title;
  final double progress;
  final DateTime deadline;
  final List<Meeting> meetings;
  final List<Todo> todos;
  final DocumentReference ref;

  const Project(this.title,
      {this.progress = 1,
      this.deadline,
      this.meetings = const [],
      this.todos = const [],
      this.ref});

  static Project fromEntity(ProjectEntity entity) {
    return Project(entity.title,
        progress: entity.progress,
        deadline: entity.deadline != null ? entity.deadline.toDate() : null,
        meetings: entity.meetings,
        todos: entity.todos,
        ref: entity.ref);
  }

  ProjectEntity toEntity() {
    return ProjectEntity(
        title,
        progress,
        deadline != null ? Timestamp.fromDate(deadline) : null,
        meetings,
        todos,
        ref);
  }

  Project copyWith(
      {String title,
      double progress,
      DateTime deadline,
      List<Meeting> meetings,
      List<Todo> todos,
      DocumentReference ref}) {
    return Project(title ?? this.title,
        progress: progress ?? this.progress,
        deadline: deadline ?? this.deadline,
        meetings: meetings ?? this.meetings,
        todos: todos ?? this.todos,
        ref: ref ?? this.ref);
  }

  @override
  List<Object> get props => [title, progress, deadline, meetings];

  @override
  String toString() {
    return 'Project[' +
        this.title +
        ' ' +
        this.progress.toString() +
        ' ' +
        this.deadline.toString() +
        ']';
  }
}
