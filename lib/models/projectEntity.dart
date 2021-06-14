import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectEntity {
  final String title;
  final double progress;
  final Timestamp deadline;
  final List<Meeting> meetings;
  final List<Todo> todos;
  final DocumentReference ref;

  ProjectEntity(this.title, this.progress, this.deadline, this.meetings,
      this.todos, this.ref);

  static ProjectEntity fromJson(Map<String, Object> json, List<Todo> todos,
      [String id, DocumentReference ref]) {
    return ProjectEntity(
        json['title'],
        double.parse(json['progress'].toString()),
        json['deadline'],
        [],
        todos,
        ref);
  }

  Map<String, Object> toJson() {
    return {
      'title': title,
      'progress': progress,
      'meetings': meetings,
      'todos': todos,
      'deadline': deadline
    };
  }

  @override
  String toString() {
    return 'ProjectEntity{title: $title, progress: $progress, deadline: $deadline, ref: $ref}';
  }
}
