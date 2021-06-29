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

class AcceptInvitation extends InvitationEvent {
  final String url;
  final String userId;

  AcceptInvitation(this.url, this.userId) : super();

  @override
  String toString() => 'AcceptInvitation';

  @override
  List<Object> get props => [url];
}
