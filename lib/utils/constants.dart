import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';

class AppConstants {
  static const String DEV_UPDATEMEETING =
      'http://localhost:5001/timelinus-2021/asia-east2/updateMeetingTimeslotByDateTime';
  static const String PROD_UPDATEMEETING =
      'https://asia-east2-timelinus-2021.cloudfunctions.net/updateMeetingTimeslotByDateTime';

  static const String DEV_FINDCOMMON = 'http://localhost:5001/timelinus-2021/asia-east2/findNusModsCommon';
  static const String PROD_FINDCOMMON = 'https://asia-east2-timelinus-2021.cloudfunctions.net/findNusModsCommon';

  static bool isSimulator = false;

  static Future<void> init() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      isSimulator = !iosDeviceInfo.isPhysicalDevice;
    } else {
      AndroidDeviceInfo androidDeviceInfo = await deviceInfo.androidInfo;
      isSimulator = !androidDeviceInfo.isPhysicalDevice;
    }
    if (isSimulator) {
      String host = defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2:8080' : 'localhost:8080';
      FirebaseFirestore.instance.settings = Settings(host: host, sslEnabled: false);
    }
  }

  static String updateMeetingUrl = (isSimulator) ? DEV_UPDATEMEETING : PROD_UPDATEMEETING;

  static String findCommonUrl = (isSimulator) ? DEV_FINDCOMMON : PROD_FINDCOMMON;
}
