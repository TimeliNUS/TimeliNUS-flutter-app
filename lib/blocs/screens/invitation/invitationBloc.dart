import 'dart:async';

import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

part 'invitationEvent.dart';
part 'invitationState.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final MeetingRepository meetingRepository;
  InvitationBloc(this.meetingRepository) : super(InvitationInitial());

  @override
  Stream<InvitationState> mapEventToState(
    InvitationEvent event,
  ) async* {
    if (event is LoadInvitation) {
      yield* _mapLoadInvitationToState(event);
    } else if (event is AcceptInvitation) {
      yield* _mapAcceptInvitationToState(event);
    }
  }

  Stream<InvitationState> _mapLoadInvitationToState(
      LoadInvitation event) async* {
    try {
      yield InvitationLoading();
      final meetingEntity = await meetingRepository.loadMeetingById(event.id);
      print(meetingEntity);
      final Meeting invitation = Meeting.fromEntity(meetingEntity);
      yield InvitationLoaded(invitation);
    } catch (err) {
      print(err);
      yield InvitationNotLoaded();
    }
  }

  Stream<InvitationState> _mapAcceptInvitationToState(
      AcceptInvitation event) async* {
    try {
      yield InvitationLoading();
      print(event.url);
      print(state.meeting);
      meetingRepository.acceptInvitation(
          state.meeting, state.meeting.id, event.url);
      yield InvitationAccepted();
    } catch (err) {
      print(err);
      yield InvitationNotLoaded();
    }
  }
}
