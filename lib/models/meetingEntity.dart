import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class MeetingEntity extends Equatable {
  final String title;
  final Timestamp startDate;
  final Timestamp endDate;
  final int timeLength;
  final DocumentReference author;
  final List<User> groupmates;
  final List<User> invited;
  final List<User> confirmed;
  final String meetingVenue;
  final Project project;
  final String id;
  final DocumentReference ref;
  final List<TimeRegion> timeslots;
  final Timestamp selectedDate;
  final bool isConfirmed;
  final String meetingLink;
  final bool isOnlineVenue;

  MeetingEntity(
      this.title,
      this.id,
      this.timeLength,
      this.startDate,
      this.endDate,
      this.author,
      this.groupmates,
      this.invited,
      this.confirmed,
      this.meetingVenue,
      this.ref,
      this.project,
      this.timeslots,
      this.selectedDate,
      this.isConfirmed,
      this.meetingLink,
      this.isOnlineVenue);

  static MeetingEntity fromJson(Map<String, Object> json, List<User> invited, List<User> confirmed,
      [String id, DocumentReference ref]) {
    return MeetingEntity(
        json['title'] ?? '',
        id != null ? id : (json['id'] as String),
        json['timeLength'] != null ? int.parse(json['timeLength'].toString()) : 0,
        json['startDate'],
        json['endDate'],
        // groupmates != null ? groupmates[0] : null,
        json['author'],
        // User(
        //     id: ((json['author'] as Map<String, Object>)['ref']
        //             as DocumentReference)
        //         .path
        //         .split('/')[1],
        //     name: (json['author'] as Map<String, Object>)['name']),
        [],
        invited,
        confirmed,
        json['meetingVenue'],
        ref,
        json['project'] != null ? Project.fromEntity(ProjectEntity.fromJson(json['project'], [], [], [], [])) : null,
        json['timeslot'] != null
            ? (json['timeslot'] as List)
                .map((timeslot) => TimeRegion(
                    startTime: (timeslot['start'] as Timestamp).toDate(),
                    enablePointerInteraction: false,
                    endTime: (timeslot['end'] as Timestamp).toDate()))
                .toList()
            : null,
        json['selectedDate'],
        json['isConfirmed'] ?? false,
        json['meetingLink'],
        json['isOnlineVenue'] as bool);
  }

  Map<String, Object> toJson() {
    return {
      'id': id,
      'title': title,
      'timeLength': timeLength,
      'meetingVenue': meetingVenue,
      // .toString().split('.')[1],
      'groupmates': groupmates.map((x) => x.ref).toList(),
      'author': groupmates[0].ref,
      'project': project != null
          ? {
              'id': project.id,
              'title': project.title,
            }
          : null,
      "startDate": startDate,
      "endDate": endDate,
      "selectedDate": selectedDate,
      "isConfirmed": isConfirmed,
      "isOnlineVenue": isOnlineVenue,
      "timeslot": timeslots ?? [],
      "invitations": invited.map((x) => x.ref).toList() ?? [],
      "confirmedInvitations": confirmed.map((x) => x.ref).toList() ?? [],
      // "interval" ??
    };
  }

  @override
  String toString() {
    return 'MeetingEntity{title: $title, id: $id, timeLength: $timeLength, ref: $ref, groupmates: $groupmates}';
  }

  @override
  List<Object> get props =>
      [title, project, meetingVenue, timeLength, ref, id, groupmates, selectedDate, isConfirmed, isOnlineVenue];
}
