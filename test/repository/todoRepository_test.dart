import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

void main() {
  TodoRepository todoRepository;
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
    todoRepository = new TodoRepository(firestore: instance);
    user = new User(id: 'userId', name: 'testUser', ref: instance.collection('user').doc('userId'));
    project = Project.fromEntity(ProjectEntity('original', 'code', 'id', 1, Timestamp.fromDate(currentDate), [], 0, [],
        [], [], FirebaseFirestore.instance.collection('project').doc('id')));
    newProject = Project('test',
        id: 'testId',
        deadline: currentDate.subtract(Duration(days: 1)),
        ref: FirebaseFirestore.instance.collection('project').doc('testId'));
  });

  test('add new todo', () async {
    todoRepository.addNewTodo(
        TodoEntity('original', '123', '', false, Timestamp.fromDate(currentDate),
            new Project('projectName', id: 'projectId'), [], null),
        'userId');
    final snapshot = await instance.collection('todo').get();
    expect(snapshot.docs.length, 1);
  });

  test('delete todo', () async {
    DocumentReference ref = await todoRepository.addNewTodo(
        TodoEntity('original', '123', '', false, Timestamp.fromDate(currentDate),
            new Project('projectName', id: 'projectId'), [], null),
        'userId');
    // print(instance.dump());
    todoRepository.deleteTodo(
        Todo('title',
            project: new Project('projectName', id: 'projectId'),
            id: ref.id,
            complete: false,
            pic: [],
            ref: FirebaseFirestore.instance.collection('todo').doc(ref.id)),
        'userId');
    final snapshot = await instance.collection('todo').get();
    expect(snapshot.docs.length, 0);
  });

  test('load todos', () async {
    DocumentReference ref = await instance.collection('user').add(user.toJson());
    instance.collection('todo').add(TodoEntity('original', '123', '', false, Timestamp.fromDate(currentDate),
            new Project('projectName', id: 'projectId'), [new User(ref: ref, id: ref.id)], null)
        .toJson());
    // print(ref.id);
    // print(instance.dump());
    final snapshot = await instance.collection('todo').get();
    final todoEntities = await todoRepository.loadTodos(ref.id);
    expect(snapshot.docs.length, todoEntities.length);
  });

  test('load project todos', () async {
    DocumentReference ref = await instance.collection('user').add(user.toJson());
    instance.collection('todo').add(TodoEntity('original', '123', '', false, Timestamp.fromDate(currentDate),
            new Project('projectName', id: 'projectId'), [new User(ref: ref, id: ref.id)], null)
        .toJson());
    // print(ref.id);
    // print(instance.dump());
    final snapshot = await instance.collection('todo').get();
    final todoEntities = await todoRepository.loadProjectTodos('projectId');
    expect(snapshot.docs.length, todoEntities.length);
  });

  test('load todos ref list', () async {
    DocumentReference ref = await instance.collection('user').add(user.toJson());
    DocumentReference todoRef = await instance.collection('todo').add(TodoEntity(
            'original',
            '123',
            '',
            false,
            Timestamp.fromDate(currentDate),
            new Project('projectName', id: 'projectId'),
            [new User(ref: ref, id: ref.id)],
            null)
        .toJson());
    // print(ref.id);
    // print(instance.dump());
    final snapshot = await instance.collection('todo').get();
    final todoEntities = await todoRepository.loadTodosFromReferenceList([todoRef]);
    expect(snapshot.docs.length, todoEntities.length);
  });

  test('update todos', () async {
    DocumentReference ref = await instance.collection('user').add(user.toJson());
    DocumentReference projectRef = await instance.collection('project').add(project.toEntity().toJson());
    DocumentReference newProjectRef = await instance.collection('project').add(newProject.toEntity().toJson());

    TodoEntity testEntity = TodoEntity('original', '123', '', false, Timestamp.fromDate(currentDate),
        new Project('projectName', id: 'testId', ref: newProjectRef), [new User(ref: ref, id: ref.id)], null);
    DocumentReference todoRef = await instance.collection('todo').add(testEntity.toJson());
    TodoEntity updatedEntity =
        Todo.fromEntity(testEntity).copyWith(id: todoRef.id, title: 'updated', project: project).toEntity();
    await todoRepository.updateTodo(testEntity, updatedEntity);
    final snapshot = await instance.collection('todo').get();
    expect(snapshot.docs[0].data()['task'], updatedEntity.task);
    TodoEntity updatedProjectEntity = Todo.fromEntity(testEntity).copyWith(id: todoRef.id, title: 'updated').toEntity();
  });
}
