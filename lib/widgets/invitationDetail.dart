import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/screens/invitationScreen.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class InvitationDetail extends StatelessWidget {
  final Meeting meeting;
  final Project project;
  final String authorName;
  final bool isAccepted;
  const InvitationDetail(this.meeting, this.authorName, {this.isAccepted = false, this.project, Key key})
      : super(key: key);

  // Future<String> getAuthorName() async {
  //   return AuthenticationRepository.findUsersByRef([meeting.author]).then((x) => x[0].name);
  // }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            boxShadow: [BoxShadow(color: appTheme.primaryColor, spreadRadius: 0.5, blurRadius: 0.5)],
            color: Colors.white),
        child: project != null
            ? Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(project.title ?? ''),
                    customPadding(),
                    Divider(
                      color: appTheme.primaryColorLight,
                      thickness: 1.25,
                    ),
                    customPadding(),
                    // Text('Project created by: ' + authorName),
                    customPadding(),
                    (Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Confirmed Users: ' +
                          project.confirmed.map((x) => x.name).join(', ') +
                          (project.invited.length == 0 ? ' (All confirmed)' : '')),
                      customPadding(),
                      project.invited.length != 0
                          ? Container(
                              child: Text(
                                  'Invited Users (Not confirmed): ' + project.invited.map((x) => x.name).join(', ')),
                              padding: EdgeInsets.only(bottom: 10))
                          : Container(),
                    ])),
                    customPadding(),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 18, color: appTheme.primaryColorLight),
                        Text(' Deadline: ' + DateFormat('MMM dd, yyyy').format(project.deadline))
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 7.5)),
                  ],
                ))
            : Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meeting.title ?? ''),
                    customPadding(),
                    Text(meeting.project != null ? meeting.project.title : ''),
                    customPadding(),
                    Divider(
                      color: appTheme.primaryColorLight,
                      thickness: 1.25,
                    ),
                    customPadding(),
                    Text('Meeting created by: ' + authorName),
                    customPadding(),
                    isAccepted
                        ? (Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Confirmed Users: ' +
                                meeting.confirmed.map((x) => x.name).join(', ') +
                                (meeting.invited.length == 0 ? ' (All confirmed)' : '')),
                            customPadding(),
                            meeting.invited.length != 0
                                ? Container(
                                    child: Text('Invited Users (Not confirmed): ' +
                                        meeting.invited.map((x) => x.name).join(', ')),
                                    padding: EdgeInsets.only(bottom: 10))
                                : Container(),
                          ]))
                        : Container(),
                    Text('Meeting is within:'),
                    customPadding(),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_outlined, size: 18, color: appTheme.primaryColorLight),
                        Text(' ' +
                            DateFormat('MMM dd, yyyy').format(meeting.startDate) +
                            ' - ' +
                            DateFormat('MMM dd, yyyy').format(meeting.endDate))
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 7.5)),
                    Row(
                      children: [
                        Icon(Icons.av_timer_rounded, size: 18, color: appTheme.primaryColorLight),
                        Text(' ' +
                            DateFormat('kk:mm').format(meeting.startDate) +
                            ' - ' +
                            DateFormat('kk:mm').format(meeting.endDate)),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 7.5)),
                    Row(
                      children: [
                        Icon(Icons.location_pin, size: 18, color: appTheme.primaryColorLight),
                        Text(' ' + meeting.meetingVenue)
                        // .toString().split('.')[1]),
                      ],
                    ),
                    Padding(padding: EdgeInsets.only(bottom: 7.5)),
                    !(meeting.isOnlineVenue)
                        ? Divider(color: appTheme.primaryColor, thickness: 0.5, height: 20)
                        : Container(),
                    !(meeting.isOnlineVenue)
                        ? InkWell(
                            onTap: () => launch(Uri.encodeFull("https://aces.nus.edu.sg/fbs/HomeServlet")),
                            child: Text("Click here to go to NUS facility booking service",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  // color: Colors.blue
                                )))
                        : Container(),
                    meeting.meetingLink != null
                        ? Container(
                            padding: EdgeInsets.only(top: 10),
                            child: InkWell(
                                onTap: () => launch(meeting.meetingLink),
                                child: Text('Link: ' + meeting.meetingLink.substring(0, 37) + '...',
                                    softWrap: true, style: TextStyle(fontWeight: FontWeight.bold))))
                        : Container()
                  ],
                )));
  }
}
