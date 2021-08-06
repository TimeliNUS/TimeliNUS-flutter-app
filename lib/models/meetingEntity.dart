import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:TimeliNUS/utils/dateTimeExtension.dart';

class MeetingEntity extends Equatable {
  final String title;
  final Timestamp startDate;
  final Timestamp endDate;
  final int timeLength;
  final DocumentReference author;
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
        Timestamp.fromDate((json['startDate'] as Timestamp).toDate().add(Duration(
            hours: int.parse((json['startTime'] as String).substring(0, 2)),
            minutes: int.parse((json['startTime'] as String).substring(3))))),
        Timestamp.fromDate((json['endDate'] as Timestamp).toDate().add(Duration(
            hours: int.parse((json['endTime'] as String).substring(0, 2)),
            minutes: int.parse((json['endTime'] as String).substring(3))))),
        // groupmates != null ? groupmates[0] : null,
        json['author'],
        // User(
        //     id: ((json['author'] as Map<String, Object>)['ref']
        //             as DocumentReference)
        //         .path
        //         .split('/')[1],
        //     name: (json['author'] as Map<String, Object>)['name']),
        invited,
        confirmed,
        json['meetingVenue'],
        ref,
        json['project'] != null
            ? Project.fromEntity(ProjectEntity.fromJson(
                json['project'], [], [], [], (json['project'] as Map)['id'], (json['project'] as Map)['ref']))
            : null,
        json['timeslot'] != null
            ? (json['timeslot'] as List)
                .map((timeslot) => TimeRegion(
                    startTime: (timeslot['start'] as Timestamp).toDate(),
                    enablePointerInteraction: false,
                    endTime: (timeslot['end'] as Timestamp).toDate()))
                .toList()
            : null,
        json['selectedStartDate'],
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
      'author': author ?? confirmed[0].ref,
      'project': project != null
          ? {
              'id': project.id,
              'title': project.title,
              'ref': project.ref,
            }
          : null,
      "startDate": Timestamp.fromDate(startDate.toDate().stripTime()),
      "endDate": Timestamp.fromDate(endDate.toDate().stripTime()),
      "startTime": startDate.toDate().printTime(),
      "endTime": endDate.toDate().printTime(),
      "selectedStartDate": selectedDate,
      "selectedEndDate": selectedDate != null ? selectedDate.toDate().add(Duration(minutes: timeLength)) : null,
      "isConfirmed": isConfirmed,
      "isOnlineVenue": isOnlineVenue,
      "timeslot": timeslots.map((x) {
            return {"start": Timestamp.fromDate(x.startTime), "end": Timestamp.fromDate(x.endTime)};
          }).toList() ??
          [],
      "invitations": invited != null ? invited.map((x) => x.ref).toList() : [],
      "confirmedInvitations": confirmed != null ? confirmed.map((x) => x.ref).toList() : [],
      "meetingLink": meetingLink,
      // "interval" ??
    };
  }

  @override
  String toString() {
    return 'MeetingEntity{title: $title, id: $id, timeLength: $timeLength, ref: $ref}';
  }

  @override
  List<Object> get props =>
      [title, project, meetingVenue, timeLength, ref, id, selectedDate, isConfirmed, isOnlineVenue];
}
