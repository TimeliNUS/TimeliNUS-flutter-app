import 'dart:async';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

part 'invitationEvent.dart';
part 'invitationState.dart';

class InvitationBloc extends Bloc<InvitationEvent, InvitationState> {
  final AppBloc app;
  final MeetingRepository meetingRepository;
  ProjectRepository projectRepository;
  InvitationBloc(this.meetingRepository, this.app, [this.projectRepository]) : super(InvitationInitial());

  @override
  Stream<InvitationState> mapEventToState(
    InvitationEvent event,
  ) async* {
    projectRepository = projectRepository ?? ProjectRepository();
    if (event is LoadInvitation) {
      yield* _mapLoadInvitationToState(event);
    } else if (event is AcceptInvitation) {
      yield* _mapAcceptInvitationToState(event);
    } else if (event is AcceptProjectInvitation) {
      yield* _mapAcceptProjectInvitationToState(event);
    } else if (event is LoadProjectInvitation) {
      yield* _mapLoadProjectInvitationToState(event);
    }
    // else if (event is AcceptGoogle) {
    //   yield* _mapAcceptGoogleToState(event);
    // }
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

  Stream<InvitationState> _mapLoadProjectInvitationToState(LoadProjectInvitation event) async* {
    try {
      yield InvitationLoading();
      final projectEntity = await projectRepository.loadProjectById(event.id);
      print(projectEntity);
      final Project invitation = Project.fromEntity(projectEntity);
      yield ProjectInvitationLoaded(invitation);
    } catch (err) {
      print(err);
      yield InvitationNotLoaded();
    }
  }

  Stream<InvitationState> _mapAcceptInvitationToState(AcceptInvitation event) async* {
    if (event.isAccepted == false) {
      await meetingRepository.declineMeetingInvitation(state.meeting.id, event.userId);
      app.add(AppOnMeeting());
      return;
    }
    final storage = new FlutterSecureStorage();
    print('hi');
    List<Future> promises = [];
    Meeting tempMeeting = state.meeting;
    try {
      yield InvitationLoading();
      promises.add(meetingRepository.addExtraTimeslotsAndAccept(
          tempMeeting.id, event.userId, event.intervals.map((x) => x.toJson()).toList()));
      print(event.url);
      if (event.url != '') {
        promises.add(meetingRepository.importNusMods(tempMeeting, tempMeeting.id, event.url, event.userId));
      }
      if (event.useGoogle) {
        String refreshToken = await AuthenticationRepository().checkLinkedToGoogle(event.userId);
        String expiryDate = await storage.read(key: 'expiryDate');
        if (DateTime.parse(expiryDate).isBefore(DateTime.now())) {
          await AuthenticationRepository().refreshToken(refreshToken);
        } else {
          print('no need to refresh accessToken');
        }
        String accessToken = await storage.read(key: 'accessToken');
        promises.add(meetingRepository.syncGoogleCalendar(
            tempMeeting.id,
            accessToken,
            tempMeeting.startDate.toIso8601String().replaceFirst('.000', 'Z'),
            tempMeeting.endDate.toIso8601String().replaceFirst('.000', 'Z'),
            event.userId));
      }
      Future.wait(promises);
      yield InvitationAccepted();
      app.add(AppOnMeeting());
    } catch (err) {
      print(err);
      yield InvitationNotLoaded();
    }
  }

  Stream<InvitationState> _mapAcceptProjectInvitationToState(AcceptProjectInvitation event) async* {
    try {
      (event.isAccepted)
          ? await projectRepository.acceptProjectInvitation(state.project.id, event.userId)
          : await projectRepository.declineProjectInvitation(state.project.id, event.userId);
      yield InvitationAccepted();
      app.add(AppOnProject());
    } catch (err) {
      print(err);
      yield InvitationNotLoaded();
    }
  }

  // Stream<InvitationState> _mapAcceptGoogleToState(AcceptGoogle event) async* {
  //   try {
  //     Meeting temp = state.meeting;
  //     yield InvitationLoading();
  //     final storage = new FlutterSecureStorage();
  //     String refreshToken = await AuthenticationRepository.checkLinkedToGoogle(app.state.user.id);
  //     if (refreshToken != null) {
  //       String expiryDate = await storage.read(key: 'expiryDate');
  //       if (DateTime.parse(expiryDate).isBefore(DateTime.now())) {
  //         await AuthenticationRepository().refreshToken(refreshToken);
  //       } else {
  //         print('no need to refresh accessToken');
  //       }
  //     } else {
  //       await AuthenticationRepository.linkAccountWithGoogle();
  //     }
  //     // final IdTokenResult idTokenResult = await FirebaseAuth.instance.currentUser.getIdTokenResult();
  //     String accessToken = await storage.read(key: 'accessToken');
  //     await meetingRepository.syncGoogleCalendar(
  //         temp.id,
  //         // idTokenResult.token,
  //         accessToken,
  //         temp.startDate.toIso8601String().replaceFirst('.000', 'Z'),
  //         temp.endDate.toIso8601String().replaceFirst('.000', 'Z'),
  //         app.state.user.id);
  //     yield InvitationAccepted();
  //     app.add(AppOnMeeting());
  //   } catch (err) {
  //     print(err);
  //     yield InvitationNotLoaded();
  //   }
  // }
}
