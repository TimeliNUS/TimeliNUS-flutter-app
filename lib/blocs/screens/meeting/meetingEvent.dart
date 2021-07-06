part of 'meetingBloc.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object> get props => [];
}

class LoadMeetings extends MeetingEvent {
  final String id;
  final bool isSearchByProject;
  LoadMeetings(this.id, {this.isSearchByProject = false}) : super();

  @override
  String toString() => 'LoadMeetings';

  @override
  List<Object> get props => [id];
}

class AddMeeting extends MeetingEvent {
  final Meeting meeting;
  final String id;
  AddMeeting(this.meeting, this.id) : super();

  @override
  String toString() => 'AddMeeting { meeting: $meeting, id: $id }';

  @override
  List<Object> get props => [meeting, id];
}

class DeleteMeeting extends MeetingEvent {
  final Meeting meeting;
  final String userId;

  DeleteMeeting(this.meeting, this.userId) : super();

  @override
  String toString() => 'DeleteMeeting { meeting: $meeting }';

  @override
  List<Object> get props => [meeting, userId];
}

class UpdateMeeting extends MeetingEvent {
  final Meeting updatedMeeting;
  final String id;

  UpdateMeeting(this.updatedMeeting, this.id) : super();

  @override
  String toString() => 'UpdateMeeting { updatedMeeting: $updatedMeeting }';

  @override
  List<Object> get props => [updatedMeeting];
}
