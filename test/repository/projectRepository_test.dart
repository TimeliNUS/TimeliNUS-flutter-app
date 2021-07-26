import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

void main() {
  ProjectRepository projectRepository;
  DateTime currentDate = DateTime.now();
  FakeFirebaseFirestore instance;
  User user;
  Project project;
  Project newProject;
  setupCloudFirestoreMocks();
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    instance = FakeFirebaseFirestore();
    projectRepository = new ProjectRepository(firestore: instance);
    user = new User(id: 'userId', name: 'testUser', ref: instance.collection('user').doc('userId'));
    project = Project.fromEntity(ProjectEntity('original', 'code', 'id', 1, Timestamp.fromDate(currentDate), [], 0, [],
        [], [], FirebaseFirestore.instance.collection('project').doc('id')));
    newProject = Project('test',
        id: 'testId',
        deadline: currentDate.subtract(Duration(days: 1)),
        ref: FirebaseFirestore.instance.collection('project').doc('testId'));
  });

  test('add new project', () async {
    projectRepository.addNewProject(project.toEntity(), 'userId');
    final snapshot = await instance.collection('project').get();
    expect(snapshot.docs.length, 1);
  });

  test('delete project', () async {
    DocumentReference ref = await projectRepository.addNewProject(project.toEntity(), 'userId');
    QuerySnapshot snapshot = await instance.collection('project').get();
    expect(snapshot.docs.length, 1);
    projectRepository.deleteProject(project.copyWith(id: ref.id, ref: ref), 'userId');
    snapshot = await instance.collection('project').get();
    expect(snapshot.docs.length, 0);
  });

  test('load project', () async {
    DocumentReference ref = await instance.collection('user').add(user.toJson());
    await projectRepository.addNewProject(
        project.copyWith(groupmates: [new User(ref: ref, id: ref.id)]).toEntity(), 'userId');
    final snapshot = await instance.collection('project').get();
    final projectEntities = await projectRepository.loadProjects(ref.id);
    expect(snapshot.docs.length, projectEntities.length);
  });

  test('load project by id', () async {
    DocumentReference userRef = await instance.collection('user').add(user.toJson());
    DocumentReference ref = await projectRepository.addNewProject(
        project.copyWith(groupmates: [new User(ref: userRef, id: userRef.id)]).toEntity(), 'userId');
    final snapshot = await instance.collection('project').get();
    final projectEntities = await projectRepository.loadProjectById(ref.id);
    expect(snapshot.docs[0].id, projectEntities.id);
  });

  test('load project invitation', () async {
    DocumentReference userRef = await instance.collection('user').add(user.toJson());
    await projectRepository.addNewProject(
        project.copyWith(
            groupmates: [new User(ref: userRef, id: userRef.id)],
            invited: [new User(ref: userRef, id: userRef.id)]).toEntity(),
        'userId');
    final snapshot = await instance.collection('project').get();
    final projectEntities = await projectRepository.loadProjectInvitations(userRef.id);
    expect(snapshot.docs.length, projectEntities.length);
  });

  test('update project', () async {
    DocumentReference ref = await instance.collection('user').add(user.toJson());
    ProjectEntity testEntity = ProjectEntity('original', 'code', 'id', 1, Timestamp.fromDate(currentDate),
        [new User(ref: ref, id: ref.id)], 0, [], [], [], FirebaseFirestore.instance.collection('project').doc('id'));
    DocumentReference itemRef = await instance.collection('project').add(testEntity.toJson());
    ProjectEntity updatedEntity = project.copyWith(id: itemRef.id, title: 'updated').toEntity();
    await projectRepository.updateProject(updatedEntity);
    final snapshot = await instance.collection('project').get();
    expect(snapshot.docs[0].data()['title'], updatedEntity.title);
  });

  test('accept Project Invitation', () async {
    DocumentReference ref = await instance.collection('user').add(user.toJson());
    ProjectEntity testEntity = ProjectEntity(
        'original',
        'code',
        'id',
        1,
        Timestamp.fromDate(currentDate),
        [new User(ref: ref, id: ref.id)],
        0,
        [],
        [new User(ref: ref, id: ref.id)],
        [],
        FirebaseFirestore.instance.collection('project').doc('id'));
    DocumentReference itemRef = await projectRepository.addNewProject(testEntity, ref.id);
    await projectRepository.acceptProjectInvitation(itemRef.id, ref.id);
    final snapshot = await instance.collection('project').get();
    expect(snapshot.docs[0].data()['invitations'], []);
    expect(snapshot.docs[0].data()['confirmedInvitations'].length, 1);
  });

  test('decline Project Invitation', () async {
    DocumentReference ref = await instance.collection('user').add(user.toJson());
    ProjectEntity testEntity = ProjectEntity(
        'original',
        'code',
        'id',
        1,
        Timestamp.fromDate(currentDate),
        [new User(ref: ref, id: ref.id)],
        0,
        [],
        [new User(ref: ref, id: ref.id)],
        [],
        FirebaseFirestore.instance.collection('project').doc('id'));
    DocumentReference itemRef = await projectRepository.addNewProject(testEntity, ref.id);
    await projectRepository.declineProjectInvitation(itemRef.id, ref.id);
    final snapshot = await instance.collection('project').get();
    expect(snapshot.docs[0].data()['invitations'], []);
    expect(snapshot.docs[0].data()['groupmates'].length, 0);
  });
}
