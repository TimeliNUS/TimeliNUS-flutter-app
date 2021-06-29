import 'dart:async';

import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/screens/invitationScreen.dart';
import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

part 'meetingEvent.dart';
part 'meetingState.dart';

class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  final MeetingRepository meetingRepository;
  MeetingBloc(this.meetingRepository) : super(MeetingInitial());

  @override
  Stream<MeetingState> mapEventToState(
    MeetingEvent event,
  ) async* {
    if (event is LoadMeetings) {
      yield* _mapLoadMeetingsToState(event);
    } else if (event is AddMeeting) {
      yield* _mapAddMeetingToState(event);
    } else if (event is UpdateMeeting) {
      yield* _mapUpdateMeetingToState(event);
    } else if (event is DeleteMeeting) {
      yield* _mapDeleteMeetingtToState(event);
    }
  }

  Stream<MeetingState> _mapLoadMeetingsToState(LoadMeetings event) async* {
    try {
      yield MeetingLoading();
      final meetingEntities =
          await meetingRepository.loadConfirmedMeetings(event.id);
      final invitationEntities =
          await meetingRepository.loadInvitation(event.id);
      final List<Meeting> meetings = meetingEntities
          .map((meeting) => Meeting.fromEntity(meeting))
          .toList();
      final List<Meeting> invitations = invitationEntities
          .map((invitation) => Meeting.fromEntity(invitation))
          .toList();
      yield MeetingLoaded(meetings, invitations: invitations);
    } catch (err) {
      print(err);
      yield MeetingNotLoaded();
    }
  }

  Stream<MeetingState> _mapAddMeetingToState(AddMeeting event) async* {
    try {
      List<Meeting> currentMeetings = state.meetings;
      yield MeetingLoading();
      DocumentReference newMeetingRef = await meetingRepository.addNewMeeting(
          event.meeting.toEntity(), event.id);
      final updatedProjects = currentMeetings
        ..add(event.meeting.copyWith(ref: newMeetingRef, id: newMeetingRef.id));
      yield MeetingLoaded(updatedProjects);
    } catch (err) {
      print(err);
      yield MeetingNotLoaded();
    }
  }

  Stream<MeetingState> _mapUpdateMeetingToState(UpdateMeeting event) async* {
    yield MeetingLoading();
    final updatedMeetings = state.meetings.map((project) {
      return project.id == event.updatedMeeting.id
          ? event.updatedMeeting
          : project;
    }).toList();
    yield MeetingLoaded(updatedMeetings);
    print(event.updatedMeeting);
    await meetingRepository.updateMeeting(event.updatedMeeting.toEntity());
  }

  Stream<MeetingState> _mapDeleteMeetingtToState(DeleteMeeting event) async* {
    // if (state is TodoLoaded) {
    yield MeetingLoading();
    final updatedMeetings = state.meetings
        .where((project) => project.id != event.meeting.id)
        .toList();
    yield MeetingLoaded(
      updatedMeetings,
    );
    // }
    await meetingRepository.deleteMeeting(event.meeting, event.userId);
  }
}
