part of 'invitationBloc.dart';

abstract class InvitationEvent extends Equatable {
  const InvitationEvent();

  @override
  List<Object> get props => [];
}

class LoadInvitation extends InvitationEvent {
  final String id;
  LoadInvitation(this.id) : super();

  @override
  String toString() => 'LoadInvitation';

  @override
  List<Object> get props => [id];
}

class LoadProjectInvitation extends InvitationEvent {
  final String id;
  LoadProjectInvitation(this.id) : super();

  @override
  String toString() => 'LoadProjectInvitation';

  @override
  List<Object> get props => [id];
}

class AcceptInvitation extends InvitationEvent {
  final String url;
  final String userId;
  final bool useGoogle;
  // final Meeting meeting;
  final List<Intervals> intervals;

  AcceptInvitation(this.url, this.userId, this.intervals, {this.useGoogle = false}) : super();

  @override
  String toString() => 'AcceptInvitation';

  @override
  List<Object> get props => [url];
}

class AcceptProjectInvitation extends InvitationEvent {
  final String userId;
  final bool isAccepted;
  AcceptProjectInvitation(this.userId, this.isAccepted) : super();

  @override
  String toString() => 'AcceptProjectInvitation';

  @override
  List<Object> get props => [userId, isAccepted];
}

// class AcceptGoogle extends InvitationEvent {
//   AcceptGoogle() : super();

//   @override
//   String toString() => 'AcceptGoogle';
// }
