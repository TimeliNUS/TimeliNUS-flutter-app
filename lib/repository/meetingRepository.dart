import 'dart:convert';

import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class MeetingRepository {
  static CollectionReference ref = FirebaseFirestore.instance.collection('meeting');
  static CollectionReference person = FirebaseFirestore.instance.collection('user');
  static CollectionReference project = FirebaseFirestore.instance.collection('project');

  final FirebaseFirestore firestore;

  const MeetingRepository({this.firestore});

  Future<DocumentReference> addNewMeeting(MeetingEntity meeting, String id) async {
    Map<String, dynamic> tempJson = meeting.toJson();
    tempJson.addEntries([MapEntry("_createdAt", Timestamp.fromDate(DateTime.now()))]);
    final newMeetingref = await ref.add(tempJson);
    final List<Future> promises = [];
    final updateTimeslot = http.post(
      Uri.parse(AppConstants.updateMeetingUrl),
      // 'https://asia-east2-timelinus-2021.cloudfunctions.net/updateMeetingTimeslotByDateTime'),
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

  Future<List<MeetingEntity>> loadProjectMeetings(String id) async {
    QuerySnapshot documentSnapshot = await ref.where('project.id', isEqualTo: id).get();
    final list = documentSnapshot.docs.toList();
    List<MeetingEntity> meetings = [];
    for (QueryDocumentSnapshot documentReference in list) {
      final DocumentSnapshot temp = documentReference;
      MeetingEntity documentSnapshotTask =
          MeetingEntity.fromJson(temp.data(), [], [], temp.id, documentReference.reference);
      meetings.add(documentSnapshotTask);
    }
    return meetings;
  }

  Future<MeetingEntity> loadMeetingById(String id) async {
    DocumentSnapshot snapshot = await ref.doc(id).get();
    return MeetingEntity.fromJson(snapshot.data(), [], [], snapshot.id, snapshot.reference);
  }

  Future<void> updateMeeting(MeetingEntity meeting) {
    print("Update meeting");
    print(meeting);
    return ref.doc(meeting.id).update(meeting.toJson());
  }

  Future<void> acceptInvitation(Meeting meeting, String id, String url, String user) async {
    await http.post(
      Uri.parse(AppConstants.findCommonUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{
        "link": url,
        "startDate": meeting.startDate.toUtc().toIso8601String(),
        "endDate": meeting.endDate.toUtc().toIso8601String(),
        "id": id,
        "user": user
      }),
    );
    return;
  }

  static Future<List<MeetingEntity>> loadMeetingsFromReferenceList(List<dynamic> refs) async {
    List<MeetingEntity> meetings = [];
    for (DocumentReference documentReference in refs) {
      final DocumentSnapshot temp = await documentReference.get();
      // print(documentReference);
      // final Map<String, Object> data = temp.data();
      MeetingEntity documentSnapshotTask = MeetingEntity.fromJson(temp.data(), [], [], temp.id, documentReference);
      meetings.add(documentSnapshotTask);
    }
    // print("meetings: " + meetings.toString());
    return meetings;
  }

  Future<List<MeetingEntity>> loadInvitation(String id) async {
    DocumentReference documentReference = person.doc(id);
    QuerySnapshot documentSnapshot = await ref.where('invitations', arrayContains: documentReference).get();
    final list = documentSnapshot.docs.toList();
    print(list);
    List<MeetingEntity> meetings = [];
    for (QueryDocumentSnapshot documentReference in list) {
      final DocumentSnapshot temp = documentReference;
      MeetingEntity documentSnapshotTask =
          MeetingEntity.fromJson(temp.data(), [], [], temp.id, documentReference.reference);
      meetings.add(documentSnapshotTask);
    }
    return meetings;
  }

  Future<List<MeetingEntity>> loadConfirmedMeetings(String id) async {
    DocumentReference documentReference = person.doc(id);
    QuerySnapshot documentSnapshot = await ref.where('author', isEqualTo: documentReference).get();
    QuerySnapshot documentSnapshot2 = await ref
        .where('confirmedInvitations', arrayContains: documentReference)
        .where('author', isNotEqualTo: documentReference)
        .get();
    final list = documentSnapshot.docs.toList()..addAll(documentSnapshot2.docs.toList());
    List<MeetingEntity> meetings = [];
    for (QueryDocumentSnapshot temp in list) {
      List<Future<dynamic>> promises = [];
      print(((temp.data() as Map<String, Object>)['invitations'] as List<dynamic>)
          .map((x) => x as DocumentReference)
          .toList()
          .runtimeType);
      List<DocumentReference> invitedUserRefs =
          ((temp.data() as Map<String, Object>)['invitations'] as List<dynamic>).isNotEmpty
              ? ((temp.data() as Map<String, Object>)['invitations'] as List<dynamic>)
                  .map((x) => x as DocumentReference)
                  .toList()
              : [];
      List<DocumentReference> acceptedUserRefs =
          ((temp.data() as Map<String, Object>)['confirmedInvitations'] as List<dynamic>).isNotEmpty
              ? ((temp.data() as Map<String, Object>)['confirmedInvitations'] as List<dynamic>)
                  .map((x) => x as DocumentReference)
                  .toList()
              : [];
      List<User> invitedUsers;
      List<User> confirmedUsers;
      promises.add(AuthenticationRepository.findUsersByRef(invitedUserRefs).then((x) => invitedUsers = x));
      promises.add(AuthenticationRepository.findUsersByRef(acceptedUserRefs).then((x) => confirmedUsers = x));
      await Future.wait(promises);
      MeetingEntity documentSnapshotTask =
          MeetingEntity.fromJson(temp.data(), invitedUsers, confirmedUsers, temp.id, temp.reference);
      meetings.add(documentSnapshotTask);
    }
    return meetings;
  }

  Future<void> syncGoogleCalendar(
      String meetingId, String accessToken, String timeMin, String timeMax, String userId) async {
    print('accessToken ' + accessToken);
    final resp = await http.post(
      Uri.parse(AppConstants.findGoogleCommonUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'google-token': accessToken,
      },
      body: jsonEncode(<String, String>{"timeMin": timeMin, "timeMax": timeMax, "id": meetingId, "user": userId}),
    );
    print('response ');
    print(resp.body);
    return;
  }

  Future<void> deleteMeeting(Meeting meeting, String id) async {
    await person.doc(id).update({
      'meeting': FieldValue.arrayRemove([meeting.ref])
    });
    return ref.doc(meeting.id).delete();
  }
}
