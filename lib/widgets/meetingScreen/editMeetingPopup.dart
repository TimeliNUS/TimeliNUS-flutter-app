import 'dart:ui';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/repository/authenticationRepository.dart';
import 'package:TimeliNUS/utils/alertDialog.dart';
import 'package:TimeliNUS/widgets/meetingScreen/meetingVenueSelect.dart';
import 'package:TimeliNUS/widgets/meetingScreen/timeslotView.dart';
import 'package:TimeliNUS/widgets/overlayPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:TimeliNUS/utils/dateTimeExtension.dart';
import 'package:url_launcher/url_launcher.dart';

class EditMeetingPopup extends StatefulWidget {
  final Meeting meetingToEdit;
  final MeetingBloc meetingBloc;
  const EditMeetingPopup(this.meetingBloc, this.meetingToEdit);
  @override
  State<EditMeetingPopup> createState() => _EditMeetingPopupState();
}

class _EditMeetingPopupState extends State<EditMeetingPopup> {
  DateTime startDateValue = DateTime.now().stripTime();
  DateTime endDateValue;
  String meetingVenue;
  List<User> pics = [];
  Project selectedProject;
  DateTime selectedTime;
  bool isNeeded = false;
  TextEditingController textController = new TextEditingController();
  bool isLinkedToZoom = false;

  @override
  void initState() {
    super.initState();
    textController = new TextEditingController(text: widget.meetingToEdit.title);
    meetingVenue = widget.meetingToEdit.meetingVenue;
    AuthenticationRepository()
        .checkLinkedToZoom(context.read<AppBloc>().state.user.id)
        .then((val) => isLinkedToZoom = (val != null));
  }

