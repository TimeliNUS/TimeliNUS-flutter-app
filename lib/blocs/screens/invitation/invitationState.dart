part of 'invitationBloc.dart';

abstract class InvitationState extends Equatable {
  final Meeting meeting;
  final Project project;
  const InvitationState(this.meeting, {this.project});

  @override
  List<Object> get props => [meeting, project];
}

class InvitationInitial extends InvitationState {
  InvitationInitial() : super(null);
}

class InvitationLoaded extends InvitationState {
  final Meeting meeting;
  InvitationLoaded(this.meeting) : super(meeting);

  @override
  String toString() => 'InvitationLoaded { meeting: $meeting }';

  @override
  List<Object> get props => [meeting];
}

class ProjectInvitationLoaded extends InvitationState {
  final Project project;
  ProjectInvitationLoaded(this.project) : super(null, project: project);

  @override
  String toString() => 'ProjectInvitationLoaded { project: $project }';

  @override
  List<Object> get props => [project];
}

class InvitationNotLoaded extends InvitationState {
  InvitationNotLoaded() : super(null);
  @override
  String toString() => 'InvitationNotLoaded';
}

class InvitationLoading extends InvitationState {
  InvitationLoading() : super(null);
  @override
  String toString() => 'InvitationLoading';
}

class InvitationAccepted extends InvitationState {
  InvitationAccepted() : super(null);
  @override
  String toString() => 'InvitationAccepted';
}
