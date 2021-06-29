part of 'meetingBloc.dart';

abstract class MeetingState extends Equatable {
  final List<Meeting> meetings;
  final List<Meeting> invitations;
  const MeetingState(this.meetings, {this.invitations = const []});

  @override
  List<Object> get props => [];
}

class MeetingInitial extends MeetingState {
  MeetingInitial() : super([]);
}

class MeetingLoaded extends MeetingState {
  final List<Meeting> meetings;
  final List<Meeting> invitations;

  MeetingLoaded(this.meetings, {this.invitations = const []})
      : super(meetings, invitations: invitations);

  @override
  String toString() => 'MeetingLoaded { projects: $meetings }';

  @override
  List<Object> get props => [meetings];
}

class MeetingNotLoaded extends MeetingState {
  MeetingNotLoaded() : super([]);
  @override
  String toString() => 'MeetingNotLoaded';
}

class MeetingLoading extends MeetingState {
  MeetingLoading() : super([]);
  @override
  String toString() => 'MeetingLoading';
}
