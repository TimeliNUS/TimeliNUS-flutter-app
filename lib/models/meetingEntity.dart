import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class MeetingEntity extends Equatable {
  final String title;
  final Timestamp deadline;
  final double timeLength;
  final List<Person> groupmates;
  final MeetingVenue meetingVenue;
  final String projectTitle;
  final String id;
  final DocumentReference ref;

  MeetingEntity(this.title, this.id, this.timeLength, this.deadline,
      this.groupmates, this.meetingVenue, this.ref, this.projectTitle);

  static MeetingEntity fromJson(
      Map<String, Object> json, List<Person> groupmates,
      [String id, DocumentReference ref]) {
    print('hi');
    print(convertMeetingVenue(json['meetingVenue']));
    return MeetingEntity(
        json['title'],
        id != null ? id : json['id'] as String,
        double.parse(json['timeLength'].toString()),
        json['deadline'] as Timestamp,
        [],
        convertMeetingVenue(json['meetingVenue']),
        ref,
        (json['project'] as Map)['title']);
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'title': title,
      'timeLength': timeLength,
      'meetingVenue': meetingVenue,
      'groupmates': groupmates,
      'projectTitle': projectTitle,
      'deadline': deadline
    };
  }

  @override
  String toString() {
    return 'ProjectEntity{title: $title, id: $id, timeLength: $timeLength, deadline: $deadline, ref: $ref}';
  }

  @override
  List<Object> get props => [
        title,
        projectTitle,
        deadline,
        meetingVenue,
        timeLength,
        ref,
        id,
        groupmates
      ];
}
