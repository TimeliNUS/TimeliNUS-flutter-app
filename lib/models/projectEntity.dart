import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ProjectEntity extends Equatable {
  final String title;
  final String moduleCode;
  final String id;
  final double progress;
  final Timestamp deadline;
  final int noOfMeetings;
  final List<Todo> todos;
  final List<User> groupmates;
  final List<User> invited;
  final List<User> confirmed;
  final DocumentReference ref;

  ProjectEntity(this.title, this.moduleCode, this.id, this.progress, this.deadline, this.groupmates, this.noOfMeetings,
      this.todos, this.invited, this.confirmed, this.ref);

  static ProjectEntity fromJson(
      Map<String, Object> json, List<Todo> todos, List<User> users, List<User> invited, List<User> confirmed,
      [String id, DocumentReference ref]) {
    return ProjectEntity(
        json['title'],
        json['moduleCode'] ?? '',
        id != null ? id : json['id'] as String,
        json['progress'] != null ? double.parse(json['progress'].toString()) : 0,
        json['deadline'] ?? null,
        users,
        json['meetings'] != null ? (json['meetings'] as List).length : 0,
        todos,
        invited,
        confirmed,
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
      'deadline': deadline,
      // 'invitations': groupmates.sublist(1).map((x) => x.ref).toList(),
      // 'confirmedInvitations': [groupmates[0].ref],
    };
  }

  @override
  String toString() {
    return 'ProjectEntity{title: $title, moduleCode: $moduleCode, id: $id, progress: $progress, deadline: $deadline, ref: $ref, groupmates: $groupmates}';
  }

  @override
  List<Object> get props => [title, progress, moduleCode, deadline, noOfMeetings, todos, ref, id, groupmates];
}
