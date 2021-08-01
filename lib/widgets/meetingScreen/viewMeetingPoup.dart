import 'package:TimeliNUS/models/meeting.dart';
import 'package:TimeliNUS/models/userModel.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/repository/meetingRepository.dart';
import 'package:TimeliNUS/widgets/invitationDetail.dart';
import 'package:TimeliNUS/widgets/meetingScreen/timeslotView.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/url_launcher.dart';

class ViewMeetingPopup extends StatefulWidget {
  final Meeting meeting;
  const ViewMeetingPopup(this.meeting, {Key key}) : super(key: key);

  @override
  ViewMeetingPopupState createState() => ViewMeetingPopupState();
}

class ViewMeetingPopupState extends State<ViewMeetingPopup> {
  String authorName = '';
  bool isEditingLink = false;
  String link;
  TextEditingController controller;

  @override
  void initState() {
    super.initState();
    findAuthorName();
    controller = new TextEditingController(text: widget.meeting.meetingLink);
  }

  void findAuthorName() async {
    List<User> temp = await AuthenticationRepository().findUsersByRef([widget.meeting.author]);
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
                              authorName ?? 'No author found',
                              isAccepted: true,
                            ),
                            !(widget.meeting.isOnlineVenue)
                                ? Divider(color: appTheme.primaryColor, thickness: 0.5, height: 20)
                                : Container(),
                            !(widget.meeting.isOnlineVenue)
                                ? InkWell(
                                    onTap: () => launch(Uri.encodeFull("https://aces.nus.edu.sg/fbs/ADFSLogin")),
                                    child: Text("Click here to go to NUS facility booking service",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          // color: Colors.blue
                                        )))
                                : Container(),
                            widget.meeting.isOnlineVenue
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text("Meeting Link",
                                          style: TextStyle(fontSize: 16, height: 3, fontWeight: FontWeight.bold)),
                                      widget.meeting.meetingLink != null
                                          ? Container(
                                              padding: EdgeInsets.only(top: 10),
                                              child: InkWell(
                                                  onTap: () => launch(widget.meeting.meetingLink),
                                                  child: Text(
                                                      'Link: ' +
                                                          (widget.meeting.meetingLink.length > 38
                                                              ? (widget.meeting.meetingLink.substring(0, 37) + '...')
                                                              : widget.meeting.meetingLink),
                                                      softWrap: true,
                                                      style: TextStyle(fontWeight: FontWeight.bold))))
                                          : Container(),
                                      ElevatedButton(
                                          style: ButtonStyle(
                                              backgroundColor: MaterialStateProperty.all(appTheme.primaryColorLight)),
                                          onPressed: () => setState(() {
                                                isEditingLink = true;
                                                controller.text = link ?? widget.meeting.meetingLink;
                                              }),
                                          child: Text(
                                            "Edit Meeting Link",
                                          )),
                                    ],
                                  )
                                : Container(),
                            isEditingLink
                                ? Container(
                                    decoration: BoxDecoration(
                                        border: Border(bottom: BorderSide(color: appTheme.accentColor, width: 1.0))),
                                    child: Row(children: [
                                      Expanded(
                                        child: TextFormField(
                                            decoration: InputDecoration(border: InputBorder.none),
                                            controller: controller,
                                            onChanged: (newValue) => setState(() => link = newValue)
                                            // initialValue: link,
                                            ),
                                      ),
                                      IconButton(
                                          icon: Icon(Icons.check, color: appTheme.primaryColorLight),
                                          onPressed: () {
                                            setState(() => isEditingLink = false);
                                            MeetingRepository()
                                                .updateMeeting(widget.meeting.copyWith(meetingLink: link).toEntity());
                                          })
                                    ]))
                                : Container(),
                            // Padding(padding: EdgeInsets.only(bottom: 5)),
                            // Expanded(
                            //     child: TimeslotView(
                            //   widget.meeting.timeslots,
                            //   widget.meeting.startDate,
                            //   widget.meeting.endDate,
                            //   isDialog: false,
                            //   meetingLength: widget.meeting.timeLength,
                            //   isConfirmed: widget.meeting.isConfirmed,
                            //   selectedDate: widget.meeting.selectedTimeStart,
                            // ))
                            // )
                          ])))
                ]))));
  }
}
