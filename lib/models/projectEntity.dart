import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String title;
  final String moduleCode;
  final String id;
  final double progress;
  final Timestamp deadline;
  final List<Meeting> meetings;
  final List<Todo> todos;
  final List<User> groupmates;
  final DocumentReference ref;

  ProjectEntity(this.title, this.moduleCode, this.id, this.progress,
      this.deadline, this.groupmates, this.meetings, this.todos, this.ref);

  static ProjectEntity fromJson(Map<String, Object> json, List<Todo> todos,
      List<User> users, List<MeetingEntity> meetings,
      [String id, DocumentReference ref]) {
    return ProjectEntity(
        json['title'],
        json['moduleCode'] ?? '',
        id != null ? id : json['id'] as String,
        json['progress'] != null
            ? double.parse(json['progress'].toString())
            : 0,
        json['deadline'],
        users,
        meetings.map((x) => Meeting.fromEntity(x)).toList(),
        todos,
        ref);
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'moduleCode': moduleCode,
      'title': title,
      'progress': progress,
      // 'meetings':
      //     meetings.map((meeting) => meeting.toEntity().toJson()).toList(),
      'groupmates': groupmates.map((x) => x.ref).toList(),
      // 'todos': todos,
      'deadline': deadline
    };
  }

  @override
  String toString() {
    return 'ProjectEntity{title: $title, moduleCode: $moduleCode, id: $id, progress: $progress, deadline: $deadline, ref: $ref, groupmates: $groupmates}';
  }

  @override
  List<Object> get props => [
        title,
        progress,
        moduleCode,
        deadline,
        meetings,
        todos,
        ref,
        id,
        groupmates
      ];
}
