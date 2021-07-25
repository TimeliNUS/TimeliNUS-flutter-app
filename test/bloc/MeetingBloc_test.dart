import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoBloc.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

class MockMeetingRepository extends Mock implements MeetingRepository {}

class MockMeetingBloc extends MockBloc<MeetingEvent, MeetingState> implements MeetingBloc {}

void main() {
  MeetingRepository meetingRepository;
  MeetingBloc meetingBloc;
  DateTime currentDate = DateTime.now();
  setupCloudFirestoreMocks();
  Meeting testMeeting;
  MeetingEntity originalMeetingEntity;
  Meeting originalMeeting;
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    meetingRepository = MockMeetingRepository();
    originalMeeting = Meeting('original', [User(id: 'userId', name: 'userName')], 'Zoom', null,
        id: 'id',
        ref: FirebaseFirestore.instance.collection('meeting').doc('id'),
        confirmed: [],
        invited: [],
        selectedTimeStart: currentDate);
    originalMeetingEntity = MeetingEntity(
        'original',
        'id',
        60,
        null,
        null,
        null,
        [User(id: 'userId', name: 'userName')],
        [],
        [],
        'Zoom',
        FirebaseFirestore.instance.collection('meeting').doc('id'),
        null,
        [],
        Timestamp.fromDate(currentDate),
        false,
        null,
        true);
    testMeeting = Meeting(
      'test',
      [User(id: 'userId', name: 'userName')],
      'Microsoft Teams',
      null,
      id: 'testId',
      ref: FirebaseFirestore.instance.collection('meeting').doc('testId'),
      confirmed: [],
      invited: [],
    );
    ;
    when(meetingRepository.loadConfirmedMeetings(any)).thenAnswer((ans) => Future.value([originalMeetingEntity]));
    when(meetingRepository.loadInvitation(any)).thenAnswer((ans) => Future.value([]));
    when(meetingRepository.updateMeeting(any)).thenAnswer((ans) => Future.value(null));

    when(meetingRepository.addNewMeeting(any, any)).thenAnswer(
        (ans) => Future.value(FirebaseFirestore.instance.collection('meeting').doc(ans.positionalArguments[0].id)));
    meetingBloc = MeetingBloc(meetingRepository);
  });
  group('MeetingBloc', () {
    // test('throws AssertionError if Authentication Repository is null', () {
    //   expect(
    //     () => MeetingBloc(null),
    //     throwsA(isAssertionError),
    //   );
    // });
    group('MeetingBloc Load', () {
      // blocTest(
      //   'Not Loading Meetings',
      //   build: () => meetingBloc,
      //   act: (bloc) => bloc..add(LoadMeetings(null)),
      //   expect: () => [MeetingLoading(), MeetingNotLoaded()],
      // );
      blocTest(
        'Load Meetings',
        build: () => meetingBloc,
        act: (bloc) => bloc.add(LoadMeetings('id')),
        expect: () => [
          MeetingLoading(),
          MeetingLoaded([originalMeeting]),
        ],
      );
      blocTest(
        'Add Meetings',
        build: () => meetingBloc,
        act: (bloc) => bloc.add(AddMeeting(testMeeting, 'userId')),
        expect: () => [
          MeetingLoading(),
          MeetingLoaded([testMeeting]),
        ],
      );
      blocTest(
        'Delete Meetings',
        build: () => meetingBloc,
        act: (bloc) => bloc..add(AddMeeting(testMeeting, 'userId'))..add(DeleteMeeting(testMeeting, 'userId')),
        expect: () => [
          MeetingLoading(),
          MeetingLoaded([testMeeting]),
          MeetingLoading(),
          MeetingLoaded([]),
        ],
      );
      blocTest(
        'Update Meetings',
        build: () => meetingBloc,
        act: (bloc) => bloc
          ..add(AddMeeting(testMeeting, 'userId'))
          ..add(UpdateMeeting(
              testMeeting.copyWith(
                title: "original",
                ref: FirebaseFirestore.instance.collection('meeting').doc('id'),
              ),
              'userId')),
        expect: () => [
          MeetingLoading(),
          MeetingLoaded([testMeeting]),
          MeetingLoading(),
          MeetingLoaded([originalMeeting.copyWith(id: 'testId')]),
        ],
      );
      blocTest(
        'Today Todos',
        build: () => meetingBloc,
        act: (bloc) => bloc..add(TodayMeeting('userId')),
        expect: () => [
          MeetingLoading(),
          MeetingLoaded([originalMeeting]),
        ],
      );
    });
  });
}
