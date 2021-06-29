import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/screens/invitationScreen.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

class InvitationDetail extends StatelessWidget {
  final Meeting meeting;
  final String authorName;
  final bool isAccepted;
  const InvitationDetail(this.meeting, this.authorName,
      {this.isAccepted = false, Key key})
      : super(key: key);

  Future<String> getAuthorName() async {
    return AuthenticationRepository.findUsersByRef([meeting.author])
        .then((x) => x[0].name);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                  color: appTheme.primaryColor,
                  spreadRadius: 0.5,
                  blurRadius: 0.5)
            ],
            color: Colors.white),
        child: Padding(
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
                    ? (Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                            Text('Confirmed Users: ' +
                                meeting.confirmed
                                    .map((x) => x.name)
                                    .join(', ')),
                            customPadding(),
                            Text('Invited Users (Not confirmed): ' +
                                meeting.invited.map((x) => x.name).join(', ')),
                            customPadding()
                          ]))
                    : Container(),
                Text('Meeting is within:'),
                customPadding(),
                Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: appTheme.primaryColorLight),
                    Text(' ' +
                        DateFormat('MMM dd, yyyy').format(meeting.startDate) +
                        ' - ' +
                        DateFormat('MMM dd, yyyy').format(meeting.endDate))
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 7.5)),
                Row(
                  children: [
                    Icon(Icons.av_timer_rounded,
                        size: 18, color: appTheme.primaryColorLight),
                    Text(' ' +
                        DateFormat('kk:mm').format(meeting.startDate) +
                        ' - ' +
                        DateFormat('kk:mm').format(meeting.endDate)),
                  ],
                ),
                Padding(padding: EdgeInsets.only(bottom: 7.5)),
                Row(
                  children: [
                    Icon(Icons.location_pin,
                        size: 18, color: appTheme.primaryColorLight),
                    Text(' ' + meeting.meetingVenue.toString().split('.')[1]),
                  ],
                )
              ],
            )));
  }
}
