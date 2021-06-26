import 'package:TimeliNUS/models/models.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

enum MeetingVenue { Zoom, FaceToFace }
MeetingVenue convertMeetingVenue(input) {
  return MeetingVenue.values.firstWhere((e) {
    return (e.toString().split('.')[1] == input);
  });
}

// class Intervals {
//   final DateTime start;
//   final DateTime end;
//   const Intervals(this.start, this.end);

//   static fromJson(Map<String, Object> json) {
//     return new Intervals(json['start'], json['end']);
//   }
// }

@immutable
class Meeting extends Equatable {
  final String title;
  final String id;
  final DateTime startDate;
  final DateTime endDate;
  final double timeLength;
  final List<User> groupmates;
  final MeetingVenue meetingVenue;
  final Project project;
  final DocumentReference ref;
  final List<TimeRegion> timeslots;

  const Meeting(this.title, this.groupmates, this.meetingVenue, this.project,
      {this.id,
      this.startDate,
      this.endDate,
      this.timeLength = 1,
      this.ref,
      this.timeslots = const []});
  @override
  List<Object> get props => [title, groupmates, timeLength, startDate];

  static Meeting fromEntity(MeetingEntity entity) {
    return Meeting(entity.title, [], entity.meetingVenue, entity.project,
        startDate: entity.startDate != null ? entity.startDate.toDate() : null,
        endDate: entity.endDate != null ? entity.endDate.toDate() : null,
        id: entity.id ?? null,
        timeLength: entity.timeLength,
        timeslots: entity.timeslots ?? []);
  }

  MeetingEntity toEntity() {
    return MeetingEntity(
        title,
        id,
        timeLength,
        startDate != null ? Timestamp.fromDate(startDate.toUtc()) : null,
        endDate != null ? Timestamp.fromDate(endDate.toUtc()) : null,
        groupmates,
        meetingVenue,
        ref,
        project,
        timeslots ?? []);
  }

  Meeting copyWith(
      {String title,
      String id,
      DateTime startDate,
      DateTime endDate,
      double timeLength,
      List<User> groupmates,
      MeetingVenue meetingVenue,
      Project project,
      DocumentReference ref,
      List<TimeRegion> timeslots}) {
    return Meeting(title ?? this.title, groupmates ?? this.groupmates,
        meetingVenue ?? this.meetingVenue, project ?? this.project,
        id: id ?? this.id,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        timeLength: timeLength ?? this.timeLength,
        ref: ref ?? this.ref,
        timeslots: timeslots ?? this.timeslots);
  }

  // @override
  // String toString() {
  //   // return '[Meeting: ' + id != null ? id : "" + "]";
  // }
}