  @override
  Widget build(BuildContext context) {
    String userId = context.read<AppBloc>().getCurrentUser().id;
    if (pics.isEmpty) {
      pics.add(context.select((AppBloc bloc) => bloc.state.user));
    }
    return BlocProvider<MeetingBloc>(
        create: (context) => widget.meetingBloc,
        child: ColoredSafeArea(
            appTheme.primaryColorLight,
            Scaffold(
                body: Container(
                    color: appTheme.primaryColorLight,
                    child: Column(children: [
                      TopBar(widget.meetingToEdit.invited.isEmpty ? "Confirm Meeting" : "Edit Meeting",
                          onPressedCallback: () => Navigator.pop(context),
                          rightWidget: Row(children: [
                            IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  widget.meetingBloc
                                      .add(DeleteMeeting(widget.meetingToEdit, context.read<AppBloc>().state.user.id));
                                  Navigator.pop(context);
                                }),
                            widget.meetingToEdit.invited.isEmpty
                                ? IconButton(
                                    icon: Icon(Icons.access_time, color: Colors.white),
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => TimeslotView(widget.meetingToEdit.timeslots,
                                            widget.meetingToEdit.startDate, widget.meetingToEdit.endDate,
                                            meetingLength: widget.meetingToEdit.timeLength,
                                            callback: (val) => setState(() => selectedTime = val))),
                                  )
                                : Container()
                          ])),
                      Expanded(
                          child: GestureDetector(
                              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40.0), topLeft: Radius.circular(40.0))),
                                  child: Padding(
                                      padding: EdgeInsets.only(left: 30, right: 30, top: 15),
                                      child: ListView(
                                        children: [
                                          // TopBar(),
                                          PopupInput(textController,
                                              inputLabel: 'Meeting Title',
                                              errorMsg: 'Please enter your meeting title!'),
                                          customPadding(),
                                          PopupDropdown(
                                              initialProject: widget.meetingToEdit.project,
                                              dropdownLabel: 'Module Project',
                                              isDisabled: true,
                                              callback: (val) => {setState(() => selectedProject = val)}),
                                          customPadding(),
                                          PersonInChargeChips(pics, "Person in Charge", project: selectedProject,
                                              callback: (val) {
                                            setState(() => pics = val);
                                          }),
                                          customPadding(),
                                          // constraints: BoxConstraints.expand(height: 200)),
                                          Text(
                                            'Meeting must be within...*',
                                          ),
                                          Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                SizedBox(
                                                    width: 50,
                                                    height: 28,
                                                    child: Text(
                                                      'From:',
                                                    )),
                                                Expanded(
                                                    child: DeadlineInput(
                                                  (val) => setState(() => startDateValue = val),
                                                  false,
                                                  true,
                                                  isNotMini: false,
                                                  isDisabled: true,
                                                  initialTime: widget.meetingToEdit.startDate,
                                                )),
                                              ]),
                                          Row(
                                            children: [
                                              SizedBox(
                                                  width: 50,
                                                  height: 14,
                                                  child: Text(
                                                    'to:',
                                                  )),
                                              Expanded(
                                                  child: DeadlineInput(
                                                (val) => setState(() => endDateValue = val),
                                                false,
                                                true,
                                                isNotMini: false,
                                                isDisabled: true,
                                                initialTime: widget.meetingToEdit.endDate,
                                              )),
                                            ],
                                          ),
                                          customPadding(),
                                          Text(
                                            'Meeting Venue*',
                                          ),
                                          MeetingVenueSelect(null, null, widget.meetingToEdit.meetingVenue,
                                              isDisabled: true, isOnline: widget.meetingToEdit.isOnlineVenue),
                                          customPadding(),
                                          Text('Selected datetime: \n' +
                                              (selectedTime != null
                                                  ? DateFormat.yMMMd().add_jm().format(selectedTime)
                                                  : 'None')),
                                          widget.meetingToEdit.invited.isEmpty &&
                                                  widget.meetingToEdit.meetingVenue == 'Zoom'
                                              ? Row(children: [
                                                  Text('Create Zoom Meeting automatically: '),
                                                  Checkbox(
                                                    value: isNeeded,
                                                    onChanged: (boolean) {
                                                      setState(() => isNeeded = boolean);
                                                      print('isLinked : ' + isLinkedToZoom.toString());
                                                    },
                                                  )
                                                ])
                                              : Container()
                                        ],
                                      ))))),
                      Container(
                        color: Colors.white,
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                (isLinkedToZoom || !isNeeded)
                                    ? ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<Color>(appTheme.primaryColorLight)),
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text("Done",
                                                style: appTheme.textTheme.bodyText2.apply(color: Colors.white))),
                                        onPressed: () {
                                          if (textController.text != '' &&
                                              (widget.meetingToEdit.invited.isNotEmpty || selectedTime != null)) {
                                            widget.meetingBloc.add(UpdateMeeting(
                                                widget.meetingToEdit.copyWith(
                                                    title: textController.text,
                                                    groupmates: pics,
                                                    meetingVenue: meetingVenue,
                                                    project: selectedProject,
                                                    startDate: startDateValue,
                                                    endDate: endDateValue,
                                                    isConfirmed: !widget.meetingToEdit.invited.isNotEmpty,
                                                    selectedTimeStart: selectedTime),
                                                userId,
                                                createZoomMeeting: isNeeded));
                                            Navigator.pop(context);
                                          } else {
                                            customAlertDialog(context,
                                                message: (widget.meetingToEdit.invited.isEmpty && selectedTime == null)
                                                    ? 'Meeting time need to be selected using the top right corner button!'
                                                    : null);
                                          }
                                        })
                                    : ElevatedButton(
                                        style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<Color>(appTheme.primaryColorLight)),
                                        onPressed: () {
                                          final url = Uri.encodeFull(
                                              'https://zoom.us/oauth/authorize?response_type=code&client_id=5NM6HEpT4CWNO0zQ9s0fg&redirect_uri=https://asia-east2-timelinus-2021.cloudfunctions.net/zoomAuth&state={"client":"mobile", "id": "${context.read<AppBloc>().state.user.id}"}');
                                          launch(url, forceSafariVC: true);
                                          Navigator.pop(context);
                                        },
                                        child: Padding(
                                            padding: EdgeInsets.symmetric(horizontal: 10),
                                            child: Text("Link your Zoom Account",
                                                style: appTheme.textTheme.bodyText2.apply(color: Colors.white))))
                              ],
                            )),
                      )
                    ])))));
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 30));
