import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
// import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:TimeliNUS/models/userModel.dart' as UserModel;
import 'package:mockito/mockito.dart';

import '../integration/services/firebase/firebase_auth_test.dart';
import '../utils/firebase_util.dart';

class MockSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  final String userEmail = "bob@somedomain.com";
  MeetingRepository meetingRepository;
  ProjectRepository projectRepository;
  AuthenticationRepository authenticationRepository;
  DateTime currentDate = DateTime.now();
  FakeFirebaseFirestore instance;
  final loginUser = MockUser(
    isAnonymous: false,
    uid: 'someuid',
    email: userEmail,
    displayName: 'Bob',
  );
  User user;
  Meeting meeting;
  Meeting newMeeting;
  setupCloudFirestoreMocks();
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    instance = FakeFirebaseFirestore();
    final auth = MockFirebaseAuth(mockUser: loginUser);
    meetingRepository = new MeetingRepository(firestore: instance);
    projectRepository = new ProjectRepository(firestore: instance);
    authenticationRepository = new AuthenticationRepository(
        firebaseAuth: auth, firebaseFirestore: instance, secureStorage: MockSecureStorage());
    user = new User(id: 'userId', name: 'testUser', ref: instance.collection('user').doc('userId'));
    meeting = Meeting(
      'meeting',
      [user],
      'Zoom',
      null,
      timeLength: 0,
      invited: [],
      confirmed: [],
    );
    newMeeting = Meeting('newMeeting', [], 'Zoom', null, id: 'newMeetingId', timeLength: 0);
  });

  test('add new meeting', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(project: (newProject.copyWith(id: projectRef.id)), groupmates: [
      new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
    ]).toEntity();

    await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    final snapshot = await instance.collection('meeting').get();
    expect(snapshot.docs.length, 1);
  });

  test('delete meeting', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(
        project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
        groupmates: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ]).toEntity();
    DocumentReference ref = await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    QuerySnapshot snapshot = await instance.collection('meeting').get();
    await meetingRepository.deleteMeeting(Meeting.fromEntity(entityToAdd).copyWith(id: ref.id, ref: ref), 'userId');
    snapshot = await instance.collection('meeting').get();
    expect(snapshot.docs.length, 0);
  });

  test('load confirmed meeting', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(
        project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
        groupmates: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ],
        invited: [],
        confirmed: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ]).toEntity();
    DocumentReference ref = await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    final snapshot = await instance.collection('meeting').get();
    final meetingEntities = await meetingRepository.loadConfirmedMeetings(returnedUser.id);
    expect(snapshot.docs.length, meetingEntities.length);
  });

  test('load project meeting', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(
        project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
        groupmates: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ],
        invited: [],
        confirmed: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ]).toEntity();
    DocumentReference ref = await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    final snapshot = await instance.collection('meeting').get();
    final meetingEntities = await meetingRepository.loadProjectMeetings(projectRef.id);
    expect(snapshot.docs.length, meetingEntities.length);
  });

  test('load meeting by id', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(
        project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
        groupmates: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ],
        invited: [],
        confirmed: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ]).toEntity();
    DocumentReference ref = await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    final snapshot = await instance.collection('meeting').get();
    final meetingEntities = await meetingRepository.loadMeetingById(ref.id);
    expect(snapshot.docs[0].data()['title'], meetingEntities.title);
  });

  test('load meeting by reference list', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(
        project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
        groupmates: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ],
        invited: [],
        confirmed: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ]).toEntity();
    DocumentReference ref = await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    final snapshot = await instance.collection('meeting').get();
    final meetingEntities = await meetingRepository.loadMeetingsFromReferenceList([ref]);
    expect(snapshot.docs[0].data()['title'], meetingEntities[0].title);
  });

  test('load meeting invitations', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(
        selectedTimeStart: DateTime.now().add(Duration(days: 2)),
        project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
        groupmates: [new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))],
        invited: [new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))],
        confirmed: []).toEntity();
    // MeetingEntity secondEntityToAdd = meeting.copyWith(
    //     selectedTimeStart: DateTime.now().add(Duration(days: 1)),
    //     project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
    //     groupmates: [new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))],
    //     invited: [new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))],
    //     confirmed: []).toEntity();
    await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    final snapshot = await instance.collection('meeting').get();
    List<MeetingEntity> meetingEntities = await meetingRepository.loadInvitation(returnedUser.id);
    expect(snapshot.docs.length, meetingEntities.length);
    // await meetingRepository.addNewMeeting(secondEntityToAdd, 'userId');
    // meetingEntities = await meetingRepository.loadInvitation(returnedUser.id);
    // expect(2, meetingEntities.length);
  });

  test('addExtraTimeslotsAndAccept', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(
        project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
        groupmates: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ],
        confirmed: [],
        invited: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ]).toEntity();
    DocumentReference ref = await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    await meetingRepository.addExtraTimeslotsAndAccept(ref.id, returnedUser.id, []);
    final snapshot = await instance.collection('meeting').get();
    expect(snapshot.docs[0].data()['invitations'], []);
  });

  // test('load meeting by id', () async {
  //   DocumentReference userRef = await instance.collection('user').add(user.toJson());
  //   DocumentReference ref = await meetingRepository.addNewMeeting(
  //       meeting.copyWith(groupmates: [new User(ref: userRef, id: userRef.id)]).toEntity(), 'userId');
  //   final snapshot = await instance.collection('meeting').get();
  //   final meetingEntities = await meetingRepository.loadMeetingById(ref.id);
  //   expect(snapshot.docs[0].id, meetingEntities.id);
  // });

  // test('load meeting invitation', () async {
  //   DocumentReference userRef = await instance.collection('user').add(user.toJson());
  //   await meetingRepository.addNewMeeting(
  //       meeting.copyWith(
  //           groupmates: [new User(ref: userRef, id: userRef.id)],
  //           invited: [new User(ref: userRef, id: userRef.id)]).toEntity(),
  //       'userId');
  //   final snapshot = await instance.collection('meeting').get();
  //   final meetingEntities = await meetingRepository.loadMeetingInvitations(userRef.id);
  //   expect(snapshot.docs.length, meetingEntities.length);
  // });
  // // test('load meeting todos', () async {
  // //   DocumentReference ref = await instance.collection('user').add(user.toJson());
  // //   instance.collection('todo').add(TodoEntity('original', '123', '', false, Timestamp.fromDate(currentDate),
  // //           new Meeting('meetingName', id: 'meetingId'), [new User(ref: ref, id: ref.id)], null)
  // //       .toJson());
  // //   // print(ref.id);
  // //   // print(instance.dump());
  // //   final snapshot = await instance.collection('todo').get();
  // //   final todoEntities = await meetingRepository.loadMeetingTodos('meetingId');
  // //   expect(snapshot.docs.length, todoEntities.length);
  // // });
  // // test('load todos ref list', () async {
  // //   DocumentReference ref = await instance.collection('user').add(user.toJson());
  // //   DocumentReference todoRef = await instance.collection('todo').add(TodoEntity(
  // //           'original',
  // //           '123',
  // //           '',
  // //           false,
  // //           Timestamp.fromDate(currentDate),
  // //           new Meeting('meetingName', id: 'meetingId'),
  // //           [new User(ref: ref, id: ref.id)],
  // //           null)
  // //       .toJson());
  // //   // print(ref.id);
  // //   // print(instance.dump());
  // //   final snapshot = await instance.collection('todo').get();
  // //   final todoEntities = await meetingRepository.loadTodosFromReferenceList([todoRef]);
  // //   expect(snapshot.docs.length, todoEntities.length);
  // // });

  test('update meeting', () async {
    await authenticationRepository.signUp(email: userEmail, password: "password", name: 'Bob');
    UserModel.User returnedUser = authenticationRepository.getUser();
    Project newProject = Project(
      'test',
      id: 'testId',
      groupmates: [new User(id: returnedUser.id, name: 'Bob')],
      deadline: currentDate.subtract(Duration(days: 1)),
    );
    ProjectEntity newProjectEntity = newProject.toEntity();
    DocumentReference projectRef = await projectRepository.addNewProject(newProjectEntity, 'userId');
    MeetingEntity entityToAdd = meeting.copyWith(
        project: (newProject.copyWith(id: projectRef.id, ref: projectRef)),
        groupmates: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ],
        confirmed: [],
        invited: [
          new User(id: returnedUser.id, name: 'Bob', ref: instance.collection('user').doc(returnedUser.id))
        ]).toEntity();
    DocumentReference ref = await meetingRepository.addNewMeeting(entityToAdd, 'userId');
    MeetingEntity updatedEntity = meeting.copyWith(id: ref.id, title: 'updated').toEntity();
    await meetingRepository.updateMeeting(updatedEntity);
    final snapshot = await instance.collection('meeting').get();
    expect(snapshot.docs[0].data()['title'], updatedEntity.title);
    expect(snapshot.docs[0].data()['title'], 'updated');
  });
}
