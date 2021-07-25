import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/models/meetingEntity.dart';
import 'package:TimeliNUS/models/project.dart';
import 'package:TimeliNUS/models/projectEntity.dart';
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
      'id': 'id',
      'moduleCode': 'moduleCode',
      'title': 'title',
      'progress': 0.0,
      'groupmates': [],
      'deadline': null
    };
  });
  test('Convert JSON to projectEntity', () {
    final project = ProjectEntity.fromJson(
        json, [], [], [], [], 'id', FirebaseFirestore.instance.collection('project').doc('testId'));
    Project actualMeeting = Project('title',
        id: 'id',
        moduleCode: 'moduleCode',
        progress: 0,
        ref: FirebaseFirestore.instance.collection('project').doc('testId'));
    expect(actualMeeting, Project.fromEntity(project));
  });

  test('Convert projectEntity to JSON', () {
    ProjectEntity actualProject = ProjectEntity(
      'title',
      'moduleCode',
      'id',
      0,
      null,
      [],
      0,
      [],
      [],
      [],
      FirebaseFirestore.instance.collection('user').doc('userId'),
    );
    expect(json, actualProject.toJson());
  });
}
