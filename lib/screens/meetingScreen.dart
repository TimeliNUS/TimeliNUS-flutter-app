import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:TimeliNUS/widgets/bottomNavigationBar.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';

import 'package:TimeliNUS/widgets/customCard.dart';

import 'package:TimeliNUS/utils/transitionBuilder.dart';

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
            bottomNavigationBar: BottomBar(2),
            body: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TopBar(() => {}, 'CS2103',
                    subtitle: "Software Engineering Project"),
                Expanded(
                  child: CustomCard(
                      padding: 0,
                      radius: BorderRadius.only(
                          topLeft: Radius.circular(40),
                          topRight: Radius.circular(40)),
                      child: Column(children: [
                        Padding(
                          padding: EdgeInsets.all(25),
                          child: Row(
                            children: [
                              Text("Meeting",
                                  style: TextStyle(
                                      fontSize: 24,
                                      color: appTheme.primaryColorLight)),
                              IconButton(
                                icon: Icon(Icons.add,
                                    color: appTheme.primaryColorLight),
                                onPressed: () => {},
                              )
                            ],
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          ),
                        ),
                        MeetingInvitations()
                      ])),
                ),
              ],
            )));
  }
}

class MeetingInvitations extends StatefulWidget {
  MeetingInvitations({Key key}) : super(key: key);

  @override
  _MeetingInvitatiosnState createState() => _MeetingInvitatiosnState();
}

class _MeetingInvitatiosnState extends State<MeetingInvitations> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: ThemeColor.lightOrange,
        child: Padding(
            padding: EdgeInsets.all(25),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text("Invitations",
                  textAlign: TextAlign.left,
                  style: TextStyle(fontSize: 16, color: appTheme.accentColor)),
              Padding(padding: EdgeInsets.only(bottom: 20)),
              IntrinsicHeight(
                  child: Row(mainAxisSize: MainAxisSize.max, children: [
                Expanded(
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(5),
                            bottomLeft: Radius.circular(5),
                          ),
                          color: Colors.white,
                        ),
                        // color: Colors.white,
                        child: Padding(
                            padding: EdgeInsets.all(25),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Invitation 1'),
                                  Padding(
                                    padding: EdgeInsets.only(bottom: 5),
                                  ),
                                  Row(
                                    children: [
                                      Icon(Icons.location_pin,
                                          size: 20,
                                          color: appTheme.primaryColor),
                                      Text('Zoom')
                                    ],
                                  )
                                ])))),
                Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(5),
                        bottomRight: Radius.circular(5),
                      ),
                      color: appTheme.primaryColor,
                    ),
                    child: Padding(
                        padding: EdgeInsets.all(15),
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Import\nCalendar',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.white))
                            ])))
              ]))
            ])));
  }
}
