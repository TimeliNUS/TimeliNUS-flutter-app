import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/blocs/screens/project/projectBloc.dart';
import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/repository/projectRepository.dart';
import 'package:TimeliNUS/widgets/meetingScreen/newMeetingPopup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:TimeliNUS/widgets/bottomNavigationBar.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';

import 'package:TimeliNUS/widgets/customCard.dart';

import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../widgets/style.dart';

class MeetingScreen extends StatefulWidget {
  static Page page() => MaterialPage(child: MeetingScreen());
  MeetingScreen({Key key}) : super(key: key);
  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final _meetingRepository = MeetingRepository();

  @override
  Widget build(BuildContext context) {
    final id = context.select((AppBloc bloc) => bloc.state.user.id);
    return BlocProvider<MeetingBloc>(
        create: (context) =>
            MeetingBloc(_meetingRepository)..add(LoadMeetings(id)),
        child:
            BlocBuilder<MeetingBloc, MeetingState>(builder: (context, state) {
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
                                      onPressed: () {
                                        Navigator.push(
                                            context,
                                            SlideRightRoute(
                                                page: NewMeetingPopup(context
                                                    .read<MeetingBloc>())));
                                      },
                                    )
                                  ],
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                ),
                              ),
                              MeetingInvitations(),
                              UpcomingMeetings(state.meetings),
                            ])),
                      ),
                    ],
                  )));
        }));
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
                            topLeft: Radius.circular(20),
                            bottomLeft: Radius.circular(20),
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
                        topRight: Radius.circular(20),
                        bottomRight: Radius.circular(20),
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

class UpcomingMeetings extends StatefulWidget {
  List<Meeting> meetings;
  UpcomingMeetings(this.meetings, {Key key}) : super(key: key);

  @override
  _UpcomingMeetingsState createState() => _UpcomingMeetingsState();
}

class _UpcomingMeetingsState extends State<UpcomingMeetings> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Upcoming Meetings",
              textAlign: TextAlign.left,
              style: TextStyle(fontSize: 16, color: appTheme.accentColor)),
          CustomPadding(),
          ...(widget.meetings.map((meeting) => Padding(
              padding: EdgeInsets.only(bottom: 15),
              child: IntrinsicHeight(
                  child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                    Expanded(
                        child: Container(
                            // constraints: BoxConstraints.expand(),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                      color: appTheme.primaryColor,
                                      spreadRadius: 0.5,
                                      blurRadius: 0.5)
                                ],
                                color: Colors.white),
                            // color: Colors.white,
                            child: Row(children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text('Today')),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25),
                                  child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(meeting.title),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 5),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.alarm,
                                                size: 20,
                                                color: appTheme.primaryColor),
                                            Text("2:00 - 3:00 pm")
                                          ],
                                        ),
                                        Padding(
                                          padding: EdgeInsets.only(bottom: 5),
                                        ),
                                        Row(
                                          children: [
                                            Icon(Icons.location_pin,
                                                size: 20,
                                                color: appTheme.primaryColor),
                                            Text(meeting.meetingVenue
                                                .toString()
                                                .split('.')[1]
                                                .replaceAllMapped(
                                                    RegExp('([A-Z])'),
                                                    (Match m) => ' ${m[0]}')
                                                .trim())
                                          ],
                                        )
                                      ]))
                            ]))),
                    Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(20),
                            bottomRight: Radius.circular(20),
                          ),
                          color: appTheme.primaryColor,
                        ),
                        child: Padding(
                            padding: EdgeInsets.all(15),
                            child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('Join Now',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white))
                                ])))
                  ])))))
        ]));
  }
}
