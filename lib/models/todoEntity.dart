import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/models/projectEntity.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TodoEntity extends Equatable {
  final bool complete;
  final String id;
  final String note;
  final String task;
  final Timestamp deadline;
  final Project project;
  final List<User> pic;
  final bool includeTime;
  final DocumentReference ref;

  TodoEntity(
      this.task, this.id, this.note, this.complete, this.deadline, this.project, this.pic, this.includeTime, this.ref);

  Map<String, Object> toJson() {
    return {
      'complete': complete,
      'task': task,
      'note': note,
      'id': id,
      'project': project != null
          ? {
              'id': project.id,
              'title': project.title,
              'ref': project.ref,
            }
          : null,
      'PIC': pic.map((x) => x.ref).toList(),
      'includeTime': includeTime,
      'deadline': deadline
    };
  }

  @override
  String toString() {
    return 'TodoEntity{complete: $complete, task: $task, note: $note, id: $id, deadline: $deadline, ref: $ref}';
  }

  static TodoEntity fromJson(Map<String, Object> json, List<User> users, [String id, DocumentReference ref]) {
    return TodoEntity(
        json['task'] as String,
        id != null ? id : json['id'] as String,
        json['note'] as String,
        json['complete'] as bool,
        json['deadline'] as Timestamp,
        json['project'] != null
            ? Project.fromEntity(ProjectEntity.fromJson(
                json['project'], [], [], [], (json['project'] as Map)['id'], (json['project'] as Map)['ref']))
            : null,
        users,
        json['includeTime'] ?? false,
        ref);
  }

  @override
  List<Object> get props => [task, id, note, complete, deadline, pic, ref, includeTime];
}
