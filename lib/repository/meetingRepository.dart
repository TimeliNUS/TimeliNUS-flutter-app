import 'dart:convert';

import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/models/meetingEntity.dart';
import 'package:TimeliNUS/models/projectEntity.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:http/http.dart' as http;

class MeetingRepository {
  static CollectionReference ref =
      FirebaseFirestore.instance.collection('meeting');
  static CollectionReference person =
      FirebaseFirestore.instance.collection('user');
  static CollectionReference project =
      FirebaseFirestore.instance.collection('project');

  final FirebaseFirestore firestore;

  const MeetingRepository({this.firestore});

  Future<DocumentReference> addNewMeeting(
      MeetingEntity meeting, String id) async {
    Map<String, dynamic> tempJson = meeting.toJson();
    tempJson.addEntries(
        [MapEntry("_createdAt", Timestamp.fromDate(DateTime.now()))]);
    final newMeetingref = await ref.add(tempJson);
    final List<Future> promises = [];
    final updateTimeslot = http.post(
      Uri.parse(
          // 'http://localhost:5001/timelinus-2021/asia-east2/updateMeetingTimeslotByDateTime'),
          'https://asia-east2-timelinus-2021.cloudfunctions.net/updateMeetingTimeslotByDateTime'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "startDate": meeting.startDate.toDate().toUtc().toIso8601String(),
        "endDate": meeting.endDate.toDate().toUtc().toIso8601String(),
        "id": newMeetingref.id
      }),
    );

    promises.add(updateTimeslot);
    promises.add(person.doc(id).update({
      'meeting': FieldValue.arrayUnion([newMeetingref])
    }));
    promises.add(project.doc(meeting.project.id).update({
      'meetings': FieldValue.arrayUnion([newMeetingref])
    }));
    Future.wait(promises);
    return newMeetingref;
  }

  Future<List<MeetingEntity>> loadMeetings(String id) async {
    DocumentSnapshot documentSnapshot = await person.doc(id).get();
    // if (!documentSnapshot.exists) {
    //   print('Document exists on the database: ' + documentSnapshot.data());
    // }
    final list = documentSnapshot.get("meeting");
    List<MeetingEntity> meetings = [];
    for (DocumentReference documentReference in list) {
      final DocumentSnapshot temp = await documentReference.get();
      Map<String, Object> tempData = temp.data();
      // print(tempData);
      MeetingEntity documentSnapshotTask =
          MeetingEntity.fromJson(temp.data(), [], temp.id, documentReference);
      // print(documentSnapshotTask);
      meetings.add(documentSnapshotTask);
    }
    // print(meetings);
    return meetings;
  }

  Future<MeetingEntity> loadMeetingById(String id) async {
    DocumentSnapshot snapshot = await ref.doc(id).get();
    return MeetingEntity.fromJson(
        snapshot.data(), [], snapshot.id, snapshot.reference);
  }

  Future<void> updateMeeting(MeetingEntity meeting) {
    print("Update meeting");
    print(meeting);
    return ref.doc(meeting.id).update(meeting.toJson());
  }

  Future<void> acceptInvitation(Meeting meeting, String id, String url) {
    print({
      "link": url,
      "startDate": meeting.startDate.toUtc().toIso8601String(),
      "endDate": meeting.endDate.toUtc().toIso8601String(),
      "id": id
    });
    return http.post(
      Uri.parse(
          'https://asia-east2-timelinus-2021.cloudfunctions.net/findNusModsCommon'),
      // 'http://localhost:5001/timelinus-2021/asia-east2/findNusModsCommon'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "link": url,
        "startDate": meeting.startDate.toUtc().toIso8601String(),
        "endDate": meeting.endDate.toUtc().toIso8601String(),
        "id": id
      }),
    );
  }

  static Future<List<MeetingEntity>> loadMeetingsFromReferenceList(
      List<dynamic> refs) async {
    List<MeetingEntity> meetings = [];
    for (DocumentReference documentReference in refs) {
      final DocumentSnapshot temp = await documentReference.get();
      // print(documentReference);
      final Map<String, Object> data = temp.data();
      MeetingEntity documentSnapshotTask =
          MeetingEntity.fromJson(temp.data(), [], temp.id, documentReference);
      meetings.add(documentSnapshotTask);
    }
    // print("Task: " + tasks.toString());
    return meetings;
  }

  Future<void> deleteMeeting(Meeting meeting, String id) async {
    await person.doc(id).update({
      'meeting': FieldValue.arrayRemove([meeting.ref])
    });
    return ref.doc(meeting.id).delete();
  }
}
