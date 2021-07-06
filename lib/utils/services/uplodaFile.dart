import 'dart:io';
import 'package:path/path.dart';

import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadImageToFirebase(File imageFile) async {
  String fileName = basename(imageFile.path);
  Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('ProfilePicture/$fileName');
  UploadTask uploadTask = firebaseStorageRef.putFile(imageFile);
  TaskSnapshot taskSnapshot = await uploadTask;
  return await taskSnapshot.ref.getDownloadURL();
}
