import 'dart:ui';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/utils/transitionBuilder.dart';
import 'package:TimeliNUS/widgets/meetingScreen/timeslotView.dart';
import 'package:TimeliNUS/widgets/overlayPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EditMeetingPopup extends StatefulWidget {
  final Meeting meetingToEdit;
  final MeetingBloc meetingBloc;
  const EditMeetingPopup(this.meetingBloc, this.meetingToEdit);
  @override
  State<EditMeetingPopup> createState() => _EditMeetingPopupState();
}

class _EditMeetingPopupState extends State<EditMeetingPopup> {
  DateTime startDateValue;
  DateTime endDateValue;
  MeetingVenue meetingVenue;
  List<User> pics = [];
  Project selectedProject;
  TextEditingController textController = new TextEditingController();

  @override
  void initState() {
    super.initState();
    textController =
        new TextEditingController(text: widget.meetingToEdit.title);
    meetingVenue = widget.meetingToEdit.meetingVenue;
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
                      TopBar(() => Navigator.pop(context), "Edit Meeting",
                          rightWidget: Row(children: [
                            IconButton(
                                icon: Icon(Icons.delete, color: Colors.white),
                                onPressed: () {
                                  widget.meetingBloc.add(DeleteMeeting(
                                      widget.meetingToEdit,
                                      context.read<AppBloc>().state.user.id));
                                  Navigator.pop(context);
                                }),
                            OutlinedButton(
                                onPressed: () => showDialog(
                                    context: context,
                                    builder: (context) => TimeslotView(
                                        widget.meetingToEdit.timeslots,
                                        widget.meetingToEdit.startDate,
                                        widget.meetingToEdit.endDate)),
                                child: Text('hi'))
                          ])),
                      Expanded(
                          child: GestureDetector(
                              onTap: () =>
                                  FocusManager.instance.primaryFocus?.unfocus(),
                              child: Container(
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(40.0),
                                          topLeft: Radius.circular(40.0))),
                                  child: Padding(
                                      padding: EdgeInsets.only(
                                          left: 30, right: 30, top: 15),
                                      child: ListView(
                                        children: [
                                          // TopBar(),
                                          PopupInput(textController,
                                              inputLabel: 'Project Title',
                                              errorMsg:
                                                  'Please enter your project title!'),
                                          customPadding(),
                                          PopupDropdown(
                                              initialProject:
                                                  widget.meetingToEdit.project,
                                              dropdownLabel: 'Module Project',
                                              callback: (val) => {
                                                    setState(() =>
                                                        selectedProject = val)
                                                  }),
                                          customPadding(),
                                          PersonInChargeChips(
                                              pics, "Person in Charge",
                                              project: selectedProject,
                                              callback: (val) {
                                            setState(() => pics = val);
                                          }),
                                          customPadding(),
                                          // constraints: BoxConstraints.expand(height: 200)),
                                          Text(
                                            'Meeting must be within...',
                                          ),
                                          Row(
                                              mainAxisSize: MainAxisSize.max,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
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
                                                  (val) => setState(() =>
                                                      startDateValue = val),
                                                  false,
                                                  isNotMini: false,
                                                  initialTime: widget
                                                      .meetingToEdit.startDate,
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
                                                (val) => setState(
                                                    () => endDateValue = val),
                                                false,
                                                isNotMini: false,
                                                initialTime: widget
                                                    .meetingToEdit.endDate,
                                              )),
                                            ],
                                          ),
                                          customPadding(),
                                          Text(
                                            'Meeting Venue',
                                          ),
                                          Row(
                                            children: [
                                              Text('Zoom'),
                                              Radio<MeetingVenue>(
                                                value: MeetingVenue.Zoom,
                                                groupValue: meetingVenue,
                                                onChanged:
                                                    (MeetingVenue value) {
                                                  setState(() {
                                                    meetingVenue = value;
                                                  });
                                                },
                                              ),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      right: 30)),
                                              Text('Face to Face'),
                                              Radio<MeetingVenue>(
                                                value: MeetingVenue.FaceToFace,
                                                groupValue: meetingVenue,
                                                onChanged:
                                                    (MeetingVenue value) {
                                                  setState(() {
                                                    meetingVenue = value;
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        ],
                                      ))))),
                      Container(
                        color: Colors.white,
                        alignment: Alignment.bottomCenter,
                        child: Padding(
                            padding: EdgeInsets.only(
                                bottom: MediaQuery.of(context).padding.bottom),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                ElevatedButton(
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all<Color>(
                                                appTheme.primaryColorLight)),
                                    child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10),
                                        child: Text("Done",
                                            style: appTheme.textTheme.bodyText2
                                                .apply(color: Colors.white))),
                                    onPressed: () {
                                      widget.meetingBloc.add(UpdateMeeting(
                                          widget.meetingToEdit.copyWith(
                                            title: textController.text,
                                            groupmates: pics,
                                            meetingVenue: meetingVenue,
                                            project: selectedProject,
                                            startDate: startDateValue,
                                            endDate: endDateValue,
                                          ),
                                          userId));
                                      Navigator.pop(context);
                                    })
                              ],
                            )),
                      )
                    ])))));
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 40));
