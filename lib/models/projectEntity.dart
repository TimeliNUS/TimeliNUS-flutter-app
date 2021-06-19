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
  final List<User> groupmates;
  final DocumentReference ref;

  ProjectEntity(this.title, this.id, this.progress, this.deadline,
      this.groupmates, this.meetings, this.todos, this.ref);

  static ProjectEntity fromJson(Map<String, Object> json, List<Todo> todos,
      [String id, DocumentReference ref]) {
    return ProjectEntity(
        json['title'],
        id != null ? id : json['id'] as String,
        double.parse(json['progress'].toString()),
        json['deadline'],
        json['groupmates'] != null
            ? (json['groupmates'] as List)
                .map((x) => User.fromJson(x as Map<String, dynamic>, x['id']))
                .toList()
            : [],
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
      'groupmates': groupmates.map((x) => x.toJson()).toList(),
      'todos': todos,
      'deadline': deadline
    };
  }

  @override
  String toString() {
    return 'ProjectEntity{title: $title, id: $id, progress: $progress, deadline: $deadline, ref: $ref, groupmates: $groupmates}';
  }

  @override
  List<Object> get props =>
      [title, progress, deadline, meetings, todos, ref, id, groupmates];
}
