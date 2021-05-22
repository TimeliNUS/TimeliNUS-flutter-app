import 'package:TimeliNUS/screens/landingScreen.dart';
import 'package:TimeliNUS/utils/services/firebase.dart';
import 'package:TimeliNUS/widgets/style.dart';
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
    await FirebaseService.switchToEmulator();
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: appTheme,
      home: LandingScreen(),
    );
  }
}
