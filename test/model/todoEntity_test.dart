import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/models/meetingEntity.dart';
import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/models/projectEntity.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

void main() {
  setupCloudFirestoreMocks();
  Map<String, Object> json;
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    json = {
      'complete': false,
      'task': 'title',
      'note': '',
      'id': 'id',
      'project': {'id': 'projectId', 'title': 'projectName'},
      'pic': [],
      'deadline': null
    };
  });
  test('Convert JSON to todoEntity', () {
    final todo = TodoEntity.fromJson(json, [], 'id', FirebaseFirestore.instance.collection('todo').doc('testId'));
    Todo actualTodo = Todo('title',
        project: new Project('projectName', id: 'projectId'),
        id: 'id',
        complete: false,
        pic: [],
        ref: FirebaseFirestore.instance.collection('todo').doc('testId'),
        includeTime: false);
    expect(actualTodo, Todo.fromEntity(todo));
  });

  test('Convert todoEntity to JSON', () {
    TodoEntity actualTodo = TodoEntity(
      'title',
      'id',
      '',
      false,
      null,
      new Project('projectName', id: 'projectId'),
      [],
      false,
      FirebaseFirestore.instance.collection('user').doc('userId'),
    );
    expect(json, actualTodo.toJson());
  });
}
