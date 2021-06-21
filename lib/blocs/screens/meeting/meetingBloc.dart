import 'dart:async';

import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
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
    }
  }

  Stream<MeetingState> _mapLoadMeetingsToState(LoadMeetings event) async* {
    try {
      yield MeetingLoading();
      final projectEntities = await meetingRepository.loadMeetings(event.id);
      final List<Meeting> projects = projectEntities
          .map((project) => Meeting.fromEntity(project))
          .toList();
      yield MeetingLoaded(projects);
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
}
