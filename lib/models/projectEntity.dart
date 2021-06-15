import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String title;
  final String id;
  final double progress;
  final Timestamp deadline;
  final List<Meeting> meetings;
  final List<Todo> todos;
  final DocumentReference ref;

  ProjectEntity(this.title, this.id, this.progress, this.deadline,
      this.meetings, this.todos, this.ref);

  static ProjectEntity fromJson(Map<String, Object> json, List<Todo> todos,
      [String id, DocumentReference ref]) {
    return ProjectEntity(
        json['title'],
        id != null ? id : json['id'] as String,
        double.parse(json['progress'].toString()),
        json['deadline'],
        [],
        todos,
        ref);
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'title': title,
      'progress': progress,
      'meetings': meetings,
      'todos': todos,
      'deadline': deadline
    };
  }

  @override
  String toString() {
    return 'ProjectEntity{title: $title, id: $id, progress: $progress, deadline: $deadline, ref: $ref}';
  }

  @override
  List<Object> get props =>
      [title, progress, deadline, meetings, todos, ref, id];
}
