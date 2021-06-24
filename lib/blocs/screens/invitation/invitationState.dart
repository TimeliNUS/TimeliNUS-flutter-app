part of 'invitationBloc.dart';

abstract class InvitationState extends Equatable {
  final Meeting meeting;
  const InvitationState(this.meeting);

  @override
  List<Object> get props => [meeting];
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
