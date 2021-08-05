import 'dart:ui';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/widgets/meetingScreen/timeslotView.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/utils/alertDialog.dart';
import 'package:TimeliNUS/widgets/meetingScreen/meetingVenueSelect.dart';
import 'package:TimeliNUS/widgets/overlayPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:TimeliNUS/utils/dateTimeExtension.dart';
import 'package:intl/intl.dart';

class NewMeetingPopup extends StatefulWidget {
  final MeetingBloc projectBloc;
  const NewMeetingPopup(this.projectBloc);
  @override
  State<NewMeetingPopup> createState() => _NewMeetingPopupState();
}

class _NewMeetingPopupState extends State<NewMeetingPopup> {
  DateTime startDateValue = DateTime.now().stripTime();
  DateTime endDateValue = DateTime.now().stripTime();
  String meetingVenue = "";
  bool isOnlineVenue = false;
  bool isDirectCreate = false;
  int timeLength = 60;
  List<User> pics = [];
  Project selectedProject;
  DateTime selectedTime;

  final TextEditingController textController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    String userId = context.read<AppBloc>().getCurrentUser().id;
    if (pics.isEmpty) {
      pics.add(context.select((AppBloc bloc) => bloc.state.user));
    }
    return BlocProvider<MeetingBloc>(
        create: (context) => widget.projectBloc,
        child: ColoredSafeArea(
            appTheme.primaryColorLight,
            Scaffold(
                body: Container(
                    color: appTheme.primaryColorLight,
                    child: Column(children: [
                      TopBar(
                        "Create Meeting",
                        onPressedCallback: () => Navigator.pop(context),
                      ),
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
                                              dropdownLabel: 'Module Project',
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
                                                    child: Padding(
                                                        padding: EdgeInsets.only(right: 2),
                                                        child: DeadlineInput(
                                                          (val) => setState(() => startDateValue = val),
                                                          false,
                                                          true,
                                                          isNotMini: false,
                                                        ))),
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
                                                  child: Padding(
                                                      padding: EdgeInsets.only(right: 2),
                                                      child: DeadlineInput(
                                                        (val) => setState(() => endDateValue = val),
                                                        false,
                                                        true,
                                                        isNotMini: false,
                                                      ))),
                                            ],
                                          ),
                                          isDirectCreate
                                              ? Padding(
                                                  padding: EdgeInsets.only(top: 15),
                                                  child:
                                                      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                                                    Text('Selected datetime: ' +
                                                        (selectedTime != null
                                                            ? DateFormat.yMMMd().add_jm().format(selectedTime)
                                                            : 'None')),
                                                    ElevatedButton(
                                                      child: Text('Select Date and Time for meeting'),
                                                      style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all<Color>(
                                                              appTheme.primaryColorLight)),
                                                      onPressed: () => (startDateValue != null &&
                                                              endDateValue != null &&
                                                              endDateValue.isAfter(startDateValue) &&
                                                              endDateValue.hour >= startDateValue.hour)
                                                          ? showDialog(
                                                              context: context,
                                                              builder: (context) => TimeslotView(
                                                                  [], startDateValue, endDateValue,
                                                                  meetingLength: timeLength,
                                                                  callback: (val) =>
                                                                      setState(() => selectedTime = val)))
                                                          : customAlertDialog(context,
                                                              message: endDateValue.isAfter(startDateValue)
                                                                  ? (endDateValue.hour >= startDateValue.hour
                                                                      ? null
                                                                      : 'End hour must be after start hour')
                                                                  : 'End date must be after start date'),
                                                    ),
                                                  ]))
                                              : Container(),
                                          customPadding(),
                                          Text(
                                            'Meeting Venue*',
                                          ),
                                          MeetingVenueSelect((val) => setState(() => meetingVenue = val),
                                              (boolean) => setState(() => isOnlineVenue = boolean), meetingVenue),
                                          // Padding(padding: EdgeInsets.only(top: 10)),
                                          Row(children: [
                                            SizedBox(
                                                height: 44.0,
                                                width: 24.0,
                                                child: Container(
                                                    child: Checkbox(
                                                  onChanged: (val) => setState(() {
                                                    isDirectCreate = val;
                                                    if (val == false) selectedTime = null;
                                                  }),
                                                  value: isDirectCreate,
                                                ))),
                                            Text('Create meeting without confirmation required')
                                          ])
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
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor: MaterialStateProperty.all<Color>(appTheme.primaryColorLight)),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 10),
                                        child: Text("Done",
                                            style: appTheme.textTheme.bodyText2.apply(color: Colors.white))),
                                    onPressed: () {
                                      if (textController.text != '' &&
                                          (selectedProject != null &&
                                              selectedProject.title != 'Please select a project!') &&
                                          endDateValue.hour >= startDateValue.hour &&
                                          endDateValue.isAfter(startDateValue) &&
                                          endDateValue != null &&
                                          (isOnlineVenue || meetingVenue != '') &&
                                          (selectedTime != null || !isDirectCreate)) {
                                        widget.projectBloc
                                          ..add(AddMeeting(
                                              Meeting(textController.text, pics, meetingVenue, selectedProject,
                                                  startDate: startDateValue,
                                                  endDate: endDateValue,
                                                  isConfirmed: isDirectCreate,
                                                  invited: isDirectCreate ? [] : pics,
                                                  confirmed: isDirectCreate ? pics : [],
                                                  timeslots: [],
                                                  selectedTimeStart: isDirectCreate ? selectedTime : null,
                                                  isOnlineVenue: isOnlineVenue),
                                              userId))
                                          ..add(LoadMeetings(context.read<AppBloc>().state.user.id));
                                        Navigator.pop(context);
                                      } else {
                                        customAlertDialog(context,
                                            message: (selectedTime == null && isDirectCreate)
                                                ? 'Please select the meeting time'
                                                : endDateValue.isAfter(startDateValue)
                                                    ? (endDateValue.hour >= startDateValue.hour
                                                        ? null
                                                        : 'End hour must be after start hour')
                                                    : 'End date must be after start date');
                                      }
                                    })
                              ],
                            )),
                      )
                    ])))));
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 40));
