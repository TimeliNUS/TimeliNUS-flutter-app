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
  final DocumentReference author;
  final List<User> groupmates;
  final List<User> confirmed;
  final List<User> invited;
  final MeetingVenue meetingVenue;
  final Project project;
  final DocumentReference ref;
  final List<TimeRegion> timeslots;
  final DateTime selectedTimeStart;
  final bool isConfirmed;

  const Meeting(this.title, this.groupmates, this.meetingVenue, this.project,
      {this.id,
      this.startDate,
      this.endDate,
      this.author,
      this.confirmed,
      this.invited,
      this.timeLength = 1,
      this.ref,
      this.timeslots = const [],
      this.selectedTimeStart,
      this.isConfirmed});
  @override
  List<Object> get props => [title, groupmates, timeLength, startDate];

  static Meeting fromEntity(MeetingEntity entity) {
    return Meeting(entity.title, entity.groupmates ?? [], entity.meetingVenue, entity.project,
        startDate: entity.startDate != null ? entity.startDate.toDate() : null,
        endDate: entity.endDate != null ? entity.endDate.toDate() : null,
        author: entity.author ?? (entity.groupmates[0] != null ? entity.groupmates[0].ref : null),
        id: entity.id ?? null,
        confirmed: entity.confirmed ?? null,
        invited: entity.invited ?? null,
        timeLength: entity.timeLength,
        timeslots: entity.timeslots ?? [],
        selectedTimeStart: entity.selectedDate != null ? entity.selectedDate.toDate() : null,
        isConfirmed: entity.isConfirmed ?? false);
  }

  MeetingEntity toEntity() {
    return MeetingEntity(
      title,
      id,
      timeLength,
      startDate != null ? Timestamp.fromDate(startDate.toUtc()) : null,
      endDate != null ? Timestamp.fromDate(endDate.toUtc()) : null,
      groupmates[0].ref,
      groupmates,
      invited,
      confirmed,
      meetingVenue,
      ref,
      project,
      timeslots ?? [],
      selectedTimeStart != null ? Timestamp.fromDate(selectedTimeStart.toUtc()) : null,
      isConfirmed ?? false,
    );
  }

  Meeting copyWith(
      {String title,
      String id,
      DateTime startDate,
      DateTime endDate,
      double timeLength,
      DocumentReference author,
      List<User> groupmates,
      List<User> invited,
      List<User> confirmed,
      MeetingVenue meetingVenue,
      Project project,
      DocumentReference ref,
      List<TimeRegion> timeslots,
      DateTime selectedTimeStart,
      bool isConfirmed}) {
    return Meeting(
        title ?? this.title, groupmates ?? this.groupmates, meetingVenue ?? this.meetingVenue, project ?? this.project,
        id: id ?? this.id,
        author: author ?? this.author,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        invited: invited ?? this.invited,
        confirmed: confirmed ?? this.confirmed,
        timeLength: timeLength ?? this.timeLength,
        ref: ref ?? this.ref,
        timeslots: timeslots ?? this.timeslots,
        isConfirmed: isConfirmed ?? this.isConfirmed,
        selectedTimeStart: selectedTimeStart ?? this.selectedTimeStart);
  }

  // @override
  // String toString() {
  //   // return '[Meeting: ' + id != null ? id : "" + "]";
  // }
}
