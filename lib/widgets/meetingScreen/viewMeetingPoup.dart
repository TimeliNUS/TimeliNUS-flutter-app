import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/widgets/invitationDetail.dart';
import 'package:TimeliNUS/widgets/meetingScreen/timeslotView.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class ViewMeetingPopup extends StatefulWidget {
  final Meeting meeting;
  const ViewMeetingPopup(this.meeting, {Key key}) : super(key: key);

  @override
  ViewMeetingPopupState createState() => ViewMeetingPopupState();
}

class ViewMeetingPopupState extends State<ViewMeetingPopup> {
  String authorName = '';
  @override
  void initState() {
    super.initState();
    findAuthorName();
  }

  void findAuthorName() async {
    List<User> temp = await AuthenticationRepository.findUsersByRef([widget.meeting.author]);
    setState(() => authorName = temp[0].name);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredSafeArea(
        appTheme.primaryColorLight,
        Scaffold(
            body: Container(
                color: appTheme.primaryColorLight,
                child: Column(children: [
                  TopBar(
                    "View Meeting",
                    onPressedCallback: () => Navigator.pop(context),
                  ),
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.symmetric(vertical: 25, horizontal: 30),
                          // width: double.infinity,
                          // height: double.infinity,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.only(topRight: Radius.circular(40.0), topLeft: Radius.circular(40.0))),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            // Expanded(
                            //     // height: 100,
                            //     child:
                            InvitationDetail(
                              widget.meeting,
                              authorName,
                              isAccepted: true,
                            ),
                            Padding(padding: EdgeInsets.only(bottom: 5)),
                            Expanded(
                                child: TimeslotView(
                              widget.meeting.timeslots,
                              widget.meeting.startDate,
                              widget.meeting.endDate,
                              isDialog: false,
                              isConfirmed: widget.meeting.isConfirmed,
                              selectedDate: widget.meeting.selectedTimeStart,
                            ))
                            // )
                          ])))
                ]))));
  }
}
