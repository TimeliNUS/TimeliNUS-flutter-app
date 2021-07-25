import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/app/appState.dart';
import 'package:TimeliNUS/blocs/screens/invitation/invitationBloc.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

class MockInvitationRepository extends Mock implements MeetingRepository {}

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockInvitationBloc extends MockBloc<InvitationEvent, InvitationState> implements InvitationBloc {}

class MockAppBloc extends MockBloc<AppEvent, AppState> implements AppBloc {}

class MockAppState extends Fake implements AppState {}

class MockAppEvent extends Fake implements AppEvent {}

void main() {
  MeetingRepository invitationRepository;
  ProjectRepository projectRepository;

  InvitationBloc invitationBloc;
  AppBloc appBloc;
  DateTime currentDate = DateTime.now();
  setupCloudFirestoreMocks();
  Meeting testInvitation;
  MeetingEntity originalInvitationEntity;
  Meeting originalInvitation;
  Project originalProject;
  ProjectEntity originalProjectEntity;
  setUpAll(() {
    registerFallbackValue<MockAppState>(MockAppState());
    registerFallbackValue<MockAppEvent>(MockAppEvent());
  });
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    invitationRepository = MockInvitationRepository();
    projectRepository = MockProjectRepository();
    appBloc = MockAppBloc();
    originalInvitation = Meeting('original', [User(id: 'userId', name: 'userName')], 'Zoom', null,
        id: 'id',
        ref: FirebaseFirestore.instance.collection('invitation').doc('id'),
        confirmed: [],
        invited: [],
        selectedTimeStart: currentDate);
    originalInvitationEntity = MeetingEntity(
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
        FirebaseFirestore.instance.collection('invitation').doc('id'),
        null,
        [],
        Timestamp.fromDate(currentDate),
        false,
        null,
        true);
    testInvitation = Meeting(
      'test',
      [User(id: 'userId', name: 'userName')],
      'Microsoft Teams',
      null,
      id: 'testId',
      ref: FirebaseFirestore.instance.collection('invitation').doc('testId'),
      confirmed: [],
      invited: [],
    );
    originalProject = Project('original',
        id: 'id',
        moduleCode: 'code',
        deadline: currentDate,
        ref: FirebaseFirestore.instance.collection('project').doc('id'),
        groupmates: [],
        confirmed: [],
        invited: [],
        noOfMeetings: 0);
    originalProjectEntity = ProjectEntity('original', 'code', 'id', 1, Timestamp.fromDate(currentDate), [], 0, [], [],
        [], FirebaseFirestore.instance.collection('project').doc('id'));

    when(() => invitationRepository.loadInvitation(any()))
        .thenAnswer((ans) => Future.value([originalInvitationEntity]));
    when(() => invitationRepository.loadMeetingById(any())).thenAnswer((ans) => Future.value(originalInvitationEntity));
    when(() => invitationRepository.addExtraTimeslotsAndAccept(any(), any(), any()))
        .thenAnswer((ans) => Future.value(null));
    when(() => appBloc.add(MockAppEvent())).thenAnswer((ans) => Future.value(null));
    when(() => projectRepository.loadProjectById(any())).thenAnswer((ans) => Future.value(originalProjectEntity));
    // when(invitationRepository.load(any)).thenAnswer((ans) => Future.value([]));
    // when(invitationRepository.updateInvitation(any)).thenAnswer((ans) => Future.value(null));

    // when(invitationRepository.addNewInvitation(any, any)).thenAnswer(
    //     (ans) => Future.value(FirebaseFirestore.instance.collection('invitation').doc(ans.positionalArguments[0].id)));
    invitationBloc = InvitationBloc(
      invitationRepository,
      appBloc,
    );
  });
  group('InvitationBloc', () {
    group('InvitationBloc Load', () {
      blocTest(
        'Load Invitations',
        build: () => invitationBloc,
        act: (bloc) => bloc.add(LoadInvitation('id')),
        expect: () => [
          InvitationLoading(),
          InvitationLoaded(originalInvitation),
        ],
      );
      // blocTest(
      //   'Load Project Invitations',
      //   build: () => invitationBloc,
      //   act: (bloc) => bloc.add(LoadProjectInvitation('userId')),
      //   expect: () => [
      //     InvitationLoading(),
      //     ProjectInvitationLoaded(originalProject),
      //   ],
      // );
      blocTest(
        'Accept Invitations',
        build: () => invitationBloc,
        act: (bloc) => bloc..add(LoadInvitation('id'))..add(AcceptInvitation('', 'userId', [], useGoogle: false)),
        expect: () => [
          InvitationLoading(),
          InvitationLoaded(originalInvitation),
          InvitationLoading(),
          InvitationAccepted(),
        ],
      );
      // blocTest(
      //   'Delete Invitations',
      //   build: () => invitationBloc,
      //   act: (bloc) =>
      //       bloc..add(AddInvitation(testInvitation, 'userId'))..add(DeleteInvitation(testInvitation, 'userId')),
      //   expect: () => [
      //     InvitationLoading(),
      //     InvitationLoaded([testInvitation]),
      //     InvitationLoading(),
      //     InvitationLoaded([]),
      //   ],
      // );
      // blocTest(
      //   'Update Invitations',
      //   build: () => invitationBloc,
      //   act: (bloc) => bloc
      //     ..add(AddInvitation(testInvitation, 'userId'))
      //     ..add(UpdateInvitation(
      //         testInvitation.copyWith(
      //           title: "original",
      //           ref: FirebaseFirestore.instance.collection('invitation').doc('id'),
      //         ),
      //         'userId')),
      //   expect: () => [
      //     InvitationLoading(),
      //     InvitationLoaded([testInvitation]),
      //     InvitationLoading(),
      //     InvitationLoaded([originalInvitation.copyWith(id: 'testId')]),
      //   ],
      // );
      // blocTest(
      //   'Today Todos',
      //   build: () => invitationBloc,
      //   act: (bloc) => bloc..add(TodayInvitation('userId')),
      //   expect: () => [
      //     InvitationLoading(),
      //     InvitationLoaded([originalInvitation]),
      //   ],
      // );
    });
  });
}
