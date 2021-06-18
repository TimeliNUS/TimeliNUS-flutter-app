part of 'meetingBloc.dart';

abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object> get props => [];
}

class LoadMeetings extends MeetingEvent {
  final String id;
  LoadMeetings(this.id) : super();

  @override
  String toString() => 'LoadMeetings';

  @override
  List<Object> get props => [id];
}
