import 'package:TimeliNUS/models/meetingEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

import 'person.dart';

enum MeetingVenue { Zoom, FaceToFace }
MeetingVenue convertMeetingVenue(input) {
  return MeetingVenue.values.firstWhere((e) {
    return (e.toString().split('.')[1] == input);
  });
}

@immutable
class Meeting extends Equatable {
  final String title;
  final DateTime deadline;
  final double timeLength;
  final List<Person> groupmates;
  final MeetingVenue meetingVenue;
  final String projectTitle;

  const Meeting(
      this.title, this.groupmates, this.meetingVenue, this.projectTitle,
      {this.deadline, this.timeLength = 1});
  @override
  List<Object> get props => [title, groupmates, timeLength, deadline];

  static Meeting fromEntity(MeetingEntity entity) {
    return Meeting(entity.title, [], MeetingVenue.Zoom, entity.projectTitle,
        deadline: entity.deadline != null ? entity.deadline.toDate() : null,
        timeLength: entity.timeLength);
  }
}
