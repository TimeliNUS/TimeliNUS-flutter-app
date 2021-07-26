import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/todoRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProjectRepository {
  ProjectRepository._internal();
  static final ProjectRepository _singleton = ProjectRepository._internal();

  CollectionReference ref;
  CollectionReference person;
  FirebaseFirestore firestore;

  factory ProjectRepository({FirebaseFirestore firestore}) {
    if (firestore != null) {
      _singleton.firestore = firestore;
    } else {
      _singleton.firestore = FirebaseFirestore.instance;
    }
    _singleton.ref = _singleton.firestore.collection('project');
    _singleton.person = _singleton.firestore.collection('user');
    return _singleton;
  }

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

  Future<void> deleteProject(Project project, String id) async {
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
    List<TodoEntity> todoEntities = await TodoRepository().loadTodosFromReferenceList(tempData['todos']);
    List<Todo> todos = todoEntities.map((todoEntity) => Todo.fromEntity(todoEntity)).toList();
    List<User> users = await AuthenticationRepository().findUsersByRef(tempData['groupmates']);
    List<User> invited = await AuthenticationRepository().findUsersByRef(tempData['invitations']);
    List<User> confirmed = await AuthenticationRepository().findUsersByRef(tempData['confirmedInvitations']);
    // List<MeetingEntity> meetings = await MeetingRepository.loadMeetingsFromReferenceList(tempData['meetings']);
    ProjectEntity documentSnapshotTask =
        ProjectEntity.fromJson(tempData, todos, users, invited, confirmed, id, documentSnapshot.reference);
    return documentSnapshotTask;
  }

  Future<List<ProjectEntity>> loadProjects(String id) async {
    DocumentReference personRef = person.doc(id);
    final querySnapshot = await ref.where('confirmedInvitations', arrayContains: personRef).get();
    List<ProjectEntity> projects = [];
    for (QueryDocumentSnapshot temp in querySnapshot.docs.toList()) {
      Map<String, Object> tempData = temp.data();
      print(tempData);
      List<TodoEntity> todoEntities =
          tempData['todos'] != null ? await TodoRepository().loadTodosFromReferenceList(tempData['todos']) : [];
      List<Todo> todos = todoEntities.map((todoEntity) => Todo.fromEntity(todoEntity)).toList();
      List<User> users = await AuthenticationRepository().findUsersByRef(tempData['groupmates']);
      List<User> invited = await AuthenticationRepository().findUsersByRef(tempData['invitations']);
      List<User> confirmed = await AuthenticationRepository().findUsersByRef(tempData['confirmedInvitations']);
      // List<MeetingEntity> meetings = await MeetingRepository.loadMeetingsFromReferenceList(tempData['meetings']);
      ProjectEntity documentSnapshotTask =
          ProjectEntity.fromJson(temp.data(), todos, users, invited, confirmed, temp.id, temp.reference);
      projects.add(documentSnapshotTask);
    }
    return projects;
  }

  Future<List<ProjectEntity>> loadProjectInvitations(String id) async {
    DocumentReference personRef = person.doc(id);
    final querySnapshot = await ref.where('invitations', arrayContains: personRef).get();
    List<ProjectEntity> projects = [];
    for (QueryDocumentSnapshot temp in querySnapshot.docs.toList()) {
      Map<String, Object> tempData = temp.data();
      List<TodoEntity> todoEntities =
          tempData['todos'] != null ? await TodoRepository().loadTodosFromReferenceList(tempData['todos']) : [];
      List<Todo> todos = todoEntities.map((todoEntity) => Todo.fromEntity(todoEntity)).toList();
      List<User> users = await AuthenticationRepository().findUsersByRef(tempData['groupmates']);
      List<User> invited = await AuthenticationRepository().findUsersByRef(tempData['invitations']);
      List<User> confirmed = await AuthenticationRepository().findUsersByRef(tempData['confirmedInvitations']);

      // List<MeetingEntity> meetings = await MeetingRepository.loadMeetingsFromReferenceList(tempData['meetings']);
      print(users);
      ProjectEntity documentSnapshotTask =
          ProjectEntity.fromJson(temp.data(), todos, users, invited, confirmed, temp.id, temp.reference);
      projects.add(documentSnapshotTask);
    }
    // print('invitations: ' + projects.length.toString());
    return projects;
  }

  Future<void> acceptProjectInvitation(String projectId, String userId) async {
    DocumentReference personRef = person.doc(userId);
    await ref.doc(projectId).update({
      "confirmedInvitations": FieldValue.arrayUnion([personRef]),
      "invitations": FieldValue.arrayRemove([personRef])
    });
  }

  Future<void> declineProjectInvitation(String projectId, String userId) async {
    DocumentReference personRef = person.doc(userId);
    await ref.doc(projectId).update({
      "groupmates": FieldValue.arrayRemove([personRef]),
      "invitations": FieldValue.arrayRemove([personRef])
    });
  }

  Future<void> updateProject(ProjectEntity project) {
    print(project.toJson());
    return ref.doc(project.id).update(project.toJson());
  }
}
