import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoRepository {
  static CollectionReference ref =
      FirebaseFirestore.instance.collection('todo');
  static CollectionReference person =
      FirebaseFirestore.instance.collection('user');
  static CollectionReference project =
      FirebaseFirestore.instance.collection('project');

  final FirebaseFirestore firestore;

  const TodoRepository({this.firestore});

  Future<DocumentReference> addNewTodo(TodoEntity todo, String id) async {
    Map<String, dynamic> tempJson = todo.toJson();
    tempJson.addEntries(
        [MapEntry("_createdAt", Timestamp.fromDate(DateTime.now()))]);
    final newTodoRef = await ref.add(tempJson);
    bool userTodosExist = await person
        .doc(id)
        .get()
        .then((DocumentSnapshot snapshot) => snapshot.exists);
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
    DocumentSnapshot documentSnapshot = await person.doc(id).get();
    if (!documentSnapshot.exists) {
      print('Document exists on the database: ' + documentSnapshot.data());
    }
    final list = documentSnapshot.get("todo");
    return await loadTodosFromReferenceList(list);
  }

  static Future<List<TodoEntity>> loadTodosFromReferenceList(
      List<dynamic> refs) async {
    List<TodoEntity> tasks = [];
    for (DocumentReference documentReference in refs) {
      final DocumentSnapshot temp = await documentReference.get();
      // print(documentReference);
      final Map<String, Object> data = temp.data();
      final List<User> users =
          await ProjectRepository.findUsersByRef(data['pic']);
      TodoEntity documentSnapshotTask =
          TodoEntity.fromJson(temp.data(), users, temp.id, documentReference);
      tasks.add(documentSnapshotTask);
    }
    // print("Task: " + tasks.toString());
    return tasks;
  }

  // Future<List<TodoEntity>> todos() {
  //   return ref.snapshots().map((snapshot) {
  //     return TodoEntity(
  //       snapshot['task'],
  //       snapshot.documentID,
  //       snapshot['note'] ?? '',
  //       snapshot['complete'] ?? false,
  //     );
  //   }).toList();
  // }

  Future<void> updateTodo(TodoEntity todo) {
    return ref.doc(todo.id).update(todo.toJson());
  }
}
