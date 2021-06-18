import 'package:TimeliNUS/models/meetingEntity.dart';
import 'package:TimeliNUS/models/projectEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MeetingRepository {
  static CollectionReference ref =
      FirebaseFirestore.instance.collection('meeting');
  static CollectionReference person =
      FirebaseFirestore.instance.collection('user');

  final FirebaseFirestore firestore;

  const MeetingRepository({this.firestore});

  Future<DocumentReference> addNewMeeting(
      MeetingEntity meeting, String id) async {
    Map<String, dynamic> tempJson = meeting.toJson();
    tempJson.addEntries(
        [MapEntry("_createdAt", Timestamp.fromDate(DateTime.now()))]);
    final newTodoRef = await ref.add(tempJson);
    // if (!userTodosExist) {
    //   person.doc(id).set({
    //     'project': [newTodoRef]
    //   });
    // } else {
    //   await person.doc(id).update({
    //     'project': FieldValue.arrayUnion([newTodoRef])
    //   });
    // }
    return newTodoRef;
  }

  // Future<void> deleteTodo(Todo todo, String id) async {
  //   await person.doc(id).update({
  //     'todo': FieldValue.arrayRemove([todo.ref])
  //   });
  //   return ref.doc(todo.id).delete();
  // }

  // Future<void> reorderTodo(List<DocumentReference> refs, String id) async {
  //   return await person.doc(id).update({
  //     'todo': [...refs]
  //   });
  // }

  Future<List<MeetingEntity>> loadMeetings(String id) async {
    DocumentSnapshot documentSnapshot = await person.doc(id).get();
    if (!documentSnapshot.exists) {
      print('Document exists on the database: ' + documentSnapshot.data());
    }
    print(documentSnapshot.get("meeting"));
    final list = documentSnapshot.get("meeting");
    List<MeetingEntity> meetings = [];
    for (DocumentReference documentReference in list) {
      final DocumentSnapshot temp = await documentReference.get();
      Map<String, Object> tempData = temp.data();
      print(tempData);
      MeetingEntity documentSnapshotTask =
          MeetingEntity.fromJson(temp.data(), [], temp.id, documentReference);
      print(documentSnapshotTask);
      meetings.add(documentSnapshotTask);
    }
    print(meetings);
    return meetings;
  }

  Future<void> updateProject(ProjectEntity project) {
    return ref.doc(project.id).update(project.toJson());
  }
}
