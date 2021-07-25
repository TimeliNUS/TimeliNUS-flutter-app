import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/models/meetingEntity.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

import '../integration/services/firebase/firebase_auth_test.dart';

void main() {
  setupCloudFirestoreMocks();
  Map<String, Object> json;
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    json = {
      'title': 'title',
      'id': 'id',
      'timeLength': 0,
      'meetingVenue': 'Zoom',
      'groupmates': [FirebaseFirestore.instance.collection('user').doc('userId')],
      'author': FirebaseFirestore.instance.collection('user').doc('userId'),
      'project': null,
      'startDate': null,
      'endDate': null,
      'selectedDate': null,
      'isConfirmed': null,
      'isOnlineVenue': null,
      'timeslot': [],
      'invitations': [],
      'confirmedInvitations': []
    };
  });
  test('Convert JSON to meetingEntityy', () {
    final meeting = MeetingEntity.fromJson(json, [], []);

    Meeting actualMeeting = Meeting('title', [], 'Zoom', null, id: 'id', timeLength: 0);
    expect(actualMeeting, Meeting.fromEntity(meeting));
  });

  test('Convert meetingEntity to JSON', () {
    MeetingEntity actualMeeting = MeetingEntity(
        'title',
        'id',
        0,
        null,
        null,
        FirebaseFirestore.instance.collection('user').doc('userId'),
        [User(id: 'userId', ref: FirebaseFirestore.instance.collection('user').doc('userId'), name: 'userId')],
        [],
        [],
        'Zoom',
        null,
        null,
        [],
        null,
        null,
        null,
        null);
    expect(json, actualMeeting.toJson());
  });
}
