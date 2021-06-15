import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../widgets/style.dart';

class MeetingScreen extends StatefulWidget {
  static Page page() => MaterialPage(child: MeetingScreen());
  MeetingScreen({Key key}) : super(key: key);
  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  @override
  Widget build(BuildContext context) {
    return ColoredSafeArea(
        appTheme.primaryColorLight,
        Scaffold(
            backgroundColor: appTheme.primaryColorLight,
            body: Container(
              child: null,
            )));
  }
}
