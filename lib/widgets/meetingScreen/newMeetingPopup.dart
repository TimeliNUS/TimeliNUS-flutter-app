import 'dart:ui';

import 'package:TimeliNUS/blocs/app/appBloc.dart';
import 'package:TimeliNUS/blocs/screens/meeting/meetingBloc.dart';
import 'package:TimeliNUS/blocs/screens/project/projectBloc.dart';
import 'package:TimeliNUS/models/models.dart';
import 'package:TimeliNUS/widgets/overlayPopup.dart';
import 'package:TimeliNUS/widgets/style.dart';
import 'package:TimeliNUS/widgets/topBar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class NewMeetingPopup extends StatefulWidget {
  final MeetingBloc projectBloc;
  const NewMeetingPopup(this.projectBloc);
  @override
  State<NewMeetingPopup> createState() => _NewMeetingPopupState();
}

class _NewMeetingPopupState extends State<NewMeetingPopup> {
  DateTime deadlineValue;
  MeetingVenue meetingVenue = MeetingVenue.Zoom;
  final TextEditingController textController = new TextEditingController();
  @override
  Widget build(BuildContext context) {
    // final projectBloc =
    //     ProjectBloc(projectRepository: context.read<ProjectRepository>());
    return BlocProvider<MeetingBloc>(
        create: (context) => widget.projectBloc,
        child: ColoredSafeArea(
            appTheme.primaryColorLight,
            Scaffold(
                body: Container(
                    color: appTheme.primaryColorLight,
                    child: Column(children: [
                      TopBar(() => Navigator.pop(context), "Create Meeting"),
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
                                            dropdownLabel: 'Module Code',
                                          ),
                                          customPadding(),
                                          PersonInChargeChips([
                                            context.select((AppBloc bloc) =>
                                                    bloc.state.user.name) ??
                                                "Myself"
                                          ], "Groupmates"),
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
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom: 9, right: 10),
                                                  child: Text(
                                                    'From',
                                                  )),
                                              Expanded(
                                                  child: DeadlineInput(
                                                (val) => setState(
                                                    () => deadlineValue = val),
                                                false,
                                                isNotMini: false,
                                              )),
                                              Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 9,
                                                      horizontal: 10),
                                                  child: Text(
                                                    'to',
                                                  )),
                                              Expanded(
                                                  child: DeadlineInput(
                                                (val) => setState(
                                                    () => deadlineValue = val),
                                                false,
                                                isNotMini: false,
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
                                      // widget.projectBloc.add(AddProject(
                                      //     Project(
                                      //       textController.text,
                                      //       deadline: deadlineValue,
                                      //     ),
                                      //     context
                                      //         .read<AppBloc>()
                                      //         .getCurrentUser()
                                      //         .id));
                                      // Navigator.pop(context);
                                    })
                              ],
                            )),
                      )
                    ])))));
  }
}

Widget customPadding() => Padding(padding: EdgeInsets.only(bottom: 40));
