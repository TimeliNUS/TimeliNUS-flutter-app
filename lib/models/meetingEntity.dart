import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MeetingEntity extends Equatable {
  final String title;
  final Timestamp startDate;
  final Timestamp endDate;
  final double timeLength;
  final List<User> groupmates;
  final MeetingVenue meetingVenue;
  final Project project;
  final String id;
  final DocumentReference ref;

  MeetingEntity(this.title, this.id, this.timeLength, this.startDate,
      this.endDate, this.groupmates, this.meetingVenue, this.ref, this.project);

  static MeetingEntity fromJson(Map<String, Object> json, List<User> groupmates,
      [String id, DocumentReference ref]) {
    return MeetingEntity(
        json['title'] ?? '',
        id != null ? id : (json['id'] as String),
        json['timeLength'] != null
            ? double.parse(json['timeLength'].toString())
            : 0,
        json['startDate'],
        json['endDate'],
        [],
        convertMeetingVenue(json['meetingVenue']),
        ref,
        json['project'] != null
            ? Project.fromEntity(
                ProjectEntity.fromJson(json['project'], [], [], []))
            : null);
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'title': title,
      'timeLength': timeLength,
      'meetingVenue': meetingVenue.toString().split('.')[1],
      'groupmates': groupmates.map((x) => x.ref).toList(),
      'project': project != null
          ? {
              'id': project.id,
              'title': project.title,
            }
          : null,
      "startDate": startDate,
      "endDate": endDate
    };
  }

  @override
  String toString() {
    return 'MeetingEntity{title: $title, id: $id, timeLength: $timeLength, ref: $ref}';
  }

  @override
  List<Object> get props =>
      [title, project, meetingVenue, timeLength, ref, id, groupmates];
}
