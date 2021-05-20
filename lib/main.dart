import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:device_info/device_info.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  // AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  // print('Is emulator: ${androidInfo.isPhysicalDevice}');

  IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  await Firebase.initializeApp();
  if (!iosInfo.isPhysicalDevice) {
    await FirebaseAuth.instance.useEmulator('http://localhost:9099');
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LandingScreen(),
    );
  }
}
