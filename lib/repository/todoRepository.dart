import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoRepository {
  TodoRepository._internal();
  static final TodoRepository _singleton = TodoRepository._internal();
  factory TodoRepository({FirebaseFirestore firestore}) {
    if (firestore != null) {
      _singleton._firestore = firestore;
    } else {
      _singleton._firestore = FirebaseFirestore.instance;
    }
    _singleton.ref = _singleton._firestore.collection('todo');
    _singleton.person = _singleton._firestore.collection('user');
    _singleton.project = _singleton._firestore.collection('project');
    return _singleton;
  }
  CollectionReference ref;
  CollectionReference person;
  CollectionReference project;

  FirebaseFirestore _firestore;

  Future<DocumentReference> addNewTodo(TodoEntity todo, String id) async {
    Map<String, dynamic> tempJson = todo.toJson();
    tempJson.addEntries([MapEntry("_createdAt", Timestamp.fromDate(DateTime.now()))]);
    final newTodoRef = await ref.add(tempJson);
    bool userTodosExist = await person.doc(id).get().then((DocumentSnapshot snapshot) => snapshot.exists);
    final List<Future> promises = [];
    if (!userTodosExist) {
      person.doc(id).set({
        'todo': [newTodoRef]
      });
    } else {
      promises.add(person.doc(id).update({
        'todo': FieldValue.arrayUnion([newTodoRef])
      }));
    }
    promises.add(project.doc(todo.project.id).update({
      'todos': FieldValue.arrayUnion([newTodoRef])
    }));
    await Future.wait(promises);
    return newTodoRef;
  }

  Future<void> deleteTodo(Todo todo, String id) async {
    final List<Future> promises = [];
    promises.add(person.doc(id).update({
      'todo': FieldValue.arrayRemove([todo.ref])
    }));
    promises.add(project.doc(todo.project.id).update({
      'todos': FieldValue.arrayRemove([todo.ref])
    }));
    await Future.wait(promises);
    return ref.doc(todo.id).delete();
  }

  Future<void> reorderTodo(List<DocumentReference> refs, String id) async {
    return await person.doc(id).update({
      'todo': [...refs]
    });
  }

  Future<List<TodoEntity>> loadTodos(String id) async {
    DocumentReference documentReference = person.doc(id);
    QuerySnapshot documentSnapshot = await ref.where('PIC', arrayContains: documentReference).get();
    List<TodoEntity> tasks = [];
    print(documentSnapshot.docs.length);
    for (QueryDocumentSnapshot temp in documentSnapshot.docs.toList()) {
      final Map<String, Object> data = temp.data();
      final List<User> users = await AuthenticationRepository().findUsersByRef(data['PIC']);
      TodoEntity documentSnapshotTask = TodoEntity.fromJson(temp.data(), users, temp.id, temp.reference);
      tasks.add(documentSnapshotTask);
    }
    tasks.sort((x, y) => y.complete ? -1 : 1);
    return tasks;
  }

  Future<List<TodoEntity>> loadProjectTodos(String projectId) async {
    // DocumentReference documentReference = person.doc(id);
    QuerySnapshot documentSnapshot = await ref.where('project.id', isEqualTo: projectId).get();
    List<TodoEntity> tasks = [];
    for (QueryDocumentSnapshot temp in documentSnapshot.docs.toList()) {
      final Map<String, Object> data = temp.data();
      final List<User> users = await AuthenticationRepository().findUsersByRef(data['PIC']);
      TodoEntity documentSnapshotTask = TodoEntity.fromJson(temp.data(), users, temp.id, temp.reference);
      tasks.add(documentSnapshotTask);
    }
    // print(tasks);
    return tasks;
  }

  Future<List<TodoEntity>> loadTodosFromReferenceList(List<dynamic> refs) async {
    List<TodoEntity> tasks = [];
    for (DocumentReference documentReference in refs) {
      final DocumentSnapshot temp = await documentReference.get();
      // print(documentReference);
      final Map<String, Object> data = temp.data();
      if (data != null) {
        final List<User> users = await AuthenticationRepository().findUsersByRef(data['PIC']);
        TodoEntity documentSnapshotTask = TodoEntity.fromJson(temp.data(), users, temp.id, documentReference);
        tasks.add(documentSnapshotTask);
      }
    }
    return tasks;
  }

  Future<void> updateTodo(TodoEntity oldTodo, TodoEntity newTodo) {
    if (oldTodo.project.id != newTodo.project.id) {
      project.doc(oldTodo.project.id).update({
        'todos': FieldValue.arrayRemove([oldTodo.ref])
      });
      project.doc(newTodo.project.id).update({
        'todos': FieldValue.arrayUnion([oldTodo.ref])
      });
    }
    return ref.doc(newTodo.id).update(newTodo.toJson());
  }
}
