import 'dart:async';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'invitationEvent.dart';
part 'invitationState.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final AppBloc app;
  final MeetingRepository meetingRepository;
  InvitationBloc(this.meetingRepository, this.app) : super(InvitationInitial());

  @override
  Stream<InvitationState> mapEventToState(
    InvitationEvent event,
  ) async* {
    if (event is LoadInvitation) {
      yield* _mapLoadInvitationToState(event);
    } else if (event is AcceptInvitation) {
      yield* _mapAcceptInvitationToState(event);
    } else if (event is AcceptGoogle) {
      yield* _mapAcceptGoogleToState(event);
    }
  }

  Stream<InvitationState> _mapLoadInvitationToState(LoadInvitation event) async* {
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

  Stream<InvitationState> _mapAcceptInvitationToState(AcceptInvitation event) async* {
    try {
      yield InvitationLoading();
      await meetingRepository.acceptInvitation(state.meeting, state.meeting.id, event.url, event.userId);
      yield InvitationAccepted();
      app.add(AppOnMeeting());
    } catch (err) {
      print(err);
      yield InvitationNotLoaded();
    }
  }

  Stream<InvitationState> _mapAcceptGoogleToState(AcceptGoogle event) async* {
    try {
      Meeting temp = state.meeting;
      yield InvitationLoading();
      final storage = new FlutterSecureStorage();
      await AuthenticationRepository().refreshToken();
      // final IdTokenResult idTokenResult = await FirebaseAuth.instance.currentUser.getIdTokenResult();
      String accessToken = await storage.read(key: 'accessToken');
      print(accessToken);
      await meetingRepository.syncGoogleCalendar(
          temp.id,
          // idTokenResult.token,
          accessToken,
          temp.startDate.toIso8601String().replaceFirst('.000', 'Z'),
          temp.endDate.toIso8601String().replaceFirst('.000', 'Z'),
          app.state.user.id);
      yield InvitationAccepted();
      app.add(AppOnMeeting());
    } catch (err) {
      print(err);
      yield InvitationNotLoaded();
    }
  }
}
