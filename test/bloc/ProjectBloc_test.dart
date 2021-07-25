import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/project/projectBloc.dart';
import 'package:TimeliNUS/blocs/screens/todo/todo.dart';
import 'package:TimeliNUS/blocs/screens/todo/todoBloc.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

class MockProjectRepository extends Mock implements ProjectRepository {}

class MockProjectBloc extends MockBloc<ProjectEvent, ProjectState> implements ProjectBloc {}

void main() {
  ProjectRepository projectRepository;
  ProjectBloc projectBloc;
  DateTime currentDate = DateTime.now();
  setupCloudFirestoreMocks();
  Project testProject;
  ProjectEntity originalProjectEntity;
  Project originalProject;
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    projectRepository = MockProjectRepository();
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
    testProject = Project('test',
        id: 'testId',
        deadline: currentDate.subtract(Duration(days: 1)),
        ref: FirebaseFirestore.instance.collection('project').doc('testId'));
    when(projectRepository.loadProjects(any)).thenAnswer((ans) => Future.value([originalProjectEntity]));
    when(projectRepository.loadProjects(null)).thenThrow(new Error());
    when(projectRepository.loadProjectInvitations(any)).thenAnswer((ans) => Future.value([]));

    when(projectRepository.addNewProject(any, any)).thenAnswer(
        (ans) => Future.value(FirebaseFirestore.instance.collection('project').doc(ans.positionalArguments[0].id)));
    projectBloc = ProjectBloc(projectRepository: projectRepository);
  });
  group('ProjectBloc', () {
    test('throws AssertionError if Authentication Repository is null', () {
      expect(
        () => ProjectBloc(projectRepository: null),
        throwsA(isAssertionError),
      );
    });
    group('ProjectBloc Load', () {
      blocTest(
        'Not Loading Projects',
        build: () => projectBloc,
        act: (bloc) => bloc..add(LoadProjects(null)),
        expect: () => [ProjectLoading(), ProjectNotLoaded()],
      );
      blocTest(
        'Load Projects',
        build: () => projectBloc,
        act: (bloc) => bloc.add(LoadProjects('id')),
        expect: () => [
          ProjectLoading(),
          ProjectLoaded([originalProject], []),
        ],
      );
      blocTest(
        'Add Projects',
        build: () => projectBloc,
        act: (bloc) => bloc.add(AddProject(testProject, 'userId')),
        expect: () => [
          ProjectLoading(),
          ProjectLoaded([testProject], []),
        ],
      );
      blocTest(
        'Delete Projects',
        build: () => projectBloc,
        act: (bloc) => bloc..add(AddProject(testProject, 'userId'))..add(DeleteProject(testProject, 'userId')),
        expect: () => [
          ProjectLoading(),
          ProjectLoaded([testProject], []),
          ProjectLoading(),
          ProjectLoaded([], []),
        ],
      );
      blocTest(
        'Update Projects',
        build: () => projectBloc,
        act: (bloc) => bloc
          ..add(AddProject(testProject, 'userId'))
          ..add(UpdateProject(
              testProject.copyWith(
                title: "original",
                // id: 'id',
                moduleCode: 'code',
                deadline: currentDate,
                ref: FirebaseFirestore.instance.collection('project').doc('id'),
              ),
              'userId')),
        expect: () => [
          ProjectLoading(),
          ProjectLoaded([testProject], []),
          ProjectLoading(),
          ProjectLoaded([originalProject.copyWith(id: 'testId')], []),
        ],
      );
    });
  });
}
