import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectRepository {
  static CollectionReference ref = FirebaseFirestore.instance.collection('project');
  static CollectionReference person = FirebaseFirestore.instance.collection('user');

  final FirebaseFirestore firestore;

  const ProjectRepository({this.firestore});

  Future<DocumentReference> addNewProject(ProjectEntity todo, String id) async {
    Map<String, dynamic> tempJson = todo.toJson();
    tempJson.addEntries([
      MapEntry("_createdAt", Timestamp.fromDate(DateTime.now())),
      MapEntry("todos", []),
      MapEntry("meetings", []),
      MapEntry("confirmedInvitations", [person.doc(id)]),
      MapEntry("invitations", todo.groupmates.where((y) => y.id != id).map((x) => x.ref).toList()),
    ]);
    final newTodoRef = await ref.add(tempJson);
    bool userTodosExist = await person.doc(id).get().then((DocumentSnapshot snapshot) => snapshot.exists);
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
  Future<ProjectEntity> loadProjectById(String id) async {
    DocumentSnapshot documentSnapshot = await ref.doc(id).get();
    Map<String, Object> tempData = documentSnapshot.data();
    List<TodoEntity> todoEntities = await TodoRepository.loadTodosFromReferenceList(tempData['todos']);
    List<Todo> todos = todoEntities.map((todoEntity) => Todo.fromEntity(todoEntity)).toList();
    List<User> users = await AuthenticationRepository.findUsersByRef(tempData['groupmates']);
    List<MeetingEntity> meetings = await MeetingRepository.loadMeetingsFromReferenceList(tempData['meetings']);
    ProjectEntity documentSnapshotTask =
        ProjectEntity.fromJson(tempData, todos, users, meetings, id, documentSnapshot.reference);
    return documentSnapshotTask;
  }

  Future<List<ProjectEntity>> loadProjects(String id) async {
    DocumentSnapshot documentSnapshot = await person.doc(id).get();
    // if (!documentSnapshot.exists) {
    //   print('Document exists on the database: ' + documentSnapshot.data());
    // }
    final list = documentSnapshot.get("project");
    List<ProjectEntity> projects = [];
    for (DocumentReference documentReference in list) {
      final DocumentSnapshot temp = await documentReference.get();
      Map<String, Object> tempData = temp.data();
      List<TodoEntity> todoEntities = await TodoRepository.loadTodosFromReferenceList(tempData['todos']);
      List<Todo> todos = todoEntities.map((todoEntity) => Todo.fromEntity(todoEntity)).toList();
      List<User> users = await AuthenticationRepository.findUsersByRef(tempData['groupmates']);
      List<MeetingEntity> meetings = await MeetingRepository.loadMeetingsFromReferenceList(tempData['meetings']);
      // print(users);
      ProjectEntity documentSnapshotTask =
          ProjectEntity.fromJson(temp.data(), todos, users, meetings, temp.id, documentReference);
      projects.add(documentSnapshotTask);
    }
    // print("Task: " + tasks.toString());
    // print("project: " + projects[0].meetings.length.toString());
    return projects;
  }

  Future<List<ProjectEntity>> loadProjectInvitations(String id) async {
    DocumentReference personRef = person.doc(id);
    final querySnapshot = await ref.where('invitations', arrayContains: personRef).get();
    List<ProjectEntity> projects = [];
    for (QueryDocumentSnapshot doc in querySnapshot.docs.toList()) {
      final DocumentSnapshot temp = doc;
      Map<String, Object> tempData = temp.data();
      List<TodoEntity> todoEntities = await TodoRepository.loadTodosFromReferenceList(tempData['todos']);
      List<Todo> todos = todoEntities.map((todoEntity) => Todo.fromEntity(todoEntity)).toList();
      List<User> users = await AuthenticationRepository.findUsersByRef(tempData['groupmates']);
      List<MeetingEntity> meetings = await MeetingRepository.loadMeetingsFromReferenceList(tempData['meetings']);
      print(users);
      ProjectEntity documentSnapshotTask =
          ProjectEntity.fromJson(temp.data(), todos, users, meetings, temp.id, doc.reference);
      projects.add(documentSnapshotTask);
    }
    print('invitations: ' + projects.length.toString());
    return projects;
  }

  Future<void> updateProject(ProjectEntity project) {
    print(project.toJson());
    return ref.doc(project.id).update(project.toJson());
  }
}
