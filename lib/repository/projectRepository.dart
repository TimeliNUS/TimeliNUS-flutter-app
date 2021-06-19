import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/models/projectEntity.dart';
import 'package:TimeliNUS/models/todo.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:TimeliNUS/models/todoEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectRepository {
  static CollectionReference ref =
      FirebaseFirestore.instance.collection('project');
  static CollectionReference person =
      FirebaseFirestore.instance.collection('user');

  final FirebaseFirestore firestore;

  const ProjectRepository({this.firestore});

  Future<DocumentReference> addNewProject(ProjectEntity todo, String id) async {
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
        'project': [newTodoRef]
      });
    } else {
      await person.doc(id).update({
        'project': FieldValue.arrayUnion([newTodoRef])
      });
    }
    return newTodoRef;
  }

  Future<void> deleteTodo(Project project, String id) async {
    await person.doc(id).update({
      'project': FieldValue.arrayRemove([project.ref])
    });
    return ref.doc(project.id).delete();
  }

  // Future<void> reorderTodo(List<DocumentReference> refs, String id) async {
  //   return await person.doc(id).update({
  //     'todo': [...refs]
  //   });
  // }

  Future<List<ProjectEntity>> loadProjects(String id) async {
    DocumentSnapshot documentSnapshot = await person.doc(id).get();
    if (!documentSnapshot.exists) {
      print('Document exists on the database: ' + documentSnapshot.data());
    }
    final list = documentSnapshot.get("project");
    List<ProjectEntity> projects = [];
    for (DocumentReference documentReference in list) {
      final DocumentSnapshot temp = await documentReference.get();
      Map<String, Object> tempData = temp.data();
      print(tempData);
      List<TodoEntity> todoEntities =
          await TodoRepository.loadTodosFromReferenceList(tempData['todos']);
      List<Todo> todos = todoEntities
          .map((todoEntity) => Todo.fromEntity(todoEntity))
          .toList();
      ProjectEntity documentSnapshotTask = ProjectEntity.fromJson(
          temp.data(), todos, temp.id, documentReference);
      print(documentSnapshotTask);
      projects.add(documentSnapshotTask);
    }
    // print("Task: " + tasks.toString());
    return projects;
  }

  Future<void> updateProject(ProjectEntity project) {
    return ref.doc(project.id).update(project.toJson());
  }
}
