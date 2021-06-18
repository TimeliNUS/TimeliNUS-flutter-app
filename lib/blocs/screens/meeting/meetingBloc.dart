import 'dart:async';

import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:bloc/bloc.dart';
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
}
