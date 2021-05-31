import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TodoRepository {
  static CollectionReference ref =
      FirebaseFirestore.instance.collection('todo');
  static CollectionReference person =
      FirebaseFirestore.instance.collection('user');

  final FirebaseFirestore firestore;

  const TodoRepository({this.firestore});

  Future<void> addNewTodo(TodoEntity todo, String id) async {
    Map<String, dynamic> tempJson = todo.toJson();
    tempJson.addEntries(
        [MapEntry("_createdAt", Timestamp.fromDate(DateTime.now()))]);
    final newTodoRef = await ref.add(tempJson);
    bool userTodosExist = await person
        .doc(id)
        .get()
        .then((DocumentSnapshot snapshot) => snapshot.exists);
    if (!userTodosExist) {
      person.doc(id).set({
        'todo': [newTodoRef]
      });
      return;
    } else {
      await person.doc(id).update({
        'todo': FieldValue.arrayUnion([newTodoRef])
      });
    }
  }

  Future<void> deleteTodo(List<String> idList) async {
    await Future.wait<void>(idList.map((id) {
      return ref.doc(id).delete();
    }));
  }

  Future<List<TodoEntity>> loadTodos(String id) async {
    DocumentSnapshot documentSnapshot = await person.doc(id).get();
    if (documentSnapshot.exists) {
      print('Document exists on the database');
      print(documentSnapshot.data());
    }
    final list = documentSnapshot.get("todo");
    List<TodoEntity> tasks = [];
    print(list);
    for (DocumentReference documentReference in list) {
      final DocumentSnapshot temp = await documentReference.get();
      // print(documentReference);
      TodoEntity documentSnapshotTask =
          TodoEntity.fromJson(temp.data(), temp.id);
      tasks.add(documentSnapshotTask);
    }
    print("Task: " + tasks.toString());
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
