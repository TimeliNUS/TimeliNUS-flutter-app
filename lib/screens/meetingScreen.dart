import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/app/appEvent.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/widgets/meetingScreen/editMeetingPopup.dart';
import 'package:TimeliNUS/widgets/meetingScreen/newMeetingPopup.dart';
import 'package:TimeliNUS/widgets/meetingScreen/viewMeetingPoup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'package:TimeliNUS/widgets/bottomNavigationBar.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';

import 'package:TimeliNUS/widgets/customCard.dart';

import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../widgets/style.dart';

class MeetingScreen extends StatefulWidget {
  final String projectId;
  final String projectTitle;
  static Page page(String projectId, String projectTitle) =>
      MaterialPage(child: MeetingScreen(projectId: projectId, projectTitle: projectTitle));
  const MeetingScreen({this.projectId, this.projectTitle, Key key}) : super(key: key);
  @override
  _MeetingScreenState createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final _meetingRepository = MeetingRepository();
  @override
  Widget build(BuildContext context) {
    final id = context.select((AppBloc bloc) => bloc.state.user.id);
    return BlocProvider<MeetingBloc>(
        create: (context) => MeetingBloc(_meetingRepository)
          ..add(LoadMeetings((widget.projectId != null) ? widget.projectId : id,
              isSearchByProject: (widget.projectId != null) ? true : false)),
        child: BlocBuilder<MeetingBloc, MeetingState>(builder: (context, state) {
          return ColoredSafeArea(
              appTheme.primaryColorLight,
              Scaffold(
                  backgroundColor: appTheme.primaryColorLight,
                  bottomNavigationBar: widget.projectId != null ? null : BottomBar(3),
                  body: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TopBar(widget.projectId != null ? ('Project: ' + widget.projectTitle) : 'My Meetings',
                          onPressedCallback: () => context.read<AppBloc>().add(AppOnProject()),
                          subtitle: "Invitations and Upcoming"),
                      Expanded(
                        child: CustomCard(
                            padding: 0,
                            radius: BorderRadius.only(topLeft: Radius.circular(40), topRight: Radius.circular(40)),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                                child: Row(
                                  children: [
                                    Text("Meeting", style: TextStyle(fontSize: 24, color: appTheme.primaryColorLight)),
                                    IconButton(
                                      icon: Icon(Icons.add, color: appTheme.primaryColorLight),
                                      onPressed: () {
                                        Navigator.push(context,
                                            SlideRightRoute(page: NewMeetingPopup(context.read<MeetingBloc>())));
                                      },
                                    )
                                  ],
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                ),
                              ),
                              MeetingInvitations(),
                              Padding(
                                  padding: EdgeInsets.only(left: 25, top: 25, bottom: 10),
                                  child: Text("Upcoming Meetings",
                                      textAlign: TextAlign.left,
                                      style: TextStyle(fontSize: 16, color: appTheme.accentColor))),
                              Expanded(child: SingleChildScrollView(child: UpcomingMeetings(state.meetings))),
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
        padding: EdgeInsets.all(25),
        child: SingleChildScrollView(
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch,
                // mainAxisSize: MainAxisSize.min,
                // mainAxisAlignment: MainAxisAlignment.start,
                children: [
              Text((context.read<MeetingBloc>().state.invitations.length == 0 ? "No " : "") + "Invitations",
                  textAlign: TextAlign.left, style: TextStyle(fontSize: 16, color: appTheme.accentColor)),
              // Expanded(child: ListView()),
              ...context
                  .read<MeetingBloc>()
                  .state
                  .invitations
                  .map((invitation) => GestureDetector(
                      onTap: () => context.read<AppBloc>().add(AppOnInvitation(invitationId: invitation.id)),
                      child: Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: IntrinsicHeight(
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
                                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                          Text(invitation.title),
                                          Padding(
                                            padding: EdgeInsets.only(bottom: 5),
                                          ),
                                          Row(
                                            children: [
                                              Icon(Icons.location_pin, size: 20, color: appTheme.primaryColor),
                                              Text(invitation.meetingVenue)
                                              // .toString().split('.')[1])
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
                                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                      Text('Import\nCalendar',
                                          textAlign: TextAlign.center, style: TextStyle(color: Colors.white))
                                    ])))
                          ])))))
                  .toList()
            ])));
  }
}

class UpcomingMeetings extends StatefulWidget {
  final List<Meeting> meetings;
  const UpcomingMeetings(this.meetings, {Key key}) : super(key: key);

  @override
  _UpcomingMeetingsState createState() => _UpcomingMeetingsState();
}

class _UpcomingMeetingsState extends State<UpcomingMeetings> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: 25),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          CustomPadding(),
          ...(widget.meetings.map((meeting) => GestureDetector(
              onTap: () {
                print(meeting);
                Navigator.push(
                    context,
                    SlideRightRoute(
                        page: ((meeting.author != context.read<AppBloc>().state.user.ref) ||
                                (meeting.isConfirmed && meeting.invited.length == 0))
                            ? ViewMeetingPopup(meeting)
                            : EditMeetingPopup(context.read<MeetingBloc>(), meeting)));
              },
              child: Padding(
                  padding: EdgeInsets.only(bottom: 15),
                  child: IntrinsicHeight(
                      child:
                          Row(mainAxisSize: MainAxisSize.max, crossAxisAlignment: CrossAxisAlignment.center, children: [
                    Expanded(
                        child: Container(
                            // constraints: BoxConstraints.expand(),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  bottomLeft: Radius.circular(20),
                                ),
                                boxShadow: [
                                  BoxShadow(color: appTheme.primaryColor, spreadRadius: 0.5, blurRadius: 0.5)
                                ],
                                color: Colors.white),
                            // color: Colors.white,
                            child: Row(children: [
                              Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 15),
                                  child: Text((meeting.isConfirmed
                                      ? ((timeago.format(meeting.selectedTimeStart,
                                                      allowFromNow: true, locale: 'en_short') ==
                                                  'now'
                                              ? ''
                                              : 'In ') +
                                          timeago.format(meeting.selectedTimeStart,
                                              allowFromNow: true, locale: 'en_short'))
                                      : "TBC"))),
                              Padding(
                                  padding: EdgeInsets.symmetric(vertical: 25),
                                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Text(meeting.title),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.alarm, size: 20, color: appTheme.primaryColor),
                                        Text(meeting.isConfirmed
                                            ? (' ' +
                                                (DateFormat('K:mm').format(meeting.selectedTimeStart)).toLowerCase() +
                                                ' - ' +
                                                DateFormat.jm()
                                                    .format(meeting.selectedTimeStart
                                                        .add(Duration(minutes: meeting.timeLength)))
                                                    .toLowerCase())
                                            : (' Within ' +
                                                (DateFormat.jm().format(meeting.startDate)).toLowerCase() +
                                                ' - ' +
                                                (DateFormat.jm().format(meeting.endDate)).toLowerCase()))
                                      ],
                                    ),
                                    Padding(
                                      padding: EdgeInsets.only(bottom: 5),
                                    ),
                                    Row(
                                      children: [
                                        Icon(Icons.location_pin, size: 20, color: appTheme.primaryColor),
                                        Text(' ' + meeting.meetingVenue
                                            // .toString()
                                            // .split('.')[1]
                                            // .replaceAllMapped(RegExp('([A-Z])'), (Match m) => ' ${m[0]}')
                                            // .trim()
                                            )
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
                            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                              Text('View\nDetails', textAlign: TextAlign.center, style: TextStyle(color: Colors.white))
                            ])))
                  ]))))))
        ]));
  }
}
