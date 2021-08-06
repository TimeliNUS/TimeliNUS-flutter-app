import 'dart:convert';

import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/utils/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:TimeliNUS/utils/dateTimeExtension.dart';

class MeetingRepository {
  MeetingRepository._internal();
  static final MeetingRepository _singleton = MeetingRepository._internal();

  CollectionReference ref;
  CollectionReference person;
  CollectionReference project;
  FirebaseFirestore _firestore;

  factory MeetingRepository({FirebaseFirestore firestore}) {
    if (firestore != null) {
      _singleton._firestore = firestore;
    } else {
      _singleton._firestore = FirebaseFirestore.instance;
    }
    _singleton.ref = _singleton._firestore.collection('meeting');
    _singleton.person = _singleton._firestore.collection('user');
    _singleton.project = _singleton._firestore.collection('project');
    return _singleton;
  }

  Future<DocumentReference> addNewMeeting(MeetingEntity meeting, String id) async {
    Map<String, dynamic> tempJson = meeting.toJson();
    tempJson.addEntries([MapEntry("_createdAt", Timestamp.fromDate(DateTime.now()))]);
    print(tempJson);
    final newMeetingref = await ref.add(tempJson);
    final List<Future> promises = [];
    // final updateTimeslot = http.post(
    //   Uri.parse(AppConstants.updateMeetingUrl),
    //   // 'https://asia-east2-timelinus-2021.cloudfunctions.net/updateMeetingTimeslotByDateTime'),
    //   headers: <String, String>{
    //     'Content-Type': 'application/json; charset=UTF-8',
    //   },
    //   body: jsonEncode(<String, String>{
    //     "startDate": meeting.startDate.toDate().toUtc().toIso8601String(),
    //     "endDate": meeting.endDate.toDate().toUtc().toIso8601String(),
    //     "id": newMeetingref.id
    //   }),
    // );

    // promises.add(updateTimeslot);
    // promises.add(person.doc(id).update({
    //   'meeting': FieldValue.arrayUnion([newMeetingref])
    // }));

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

  Future<void> importNusMods(Meeting meeting, String id, String url, String user) async {
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

  Future<List<MeetingEntity>> loadMeetingsFromReferenceList(List<dynamic> refs) async {
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
    // QuerySnapshot documentSnapshot = await ref.where('author', isEqualTo: documentReference).get();
    QuerySnapshot documentSnapshot2 = await ref
        .where('confirmedInvitations', arrayContains: documentReference)
        // .where('author', isNotEqualTo: documentReference)
        .get();
    final list = documentSnapshot2.docs.toList();
    print(list.map((x) => x.id).join(','));
    // ..addAll(documentSnapshot2.docs.toList());
    List<MeetingEntity> meetings = [];
    for (QueryDocumentSnapshot temp in list) {
      List<Future<dynamic>> promises = [];
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
      promises.add(AuthenticationRepository().findUsersByRef(invitedUserRefs).then((x) => invitedUsers = x));
      promises.add(AuthenticationRepository().findUsersByRef(acceptedUserRefs).then((x) => confirmedUsers = x));
      await Future.wait(promises);
      MeetingEntity documentSnapshotTask =
          MeetingEntity.fromJson(temp.data(), invitedUsers, confirmedUsers, temp.id, temp.reference);
      meetings.add(documentSnapshotTask);
    }
    return meetings
        .where((x) => x.selectedDate == null || x.selectedDate.toDate().isAfter(DateTime.now().stripTime()))
        .toList()
          ..sort((x, y) {
            if (x.selectedDate != null && y.selectedDate != null) {
              return x.selectedDate.toDate().compareTo(y.selectedDate.toDate());
            } else {
              if (x.selectedDate != null && y.selectedDate == null) {
                return -1;
              } else {
                return 1;
              }
            }
            // return x.startDate.toDate().isBefore(y.startDate.toDate()) ? -1 : 1;
          });
  }

  Future<void> syncGoogleCalendar(
      String meetingId, String accessToken, String timeMin, String timeMax, String userId) async {
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

  Future<void> addExtraTimeslotsAndAccept(String meetingId, String userId, List<Map<String, Object>> json) async {
    print('userId : ' + userId);
    ref.doc(meetingId).update({
      'timeslot': FieldValue.arrayUnion(json),
      'invitations': FieldValue.arrayRemove([person.doc(userId)]),
      'confirmedInvitations': FieldValue.arrayUnion([person.doc(userId)])
    });
    return;
  }

  Future<void> createZoomMeeting(String user, String meetingId, int timeLength, String topic, String startTime) async {
    print('zoom details: ' + user);
    print('zoom details: ' + meetingId);
    final response = await http.post(
      Uri.parse(
        AppConstants.createZoomUrl,
      ),
      body: jsonEncode(<String, String>{
        "user": user,
        "topic": topic,
        "startTime": startTime,
        "timeLength": timeLength.toString(),
        "id": meetingId
      }),
    );
    print(response.body);
    return;
  }

  Future<void> deleteMeeting(Meeting meeting, String id) async {
    await person.doc(id).update({
      'meeting': FieldValue.arrayRemove([meeting.ref])
    });
    await project.doc(meeting.project.id).update({
      'meeting': FieldValue.arrayRemove([meeting.ref])
    });
    print('id: ' + meeting.id);
    return ref.doc(meeting.id).delete();
  }

  Future<void> declineMeetingInvitation(String meetingId, String userId) async {
    print('user id : ' + userId);
    DocumentReference personRef = person.doc(userId);
    await ref.doc(meetingId).update({
      "invitations": FieldValue.arrayRemove([personRef])
    });
  }
}
